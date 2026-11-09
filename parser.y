
%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yylineno;              // extern porque se generan en el archivo flex
extern char* yytext;
void yyerror(const char *s);


/*TABLA SIMBOLOS*/
#define MAX_SIMBOLOS 100
char* tablaSimbolos[MAX_SIMBOLOS];
int cantidadSimbolos = 0;

void agregarSimbolo(char* id);
void verificarSimbolo(char* id);

%}


%union {
    char* str;
    int num;
}


%token INICIO FIN LEER ESCRIBIR ASIGNACION PUNTO_COMA COMA
%token SUMA RESTA PAREN_IZQ PAREN_DER 
%token  <str> ID
%token <num> CONSTANTE


%%

programa:
    INICIO listaSentencias FIN {printf("Analisis completado con exito");}
    ;


listaSentencias:
    sentencia
    | listaSentencias sentencia
    ;


sentencia:                                                               // $n indica el valor semántico de cada componente de la regla de izquierda a derecha
    ID ASIGNACION expresion PUNTO_COMA { agregarSimbolo($1); free($1); }    // free($1) para liberar la memoria que reservamos en Flex con strdup().
    | LEER PAREN_IZQ listaIdentificadores PAREN_DER PUNTO_COMA
    | ESCRIBIR PAREN_IZQ listaExpresiones PAREN_DER PUNTO_COMA
    ;


listaIdentificadores:
    ID { agregarSimbolo($1); free($1); }
    | listaIdentificadores COMA ID { agregarSimbolo($3); free($3); }
    ;


listaExpresiones:
    expresion
    | listaExpresiones COMA expresion
    ;


expresion:
    primaria
    | expresion SUMA primaria
    | expresion RESTA primaria
    ;


primaria:
    ID { verificarSimbolo($1); free($1); }
    | CONSTANTE
    | PAREN_IZQ expresion PAREN_DER
    ;


%%

 /* RUTINAS SEMÁNTICAS */

 void agregarSimbolo(char *id) {

    for(int i =0; i < cantidadSimbolos; i++){
        if(strcmp(tablaSimbolos[i], id) == 0) return;  /*verifica si ya esta en la tabla*/
    }

    if(cantidadSimbolos < MAX_SIMBOLOS){
    tablaSimbolos[cantidadSimbolos] = strdup(id);
    cantidadSimbolos++;
    }else{
        printf("Error Semantico: Tabla de simbolos llena. \n");
    }
 
}


void verificarSimbolo(char *id){

    for(int i=0; i < cantidadSimbolos; i++){
        if(strcmp(tablaSimbolos[i], id) == 0) return;
    }

    printf("Error semantico en la linea %d: La variable '%s' no ha sido inicializada o declarada previamente. \n", yylineno, id);
}


void yyerror(const char *s) {
    printf("Error Sintactico en linea %d: %s (cerca de '%s')\n", yylineno, s, yytext);
} 


int main(int argc, char** argv) {
    yyparse();
    return 0;
}


