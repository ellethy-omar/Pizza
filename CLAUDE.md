# Pizza language compiler (CMPN403, Lex/Yacc)

## Layout

- `CMPN403 - Project Document.pdf` — official assignment (source of truth).
- `Phase1-Work-Division.md` — team roles M1-M4, frozen token contract (§4.2), grammar traps.
- `PHASE1-TOKEN-PROPOSAL.md` — pizza spelling → contract token name for every token.
- `M1-LEXER-PLAN.md` — M1 requirements analysis, lexer architecture, roadmap, tooling, tests.
- `lexer.l` — flex lexer (M1). Only place pizza spellings live.
- `parser.y` — Section 0 = M1 token contract (`%token`, `%union`, `%locations`); below it a placeholder grammar that M2-1 replaces.
- `main.c` — driver: `pizza file.pz` parses, `pizza --tokens file.pz` dumps tokens. Exit 0 ok / 1 errors / 2 usage.
- `Makefile` — `all`, `test`, `clean`; order bison → flex → gcc.
- `tests/run_tests.sh` — `tests/lexer/NAME.pz` vs `NAME.tokens` golden dumps (`err_*` must exit 1); `tests/valid` must exit 0; `tests/invalid` must exit 1.
- `menus/` — real menu images (vocabulary inspiration only).

## Conventions

- Token names are frozen by the contract; only lexeme spellings are pizza words. Renaming a keyword = edit its string in `lexer.l` + regenerate the affected `.tokens` files.
- Semantic values never carry spellings (`BOOL_LIT` = 1/0).
- Build in WSL/Linux (`flex`, `bison`, `gcc`, `make`). `.gitattributes` forces LF except `tests/lexer/crlf.pz`.
