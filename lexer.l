/*
 * lexer.l - Pizza language lexical analyzer (M1).
 *
 * Token NAMES come from the frozen contract (Phase1-Work-Division.md §4.2)
 * and are declared in parser.y. Only the source SPELLINGS below are
 * pizza words (PHASE1-TOKEN-PROPOSAL.md §1). To rename a keyword, change
 * its quoted string here; the parser never sees spellings, so nothing in
 * parser.y has to change.
 *
 * Semantic values handed to the parser never contain a pizza spelling:
 * BOOL_LIT carries 1/0, not "hot"/"cold".
 */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <errno.h>
#include "parser.tab.h"

int lex_error_count = 0;            /* read by main.c for the exit code */

static int cur_line = 1;            /* position of the next unread char */
static int cur_col  = 1;
static int comment_line, comment_col;

static void update_location(const char *text, int len);
static void lex_error(int line, int col, const char *fmt, ...);
static int  check_escapes(const char *s, int len, int line, int col);
static int  decode_char(const char *s, int len, int line, int col, long long *out);
static char *copy_inner(const char *text, int len);

/* Runs before every rule action: keeps yylloc in step with the input. */
#define YY_USER_ACTION update_location(yytext, (int)yyleng);
%}

%option noyywrap nounput noinput 8bit
%x COMMENT

DIGIT   [0-9]
ALPHA   [A-Za-z_]
ALNUM   [A-Za-z0-9_]

%%

 /* ---------- comments and whitespace ---------- */

"//".*                  { /* single-line comment: ignored */ }

"/*"                    { comment_line = yylloc.first_line;
                          comment_col  = yylloc.first_column;
                          BEGIN(COMMENT); }
<COMMENT>"*/"           { BEGIN(INITIAL); }
<COMMENT>[^*\n]+        { /* comment body */ }
<COMMENT>"*"            { /* lone star inside comment */ }
<COMMENT>\n             { /* newline inside comment */ }
<COMMENT><<EOF>>        { lex_error(comment_line, comment_col,
                                    "unterminated comment (opened at line %d)",
                                    comment_line);
                          BEGIN(INITIAL);
                          yyterminate(); }

[ \t\r\f\v]+            { /* whitespace; \r makes CRLF files work */ }
\n                      { /* newline */ }

 /* ---------- reserved words (must precede IDENT) ---------- */

"mozzarella"            { return KW_INT; }
"ranch"                 { return KW_FLOAT; }
"oven"                  { return KW_BOOL; }
"olive"                 { return KW_CHAR; }
"dough"                 { return KW_STRING; }
"empty"                 { return KW_VOID; }
"secretSauce"           { return KW_CONST; }

"taste"                 { return KW_IF; }
"otherwise"             { return KW_ELSE; }
"knead"                 { return KW_WHILE; }
"stir"                  { return KW_REPEAT; }
"until"                 { return KW_UNTIL; }
"slice"                 { return KW_FOR; }
"menu"                  { return KW_SWITCH; }
"dish"                  { return KW_CASE; }
"houseSpecial"          { return KW_DEFAULT; }
"enough"                { return KW_BREAK; }
"skip"                  { return KW_CONTINUE; }
"voila"                { return KW_RETURN; }

"recipe"                { return KW_CLASS; }
"bake"                  { return KW_NEW; }
"my"                    { return KW_THIS; }

"hot"                   { yylval.ival = 1; return BOOL_LIT; }
"cold"                  { yylval.ival = 0; return BOOL_LIT; }

 /* ---------- numbers (unsigned; '-' belongs to the parser) ---------- */

{DIGIT}+"."{DIGIT}+{ALPHA}{ALNUM}*  |
{DIGIT}+{ALPHA}{ALNUM}*             { lex_error(yylloc.first_line, yylloc.first_column,
                                                "invalid numeric literal '%s'", yytext); }

{DIGIT}+"."{DIGIT}+     { yylval.fval = strtod(yytext, NULL);
                          return FLOAT_LIT; }

{DIGIT}+                { errno = 0;
                          long long v = strtoll(yytext, NULL, 10);
                          if (errno == ERANGE) {
                              lex_error(yylloc.first_line, yylloc.first_column,
                                        "integer literal out of range '%s'", yytext);
                          } else {
                              yylval.ival = v;
                              return INT_LIT;
                          } }

 /* ---------- identifiers ---------- */

{ALPHA}{ALNUM}*         { yylval.sval = strdup(yytext); return IDENT; }

 /* ---------- string and character literals ---------- */

\"([^"\\\n]|\\.)*\"     { check_escapes(yytext + 1, (int)yyleng - 2,
                                        yylloc.first_line, yylloc.first_column);
                          yylval.sval = copy_inner(yytext, (int)yyleng);
                          return STRING_LIT; }
\"([^"\\\n]|\\.)*\\?    { lex_error(yylloc.first_line, yylloc.first_column,
                                    "unterminated string literal"); }

\'([^'\\\n]|\\.)*\'     { long long c;
                          if (decode_char(yytext + 1, (int)yyleng - 2,
                                          yylloc.first_line, yylloc.first_column, &c)) {
                              yylval.ival = c;
                              return CHAR_LIT;
                          } }
\'([^'\\\n]|\\.)*\\?    { lex_error(yylloc.first_line, yylloc.first_column,
                                    "unterminated character literal"); }

 /* ---------- operators and punctuation ---------- */

"=="                    { return EQ; }
"!="                    { return NE; }
"<="                    { return LE; }
">="                    { return GE; }
"&&"                    { return AND; }
"||"                    { return OR; }

[-+*/%<>!=(){};,:.]     { return yytext[0]; }

 /* ---------- everything else is an error (always last) ---------- */

[\x80-\xff]+            { lex_error(yylloc.first_line, yylloc.first_column,
                                    "non-ASCII characters are not allowed"); }

.                       { unsigned char ch = (unsigned char)yytext[0];
                          if (ch >= 32 && ch < 127)
                              lex_error(yylloc.first_line, yylloc.first_column,
                                        "illegal character '%c'", ch);
                          else
                              lex_error(yylloc.first_line, yylloc.first_column,
                                        "illegal character (byte 0x%02X)", ch); }

%%

/* Sets yylloc to the span of the current lexeme and advances the cursor.
 * Columns are 1-based; a tab counts as one column; UTF-8 continuation
 * bytes do not advance the column. */
static void update_location(const char *text, int len)
{
    yylloc.first_line   = cur_line;
    yylloc.first_column = cur_col;
    for (int i = 0; i < len; i++) {
        if (text[i] == '\n') {
            cur_line++;
            cur_col = 1;
        } else if (((unsigned char)text[i] & 0xC0) != 0x80) {
            cur_col++;
        }
    }
    yylloc.last_line   = cur_line;
    yylloc.last_column = cur_col - 1;
}

static void lex_error(int line, int col, const char *fmt, ...)
{
    va_list ap;
    fflush(stdout);                 /* keep token dump and errors in order */
    fprintf(stderr, "Lexical error at line %d, column %d: ", line, col);
    va_start(ap, fmt);
    vfprintf(stderr, fmt, ap);
    va_end(ap);
    fputc('\n', stderr);
    lex_error_count++;
}

static int is_valid_escape(char c)
{
    return c == 'n' || c == 't' || c == 'r' || c == '0' ||
           c == '\\' || c == '"' || c == '\'';
}

static char escape_value(char c)
{
    switch (c) {
    case 'n': return '\n';
    case 't': return '\t';
    case 'r': return '\r';
    case '0': return '\0';
    default:  return c;             /* \\  \"  \'  */
    }
}

/* Reports every invalid escape in s[0..len). Returns the number found. */
static int check_escapes(const char *s, int len, int line, int col)
{
    int bad = 0;
    for (int i = 0; i < len; i++) {
        if (s[i] == '\\' && i + 1 < len) {
            if (!is_valid_escape(s[i + 1])) {
                lex_error(line, col, "invalid escape sequence '\\%c'", s[i + 1]);
                bad++;
            }
            i++;
        }
    }
    return bad;
}

/* s[0..len) is the text between the quotes of a char literal.
 * Returns 1 and stores the character code if it is exactly one
 * character or one escape; otherwise reports an error and returns 0.
 * An invalid escape is reported but the token is kept (E4). */
static int decode_char(const char *s, int len, int line, int col, long long *out)
{
    if (len == 0) {
        lex_error(line, col, "empty character literal");
        return 0;
    }
    if (s[0] == '\\' && len == 2) {
        if (!is_valid_escape(s[1]))
            lex_error(line, col, "invalid escape sequence '\\%c'", s[1]);
        *out = (unsigned char)escape_value(s[1]);
        return 1;
    }
    if (s[0] != '\\' && len == 1) {
        *out = (unsigned char)s[0];
        return 1;
    }
    lex_error(line, col, "character literal has more than one character");
    return 0;
}

/* Copy of a quoted lexeme without its quotes. Escapes are kept as written
 * (decision D6: raw text, validated). */
static char *copy_inner(const char *text, int len)
{
    char *s = malloc((size_t)len - 1);
    if (!s) { perror("malloc"); exit(2); }
    memcpy(s, text + 1, (size_t)len - 2);
    s[len - 2] = '\0';
    return s;
}
