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

/* ======================================================================
 * PARSER SETTINGS AND PRECEDENCE (owner: M2, step M2-3)
 * Lowest precedence first. Unary minus and '!' bind tightest.
 * ====================================================================== */

%define parse.error verbose

%left  OR
%left  AND
%left  EQ NE
%left  '<' '>' LE GE
%left  '+' '-'
%left  '*' '/' '%'
%precedence UMINUS '!'

%start program

%%

/* ======================================================================
 * SECTION A: CORE (owner: M2)
 * program top_item type prim_type decl
 * ====================================================================== */

program     : %empty
            | program top_item
            ;

top_item    : decl
            | statement
            | func_def
            | class_def
            ;

type        : prim_type
            | IDENT                     /* class name: Point p; */
            ;

prim_type   : KW_INT
            | KW_FLOAT
            | KW_BOOL
            | KW_CHAR
            | KW_STRING
            ;

decl        : type IDENT ';'
            | type IDENT '=' expr ';'
            | KW_CONST type IDENT '=' expr ';'      /* constants need an initializer */
            ;

/* ======================================================================
 * SECTION B: EXPRESSIONS (owner: M2)
 * expr literal assignment lvalue
 * ====================================================================== */

expr        : expr OR  expr
            | expr AND expr
            | expr EQ  expr
            | expr NE  expr
            | expr '<' expr
            | expr '>' expr
            | expr LE  expr
            | expr GE  expr
            | expr '+' expr
            | expr '-' expr
            | expr '*' expr
            | expr '/' expr
            | expr '%' expr
            | '-' expr %prec UMINUS
            | '!' expr
            | literal
            | postfix
            ;

literal     : INT_LIT
            | FLOAT_LIT
            | CHAR_LIT
            | STRING_LIT
            | BOOL_LIT
            ;

/* No ';' here: M3's for_stmt reuses assignment as the loop step. */
assignment  : lvalue '=' expr
            ;

lvalue      : IDENT
            | postfix '.' IDENT         /* obj.attr = ... (needs M4's real postfix) */
            ;

/* ======================================================================
 * SECTION C: CONTROL FLOW AND BLOCKS (owner: M3)
 * statement block decls stmts if_stmt while_stmt repeat_stmt for_stmt
 * for_init switch_stmt cases case case_const case_body default_opt
 *
 * STUBS written by M2-1 so the file builds. M3 replaces them.
 * ====================================================================== */

statement   : assignment ';'
            | call ';'
            | if_stmt
            | while_stmt
            | repeat_stmt
            | for_stmt
            | switch_stmt
            | block
            ;

block       : '{' '}' ;
if_stmt     : KW_IF ;
while_stmt  : KW_WHILE ;
repeat_stmt : KW_REPEAT ;
for_stmt    : KW_FOR ;
switch_stmt : KW_SWITCH ;

/* ======================================================================
 * SECTION D: FUNCTIONS, CLASSES AND OBJECTS (owner: M4)
 * func_def params_opt params param call args_opt args postfix
 * class_def members_opt member ctor_def
 *
 * STUBS written by M2-1 so the file builds. M4 replaces them.
 * '(' expr ')' is included early so M2 can test parenthesized expressions;
 * it belongs in the final postfix anyway (Phase1-Work-Division.md §6.2).
 * ====================================================================== */

func_def    : KW_VOID IDENT '(' ')' block
            ;

call        : IDENT '(' ')'
            ;

postfix     : IDENT
            | call
            | '(' expr ')'
            ;

class_def   : KW_CLASS
            ;

%%

void yyerror(const char *msg)
{
    fprintf(stderr, "Syntax error at line %d, column %d: %s\n",
            yylloc.first_line, yylloc.first_column, msg);
}
