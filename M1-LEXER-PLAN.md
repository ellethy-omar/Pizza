# M1: Lexical Analysis — Requirements, Architecture and Plan

Companion to `PHASE1-TOKEN-PROPOSAL.md`. Planning only: no `.l`, `.y` or `.c` files exist yet, and none should be written until the token proposal is approved.

Sources: **[Doc]** = `CMPN403 - Project Document.pdf` (3 pages, fully read). **[Contract]** = `Phase1-Work-Division.md` (fully read).

---

## 1. Requirements analysis

### 1.1 Whole project [Doc]

| Area | Requirement |
|---|---|
| Goal | Design and implement a programming language using Lex and Yacc. Groups of 3-4. |
| Language constructs | Variable and constant declarations; mathematical and logical expressions; assignment; if-then-else, while, repeat-until, for, switch; block structure (nested scopes, declarations at the beginning of blocks); functions. |
| Classes and objects | Class declarations with a name; data members; methods; object declaration and instantiation; accessing/modifying attributes with the **dot (.)** operator; calling methods through objects; constructors **[optional]**. |
| Symbol table | Extensible format for variables, constants, functions, classes, attributes, methods, objects, with scope information. |
| Lexer | "Implement the lexical analyzer using Lex." |
| Parser | YACC, with action rules producing **quadruples**. |
| Errors | A proper syntax error handler. |
| Semantic checks | Redeclaration; type misuse; use before initialization and unused variables; duplicate classes in a scope; undeclared classes/objects; undeclared attributes/methods; type compatibility on attribute assignment; argument count/type on method calls; **[optional]** type-conversion quadruples. |
| GUI | **[optional]** |
| Program behaviour | Read a source file; output quadruples, syntax errors, semantic errors and the symbol table. |
| Report | Overview; tools used; **list of tokens with descriptions**; list of quadruples; class/object syntax description; **list of class-related tokens** and class quadruples. |
| Evaluation | Correct quadruples; syntax and semantic error handling; teamwork and documentation; correct classes/objects; class-related semantic errors. Optional items and extra semantic checks are bonus. |
| Dates | Phase I: week 11. Phase II: week 14. |

### 1.2 Phase I specifically

[Doc]: "deliver your lex and yacc files, i.e. your lexer and parser." Everything else (symbol table, quadruples, full error handler, semantic analysis) is Phase II.

[Contract §1] adds: accept valid programs and report the **first** syntax error with its line; constructors as bonus; a test suite and document drafts (not required by [Doc], included to prove the parser works).

[Doc] gives **no separate evaluation criteria for Phase I**. The listed criteria are for the finished project.

### 1.3 Expected architecture

```
source.pz ──► lexer (lexer.l → flex → lex.yy.c) ──tokens──► parser (parser.y → bison → parser.tab.c)
                                                              │
                                     Phase II: symbol table, semantic checks, quadruples
main.c: opens argv[1], runs yyparse() (or the token dump), sets the exit code
```

The parser **pulls** tokens: `yyparse()` calls `yylex()` each time it needs the next token. The lexer never runs ahead.

### 1.4 Tools

| Required by [Doc] | Chosen by [Contract] | Comment |
|---|---|---|
| Lex | `flex` | Flex is the standard free implementation of Lex and accepts Lex syntax. |
| Yacc | `bison -d` | Bison is the GNU implementation of Yacc. |
| (C compiler implied) | `gcc` | Both tools generate C. |
| — | `make` (`all`, `test`, `clean`) | M1-1. |

### 1.5 Restrictions found

- Only optional items earn bonus; nothing in [Doc] forbids extra features, but extras cost grammar work.
- [Contract §4]: the shared contract is frozen; any change must be told to all four members.
- [Contract §4.4]: `bison` must report **0 conflicts**; never `%expect`.
- [Contract §6 trap 4]: semantic misuse (`break` outside a loop, `this` outside a class, assigning a constant) must be **accepted** in Phase I.

---

## 2. Contradictions, gaps and ambiguities between the documents

| # | Issue | Type | Resolution proposed |
|---|---|---|---|
| C1 | [Doc] says "Lex" and "YACC"; [Contract] uses `flex` and `bison`. | Naming, not a real conflict | Standard practice. Write "Flex (Lex) and Bison (Yacc)" in the report. Ask the TA only if they require AT&T lex specifically. |
| C2 | [Contract §4.1] freezes conventional spellings (`int`, `new Point(...)`) while the team wants pizza spellings. | **Real, procedural** | Token names stay frozen; only lexemes change. That is still a change to §4.1's text, so the approved proposal must be announced to all four members and §4.1 updated. |
| C3 | [Contract M1-4] says "`strdup` text into `yylval`" for literals; M1-2 (also M1) designs `%union`. Text-only values vs numeric values is not settled. | Ambiguity | Decision D7 (§5.7 below). |
| C4 | [Contract M1-2] puts M1's `%token`/`%union`/`%locations` header inside `parser.y`, a file whose merge owner is M2 (M2-9). | Ownership overlap | M1 owns the declarations header; M2 owns everything below it. State this in the PR. |
| C5 | Phase I reports only the **first** syntax error, and the parser pulls tokens lazily, so lexical errors **after** that point are never seen in parse mode. | Behaviour to know | Expected, not a bug. `--tokens` mode scans the whole file and shows all lexical errors. |
| C6 | Neither document requires input/output. | Gap | Optional; proposal D3 (built-in `deliver(x)` needs no contract change). |
| C7 | [Doc] report requires "class-related tokens **and the quadruples** generated for class operations". | Phase split | M1-9 writes the token half now; quadruples come in Phase II. |

No document is missing or unreadable. Some PDF bullet glyphs extract as garbled symbols; the text itself is complete (3 pages).

---

## 3. M1 responsibilities and boundaries

### 3.1 M1 owns [Contract §2, §5]

| Step | Output | Pts |
|---|---|---|
| M1-1 | Repo layout, `Makefile` (`all`, `test`, `clean`) | 2 |
| M1-2 | `%token`, `%union`, `%locations` at top of `parser.y` — **blocks M2; push first (Day 1)** | 2 |
| M1-3 | Keyword, identifier and operator rules | 3 |
| M1-4 | Literal rules (int, float, bool, char, string + escapes) | 3 |
| M1-5 | Whitespace, comments, line/column tracking | 2 |
| M1-6 | Lexical errors with line | 2 |
| M1-7 | `main.c` with `--tokens` mode | 2 |
| M1-8 | `make test` runner (valid must pass, invalid must fail) + lexer tests | 2 |
| M1-9 | Token list with descriptions (report), tools used | 2 |
| M1-10 | Clean-clone build on a second machine; package submission | 2 |

### 3.2 M1 does **not** own

- Any grammar rule in `parser.y` (M2, M3, M4).
- `yyerror` and syntax-error messages (M2-6).
- Deciding whether `-` is unary or binary, whether `IDENT` is a class or variable, whether a literal fits a type (parser / Phase II).
- Symbol table, scopes, types, quadruples (Phase II).

### 3.3 Dependencies

| Direction | What | Hard/soft |
|---|---|---|
| M2 waits on M1 | Token names (M1-2) | **Hard** — the critical path |
| M2, M3, M4 wait on M1 | Working lexer to run test programs | Soft |
| M1-7 waits on M2-1 | Linking `main.c` needs a real `yyparse` | Soft (see §6 step 3 for working around it) |
| M1-8 final run waits on M2, M3, M4 | Their test files | Final only |

---

## 4. Lexer–parser interface (the contract M1 writes in M1-2)

| Element | Who defines | Who uses | Meaning |
|---|---|---|---|
| `int yylex(void)` | flex (from `lexer.l`) | `yyparse` | Returns the next token code; `0` = end of input. |
| Token codes (`KW_IF`, `IDENT`, ...) | `%token` in `parser.y`; `bison -d` writes them to `parser.tab.h` | `lexer.l` `#include "parser.tab.h"` | Single-character tokens use their ASCII code (`'+'`), so they need no `%token`. |
| `YYSTYPE yylval` | `%union` in `parser.y` | Lexer writes, parser reads `$1` | Semantic value of the current token. |
| `YYLTYPE yylloc` | `%locations` in `parser.y` | Lexer writes, parser reads `@1` | `first_line, first_column, last_line, last_column`. |
| `FILE *yyin` | flex | `main.c` sets it to `fopen(argv[1])` | Input stream. |
| `void yyerror(const char *)` | M2 | Bison | Not used by the lexer for lexical errors (see §5.11). |
| `int lex_error_count` | M1 (in `lexer.l`) | `main.c` | Non-zero means exit code 1. |

Because `parser.tab.h` is generated, the build order is fixed: **bison first, then flex, then gcc**.

---

## 5. Lexical analyzer architecture

### 5.1 What lexical analysis is (and is not)

The lexer converts a character stream into a token stream. It groups characters into lexemes, classifies each (keyword, identifier, literal, operator), attaches a value and a location, and discards whitespace and comments. It uses **regular** languages only: it cannot count brackets, know what a name means, or check types. Anything needing nesting or context is the parser's job; anything needing meaning is Phase II.

### 5.2 Structure of a flex file

```
%{  C prologue: #includes (parser.tab.h), globals, helper prototypes  %}
%option noyywrap nounput noinput 8bit
%x COMMENT                         ← exclusive start condition for /* */
DIGIT   [0-9]                      ← named definitions
%%
rules:  pattern   { action; return TOKEN; }
%%
C epilogue: helper functions (location update, escape check, error printer)
```

- `noyywrap`: single input file; avoids linking `-lfl` (which is often missing on Windows).
- `nounput noinput`: removes unused-function warnings under `gcc -Wall`.
- `8bit`: so non-ASCII bytes can be matched and reported (E2).

### 5.3 Regular expressions

Each token class is one regular expression (see the Lexical Pattern columns of the proposal). Flex compiles all rules into a single DFA, so the number of keywords does not slow the lexer down.

### 5.4 Rule order (in `lexer.l`)

1. Comments (`"//".*`, `"/*"` entering `COMMENT`) — before `/`.
2. Whitespace and newlines.
3. **Keywords** (each a literal string) and boolean literals `hot`/`cold`.
4. Malformed numbers (`[0-9]+[A-Za-z_]...`) and float, then int literals.
5. `IDENT`.
6. String and char literals, then their unterminated/invalid forms.
7. Multi-character operators (`== != <= >= && ||`).
8. Single-character tokens `[-+*/%<>!=(){};,:.]`.
9. Non-ASCII run, then the catch-all `.` (illegal character) — **always last**.

### 5.5 Longest match

At each position flex tries every rule and keeps the **longest** match; on a tie, the **earliest** rule wins. Consequences: `<=` beats `<`; `slices` is an identifier although `slice` is a keyword; `"/*"` beats `/`. Order in §5.4 only matters for **ties**, which is why keywords must precede `IDENT` and the catch-all must be last. Full table: proposal §9.

### 5.6 Keywords vs identifiers

Two standard options:

| Option | How | Verdict |
|---|---|---|
| One rule per keyword before `IDENT` | `"taste" { return KW_IF; }` | **Recommended**: simplest, the DFA does the work, spellings are visible at a glance. |
| Lookup table | `IDENT` rule looks `yytext` up in a keyword table | Useful with hundreds of keywords; unnecessary for ~25. |

### 5.7 Token attributes and semantic values (decision D7)

Proposed `%union` (to agree with M2 at kickoff):

| Member | Tokens | Value |
|---|---|---|
| `char *sval` | `IDENT`, `STRING_LIT` | `strdup` of the name; string text without quotes (escapes kept, validated) |
| `long long ival` | `INT_LIT`, `BOOL_LIT`, `CHAR_LIT` (and `KW_INT` width if D2 = B) | numeric value (`strtoll`), 1/0, character code |
| `double fval` | `FLOAT_LIT` | `strtod` value |

Why numeric rather than "text for everything" ([Contract M1-4] wording): range errors (E10) are detected once, in the lexer; Phase II gets real numbers for constant folding and type checks. If the team prefers text (simpler quadruple printing), store `strdup(yytext)` in `sval` for literals too — the lexer change is one line per rule, but it must be decided **before M1-2 is pushed** because M2 writes `%type`s against it.

Ownership of `strdup`'d memory passes to the parser (M2 may add a `%destructor`).

### 5.8 Literal recognition

- **Int / float:** patterns in proposal §4. Unsigned. `strtoll` with `errno == ERANGE` → E10.
- **String:** `\"([^"\\\n]|\\.)*\"` accepts any char except quote, backslash, newline, or a backslash pair. The action strips quotes and checks each `\x` against the escape table (E4). Unterminated form: `\"([^"\\\n]|\\.)*\\?` (same without closing quote; longest match picks the complete form whenever the closing quote exists) → E3.
- **Char:** a quoted run `\'([^'\\\n]|\\.)*\'`; the action checks there is exactly one character or escape (E6, E7). Unterminated → E5.
- **Bool:** `hot`/`cold` keywords returning `BOOL_LIT` with `ival` 1/0.

### 5.9 Comments and whitespace

Whitespace (`[ \t\r\f\v]+`, `\n`) is matched and dropped, after updating the location. `\r` is essential for Windows CRLF files. `//` comments use `"//".*`. Block comments use start condition `COMMENT`: on `/*` save the start line and `BEGIN(COMMENT)`; inside, consume `[^*\n]+`, `"*"`, `\n`; on `*/` `BEGIN(INITIAL)`; on `<COMMENT><<EOF>>` report E8 with the saved line. A start condition is preferred over one big regex because it gives the opening line for the error and avoids a huge single match.

### 5.10 Line and column tracking

`%locations` requires the lexer to fill `yylloc`. One helper updates it for **every** match, via flex's `YY_USER_ACTION` hook (runs before each action):

```c
#define YY_USER_ACTION update_location(yytext, yyleng);
/* sets yylloc.first_* to the current position, then walks the lexeme:
   '\n' → line++, column = 1; anything else → column++; sets yylloc.last_* */
```

- Lines and columns are 1-based. A tab counts as one column (decision; matches "characters from line start").
- Use this one mechanism only (not also `%option yylineno`) so there is a single source of truth.
- Multi-line comments update correctly because the helper walks every character.

### 5.11 Lexical error reporting

`lex_error(msg)` prints `Lexical error at line L, column C: msg` to `stderr`, increments `lex_error_count`, and the rule **does not return a token** (the bad input is skipped and scanning continues). The format mirrors M2's syntax-error message. Catalogue E1-E10: proposal §8.

Alternative considered: return Bison's `YYUNDEF` token so the parser reports "invalid token". Rejected for Phase I: it produces a syntax-error message for a lexical problem and stops at the first one.

### 5.12 Returning tokens to Bison

Each action sets `yylval` if the token has a value, then `return TOKEN;`. Single characters: `return yytext[0];`. End of input: flex returns `0` automatically at EOF in `INITIAL`.

### 5.13 Integration with the parser

1. M1-2: header in `parser.y` → `bison -d` produces `parser.tab.h`.
2. `lexer.l` includes it; token codes now agree by construction.
3. `main.c`: `yyin = fopen(argv[1])`; `--tokens` loops `yylex()` and prints; otherwise `r = yyparse()`; exit `r != 0 || lex_error_count > 0`.
4. Build: `bison -d parser.y && flex lexer.l && gcc -Wall -o pizza parser.tab.c lex.yy.c main.c`.

---

## 6. Implementation roadmap (after approval)

| Order | Step | Done when |
|---|---|---|
| 0 | Kickoff: approve the proposal; settle D1-D12; update [Contract §4.1] spellings | All four agree |
| 1 | **M1-2** (first!): `%token` list with exact contract names, `%union` (D7), `%locations`; push | M2 can start; `bison` accepts the header |
| 2 | M1-1: folder layout, `Makefile` with bison → flex → gcc order | `make` reaches the compile step |
| 3 | `main.c` `--tokens` mode with a `token_name(int)` switch written by hand (do not rely on Bison's internal name table, which changed across versions). Until M2-1 exists, build `--tokens` against the header plus a one-line placeholder rule kept locally | Token dump runs on an empty file |
| 4 | M1-3: keywords, `IDENT`, operators, single chars | Dump of proposal §9 inputs matches the table |
| 5 | M1-4: literals and escapes | Literal tests pass |
| 6 | M1-5: whitespace, comments, `YY_USER_ACTION` locations | Lines/columns correct incl. CRLF and multi-line comments |
| 7 | M1-6: error rules E1-E10, error counter | Each invalid lexer test reports the right message and line |
| 8 | M1-7: full `main.c` once M2-1 lands | Parses the M4 demo |
| 9 | M1-8: `make test` | All `tests/valid` exit 0, all `tests/invalid` exit 1 |
| 10 | M1-9: report section (token tables can be lifted from the approved proposal) | Includes class-related tokens: `KW_CLASS KW_NEW KW_THIS '.' IDENT` |
| 11 | M1-10: clean clone on another machine | One `make` works |

---

## 7. Environment and tooling

### 7.1 What this machine has today (checked)

| Tool | Status |
|---|---|
| GNU Make | **4.4.1** installed (WinGet) |
| flex, bison, gcc | **Not installed** natively. `C:\msys64\ucrt64\bin` and `C:\MinGW\bin` are on `PATH` but those folders contain no compiler. |
| WSL | **Installed: Ubuntu, WSL 2** (currently stopped) |
| `git` | installed; repo initialized, no commits yet |

### 7.2 You need exactly one of each

Flex **or** Lex (flex), Bison **or** Yacc (bison), one C compiler (gcc), one make. Installing both Lex and Flex, or Yacc and Bison, is unnecessary.

### 7.3 Recommended: WSL Ubuntu (already installed)

```bash
sudo apt update
sudo apt install -y flex bison gcc make
```
Current Ubuntu LTS releases ship flex 2.6.4 and bison 3.8.2 (the latest upstream releases). `libfl-dev` is not needed with `%option noyywrap`.

Why WSL: identical tool names (`flex`, `bison`) to the `Makefile` [Contract M1-1]; same environment teammates likely use on Linux/macOS; no `unistd.h` or path-quoting surprises; `valgrind` available.

**Path warning:** this project lives in `D:\Documents\الكلية\Fall 2026\...`, which has non-ASCII characters and spaces. Spaces break unquoted paths in Makefiles, and non-ASCII paths are a known source of trouble for Windows-native toolchains. Recommended: keep the git repo at an ASCII, space-free path, for example `~/pizza` inside WSL (fastest) or `D:\dev\pizza`. Use relative paths in the `Makefile` regardless.

### 7.4 Windows-native alternatives

| Option | Install | Trade-offs |
|---|---|---|
| MSYS2 | Install MSYS2, then in its shell: `pacman -S flex bison make mingw-w64-ucrt-x86_64-gcc` | Real `flex`/`bison` names; must use the MSYS2 shell or fix `PATH` order (your `PATH` already expects `C:\msys64\ucrt64\bin`). |
| WinFlexBison | e.g. Chocolatey `choco install winflexbison3` (verify the package name with `choco search`) + a separate gcc | Executables are named `win_flex` / `win_bison`, so the `Makefile` needs `FLEX ?= flex` / `BISON ?= bison` variables. |

### 7.5 VS Code

| Extension | Purpose |
|---|---|
| WSL (`ms-vscode-remote.remote-wsl`) | Edit and run inside WSL |
| C/C++ (`ms-vscode.cpptools`) | C editing and gdb debugging |
| A Lex/Yacc syntax highlighter (search the marketplace for "Yash" or "Lex Flex Yacc Bison") | Highlighting for `.l` / `.y` |

Optional later: a small TextMate grammar for `.pz` files (bonus polish, not required).

### 7.6 Verification commands (run in the chosen shell)

```bash
flex --version      # expect: flex 2.6.x
bison --version     # expect: bison (GNU Bison) 3.x
gcc --version
make --version
# End-to-end smoke test, in a temp folder, not the project:
cd /tmp
cat > t.l <<'EOF'
%%
.|\n    ECHO;
%%
int yywrap(void) { return 1; }
int main(void) { yylex(); return 0; }
EOF
flex -o t.c t.l && gcc t.c -o t && echo "flex works" | ./t
# Bison smoke test:
printf '%%token X\n%%%%\ns: X;\n' > t.y && bison -d t.y && ls t.tab.c t.tab.h
```
The last line should print `flex works`.

### 7.7 Debugging aids

- `flex -d`: debug scanner that prints which rule matched each lexeme.
- `bison -v`: writes `parser.output` (states and conflicts; mainly M2/M3).
- `--tokens` mode: the main M1 tool (§8).

---

## 8. Testing and validation

### 8.1 Token-dump approach

`./pizza --tokens file.pz` prints one token per line and exits 1 if any lexical error occurred:

```
1:1   KW_INT      cheese
1:8   IDENT       count
1:14  '='         =
1:16  INT_LIT     8
1:17  ';'         ;
```

Lexer tests are pairs `tests/lexer/NAME.pz` + `tests/lexer/NAME.tokens` (expected output, errors included). `make test` runs the dump and `diff`s against the expected file. This tests the lexer **without the parser**: no grammar is involved in `--tokens` mode.

### 8.2 Test matrix

| Area | Valid inputs | Invalid inputs / edge cases |
|---|---|---|
| Every keyword | one file listing all keywords | `Serve`, `TASTE` → `IDENT` |
| Keyword vs identifier | `slice slices my myPizza hot hotness` | — |
| Identifiers | `a _x x9 camelCase Pascal` | `9lives` (E9), `جبنة` (E2), `$x` (E1) |
| Integers | `0 7 007 9223372036854775807` | `9223372036854775808` (E10) |
| Floats | `0.5 3.14 10.0` | `1.5abc` (E9); `.5` and `1.` (tokens `'.' INT_LIT`, `INT_LIT '.'`) |
| Strings | `"" "Margherita" "a\n\t\"\\"` | `"abc` (E3), `"a\qb"` (E4), string across two lines (E3) |
| Chars | `'a' '\n' '\''` | `''` (E6), `'ab'` (E7), `'a` (E5) |
| Comments | `//` at EOF without newline; `/* */` across lines; `/**/`; `/* ** */` | `/* never closed` (E8 with opening line) |
| Whitespace | tabs, CRLF line endings, blank lines | — |
| Consecutive operators | `a<=-b`, `a==-1`, `!!x`, `x===y`, `a//b` | `a&&&b` (E1 for `&`), `x+++y` |
| Locations | token after a multi-line comment has the right line | — |
| EOF | empty file → no tokens, exit 0; file without final newline | — |

### 8.3 Expected token sequences (samples)

| Input | Expected |
|---|---|
| `taste (x >= 10) { serve x; }` | `KW_IF '(' IDENT(x) GE INT_LIT(10) ')' '{' KW_RETURN IDENT(x) ';' '}'` |
| `Margherita m = bake Margherita(30, 8);` | `IDENT IDENT '=' KW_NEW IDENT '(' INT_LIT ',' INT_LIT ')' ';'` |
| `my.size = s;` | `KW_THIS '.' IDENT '=' IDENT ';'` |
| `oven ok = !cold \|\| hot;` | `KW_BOOL IDENT '=' '!' BOOL_LIT(0) OR BOOL_LIT(1) ';'` |
| `cheese x = 5; @` | `KW_INT IDENT '=' INT_LIT ';'` then `Lexical error at line 1, column 15: illegal character '@'`, exit 1 |

### 8.4 How you know the lexer is correct

1. Every row of proposal §1-§9 has at least one test.
2. Every error E1-E10 has a test with the exact expected message and location.
3. All M2/M3/M4 valid programs parse, and the invalid ones fail, once integrated (`make test`).
4. Clean-clone build on a second machine (M1-10).

---

## 9. Risks

| Risk | Impact | Mitigation |
|---|---|---|
| M1-2 pushed late | Blocks M2, then M3/M4 (critical path) | Settle D7 and the token list at kickoff; push Day 1 |
| Spellings changed after M2 starts | None for the grammar (names are stable) | Keep the "names frozen, spellings free" rule |
| New tokens added late (D2-B, D3-B, D4, D5) | Grammar changes for M2/M3/M4 | Decide at kickoff or defer to Phase II |
| CRLF files on Windows | Every line errors | `\r` in whitespace rule; test with a CRLF file |
| Non-ASCII/space path | Build failures | ASCII path for the repo (§7.3) |
| `%union` semantics disputed later | Rewrites in M2's actions | Decide D7 before pushing M1-2 |
