# Pizza Language: Phase I Token Proposal (DRAFT, not approved)

> **Status of this document:** proposal for team review. Nothing here is final until the team approves it.
> Edit any cell directly. When a row is agreed, change its Status to `Approved`.
> Sources: `CMPN403 - Project Document.pdf` (cited as **[Doc]**) and `Phase1-Work-Division.md` (cited as **[Contract]**, meaning its §4 "shared contract").

---

## 0. How to read this file

### Status values

| Status                        | Meaning                                                                                                                                                                                             |
| ----------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Required by Specification** | [Doc] mandates the concept. "(implied)" in the Explanation means the doc requires it indirectly (for example, type checks require types to exist). Only the pizza **spelling** is open for editing. |
| **Proposed**                  | Not mandated by [Doc], but already part of the frozen [Contract], or a recommended addition that changes nothing outside the lexer.                                                                 |
| **Needs Discussion**          | Would change the frozen [Contract] (new token or grammar rule, so all four members must agree), or the spelling is contested.                                                                       |

### The one design rule that makes this safe

**Token names stay exactly as frozen in [Contract] §4.2. Only the source spellings (lexemes) become pizza words.**

The parser (M2, M3, M4) only ever sees token names such as `KW_IF` or `IDENT`. Whether the source says `if` or `taste` is invisible to `parser.y`. So:

- Any spelling change in this file touches **only `lexer.l`** and needs no grammar change.
- Any row marked _Needs Discussion_ that adds a **new token** touches `parser.y` and must be announced to all four members ([Contract] §4: "Changing anything here requires telling all four members").

### Global lexical conventions (proposed)

| Topic                            | Proposal                                                                         | Reason                                                                                                                                   |
| -------------------------------- | -------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| Case sensitivity                 | Case-sensitive. Keywords are lowercase or camelCase (`secretSauce`, `houseSpecial`). `Voila` and `secretsauce` are identifiers.   | Flex default; matches C/Java, which the team already knows.                                                                              |
| Reserved or contextual           | All keywords **reserved** (can never be identifiers).                            | Contextual keywords need parser feedback to the lexer and invite LALR conflicts. Not worth it.                                           |
| Identifier kinds                 | One generic `IDENT` token for variables, functions, classes, methods, objects.   | The lexer cannot know what a name refers to; that is the symbol table's job (Phase II). [Contract] already uses `IDENT` for class types. |
| Operators                        | Keep conventional symbols (`+ - * / % == && ...`). No pizza words for operators. | Precedence is learned from symbols; word operators hurt readability of "mathematical and logical expressions" [Doc].                     |
| Comments                         | Keep `//` and `/* */` [Contract M1-5].                                           | Already agreed; pizza comments add nothing.                                                                                              |
| Naming convention (not enforced) | `camelCase` variables/functions, `PascalCase` classes (`Margherita`).            | Readability only; the lexer does not enforce it.                                                                                         |
| Source file extension            | `.pz`                                                                            | Short, unused by common tools. Needs team OK.                                                                                            |

---

## 1. Reserved words

Every keyword pattern is a quoted literal string and **must appear before the `IDENT` rule** in `lexer.l` (see §9).

### 1.1 Primitive types

| Programming Concept        | Proposed Pizza Keyword | Alternative Suggestions    | Token Name  | Example Usage                | Lexical Pattern | Explanation                                                                                                                                                                | Status                    |
| -------------------------- | ---------------------- | -------------------------- | ----------- | ---------------------------- | --------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------- |
| Integer type               | `mozzarella`           | `cheese`, `slices`, `whole` | `KW_INT`    | `mozzarella count = 8;`      | `"mozzarella"`  | Whole-number type. No sized variants (former §2 removed: D2 = plain int). Source: [Doc] type checks and "integer to real" conversion (implied); [Contract] `int`. | Required by Specification |
| Real (floating-point) type | `ranch`                | `sauce`, `oil`, `grams`     | `KW_FLOAT`  | `ranch weight = 2.5;`        | `"ranch"`       | Ranch is poured and measured, so it is fractional. Source: [Doc] "converting integer to real" (implied); [Contract] `float`.                                               | Required by Specification |
| Boolean type               | `oven`                 | `topped`, `bool`           | `KW_BOOL`   | `oven ready = hot;`          | `"oven"`        | An oven is on or off. Literals are `hot` / `cold` (§4). Source: [Doc] logical expressions (implied); [Contract] `bool`.                                                    | Required by Specification |
| Character type             | `olive`                | `crumb`, `pinch`           | `KW_CHAR`   | `olive size = 'L';`          | `"olive"`       | One tiny piece. Source: [Contract] `char`.                                                                                                                                 | Proposed                  |
| String type                | `dough`                | `ticket`, `label`          | `KW_STRING` | `dough name = "Margherita";` | `"dough"`       | Dough is stretched into a long strand, as a string is a strand of characters. Source: [Contract] `string`.                                                                 | Proposed                  |
| No-value return type       | `empty`                | `plain`, `nothing`, `void` | `KW_VOID`   | `empty greet() { ... }`      | `"empty"`       | "Serves an empty plate." Function return type only [Contract §4.1]. Note: `empty` is a plausible variable name; it becomes unusable as one.                                | Proposed                  |

### 1.2 Declarations

| Programming Concept  | Proposed Pizza Keyword | Alternative Suggestions | Token Name | Example Usage                  | Lexical Pattern | Explanation                                                                                                                                                                 | Status                    |
| -------------------- | ---------------------- | ----------------------- | ---------- | ------------------------------ | --------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------- |
| Variable declaration | _(none, type-first)_   | `ingredient`            | _(none)_   | `mozzarella x = 5;`            | n/a             | [Contract §4.1] declares variables C-style: a type followed by a name. A separate `ingredient` keyword would be redundant with the type and would require a grammar change. | Proposed                  |
| Constant declaration | `secretSauce`          | `secret`, `fixed`       | `KW_CONST` | `secretSauce ranch PI = 3.14;` | `"secretSauce"` | "Secret sauce: never changes." Case-sensitive: `secretsauce` is an identifier. Initializer is required (grammar, M2-2). Source: [Doc] "Variables and Constants declaration".                                               | Required by Specification |

### 1.3 Control flow

| Programming Concept             | Proposed Pizza Keyword | Alternative Suggestions | Token Name    | Example Usage                                    | Lexical Pattern | Explanation                                                                                                                | Status                    |
| ------------------------------- | ---------------------- | ----------------------- | ------------- | ------------------------------------------------ | --------------- | -------------------------------------------------------------------------------------------------------------------------- | ------------------------- |
| Conditional (`if`)              | `taste`                | `check`, `if`           | `KW_IF`       | `taste (x > 0) { ... }`                          | `"taste"`       | Taste, then decide. Source: [Doc] if-then-else.                                                                            | Required by Specification |
| Alternative branch (`else`)     | `otherwise`            | `instead`, `else`       | `KW_ELSE`     | `} otherwise { ... }`                            | `"otherwise"`   | `else if` is written `otherwise taste (...)`. No pizza word fits naturally; clarity wins.                                  | Required by Specification |
| Pre-test loop (`while`)         | `knead`                | `simmer`, `while`       | `KW_WHILE`    | `knead (n < 10) { ... }`                         | `"knead"`       | Keep kneading while the dough is not ready. Source: [Doc] while loops.                                                     | Required by Specification |
| Post-test loop start (`repeat`) | `stir`                 | `mix`, `repeat`         | `KW_REPEAT`   | `stir { ... } until (x > 5);`                    | `"stir"`        | Stir at least once, then check. Source: [Doc] repeat-until.                                                                | Required by Specification |
| Post-test loop end (`until`)    | `until`                | `till`, `ready`         | `KW_UNTIL`    | `} until (x > 5);`                               | `"until"`       | Kept conventional: it already reads as cooking English ("stir until thick").                                               | Required by Specification |
| Counted loop (`for`)            | `slice`                | `portion`, `for`        | `KW_FOR`      | `slice (mozzarella i = 0; i < 8; i = i + 1) { ... }` | `"slice"`       | Cut the pizza one slice at a time. Note `slices` is still a valid identifier (longest match, §9). Source: [Doc] for loops. | Required by Specification |
| Switch                          | `menu`                 | `order`, `switch`       | `KW_SWITCH`   | `menu (choice) { ... }`                          | `"menu"`        | Pick one dish from the menu. Source: [Doc] switch statement.                                                               | Required by Specification |
| Case label                      | `dish`                 | `item`, `case`          | `KW_CASE`     | `dish 1: ...`                                    | `"dish"`        | One entry on the menu. `item` rejected: too common as an identifier. Source: [Doc] switch (implied).                       | Required by Specification |
| Default label                   | `houseSpecial`         | `house`, `default`      | `KW_DEFAULT`  | `houseSpecial: ...`                              | `"houseSpecial"` | The house special, served when nothing else matches. Optional and last [Contract §4.1].                                    | Proposed                  |
| Break                           | `enough`               | `done`, `stop`, `break` | `KW_BREAK`    | `enough;`                                        | `"enough"`      | Exit the loop/menu. `done` rejected: common boolean variable name. Needed for switch semantics.                            | Proposed                  |
| Continue                        | `skip`                 | `next`, `continue`      | `KW_CONTINUE` | `skip;`                                          | `"skip"`        | Go to the next iteration. `next` rejected: common identifier (linked lists).                                               | Proposed                  |

### 1.4 Functions

| Programming Concept  | Proposed Pizza Keyword | Alternative Suggestions | Token Name                | Example Usage                            | Lexical Pattern  | Explanation                                                                                                                                                                     | Status                    |
| -------------------- | ---------------------- | ----------------------- | ------------------------- | ---------------------------------------- | ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------- |
| Return               | `voila`               | `return`, `plate`       | `KW_RETURN`               | `voila a + b;`                          | `"voila"`       | Voila the result to the caller. Both `voila;` and `voila expr;` [Contract M3-2]. Source: [Doc] Functions (implied).                                                          | Required by Specification |
| Function declaration | _(none, type-first)_   | `prep`, `preparation`   | _(none)_ or new `KW_FUNC` | `mozzarella add(mozzarella a, mozzarella b) { ... }` | n/a, or `"prep"` | [Contract §4.1/§5 M4-1] uses C-style `type name(params) block`, which is already conflict-free. Adding a keyword is possible but changes M4's `func_def` rule. See decision D4. | Needs Discussion          |

### 1.5 Classes and objects

| Programming Concept     | Proposed Pizza Keyword       | Alternative Suggestions   | Token Name                | Example Usage                            | Lexical Pattern | Explanation                                                                                                                                                                                                                                                                                              | Status                    |
| ----------------------- | ---------------------------- | ------------------------- | ------------------------- | ---------------------------------------- | --------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------- |
| Class declaration       | `recipe`                     | `pizza`                   | `KW_CLASS`                | `recipe Margherita { ... }`              | `"recipe"`      | **Changed from the initial idea `pizza`.** A class is a blueprint; a recipe is the blueprint of a dish. Objects are then _baked from_ a recipe, which keeps `bake` meaningful. With `pizza` as the class keyword, every class reads as "a pizza", even a `pizza Oven`. Source: [Doc] class declarations. | Needs Discussion          |
| Object instantiation    | `bake`                       | `make`, `new`             | `KW_NEW`                  | `Margherita m = bake Margherita(30, 8);` | `"bake"`        | Bake a dish from a recipe. Source: [Doc] "Object declaration and instantiation".                                                                                                                                                                                                                         | Required by Specification |
| Current object (`this`) | `my`                         | `self`, `this`            | `KW_THIS`                 | `my.size = s;`                           | `"my"`          | Reads naturally: "my size". `myPizza` stays an identifier (longest match). Source: [Contract] `KW_THIS`.                                                                                                                                                                                                 | Proposed                  |
| Constructor             | _(none, class-named method)_ | `recipe`, `baker`, `prep` | _(none)_ or new `KW_CTOR` | `Margherita(mozzarella s) { ... }`       | n/a             | [Contract §5 example] writes the constructor as a method named after the class, with no keyword. The lexer sees only `IDENT '('`. A keyword would change M4's `ctor_def`. See decision D5. Source: [Doc] constructors are optional (bonus).                                                              | Needs Discussion          |
| Member access           | `.`                          | n/a                       | `'.'`                     | `m.size`, `m.price()`                    | `"."`           | Single-character token. **Must stay `.`**: [Doc] explicitly requires "the dot (.) operator".                                                                                                                                                                                                             | Required by Specification |

### 1.6 Input / output (not in [Doc], not in [Contract])

[Doc] never requires input or output. Output is still useful for readable demo programs. Two options:

| Programming Concept            | Proposed Pizza Keyword                    | Alternative Suggestions | Token Name             | Example Usage         | Lexical Pattern          | Explanation                                                                                                                                                                    | Status           |
| ------------------------------ | ----------------------------------------- | ----------------------- | ---------------------- | --------------------- | ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------- |
| Output, option A (recommended) | `deliver` as a **built-in function name** | `print`                 | `IDENT` (no new token) | `deliver(total);`     | `[A-Za-z_][A-Za-z0-9_]*` | Parsed as an ordinary call `f(a)` [Contract M4-3]. Zero grammar change. Phase II pre-registers `deliver` in the symbol table. Not reserved, so the lexer does nothing special. | Needs Discussion |
| Output, option B               | `deliver` as a keyword                    | `print`                 | new `KW_PRINT`         | `deliver total;`      | `"deliver"`              | Needs a new token and a new statement rule owned by M3.                                                                                                                        | Needs Discussion |
| Input                          | `order` (built-in function, as option A)  | `read`                  | `IDENT`                | `mozzarella n = order();` | identifier pattern       | Optional. Only add if the team wants it.                                                                                                                                       | Needs Discussion |

---

## 3. Identifiers

| Element                                                         | Token Name        | Lexical Pattern                | Example                                 | Semantic value                                 | Explanation                                                                                                                         | Status                    |
| --------------------------------------------------------------- | ----------------- | ------------------------------ | --------------------------------------- | ---------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | ------------------------- |
| Any name (variable, function, class, method, object, attribute) | `IDENT`           | `[A-Za-z_][A-Za-z0-9_]*`       | `count`, `Margherita`, `_tmp`, `slices` | `yylval.sval = strdup(yytext)` [Contract M1-4] | One token for all kinds. The parser tells kinds apart by position (`IDENT '('` is a call, `IDENT IDENT` a class-typed declaration). | Required by Specification |
| Starts with a digit                                             | _(lexical error)_ | `[0-9]+[A-Za-z_][A-Za-z0-9_]*` | `9lives`                                | n/a                                            | Without this rule, `9lives` silently becomes `INT_LIT IDENT` and the user gets a confusing _syntax_ error.                          | Proposed                  |
| Non-ASCII letters                                               | _(lexical error)_ | `[\x80-\xff]+`                 | `جبنة`                                  | n/a                                            | Identifiers are ASCII only. Grouped so one Arabic word gives one error, not one per byte.                                           | Proposed                  |
| Maximum length                                                  | none              | n/a                            | n/a                                     | n/a                                            | No limit proposed.                                                                                                                  | Proposed                  |

`my-var` is **not** an error: it lexes as `IDENT '-' IDENT` (a subtraction). Only the parser or semantic analyzer can complain.

---

## 4. Literals

Numbers are **unsigned**: `-5` is the token `'-'` followed by `INT_LIT(5)`; the parser handles unary minus [Contract M1-4].

| Literal            | Token Name       | Lexical Pattern                                                   | Valid examples                         | Invalid examples (lexical error)                                           | Semantic value         | Status                                                                                                             |
| ------------------ | ---------------- | ----------------------------------------------------------------- | -------------------------------------- | -------------------------------------------------------------------------- | ---------------------- | ------------------------------------------------------------------------------------------------------------------ |
| Integer            | `INT_LIT`        | `[0-9]+`                                                          | `0`, `42`, `007` (decimal 7, no octal) | `99999999999999999999` (exceeds 64-bit)                                    | see decision D7        | Required by Specification                                                                                          |
| Real               | `FLOAT_LIT`      | `[0-9]+"."[0-9]+`                                                 | `3.14`, `0.5`, `10.0`                  | `1.5abc`                                                                   | see decision D7        | Required by Specification                                                                                          |
| Real with exponent | `FLOAT_LIT`      | `[0-9]+"."[0-9]+([eE][+-]?[0-9]+)?`                               | `1.5e3`                                | `1e5` (no fraction)                                                        | same                   | Needs Discussion (D8)                                                                                              |
| Boolean            | `BOOL_LIT`       | `"hot"` and `"cold"`                                              | `hot` (true), `cold` (false)           | n/a                                                                        | `ival` = 1 or 0        | Proposed (true/false required by logical expressions, spelling open; alternatives `fresh`/`stale`, `true`/`false`) |
| Character          | `CHAR_LIT`       | `\'([^'\\\n]\|\\.)*\'` (action checks exactly one char or escape) | `'a'`, `'\n'`, `'\''`                  | `''` (empty), `'ab'` (two chars), `'a` (unterminated), `'\q'` (bad escape) | decoded character code | Proposed                                                                                                           |
| String             | `STRING_LIT`     | `\"([^"\\\n]\|\\.)*\"`                                            | `"Margherita"`, `"line\n"`, `""`       | `"abc` (unterminated), `"a\qb"` (bad escape), a string spanning two lines  | text, see decision D6  | Proposed                                                                                                           |
| Null / none        | _(not proposed)_ | n/a                                                               | n/a                                    | n/a                                                                        | n/a                    | Not required: [Doc] has no references/pointers that could be null.                                                 |

### Escape sequences (strings and chars)

| Escape | Meaning         |
| ------ | --------------- |
| `\n`   | newline         |
| `\t`   | tab             |
| `\r`   | carriage return |
| `\0`   | null character  |
| `\\`   | backslash       |
| `\"`   | double quote    |
| `\'`   | single quote    |

Any other `\x` is a lexical error ("invalid escape sequence"). Strings may not span lines (no raw newline inside quotes).

---

## 5. Operators

All spellings fixed by [Contract §4.2]. Multi-character operators have names; single characters are returned as their own ASCII code (`return yytext[0];`).

| Operator | Token Name | Lexical Pattern | Example       | Meaning                                            | Status                    |
| -------- | ---------- | --------------- | ------------- | -------------------------------------------------- | ------------------------- |
| `+`      | `'+'`      | `"+"`           | `a + b`       | addition                                           | Required by Specification |
| `-`      | `'-'`      | `"-"`           | `a - b`, `-a` | subtraction and unary minus (parser decides which) | Required by Specification |
| `*`      | `'*'`      | `"*"`           | `a * b`       | multiplication                                     | Required by Specification |
| `/`      | `'/'`      | `"/"`           | `a / b`       | division                                           | Required by Specification |
| `%`      | `'%'`      | `"%"`           | `a % b`       | remainder                                          | Proposed                  |
| `=`      | `'='`      | `"="`           | `x = 5`       | assignment                                         | Required by Specification |
| `==`     | `EQ`       | `"=="`          | `a == b`      | equality                                           | Required by Specification |
| `!=`     | `NE`       | `"!="`          | `a != b`      | inequality                                         | Required by Specification |
| `<`      | `'<'`      | `"<"`           | `a < b`       | less than                                          | Required by Specification |
| `>`      | `'>'`      | `">"`           | `a > b`       | greater than                                       | Required by Specification |
| `<=`     | `LE`       | `"<="`          | `a <= b`      | less or equal                                      | Required by Specification |
| `>=`     | `GE`       | `">="`          | `a >= b`      | greater or equal                                   | Required by Specification |
| `&&`     | `AND`      | `"&&"`          | `a && b`      | logical AND                                        | Required by Specification |
| `\|\|`   | `OR`       | `"\|\|"`        | `a \|\| b`    | logical OR                                         | Required by Specification |
| `!`      | `'!'`      | `"!"`           | `!a`          | logical NOT                                        | Required by Specification |
| `.`      | `'.'`      | `"."`           | `m.size`      | member access                                      | Required by Specification |

### Deliberately **not** included

| Operator                | Reason                                                                                        |
| ----------------------- | --------------------------------------------------------------------------------------------- |
| `++`, `--`              | Not required. `x++` would lex as `IDENT '+' '+'` and fail in the parser, which is acceptable. |
| `+=`, `-=`, etc.        | Not required; adds tokens and grammar rules.                                                  |
| `::` (scope resolution) | No namespaces or static members in [Doc].                                                     |
| `->`                    | No pointers.                                                                                  |
| `[` `]`                 | No arrays in [Doc]. A `[` in source is an illegal-character error.                            |
| Single `&` or `\|`      | No bitwise operators. Illegal-character error.                                                |

---

## 6. Delimiters and punctuation

| Symbol  | Token Name  | Lexical Pattern | Used for                                                                | Status                    |
| ------- | ----------- | --------------- | ----------------------------------------------------------------------- | ------------------------- |
| `(` `)` | `'('` `')'` | `"("` `")"`     | grouping, conditions, parameters, arguments                             | Required by Specification |
| `{` `}` | `'{'` `'}'` | `"{"` `"}"`     | blocks, class bodies (mandatory on all control bodies, [Contract §4.1]) | Required by Specification |
| `;`     | `';'`       | `";"`           | statement and declaration terminator; `for` header separator            | Required by Specification |
| `,`     | `','`       | `","`           | parameter and argument lists                                            | Required by Specification |
| `:`     | `':'`       | `":"`           | after `dish` and `houseSpecial` labels                                       | Required by Specification |
| `.`     | `'.'`       | `"."`           | member access (see §5)                                                  | Required by Specification |

All single-character tokens can share one rule: `[-+*/%<>!=(){};,:.]` → `return yytext[0];`

---

## 7. Special lexical elements

| Element                      | Pattern                                          | Produces                 | Action / message                                                                                                                                                    |
| ---------------------------- | ------------------------------------------------ | ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Spaces, tabs                 | `[ \t]+`                                         | ignored                  | advance column                                                                                                                                                      |
| Carriage return              | `\r`                                             | ignored                  | **Required on Windows**: test files saved with CRLF line endings contain `\r` before every `\n`. Without this rule every line ends in an "illegal character" error. |
| Form feed, vertical tab      | `[\f\v]`                                         | ignored                  |                                                                                                                                                                     |
| Newline                      | `\n`                                             | ignored                  | line + 1, column reset to 1                                                                                                                                         |
| Single-line comment          | `"//".*`                                         | ignored                  | `.` stops before the newline, so the newline is still counted                                                                                                       |
| Multi-line comment           | `"/*"` … `"*/"` via start condition `%x COMMENT` | ignored                  | count newlines inside; not nestable (C rules): `/* a /* b */` ends at the first `*/`                                                                                |
| Unterminated comment         | `<<EOF>>` while in `COMMENT`                     | lexical error            | "unterminated comment starting at line L"                                                                                                                           |
| Stray `*/` outside a comment | (no special rule)                                | `'*'` `'/'`              | the parser reports it; optional dedicated error, decision D10                                                                                                       |
| Illegal character            | `.` (last rule)                                  | lexical error            | "illegal character '@'" then continue scanning                                                                                                                      |
| End of file                  | `<<EOF>>`                                        | token `0` (end of input) | Bison treats token 0 as end of input                                                                                                                                |

---

## 8. Lexical error catalogue

Format (mirrors M2's syntax-error format, [Contract M2-6]):
`Lexical error at line L, column C: <message>`

| #   | Input                         | Message                                         | Recovery                     |
| --- | ----------------------------- | ----------------------------------------------- | ---------------------------- |
| E1  | `@`, `$`, `#`, `[`, `&`, `\|` | `illegal character '@'`                         | skip the character, continue |
| E2  | `جبنة`                        | `non-ASCII characters are not allowed`          | skip the whole run           |
| E3  | `"abc` + newline or EOF       | `unterminated string literal`                   | skip to end of line          |
| E4  | `"a\qb"`                      | `invalid escape sequence '\q'`                  | keep the token, report error |
| E5  | `'a`                          | `unterminated character literal`                | skip                         |
| E6  | `''`                          | `empty character literal`                       | skip                         |
| E7  | `'ab'`                        | `character literal has more than one character` | skip                         |
| E8  | `/* ...` to EOF               | `unterminated comment (opened at line L)`       | stop                         |
| E9  | `9lives`, `1.5abc`            | `invalid numeric literal '9lives'`              | skip the token               |
| E10 | `99999999999999999999`        | `integer literal out of range`                  | skip                         |

**Policy (proposed):** the lexer prints every lexical error, keeps scanning, and increments a global error counter. `main.c` exits with code 1 if the counter is non-zero, even if parsing succeeded. This guarantees that every file in `tests/invalid` with a lexical error fails, as [Contract M1-8] requires.

---

## 9. Ambiguity and longest-match checks

Flex rule: (1) the **longest** match wins; (2) on equal length, the **earliest rule** wins.

| Input                         | Tokens produced                 | Why                                                           |
| ----------------------------- | ------------------------------- | ------------------------------------------------------------- |
| `slice`                       | `KW_FOR`                        | keyword and IDENT both match 5 chars; keyword rule is earlier |
| `slices`                      | `IDENT(slices)`                 | IDENT matches 6 chars, keyword only 5                         |
| `myPizza`                     | `IDENT(myPizza)`                | longer than `my`                                              |
| `mozzarella_l`                | `IDENT`                         | longer than `mozzarella`                                      |
| `secretsauce`                 | `IDENT`                         | case-sensitive: only `secretSauce` is a keyword               |
| `hotness`                     | `IDENT`                         | longer than `hot`                                             |
| `a<=b`                        | `IDENT LE IDENT`                | `<=` longer than `<`                                          |
| `a==-1`                       | `IDENT EQ '-' INT_LIT`          | `==` then `-`; `=-` is not a token                            |
| `x===y`                       | `IDENT EQ '=' IDENT`            | parser rejects                                                |
| `!!ok`                        | `'!' '!' IDENT`                 | `!!` is not a token                                           |
| `a&&&b`                       | `IDENT AND` + E1 error for `&`  |                                                               |
| `x+++y`                       | `IDENT '+' '+' '+' IDENT`       | no `++`; parser rejects                                       |
| `a/b`                         | `IDENT '/' IDENT`               |                                                               |
| `a//b`                        | `IDENT` then comment            | `//` longer than `/`                                          |
| `3.14`                        | `FLOAT_LIT`                     | float pattern longer than `3`                                 |
| `3.x`                         | `INT_LIT '.' IDENT`             | `3.` is not a float; parser rejects                           |
| `.5`                          | `'.' INT_LIT`                   | no leading-dot floats; parser rejects                         |
| `1.2.3`                       | `FLOAT_LIT(1.2) '.' INT_LIT(3)` | parser rejects                                                |
| `m.size`                      | `IDENT '.' IDENT`               |                                                               |
| `"a" "b"`                     | `STRING_LIT STRING_LIT`         | no implicit concatenation                                     |
| `Serve`                       | `IDENT`                         | case-sensitive                                                |

**Keyword list check:** no duplicates, no keyword is a prefix-match problem (longest match always resolves prefixes), no keyword equals an operator.

---

## 10. Concepts deliberately excluded (not in [Doc])

| Concept                                | Why excluded                                                                                             | Name if ever added                                        |
| -------------------------------------- | -------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| Inheritance                            | [Doc] lists classes, attributes, methods, objects, member access, optional constructors. No inheritance. | `extends` → `topping` (a recipe topped onto another)      |
| Access modifiers                       | Not in [Doc]; all members public.                                                                        | `kitchen` (private) / `table` (public)                    |
| Import / include                       | Single-file programs only ("fed by a source code file", [Doc]).                                          | `pantry`                                                  |
| Null                                   | No references that can be null.                                                                          | `nada`                                                    |
| Arrays                                 | Not in [Doc].                                                                                            | n/a                                                       |
| Static members, interfaces, exceptions | Not in [Doc].                                                                                            | n/a                                                       |

Recommendation: do **not** reserve these words now. A reserved-but-unused keyword produces a token the grammar never accepts, which only confuses error messages.

---

## 11. Syntax examples

These examples follow [Contract §4.1] grammar decisions. Token streams use the notation `TOKEN(value)`; single-character tokens are shown quoted.

### 11.1 Variable declaration and assignment

```
mozzarella count = 8;
ranch weight;
weight = 2.5;
```

Conventional: `int count = 8; float weight; weight = 2.5;`

Tokens: `KW_INT IDENT(count) '=' INT_LIT(8) ';'` · `KW_FLOAT IDENT(weight) ';'` · `IDENT(weight) '=' FLOAT_LIT(2.5) ';'`

Design note: no `ingredient` keyword; the type word starts the declaration.

### 11.2 Constants and arithmetic

```
secretSauce ranch PI = 3.14;
ranch area = PI * r * r - (cut / 2) % 3;
```

Conventional: `const float PI = 3.14; float area = PI * r * r - (cut / 2) % 3;`

Tokens: `KW_CONST KW_FLOAT IDENT(PI) '=' FLOAT_LIT(3.14) ';'` · `KW_FLOAT IDENT(area) '=' IDENT(PI) '*' IDENT(r) '*' IDENT(r) '-' '(' IDENT(cut) '/' INT_LIT(2) ')' '%' INT_LIT(3) ';'`

Design note: `%` applied to a float expression is a Phase II type error, not a lexical one.

### 11.3 Output

```
deliver(area);
```

Conventional: `print(area);`

Tokens (option A): `IDENT(deliver) '(' IDENT(area) ')' ';'`. Under option B: `KW_PRINT ...`. Decision D3.

### 11.4 Conditional and alternative execution

```
taste (count > 6 && ready) {
    deliver("big");
} otherwise taste (count == 6) {
    deliver("medium");
} otherwise {
    deliver("small");
}
```

Conventional: `if (...) { } else if (...) { } else { }`

Tokens (first line): `KW_IF '(' IDENT(count) '>' INT_LIT(6) AND IDENT(ready) ')' '{'` … `'}' KW_ELSE KW_IF '(' IDENT(count) EQ INT_LIT(6) ')' '{'` …

Design note: braces are mandatory, so there is no dangling-`otherwise` ambiguity.

### 11.5 Loops

```
knead (n < 10) {
    n = n + 1;
}

stir {
    n = n - 2;
} until (n <= 0);

slice (mozzarella i = 0; i < 8; i = i + 1) {
    taste (i == 3) { skip; }
    taste (i == 6) { enough; }
}
```

Conventional: `while`, `repeat … until`, `for` with `continue` / `break`.

Tokens (repeat): `KW_REPEAT '{' IDENT(n) '=' IDENT(n) '-' INT_LIT(2) ';' '}' KW_UNTIL '(' IDENT(n) LE INT_LIT(0) ')' ';'`

Tokens (for header): `KW_FOR '(' KW_INT IDENT(i) '=' INT_LIT(0) ';' IDENT(i) '<' INT_LIT(8) ';' IDENT(i) '=' IDENT(i) '+' INT_LIT(1) ')'`

### 11.6 Switch

```
menu (size) {
    dish 1: price = 50; enough;
    dish 2: price = 80; enough;
    houseSpecial: price = 0;
}
```

Conventional: `switch (size) { case 1: ...; break; case 2: ...; break; default: ...; }`

Tokens: `KW_SWITCH '(' IDENT(size) ')' '{' KW_CASE INT_LIT(1) ':' IDENT(price) '=' INT_LIT(50) ';' KW_BREAK ';'` … `KW_DEFAULT ':'` …

### 11.7 Function declaration, invocation and return

```
mozzarella add(mozzarella a, mozzarella b) {
    voila a + b;
}
empty greet() {
    deliver("Ciao!");
    voila;
}
mozzarella total = add(3, 4);
```

Conventional: `int add(int a, int b) { return a + b; } void greet() { ...; return; }`

Tokens: `KW_INT IDENT(add) '(' KW_INT IDENT(a) ',' KW_INT IDENT(b) ')' '{' KW_RETURN IDENT(a) '+' IDENT(b) ';' '}'`

Design note: `mozzarella add(` and `mozzarella total =` start identically; the parser decides at `(` versus `=`. The lexer does nothing special.

### 11.8 Class, attributes, constructor, methods, instantiation, member access

```
recipe Margherita {
    mozzarella size;
    mozzarella slices;

    Margherita(mozzarella s, mozzarella n) {
        my.size = s;
        my.slices = n;
    }

    mozzarella perSlice() {
        voila my.size / my.slices;
    }
}

Margherita m = bake Margherita(30, 8);
m.size = 40;
mozzarella part = m.perSlice();
```

Conventional (matches the [Contract §5] demo):

```
class Margherita { int size; int slices;
  Margherita(int s, int n) { this.size = s; this.slices = n; }
  int perSlice() { return this.size / this.slices; } }
Margherita m = new Margherita(30, 8);
m.size = 40;
int part = m.perSlice();
```

Tokens:

- `KW_CLASS IDENT(Margherita) '{'`
- `KW_INT IDENT(size) ';'` · `KW_INT IDENT(slices) ';'` (note: `slices` is an identifier, not `KW_FOR`)
- `IDENT(Margherita) '(' KW_INT IDENT(s) ',' KW_INT IDENT(n) ')' '{'` (constructor: just `IDENT '('`)
- `KW_THIS '.' IDENT(size) '=' IDENT(s) ';'`
- `IDENT(Margherita) IDENT(m) '=' KW_NEW IDENT(Margherita) '(' INT_LIT(30) ',' INT_LIT(8) ')' ';'`
- `IDENT(m) '.' IDENT(perSlice) '(' ')'`

Design notes:

- The lexer never knows `Margherita` is a class; it is `IDENT` everywhere.
- Whether `my` appears outside a class is a Phase II semantic error [Contract §6 trap 4].

### 11.9 Inheritance

Not supported (§10). `recipe Pepperoni topping Margherita { }` would lex `topping` as `IDENT` and the parser would reject it.

### 11.10 Comments

```
// one-line note: ignored to the end of the line
/* multi-line note
   spanning lines */
mozzarella x = 1; /* inline */ x = 2;
```

Tokens: only `KW_INT IDENT(x) '=' INT_LIT(1) ';' IDENT(x) '=' INT_LIT(2) ';'`. Line numbers still advance through the comment.

---

## 12. Open decisions (fill in the "Team decision" column)

| #   | Decision                                                                                                     | Recommendation                                                                                                    | Team decision |
| --- | ------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------- | ------------- |
| D1  | Class keyword: `recipe` or `pizza`?                                                                          | `recipe` (blueprint metaphor; makes `bake` coherent)                                                              |               |
| D2  | Integer sizes? | Plain `mozzarella` only | Decided: no sizes (§2 removed) |
| D3  | Output: built-in function `deliver(x)` or keyword `KW_PRINT`?                                                | Built-in function (no contract change)                                                                            |               |
| D4  | Function keyword (`prep`)?                                                                                   | No; keep type-first [Contract]                                                                                    |               |
| D5  | Constructor keyword?                                                                                         | No; class-named method [Contract]                                                                                 |               |
| D6  | String semantic value: raw text (escapes kept, quotes stripped) or decoded?                                  | Raw text, escapes validated: prints directly into quadruples later                                                |               |
| D7  | Numeric literal semantic value: text (`sval`) per [Contract M1-4] "strdup text", or numeric (`ival`/`fval`)? | Numeric value **and** keep `yytext` available; see the M1 plan, §5.7. Needs M2 agreement since `%union` is shared |               |
| D8  | Float exponent (`1.5e3`)?                                                                                    | No in Phase I                                                                                                     |               |
| D9  | Boolean literals: `hot`/`cold`, `fresh`/`stale`, or `true`/`false`?                                          | `hot`/`cold` (matches `oven`)                                                                                     |               |
| D10 | Dedicated error for stray `*/`?                                                                              | Optional, low priority                                                                                            |               |
| D11 | Every spelling in §1                                                                                         | Review each row; mark `Approved`                                                                                  |               |
| D12 | Source file extension `.pz`?                                                                                 | Yes                                                                                                               |               |
