# regulations/

Regolamento AI aziendale GMI. Fonte canonica — non modificare le copie nei singoli repo.

## Cosa c'è

| File | Chi lo legge | Quando |
|---|---|---|
| `rules.md` | sessione AI | ogni sessione di codice |
| `process.md` | umani (Parte 1) + AI (Parte 2) | pianificazione / ogni task |
| `templates/spec.md` | umani | fase 1, prima di ogni feature |
| `templates/adr.md` | umani + AI | ogni decisione strutturale |
| `templates/pr.md` | AI | ogni PR |
| `templates/debt.md` | entrambi | vive nel repo, si aggiorna in corsa |
| `CLAUDE.template.md` | umani | una volta per repo, alla prima installazione |

`rules.md`, `process.md` e i template sono **identici per tutti i progetti**: niente esempi Flutter o React qui dentro.
Tutto ciò che è specifico del progetto sta nel suo `CLAUDE.md`.

## Installare in un repo

```bash
cd <repo>
git submodule add <url-regulations> regulations
cp regulations/CLAUDE.template.md CLAUDE.md   # poi riempi i <…>
cp regulations/templates/debt.md docs/debt.md # ledger vivo, uno per repo
ln -s CLAUDE.md AGENTS.md                     # se usi anche Codex
```

Aggiornare le regole ovunque:

```bash
cd regulations && git pull          # nel repo canonico: modifica e committa
cd <repo> && git submodule update --remote regulations && git commit -am "chore: update regulations"
```

## Regola sulle modifiche

Una regola si cambia qui, una volta, e si propaga. Se ti serve un'eccezione per un progetto, non forkare `rules.md`:
scrivila nel `CLAUDE.md` di quel repo sotto "Project conventions", con il motivo.
