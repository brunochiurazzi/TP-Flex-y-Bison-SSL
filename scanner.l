%{

#include "parser.tab.h"
#include <stdlib.h>
#include <string.h>

void error_lexico(const char* lexema);

%}

/* para solo procesar un archivo */
%option noyywrap  

/* numero de linea */
%option yylineno    


DIGITO [0-9]
LETRA [a-zA-Z]
ID {LETRA}({LETRA}|{DIGITO}){0,31}
ESPACIO [ \t\r\n]+


%%

"inicio"    { return INICIO; }
"fin"       { return FIN; } 
"leer"      { return LEER; }
"escribir"  { return ESCRIBIR; }
":="        { return ASIGNACION; }
"+"         { return SUMA; }
"-"         { return RESTA; }
"("         { return PAREN_IZQ; }
")"         { return PAREN_DER; }
","         { return COMA; }
";"         { return PUNTO_COMA; }

{ID}        { yylval.str = strdup(yytext); return ID; }
{DIGITO}+   { yylval.num = atoi(yytext); return CONSTANTE; }

{ESPACIO}   { }

.           { error_lexico(yytext); } /* cualquier caracter */

%%


void error_lexico(const char* lexema) {
    printf("Error Léxico en línea %d: Carácter no reconocido '%s'\n", yylineno, lexema);
}

