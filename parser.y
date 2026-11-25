/* ======================================================================
 * parser.y - Pizza language parser
 *
 * SECTION 0: TOKEN CONTRACT (owner: M1, step M1-2)
 * Frozen by Phase1-Work-Division.md §4.2. Changing anything in this
 * section requires telling all four members.
 *
 * Token names describe concepts, not spellings: KW_IF is "the if keyword"
 * whatever the lexer maps it from (currently "taste"). Spellings live only
 * in lexer.l, so renaming a keyword never touches this file.
 * ====================================================================== */

%{
#include <stdio.h>
#include <stdlib.h>

int  yylex(void);
void yyerror(const char *msg);
%}

%locations

%union {
    char      *sval;    /* IDENT name; STRING_LIT text without quotes (escapes kept) */
    long long  ival;    /* INT_LIT value; CHAR_LIT code; BOOL_LIT 1/0 */
    double     fval;    /* FLOAT_LIT value */
}

/* Keywords (KW_ prefix avoids clashes with Windows macros such as INT, BOOL) */
%token KW_INT KW_FLOAT KW_BOOL KW_CHAR KW_STRING KW_VOID KW_CONST
%token KW_IF KW_ELSE KW_WHILE KW_REPEAT KW_UNTIL KW_FOR
%token KW_SWITCH KW_CASE KW_DEFAULT KW_BREAK KW_CONTINUE KW_RETURN
%token KW_CLASS KW_NEW KW_THIS

/* Values */
%token <sval> IDENT STRING_LIT
%token <ival> INT_LIT CHAR_LIT BOOL_LIT
%token <fval> FLOAT_LIT

/* Multi-character operators. Single characters are returned as themselves:
 *   + - * / % < > ! = ( ) { } ; , : .                                     */
%token EQ NE LE GE AND OR

/* ======================== END OF SECTION 0 (M1) ======================== */

%%

/* ======================================================================
 * PLACEHOLDER (owner: M2, step M2-1). M2 replaces everything from here
 * to the end of the file with the real skeleton (sections A-D) and the
 * real yyerror (M2-6). It exists only so the project builds before
 * M2-1 lands; it accepts the empty program and nothing else.
 * ====================================================================== */

program : %empty ;

%%

void yyerror(const char *msg)
{
    fprintf(stderr, "Syntax error at line %d, column %d: %s\n",
            yylloc.first_line, yylloc.first_column, msg);
}
