# Principles — design, engineering & working attitude

Applies to every design and coding decision. Sections: §1–15 design & structure · §16–23 working attitude · §24–45 engineering fundamentals (DRY, decoupling, contracts, errors, testing, requirements, docs).
Complements `rules.md`. If a principle here conflicts with a rule there, **the rule wins** (YAGNI, boring tech, scope isolation).

Each principle: **the rule**, then *when it applies* and *what it costs*. A principle applied without checking its cost is a defect.

---

## 1. Reuse proven solutions, don't re-derive

- Before designing, ask: already solved in this codebase, the language, or a well-known pattern? Reuse it — but only if **problem + context** match. Same shape, different context → re-evaluate.
- State every design proposal (PR, ADR, option list) in four parts: **Name** (short handle) · **Problem** (when it applies, conditions) · **Solution** (elements, responsibilities, collaboration) · **Consequences** (trade-offs: time, space, flexibility, readability, what it makes harder).
- Never omit consequences: it's the most common way a design goes wrong.

## 2. Program to an interface; interfaces are the contract

- Clients depend on **what an object can do** (interface/type/contract), not **which class does it** → implementations swap without touching clients.
- Design the interface first. Keep it minimal: what *must* be requested, nothing more; decide explicitly **what must not be exposed**.
- Declare parameters, fields, return types with the narrowest abstract type that covers the use.
- One object, different powers for different clients → **distinct interfaces** (e.g. narrow read-only for everyone, privileged for the owner).
- Instantiate concrete classes in **few, known places** (composition root, factory, constructor injection), not in business logic.
- *Don't* create a single-implementation interface "for the future" (`rules.md` #7). Introduce it when a second implementation, a test double, or a platform boundary actually exists.

## 3. Favor composition over inheritance; delegate in standard shapes

- **Inheritance** = white-box reuse: subclass depends on parent internals, fixed at compile time, parent changes break subclasses. **Composition** = black-box reuse through interfaces, swappable at run time, small focused classes.
- Default **has-a** (hold a reference, delegate) over **is-a**. E.g. a `Window` *has* a shape, it is not a `Rectangle`.
- Inherit only when the subclass is a true subtype (usable everywhere the parent is, no surprises) **and** the parent is abstract with little or no implementation.
- Never mix silently: **interface inheritance** (subtyping, good) vs **implementation inheritance** (sharing code, suspect → extract a collaborator).
- A subclass may add or override operations; never hide or disable a parent operation.
- Delegation (forward to a collaborator, optionally passing self) makes composition as expressive as inheritance. Use it only in **standard, recognizable shapes** (strategy, state, decorator, …); ad-hoc delegation chains are forbidden.
- Cost: more objects, behavior spread across relationships, dynamic code harder to follow than static (human cost > runtime cost). Accept only when it simplifies more than it complicates.

## 4. Encapsulate what varies

- Put the aspect most likely to change behind its own object/interface. Ask: *what do I want to change without redesign?* Isolate only that.

| Cause of redesign | Remedy |
|---|---|
| Naming a concrete class everywhere at creation | Create indirectly: factory, injected constructor, registry |
| Hard-coding which operation handles a request | Request as object (command) or chain of handlers |
| Direct dependency on platform / OS / vendor API | App-owned adapter/abstraction (§13) |
| Clients knowing storage, location, representation | Hide behind an interface; expose behavior, not layout |
| Algorithms likely to be tuned or replaced | Strategy or template method (§10) |
| Tight coupling between classes | Depend on abstractions, mediator/facade, publish/subscribe |
| Extending behavior by piling up subclasses | Decorator, strategy, small collaborators |
| Class you cannot (or should not) modify | Wrap it: adapter, decorator |

- Isolate only variation that is **real or explicitly required**. Speculative flexibility is debt.

## 5. Finding the right objects

- Don't model only the real world (that reflects today's requirements). Useful objects often have no physical counterpart: an **algorithm**, a **state**, a **request**, a **group treated as one**. Promote them when they need to vary, be stored, queued, undone or swapped.
- Choose granularity by responsibility, not size: whole subsystem → one simplified entry point (facade); huge numbers of tiny objects → share intrinsic state (flyweight), only if memory is measured to matter. Objects whose sole job is creating or operating on others are legitimate.

## 6. Ownership vs. acquaintance

- Same syntax, different intent — make it explicit (naming, docs, lifetimes):
  - **Ownership** — A owns B, lifetimes bound. Few, permanent.
  - **Acquaintance** — A knows B, requests operations, not responsible. Many, transient, looser.
- Prefer acquaintance; own only when the lifetime really is shared.
- Code structure ≠ run-time structure. Document the run-time relationships that matter (who notifies, owns, forwards to whom).

## 7. Uniform treatment of parts and wholes

- Hierarchical data (documents, UI trees, menus, file systems, org charts) → **recursive composition** through a common interface. Clients don't distinguish element from group (`draw()`, `size()` work on both).
- Treat heterogeneous leaves uniformly (text and graphics); making one a special case of the other duplicates every mechanism.
- Leaf-specific operations (spell-check text, not shapes) → a separate operation mechanism (§15), don't pollute the common interface.
- Decide explicitly: children reference parent? who owns/deletes children? child-management ops on the leaf interface (uniformity) or not (safety)? Don't store child collections in the common base type.
- Cost: many small objects; if prohibitive, share immutable parts (§5).

## 8. Application vs. library vs. framework

| Kind | Who calls whom | Priority |
|---|---|---|
| **Application** | You write main, call libraries | Internal reuse, maintainability. Don't build more than needed. |
| **Library / toolkit** | You're the callee for unknown apps | No assumptions/dependencies that limit where it's used. |
| **Framework** | Inversion of control: it calls your code | Architecture stability; interface changes ripple to every app → loose coupling mandatory. |

- Know which one you're writing. Most project code is **application**: optimize for simplicity, not generality.
- Using a framework: follow its conventions (names, hooks, lifecycle). Fighting it costs more than the freedom it takes.

## 9. Patterns: when and how

- Patterns add indirection (readability, sometimes performance). Apply one **only when the flexibility is needed now**; if the protected change is hypothetical, write direct code and refactor when the second case arrives.
- Red flags: interface with one implementation, factory for one type, strategy with one strategy, observer with one hard-wired listener, names that are only the pattern (`Manager`, `Handler`, `Factory` with no domain meaning).
- Calling something a pattern requires specific, articulable benefits and at least two real uses.
- How:
  1. Confirm applicability and consequences; understand participants and collaboration before coding.
  2. Name participants with **domain names carrying the role**: `PdfExportStrategy`, `OrderCreatedObserver`, `createInvoice()`. Keep conventions consistent (`create*` for every factory method).
  3. Integrate into existing classes; no parallel structure.
  4. Before and after: "what does this let me vary, and is that variation real here?" Can't name it → remove the pattern.

## 10. Separate structure from the algorithms that act on it

- Data representation and processing (layout, formatting, pricing, validation, analysis) change for different reasons: separate objects. New data type must not touch algorithms; new algorithm must not touch data types.
- Interchangeable algorithms are worth it only with **real trade-offs** between variants (speed vs quality, memory vs time) or run-time/user choice.
- Algorithm and context interfaces must be **general enough for the whole family**: a new variant never changes either. Too narrow blocks variants; too wide burdens simple ones. Decide data flow (context passes everything vs algorithm queries context).
- Name variants by what they do: `SimpleLineBreaker`, `OptimalLineBreaker`.
- Stateless algorithm + first-class functions → a plain function parameter is the lightest form.

## 11. Add responsibilities by wrapping, not subclassing

- Optional add-ons (borders, scrolling, caching, logging, retries, auth, metrics) via subclassing explode per combination (`BorderedScrollableX`). Forbidden.
- Use a **transparent wrapper**: holds exactly **one** component, same interface, forwards every call, extends it before/after (replace only if that's the explicit purpose). Clients can't tell plain from wrapped.
- Wrap order is meaningful (border outside scroller ≠ scroller outside border): make it explicit at the composition site.
- Grouping many elements is a container's job, not the wrapper's. The wrapped object stays unaware of its wrappers.
- Costs: wrapper hides the inner object's extra methods; wrapper and inner are different identities — never rely on identity/equality/type checks through wrappers.
- Keep the wrapper base lightweight. Heavy component type → change behavior from inside with a strategy (§10).

## 12. Creation: consistent families, no hard-coded graphs

- Never scatter `new ConcreteVariantX()` when the variant (platform, theme, tenant, provider, env) may differ: one missed call site = mixed variants at run time.
- Objects that must come from the **same family** → all from one creator for that family. Select the family **once**, early (startup/config/composition root).
- Selection by config string: `if/else` or map is fine. Registry only when variants must be added without editing the selector or can't all be linked/loaded on every platform.
- "Well-known single instance" ≠ global: pass it in or expose through one controlled accessor.
- A function building a whole object graph with explicit constructors forces rewriting/copy-paste when any component changes. Lightest remedy first: pass the creator in → pass prototypes to copy → pass a builder → overridable creation method (needs subclassing, least preferred).
- Goal is **flexibility of what gets created, not less code**. Nothing will vary → keep explicit constructors.
- Cost: a new *kind* of product changes the creator interface and every family. Fits when kinds are stable and families vary; otherwise constructor injection or a map of builders.

## 13. Isolate platform & vendor APIs; keep decisions reversible

- No decision is final (database, vendor, monolith/services, cloud/on-prem, platform version). Hard-coded parameters, poor encapsulation and coupling make them irreversible.
- Hide every third-party product behind a small app-owned interface. The DB is "persistence as a service", not SQL scattered everywhere. Deployment topology is wiring/config, not business logic.
- Incompatible vendor APIs: not the **intersection** (weak as the weakest vendor) nor the **union** (huge, breaks at every vendor change) — the features the app actually needs, in two independently evolving layers:
  - **App-facing abstraction** — caller's view, stable, small; holds and delegates to an implementation.
  - **Implementation interface** — what vendors really provide, "warts and all"; one per vendor. No subclass per (abstraction × vendor).
- New vendor = new implementation, zero changes to abstraction or callers. Vendor specifics (units, coordinates, error codes) live only there.
- Cost: both tend toward one-size-fits-all; review when a vendor needs something truly different. The §12 creator at the composition root picks the implementation; stateless ones can be shared.
- Anything added automatically (generated code, injected instrumentation) must be removable automatically.
- Don't build alternatives for every future (§9, `rules.md` #7): keep **seams** cheap.

## 14. Represent user actions as objects

- An operation reachable from several entry points (menu, button, shortcut, API, CLI, job) is a **request object** with one `execute`; entry points just call it. No subclass per (widget × action).
- Prefer an object over a bare callback when it needs parameters/state, undo, logging, queuing, or reuse of parts. Otherwise a plain function/closure is enough (cost: many trivial classes).
- Undo/redo:
  - Request stores what it needs to reverse itself. Store a **snapshot/copy** in history, not a mutable object.
  - No-op actions (decided at run time) and non-modifying actions (save, quit, read) never enter history.
  - History = list + "present" pointer. Undo = reverse current, move left; redo = execute next, move right; a new action discards everything right of present. No depth limit unless memory requires.
  - Group into a macro request to undo as a unit; multi-step changes → consider all-or-nothing.

## 15. Traversal: hide representation, separate the action

- A container's public interface must not favor one storage (index access that's O(n) on a linked list). Inside the class too, go through the accessor, not the raw field.
- Traversal lives in **iterators**: new orders without changing the container; each owns its state (concurrent traversals); leaves return an empty iterator, not "no children" special cases. Use the language's native protocol.
- Prefer **internal** iteration (simpler, safer); **external** only to interleave traversals or stop early.
- Define behavior on modification during iteration: fail fast, snapshot, or guaranteed robust. Never undefined.
- Don't pass "traversal kind" enums through the tree.
- Many operations (search, count, validate, export, spell-check) share one walk: keep walk and action separate. Don't bloat the type's core interface with every analysis (a default implementation reduces edits, not bloat).
- **Type switches / downcasts** over a hierarchy break silently on new types → polymorphic dispatch.
- Ask: **which changes more, types or operations?** Operations → visitor (`accept(visitor)`, one method per type). Types → methods on the types.
- Closed types with compiler-checked exhaustive `match` (sealed classes, tagged unions) are an acceptable visitor alternative; unchecked `if/else` type tests are not.
- Visitor costs: circular dependency with elements; each new element breaks every visitor → provide a default/catch-all visit.

---

# Working attitude

## 16. Own the outcome: options, not excuses

- Can't be done, late, broken → say so plainly, then **offer options** (what's salvageable, cost, prevention). Never blame a tool, vendor, or "the previous code" as the answer.
- Before reporting a blocker, rehearse "did you try X?" — and try X.
- Admit ignorance and mistakes immediately. A confident wrong answer is worse than "I don't know, here's how to find out".
- Refuse an outcome only with a stated reason (risk, impossible constraint); never silently deliver less.

## 17. Don't live with broken windows

- One neglected defect signals "nobody cares" and accelerates decay around it.
- **Inside your scope**: fix it (refactoring rules: §39). **Outside** (`rules.md` #11): don't fix silently, don't copy it; record in `debt.md` and mention in the PR.
- No time to fix properly → board it up: fail explicitly ("not implemented", guarded path), never silent wrong behavior.
- Match the codebase's conventions, not its defects.

## 18. Watch the big picture

- Systems drift one small change at a time until nothing matches the spec. Check each change against the spec and overall design, not only the local task; if accumulated changes diverge from intent, stop and flag it.

## 19. Good enough, then stop

- "Good enough" ≠ sloppy: meets the stated requirements, including quality ones — no more, no less.
- Quality level is a **requirement** decided with the user/owner, not the implementer; ask when unstated. Safety-critical and widely reused code have a higher bar.
- Extra layers, refactors, features beyond acceptance criteria = scope creep. Ship early, get feedback, iterate.

## 20. Evaluate sources, methods and tools critically

- Docs, posts, forum answers, vendor claims, AI snippets can be outdated, sponsored, or wrong: verify against the version in use (lockfile, official docs, source).
- Distrust "that's how it's always done" and "this tool solves everything"; ask for evidence or the trade-off. No dogma fits every project.
- No methodology, notation, diagram or framework replaces thinking; take the useful parts. Diagrams are interpretation — prefer something runnable.
- New tools/methods have an adoption cost (initial productivity drop); count it. Expensive tools don't make better designs.
- Know the whole system at least at: how components interact, where data lives, what the requirements are.
- Continuously refine working practices (this document included) based on what works.

## 21. Communicate for the reader

Applies to PR descriptions, ADRs, commit messages, status reports, answers.

- Know what you want to say: outline, then check it says that.
- Know the audience (what to learn, detail, technicality): reviewer ≠ manager.
- Match requested format and length; if it can't hold the content, say so instead of overflowing or truncating.
- Presentation matters: structure, headings, spelling.
- Close the loop: answer every question, even with "will follow up".

## 22. Meet expectations, then gently exceed them

- Success is measured against users' expectations, not only the spec. Surface early and continuously where they can't be met or are too conservative; tracer code and prototypes (§26) align them.
- Small touches (clear errors, sensible defaults, shortcuts, integrity checks, easy install) earn goodwill — only within scope (`rules.md` #11), without breaking or bloating. Propose them; don't slip them in.

## 23. Sign your work

- "I wrote this and I stand behind it": tested, documented, understandable.
- Ownership ≠ territory: respect others' code, don't defend yours against improvement.
- Every change has a clear author and reviewer (commit, PR, ADR).

---

# Engineering fundamentals

## 24. One source of truth for every piece of knowledge (DRY)

- Every fact (business rule, constant, schema, validation, config) has **one authoritative representation**. Two copies = a future contradiction.
- DRY is about **knowledge**, not text: identical lines encoding different rules aren't duplication; one rule expressed two ways is.
- Four sources — check each:
  - **Imposed** (client + server types, schema + models, docs + code) → derive one from the other with an **automated, repeatable** build step. One-shot conversions become duplicates immediately.
  - **Inadvertent** (design error: `Truck` and `Route` both store `driver`) → normalize to the domain model. Derived values (`length` from `start`/`end`) are **computed**, not stored.
  - **Impatient** (copy-paste-and-tweak, repeated literals) → forbidden; extract or name the constant.
  - **Inter-developer / inter-session** → **search the codebase** before writing a helper (`rules.md` #7).
- Caching a derived value is allowed only if **localized**: private, invalidated inside the owner, invisible to callers. Use accessors/properties (uniform access) so stored vs computed is invisible.
- Comments say **why**; code says how. A comment restating code is duplication that rots.
- Machine-readable spec → derive tests from it.
- **Code generators:**
  - **Active** (every build, from one source: schema, IDL, OpenAPI): output disposable, never hand-edited, ideally not committed or committed with `GENERATED — DO NOT EDIT`. Schema change → compile errors instead of production bugs.
  - **Passive** (scaffold, one-off conversion): output becomes normal source, owned and reviewed; fix by hand.
  - Keep input formats simple; generator mostly print/template statements. A new build generator is a structural decision (`rules.md` #4); prefer the ecosystem's standard one.

## 25. Orthogonality and loose coupling

- Orthogonal = changing one never requires changing the other (UI ↔ DB, logic ↔ transport, domain ↔ vendor SDK). DRY minimizes duplication; orthogonality minimizes interdependency.
- Each module: **one purpose** (cohesion), self-contained, minimal exposure.
- **Test:** "if the requirement behind this function changes dramatically, how many modules change?" Target **one**. Moving a button must not touch the DB schema.
- Don't depend on things you don't control (phone/email as primary key, vendor IDs as internal IDs, external field ordering).
- Libraries that force changes into your code (special base classes, creation paths, leaking remote-call exceptions) aren't orthogonal: keep them at the edges.
- Cross-cutting concerns (logging, auth, transactions, metrics) expressed once (declarative, middleware, decorators), not at every call site.
- **Shy code:** don't reveal or rely on internals; ask an object to change state, don't reach in.
- **No global mutable state**; pass context explicitly. Singletons used as globals are globals.
- Similar functions with shared start/end, different middle → extract the varying part.
- **Law of Demeter:** call only methods of self, parameters, objects you create, directly held components. No `selection.getRecorder().getLocation().getTimeZone()`; ask (`selection.getTimeZone()`) or be passed (`plot(date, timeZone)`). Fluent builders/pipelines on the same type are fine. Cost: forwarding methods; coupling for measured performance only if explicit and documented.
- Avoid cyclic dependencies between files/packages/modules: very expensive to undo.
- **Signals:** a unit test needing half the system → fix the design, not the test. A fix touching many unrelated files or breaking something else → coupling is the root cause; record in `debt.md`. Fear of changing code is a symptom.

## 26. Tracer code and prototypes

- **Tracer code:** for new systems/features with unknowns, first a **thin slice through every layer** (UI → API → logic → storage → back) doing one trivial thing for real, then widen. It's **production code** (errors, structure, tests, docs): incomplete, not sloppy, kept. Gives early integration, a skeleton, early feedback, honest progress (use case done/not done — no "95% complete" for weeks). Expect early misses; small code is cheap to re-aim. Each increment = one vertical slice (`rules.md` #3).
- **Prototype:** answers **specific questions** about anything risky, unproven or critical (architecture, external data formats, third-party components, performance, UI), then is **thrown away**. May skip correctness, completeness, robustness, style; the value is the lesson.
- Architecture prototype questions: responsibilities and collaborations defined? coupling minimal? duplication visible? interfaces acceptable? **every module has the data it needs when it needs it?**
- Prototypes **never** drift into production: mark them (separate branch/dir, `PROTOTYPE — DO NOT SHIP`). If that risk exists, use tracer code.
- Absolute performance → prototype in the target stack; relative comparisons → anything.
- Unexplained doubt before starting → small time-boxed prototype: doubt dissolves (start) or reveals a wrong premise (fix the plan).

| | Prototype | Tracer code |
|---|---|---|
| Purpose | Answer one question | Build the real skeleton |
| Scope | One aspect | All layers, thin |
| Quality | Throwaway | Production |
| Fate | Deleted | Extended |

## 27. Speak the domain's language

- Name modules, types, functions, variables with the **domain vocabulary** (users' and spec's words). Keep one **glossary**; code, docs and conversation use the same words. Same thing with two names, or two things with one name, is a defect.
- Errors speak the domain: `"AB123" is not a known format. Known: ABC123, XYZ43B`, not `undeclared identifier`.
- Declarative configuration beats imperative code for frequently changing rules.
- A DSL or embedded scripting is a **structural decision** (ADR, `rules.md` #4), justified by change frequency and number of users. Prefer extending an existing language/format (JSON/YAML schema, host-language API); if new, readable grammar over easy-to-parse.

## 28. Estimating

- First ask **what precision** and **what scope**; state assumptions ("assuming the API supports batch…").
- Units convey precision: 1–15 days → days; 3–8 weeks → weeks; 8–30 weeks → months; beyond → iterate before committing.
- Method: find prior art → rough model → components → parameters → focus on **multiplicative** parameters → a range, not a point → answer in terms of key parameters.
- A strange result usually means the **model** is wrong, not the arithmetic.
- Schedules refine per increment; confidence comes from finished increments. No off-the-cuff numbers: "I'll get back to you" beats a fast wrong one.
- Back-of-envelope estimates also tell which subsystem is worth optimizing.

## 29. Plain text, version control, no manual procedures

- Persist config, metadata, specs, fixtures, exchange formats as **human-readable, self-describing text** (JSON, YAML, TOML, CSV with headers, Markdown). Descriptive keys: `drawing_type=uml_activity`, not `Field19=467abe`. Outlives its program, works with diff/grep/VCS.
- Binary only when size/speed is measured to matter — metadata still in text. Obscurity isn't security: encrypt secrets, sign/hash for integrity (`rules.md` #6).
- Version **everything** that defines the system: code, docs, config, build/release scripts, migrations, infra, test data.
- Anything done more than once (build, test, lint, codegen, release, env setup, install, doc publishing, repeated click sequences) is a versioned script/target. Manual setup = "works on my machine".
- One command: clean checkout → built, tested, packaged artifact, including the unified check target (`rules.md` "Commands"). Any past tag rebuildable from the repo alone.
- CI runs the full build and **all** tests on every change.
- Release = tag, built by its own target (version stamp, release flags); if built differently from what was tested, re-test that build. Release-branch fixes merge back to trunk when relevant.
- Generated artifacts (docs, reports, coverage, metrics, status) come from the pipeline, never hand-maintained. Recurring admin steps (review requests, changelogs) driven by repo content where possible.

## 30. Debugging

- **Fix the problem, not the blame.** "That's impossible" is wrong — it happened; find the false assumption.
- **Root cause, not symptom**; the fault is often several steps from the failure.
- Compile with no warnings at the strictest level.
- Gather exact inputs, steps, environment, versions; reproduce what the user actually did, including unusual paths (boundaries, reverse order, empty input).
- **Reproduce with one command** — a failing automated test (`rules.md` #13).
- Techniques: inspect data (debugger, structured dumps); consistent parseable tracing for time-dependent issues; rubber-duck explanation; binary search in code, history (`git bisect`), input (shrink the case).
- **Suspect your own code first**; OS, compiler, framework, DB almost never. Even when a library is at fault, prove your code first.
- "I changed only one thing" → that thing did it, including dependency/runtime upgrades: retest after any upgrade.
- Don't assume — prove, with this data, context, boundaries.
- After the fix: add the test that would have caught it; add validation at the entry point if bad data travelled layers; grep and fix every other instance (`rules.md` "Bug fixing"); add missing diagnostics; document the wrong assumption.

## 31. Design by contract

- Code defensively against **your own** mistakes too.
- For every public routine, explicit: **preconditions** (caller's responsibility), **postconditions** (guaranteed on return; implies termination), **invariants** (always true between public calls; no unrestricted write access to invariant state). A violation on either side is a **bug**, never normal flow.
- **Preconditions ≠ input validation.** External input is validated at the boundary with error handling; contracts guard internal calls between trusted modules.
- Strict in what you accept, promise little.
- **Substitutability:** subtype accepts at least what the parent accepts, guarantees at least what it guarantees (widen inputs / strengthen outputs, never reverse). Same name, same meaning.
- Express via, in order: type system (non-null, enums, value objects that can't be invalid) → built-in contract/assert facilities → doc comments. Even written-only contracts force thinking about domain and what's *not* promised.
- **Loop invariants** for non-trivial loops (before, each iteration, exit): prevent off-by-one.
- **Semantic invariants:** the domain's inviolable laws in one sentence in the spec ("a transaction is never applied twice — on doubt, don't process"). They drive error recovery; don't confuse with changeable policies.
- Contract checks are side-effect-free.

## 32. Errors: crash early, exceptions for the exceptional

- "Impossible" happened → unknown state → **stop** near the fault. A dead program does less damage than a crippled one writing corrupt data.
- Never swallow errors. Check results of calls that "can't fail" (close, write, flush, parse).
- Every `switch`/`match` over a closed set has a loud-failing default (unless the compiler enforces exhaustiveness).
- "This can never happen" → assert it. Assertions check **bugs**, never user input/network/files; no side effects; no required logic inside (may be compiled out).
- **Keep assertions on in production**; disable only one measured too expensive.
- Crashing ≠ abrupt exit: release resources, roll back, log context — without relying on the data that triggered the failure.
- Test: "would it still work with every exception handler removed?" If not, exceptions are control flow (a non-local goto): forbidden.
- Expected outcomes (user file missing, lookup empty, validation fails) → return value / result / optional. Unexpected (required file gone, invariant broken, I/O failure mid-operation) → exception. Exceptions keep the happy path linear.
- Catch only where you can recover, retry, translate, or add context. Never catch-and-ignore or catch-all-log-continue.
- A dependency's error mechanism leaking into every caller → wrap it and translate at that boundary.

## 33. Finish what you start (resources)

- Whoever **acquires** a resource (file, connection, lock, transaction, temp file, subscription, timer, thread) **releases** it, in the same scope, visibly paired. Never open in one function and close in another via shared state.
- Always use the scoped-release construct (`with`, `using`, `try-with-resources`, `defer`, RAII, `finally`): every exit path, no duplicated cleanup.
- Release in **reverse** order; acquire the same set in the **same order** everywhere (deadlocks).
- Long-lived nested structures: decide who owns what when the parent dies (cascade, orphan, refuse), consistently.
- Long-running processes: check resource usage at a quiescent point (top of request loop); use leak detection in tests where available.

## 34. Configure, don't integrate

- Values/policies likely to change (thresholds, timeouts, limits, feature flags, payment terms, supplier categories, endpoints, algorithm choice) go in **configuration**; code implements the general case.
- Config is plain text, versioned (§29), validated at load, explicit defaults. Decide reload deliberately: live for long-running services, at startup for short-lived.
- Limits (`rules.md` "No black magic", #7): configure only what **actually varies** per environment/customer; a rules/workflow engine or embedded scripting is a structural decision (ADR); unreadable config is worse than code.

## 35. Decouple in time

- **Temporal coupling** = hidden order/timing dependency ("`init` before `use`", "one report at a time"): make explicit or remove.
- Objects are **valid whenever callable**: no construct-then-initialize; constructors/factories return ready objects.
- No hidden state between calls (tokenizer with static position): per-use state in a caller-owned object.
- Global/static mutable state is a concurrency bug (§25): remove it, don't lock it.
- Model what **really** must be sequential; don't serialize steps because they were described in order.
- Queues with multiple consumers decouple in time and load-balance naturally.
- Keep concurrency **possible** even if unused now.

## 36. Events, publish/subscribe, model and views

- Signal state changes with **events**: publisher doesn't know listeners; subscribers register only for changes they need. No giant central dispatcher `switch`.
- **Model** (data + rules) knows nothing about views. **Views** subscribe and update on notification; many per model; new views without model changes. Beyond UI: reports, exports, notifications, analytics are views. Views can be models for higher views (a network).
- **Input handling/controllers** are a replaceable strategy attached to a view: change reaction without changing look. Disabled view = no-op input handler.
- Many independent producers/consumers with no guaranteed order → a **blackboard/event store** with rules reacting to posted facts; adopting one is a structural decision (ADR).
- Events hide flow at read time (§6): document publishers and subscribers; add debug views/event tracing.
- Observer costs: unexpected update cascades; expensive frequent updates (send hints about *what* changed). Choose **push** (event carries data) vs **pull** (signal, subscriber queries) deliberately. Always unsubscribe on disposal (dangling references, leaks).

## 37. Don't program by coincidence

- Know **why** it works; code that works by accident breaks by accident.
- Rely only on documented behavior, not undocumented quirks, error side effects, or incidental call order; otherwise document and assert the assumption.
- After trial and error finally works, **remove the unneeded lines**.
- Don't silently assume GUI, locale, timezone, file system, network, user literacy: make them explicit.
- Prove implicit assumptions, especially in tests: passing for the wrong reason is worse than no test.
- Work from a plan; don't build what you don't understand; if unsure, assume the worst; document (§31) and test assumptions; do the hard parts first.

## 38. Know the cost of your algorithms

- Estimate time/memory growth per loop/recursion: O(n), nested O(n·m), halving O(log n), divide-and-conquer O(n log n), permutations O(n!) (intractable beyond tiny inputs).
- Ask **how large n can get**: small and bounded → fine; driven by external data → check 10× and 1000×.
- Watch hidden nested loops: list lookup in a loop, query per item (N+1), `contains` on an array inside iteration.
- Measure: growing inputs, profiler; only real data in the real environment counts.
- For small n simple is as fast and safer; beware setup costs; prefer the standard library.
- No premature optimization: prove the bottleneck first.

## 39. Refactoring

- Code is a garden, not a building: split, move, prune as understanding grows. Existing code isn't sacred.
- Triggers: duplication (§24), non-orthogonality (§25), outdated knowledge, oversized routine, performance.
- Later always costs more, but scope isolation (`rules.md` #11) applies: in scope → do it; out of scope → `debt.md` with who is affected, propose as its own task.
- How:
  1. **Never refactor and change behavior in the same step/commit.**
  2. Good tests **before**; run after every step.
  3. Small steps (move field, extract function, merge similar methods).
  4. Prefer tool-assisted refactorings (IDE/LSP).
  5. Incompatible interface change → old callers **fail to compile**, then fix every caller.
- Don't rewrite merely for personal style.

## 40. Design to test, test ruthlessly

- Design the contract (§31) and its test together, ideally test first. Test code alongside production code; more test than production code is normal. **Not done until all tests pass** (`rules.md` #2).
- Unit tests check the contract: valid ranges, **boundaries** (0, empty, max, off-by-one), rejected inputs, postconditions. Contracts in tests are abstract (what, not how).
- Bottom-up: verify subcomponents fully first, so failures localize.
- Tests live near the code, discoverable by convention, one command, run automatically and often (`rules.md` #2, #5); they double as usage examples. Use the ecosystem's standard framework, no custom harness.
- Beyond unit tests:
  - **Integration** — contracts between subsystems; largest bug source.
  - **Validation** — what users *need*, realistic access patterns.
  - **Resource exhaustion/recovery** — memory, disk, CPU, time, network, screen size; fail gracefully, no data loss.
  - **Performance/load** against stated targets, realistic volumes.
  - **Usability** with real users, early; a usability failure is a bug.
- Test data: **real-world** samples (reveal misunderstood requirements) and **synthetic** (volume, Feb 29, huge records, foreign formats, pre-sorted input, every third call failing).
- Business logic testable without UI; test UI separately.
- **Test the tests:** reintroduce the bug, confirm the test fails (mutation testing automates this).
- **Coverage ≠ state coverage**: 100% lines says nothing about `a / (a + b)` with `a + b == 0`. Target boundaries and state combinations.
- Slow tests (stress, soak, long integration) run on a schedule, never "when someone remembers".
- **Find bugs once:** every human-found bug and every ad-hoc debugging check becomes a permanent automated test (`rules.md` #13).
- Production observability: structured parseable logs; protected health/status endpoints or diagnostic views for long-running services.
- Everything gets tested — by you or by your users.

## 41. Never ship generated code you don't understand

- Output of wizards, scaffolding, templates, AI assistants becomes **your** code: read, understand, justify line by line. Remove what isn't needed (noise, attack surface).
- A library you don't fully understand is fine (behind an interface); generated source you don't understand is not. Can't explain it → don't commit it.

## 42. Requirements: dig, don't gather

- Ask **why**, not only how; record the reason next to the requirement.
- **Requirement ≠ policy:** "only authorized users may view an employee record" vs "only supervisors and HR". Implement the mechanism; policy goes in config/data (§34).
- **Requirement ≠ UI:** "user chooses a loan term" vs "a dropdown" — UI is a requirement only if users truly need that form.
- Don't overspecify: need, not architecture/design/UI. Abstract but precise; capture semantic invariants (§31).
- Model the concept (`Date`, `Money`, `Address` with services), not today's representation (two-digit year, float amount, one-line address).
- Use cases: goal, actors, preconditions, success/failure end conditions, main scenario, extensions/error paths, variations, frequency, performance target, open issues.
- **Track scope:** every new feature — who asked, who approved, schedule impact. Surface "just one more feature", don't absorb it.
- Domain terms: one glossary (§27).

## 43. Hard problems: find the real constraints

- Seemingly impossible → ask: easier way? right problem or a peripheral technicality? why hard? must it be done this way, or at all?
- List **all** approaches, even absurd; state and verify why each is rejected. Many "constraints" are assumptions.
- Separate absolute constraints (honor even if silly) from preconceived ones; handle the most restrictive first.
- A reinterpretation often dissolves the problem — confirm with the owner first.

## 44. Specs: enough to start, not a substitute for building

- A spec removes major ambiguities and records agreement; some things are better shown (prototype, example, test).
- Past a point, more detail has negative returns and blocks discoveries; no specs on specs without implementation.
- Spec, implementation, tests are one loop: when implementation reveals a better option or contradiction, **update the spec** (`rules.md` #1, #9) — don't silently diverge or comply with something broken.
- Detailed specs for safety-critical behavior and interfaces/libraries others call.

## 45. Documentation is part of the code

- Built in, not bolted on; same principles as code (DRY, orthogonality, plain text, automation). Code and docs disagree → fix docs in the same change (`rules.md` #9).
- **Comments say why**: purpose, trade-offs, rejected alternatives, non-obvious behavior, constraints. Brief header for modules and public types/functions (params/returns only when not obvious).
- Not in comments: function lists, revision history, file lists/names — tooling knows.
- **Names:** descriptive, spelled out (`connection_pool`, not `cp`); no `foo`, `doIt`, `manager`, `stuff`, `data2`; no type prefixes. A **misleading name is worse than a meaningless one** (`getData` that writes to disk): rename.
- **Executable documents:** one authoritative source (spec, schema, API definition) generates the other views (DDL, types, API docs) (§24).
- Content separate from presentation: Markdown rendered as needed, not copy-pasted variants.
- Published docs carry a version or date.
