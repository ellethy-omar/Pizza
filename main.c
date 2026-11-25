/*
 * main.c - driver for the Pizza compiler (M1, step M1-7).
 *
 *   pizza file.pz            parse the file
 *   pizza --tokens file.pz   print the token stream only (no parser)
 *
 * Exit status: 0 = no errors, 1 = lexical or syntax errors, 2 = usage/IO.
 */

#include <stdio.h>
#include <string.h>
#include "parser.tab.h"

extern FILE *yyin;
extern char *yytext;
extern int   lex_error_count;
int yylex(void);

/* Contract name of every token. Written by hand so the dump does not
 * depend on Bison-internal tables. */
static const char *token_name(int tok)
{
    switch (tok) {
    case KW_INT:      return "KW_INT";
    case KW_FLOAT:    return "KW_FLOAT";
    case KW_BOOL:     return "KW_BOOL";
    case KW_CHAR:     return "KW_CHAR";
    case KW_STRING:   return "KW_STRING";
    case KW_VOID:     return "KW_VOID";
    case KW_CONST:    return "KW_CONST";
    case KW_IF:       return "KW_IF";
    case KW_ELSE:     return "KW_ELSE";
    case KW_WHILE:    return "KW_WHILE";
    case KW_REPEAT:   return "KW_REPEAT";
    case KW_UNTIL:    return "KW_UNTIL";
    case KW_FOR:      return "KW_FOR";
    case KW_SWITCH:   return "KW_SWITCH";
    case KW_CASE:     return "KW_CASE";
    case KW_DEFAULT:  return "KW_DEFAULT";
    case KW_BREAK:    return "KW_BREAK";
    case KW_CONTINUE: return "KW_CONTINUE";
    case KW_RETURN:   return "KW_RETURN";
    case KW_CLASS:    return "KW_CLASS";
    case KW_NEW:      return "KW_NEW";
    case KW_THIS:     return "KW_THIS";
    case IDENT:       return "IDENT";
    case INT_LIT:     return "INT_LIT";
    case FLOAT_LIT:   return "FLOAT_LIT";
    case CHAR_LIT:    return "CHAR_LIT";
    case STRING_LIT:  return "STRING_LIT";
    case BOOL_LIT:    return "BOOL_LIT";
    case EQ:          return "EQ";
    case NE:          return "NE";
    case LE:          return "LE";
    case GE:          return "GE";
    case AND:         return "AND";
    case OR:          return "OR";
    default:          return NULL;
    }
}

/* One line per token:  line:col  NAME  lexeme  [value] */
static void dump_tokens(void)
{
    int tok;
    while ((tok = yylex()) != 0) {
        char name[16];
        const char *n = token_name(tok);
        if (n == NULL) {                        /* single-character token */
            snprintf(name, sizeof name, "'%c'", tok);
            n = name;
        }
        printf("%d:%d\t%-12s %s", yylloc.first_line, yylloc.first_column,
               n, yytext);
        switch (tok) {
        case INT_LIT:
        case CHAR_LIT:
        case BOOL_LIT:   printf("\t= %lld", yylval.ival); break;
        case FLOAT_LIT:  printf("\t= %g", yylval.fval); break;
        case STRING_LIT: printf("\t= \"%s\"", yylval.sval); break;
        default: break;
        }
        putchar('\n');
    }
    printf("EOF\n");
}

int main(int argc, char **argv)
{
    int tokens_only = 0;
    const char *path = NULL;

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--tokens") == 0) tokens_only = 1;
        else if (path == NULL)                 path = argv[i];
        else { path = NULL; break; }
    }
    if (path == NULL) {
        fprintf(stderr, "usage: %s [--tokens] file.pz\n", argv[0]);
        return 2;
    }
    yyin = fopen(path, "rb");
    if (yyin == NULL) {
        perror(path);
        return 2;
    }

    int failed;
    if (tokens_only) {
        dump_tokens();
        failed = lex_error_count > 0;
    } else {
        int r = yyparse();
        failed = r != 0 || lex_error_count > 0;
        printf(failed ? "Parsing failed.\n" : "Parsing succeeded.\n");
    }
    fclose(yyin);
    return failed ? 1 : 0;
}
