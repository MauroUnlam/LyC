/* Seccion de declaraciones */
%{
/* Includes */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"

/* Variables*/
FILE  *yyin;

/* Prototipos */
int yylex();
int yyerror(char *descripcion_error);

%}

/* Especifico tipos de datos */
%union {
int intval;
float floatval;
double val;
char *str_val;
}

/* Para obtener mensajes de error mas descriptivos */
%error-verbose

/* Tokens */

/* Generales */
%token COMA
%token PUNTO
%token PUNTO_Y_COMA
%token DOS_PUNTOS
%token PARENTESIS_A
%token PARENTESIS_C
%token CORCHETE_A
%token CORCHETE_C

/* Palabras reservadas */
%token PALABRA_RESERVADA_IF
%token PALABRA_RESERVADA_INT
%token PALABRA_RESERVADA_FLOAT
%token PALABRA_RESERVADA_STRING
%token PALABRA_RESERVADA_WHILE
%token PALABRA_RESERVADA_READ
%token PALABRA_RESERVADA_WRITE
%token PALABRA_RESERVADA_DECVAR
%token PALABRA_RESERVADA_ENDDEC
%token PALABRA_RESERVADA_ENDIF
%token PALABRA_RESERVADA_ENDWHILE
%token PALABRA_RESERVADA_AVG
%token PALABRA_RESERVADA_BETWEEN

/* Operadores */
%token OP_ASIGNACION
%token OP_OR
%token OP_AND
%token OP_NOT
%token OP_MAYOR
%token OP_MENOR
%token OP_SUMA
%token OP_RESTA
%token OP_DIVISION
%token OP_MULTIPLICACION

/* Otro */
%token IDENTIFICADOR

/* Constantes */
%token CONST_INT
%token CONST_FLOAT
%token CONST_STRING

/* Presedencia */
%right OP_ASIGNACION
%left OP_MULTIPLICACION OP_DIVISION OP_SUMA OP_RESTA

/* Defino el start simbol */
%start programa

/* Seccion de reglas */
%%
programa:
            sentencia
        |   programa sentencia
        ;

sentencia: 
            iteracion
        |   expresion
        |   seleccion
        |   asignacion
        |   bloque_de_declaracion
        ;

iteracion:
            PALABRA_RESERVADA_WHILE PARENTESIS_A condicion PARENTESIS_C PALABRA_RESERVADA_ENDWHILE          {puts("Iteracion vacia");}
        |   PALABRA_RESERVADA_WHILE PARENTESIS_A condicion PARENTESIS_C programa PALABRA_RESERVADA_ENDWHILE {puts("Iteracion");}
        ;

seleccion: 
            PALABRA_RESERVADA_IF PARENTESIS_A condicion PARENTESIS_C PALABRA_RESERVADA_ENDIF            {puts("Seleccion vacia");}
        |   PALABRA_RESERVADA_IF PARENTESIS_A condicion PARENTESIS_C programa PALABRA_RESERVADA_ENDIF   {puts("Seleccion");}
        ;

condicion:
            IDENTIFICADOR operador_comparacion IDENTIFICADOR                                                                                                                                            {puts("Condicion simple");};
        |   PARENTESIS_A IDENTIFICADOR operador_comparacion IDENTIFICADOR PARENTESIS_C OP_OR PARENTESIS_A IDENTIFICADOR operador_comparacion IDENTIFICADOR PARENTESIS_C    {puts("Condicion multiple");}
        |   PARENTESIS_A IDENTIFICADOR operador_comparacion IDENTIFICADOR PARENTESIS_C OP_AND PARENTESIS_A IDENTIFICADOR operador_comparacion IDENTIFICADOR PARENTESIS_C   {puts("Condicion multiple");}
        |   OP_NOT PARENTESIS_A IDENTIFICADOR operador_comparacion IDENTIFICADOR PARENTESIS_C                                                                                      {puts("Condicion negada");}
        |   between
        ;

operador_comparacion:
                        OP_MAYOR
                    |   OP_MENOR
                    ;        

between: PALABRA_RESERVADA_BETWEEN PARENTESIS_A parametros_between PARENTESIS_C {puts("Between");};

parametros_between: IDENTIFICADOR COMA CORCHETE_A expresion PUNTO_Y_COMA expresion CORCHETE_C;

avg: PALABRA_RESERVADA_AVG PARENTESIS_A parametros_avg PARENTESIS_C {puts("Avg");};        

parametros_avg : CORCHETE_A lista_de_expresiones CORCHETE_C;

lista_de_expresiones: 
                        expresion COMA expresion
                    |   lista_de_expresiones COMA expresion
                    ;

expresion:
            expresion OP_SUMA termino
        |   expresion OP_RESTA termino
        |   termino
        ;

termino:
            termino OP_DIVISION factor
        |   termino OP_MULTIPLICACION factor
        |   factor
        ;

factor:
            CONST_INT
        |   CONST_FLOAT
        |   IDENTIFICADOR
        |   PARENTESIS_A expresion PARENTESIS_C
        |   avg
        ;

asignacion: 
            IDENTIFICADOR OP_ASIGNACION IDENTIFICADOR {puts("Asignacion de tipo: identificador - identificador");}
        |   IDENTIFICADOR OP_ASIGNACION CONST_INT     {puts("Asignacion de tipo: identificador - const int");}
        |   IDENTIFICADOR OP_ASIGNACION CONST_FLOAT   {puts("Asignacion de tipo: identificador - const float");}
        |   IDENTIFICADOR OP_ASIGNACION CONST_STRING  {puts("Asignacion de tipo: identificador - const string");}
        ;

bloque_de_declaracion: PALABRA_RESERVADA_DECVAR linea_de_declaracion PALABRA_RESERVADA_ENDDEC {puts("Bloque de declaracion");};

linea_de_declaracion: 
                        lista_de_variables DOS_PUNTOS tipo_de_dato
                    |   linea_de_declaracion lista_de_variables DOS_PUNTOS tipo_de_dato
                    ;

lista_de_variables: 
                    IDENTIFICADOR
                |   lista_de_variables COMA IDENTIFICADOR
                ;

tipo_de_dato:
                PALABRA_RESERVADA_INT
            |   PALABRA_RESERVADA_FLOAT
            |   PALABRA_RESERVADA_STRING
            ;
%%

int main(int argc, char *argv[]){

    if((yyin = fopen(*(argv + 1),"rt")) == NULL){

        printf("Error al intentar abrir el archivo: ' %s '\n",*(argv + 1));
        return 1;

    }

    yyparse();    
    fclose(yyin);
    puts("\n");
    return 0;

}

int yyerror(char *descripcion_error){

    printf("\n%s\n",descripcion_error);
    exit(1);

}