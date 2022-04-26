/* Seccion de definiciones */
%{
/* Includes */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include "y.tab.h"

/* Defines */
#define MAX_VAL_CONST_INT_16 65535
#define MAX_VAL_CONST_FLOAT_32 INT_MAX
#define MAX_LONGITUD_COMENTARIO 120
#define MAX_LONGITUD_CONST_STRING 30
#define MAX_LONGITUD_IDENTIFICADOR 10

/* Tabla de simbolos */
FILE  *yyin;
int num_str = 0;
int flag_primera_entrada_ts = 0;
char aux_str[8];


/* Prototipos */
int verificar_rango_int(void);
int verificar_rango_float(void);
int verificar_longitud(int max_longitud);
void almacenar_en_tabla_de_simbolos (char *, char *, char *);
%}


/*Seccion de conjuntos y regex */

/* Opciones */
/* Para solo leer un archivo de entrada */
%option noyywrap
/* Para obtener el numero de linea que contiene el error */
%option yylineno

/* Tokens */

/* Palabras reservadas */
PALABRA_RESERVADA_IF        "if"
PALABRA_RESERVADA_INT       "int"
PALABRA_RESERVADA_FLOAT     "float"
PALABRA_RESERVADA_STRING    "string"
PALABRA_RESERVADA_WHILE     "while"
PALABRA_RESERVADA_READ      "read"
PALABRA_RESERVADA_WRITE     "write"
PALABRA_RESERVADA_DECVAR    "DECVAR"
PALABRA_RESERVADA_ENDDEC    "ENDDEC"
PALABRA_RESERVADA_ENDIF     "endif"
PALABRA_RESERVADA_ENDWHILE  "endwhile"
PALABRA_RESERVADA_AVG       "avg"
PALABRA_RESERVADA_BETWEEN   "between"

/* Operadores */
OP_ASIGNACION       ":="
OP_OR               "||"
OP_AND              "&&"
OP_NOT              "!"
OP_MAYOR            ">"
OP_MENOR            "<"
OP_SUMA             "+"
OP_RESTA            "-"
OP_DIVISION         "/"
OP_MULTIPLICACION   "*"

/* Generales */
LETRA           [a-zA-Z]
DIGITO_CON_CERO [0-9]
DIGITO_SIN_CERO [1-9]
COMA            ","
PUNTO           [.]
PUNTO_Y_COMA    ";"
DOS_PUNTOS      [:]
PARENTESIS_A    [(]
PARENTESIS_C    [)]
CORCHETE_A      "["
CORCHETE_C      "]"
GUION_BAJO      "_"
ESPACIO         [" "]

/* Otro */
INICIO_COMENTARIO   "-/"
FIN_COMENTARIO      "/-"
COMENTARIO          {INICIO_COMENTARIO}.*[^\n]{FIN_COMENTARIO}
IDENTIFICADOR       {LETRA}|{LETRA}({LETRA}|{DIGITO_CON_CERO}|{GUION_BAJO})*

/* Constantes */
CONST_INT       0|{DIGITO_SIN_CERO}{DIGITO_CON_CERO}*
CONST_FLOAT     0{PUNTO}{DIGITO_CON_CERO}*{DIGITO_SIN_CERO}{DIGITO_CON_CERO}*|{DIGITO_SIN_CERO}{DIGITO_CON_CERO}*{PUNTO}{DIGITO_CON_CERO}*{DIGITO_SIN_CERO}{DIGITO_CON_CERO}*
CONST_STRING    \".*[^\n]\"

/*Seccion de reglas */
%%
{PALABRA_RESERVADA_IF} 			{return PALABRA_RESERVADA_IF;}
{PALABRA_RESERVADA_INT} 		{return PALABRA_RESERVADA_INT;}
{PALABRA_RESERVADA_FLOAT} 		{return PALABRA_RESERVADA_FLOAT;}
{PALABRA_RESERVADA_STRING}      {return PALABRA_RESERVADA_STRING;}
{PALABRA_RESERVADA_WHILE}       {return PALABRA_RESERVADA_WHILE;}
{PALABRA_RESERVADA_READ}        {return PALABRA_RESERVADA_READ;}
{PALABRA_RESERVADA_WRITE}       {return PALABRA_RESERVADA_WRITE;}
{PALABRA_RESERVADA_DECVAR}      {return PALABRA_RESERVADA_DECVAR;}
{PALABRA_RESERVADA_ENDDEC}      {return PALABRA_RESERVADA_ENDDEC;}
{PALABRA_RESERVADA_ENDIF}       {return PALABRA_RESERVADA_ENDIF;}
{PALABRA_RESERVADA_ENDWHILE}    {return PALABRA_RESERVADA_ENDWHILE;}
{PALABRA_RESERVADA_AVG}         {return PALABRA_RESERVADA_AVG;}
{PALABRA_RESERVADA_BETWEEN}     {return PALABRA_RESERVADA_BETWEEN;}

{OP_ASIGNACION} 			    {return OP_ASIGNACION;}
{OP_OR}                         {return OP_OR;}
{OP_AND}                        {return OP_AND;}
{OP_NOT}                        {return OP_NOT;}
{OP_MAYOR} 				        {return OP_MAYOR;}
{OP_MENOR} 				        {return OP_MENOR;}
{OP_SUMA} 				        {return OP_SUMA;}
{OP_RESTA}                      {return OP_RESTA;}
{OP_DIVISION} 			        {return OP_DIVISION;}
{OP_MULTIPLICACION}             {return OP_MULTIPLICACION;}

{COMA}                          {return COMA;}
{PUNTO} 						{return PUNTO;}
{PUNTO_Y_COMA}                  {return PUNTO_Y_COMA;}
{DOS_PUNTOS}                    {return DOS_PUNTOS;}
{PARENTESIS_A}                  {return PARENTESIS_A;}
{PARENTESIS_C}                  {return PARENTESIS_C;}
{CORCHETE_A}                    {return CORCHETE_A;}
{CORCHETE_C}                    {return CORCHETE_C;}
{ESPACIO}

{COMENTARIO}                    {if(verificar_longitud(MAX_LONGITUD_COMENTARIO)){ printf("- Linea %d: El comentario supera la longitud maxima permitida ( max: %d ).\n",yylineno,MAX_LONGITUD_COMENTARIO); }}
{IDENTIFICADOR}                 {if(verificar_longitud(MAX_LONGITUD_IDENTIFICADOR)){ printf("- Linea %d: El nombre del identificador supera la longitud maxima permitida ( max: %d ).\n",yylineno,MAX_LONGITUD_IDENTIFICADOR); }; return IDENTIFICADOR;}

{CONST_STRING}		            { if(verificar_longitud(MAX_LONGITUD_CONST_STRING)){ printf("- Linea %d: Constante string supera la longitud maxima permitida ( max: %d ).\n",yylineno,MAX_LONGITUD_CONST_STRING); exit(1); };
                                 sprintf(aux_str, "_cte_s%d", num_str); yylval.str_val = aux_str; almacenar_en_tabla_de_simbolos ("", "string", yytext); return CONST_STRING; }
{CONST_INT}+	                { if(verificar_rango_int()){ printf("- Linea %d: Constante int fuera de rango.\n",yylineno); exit(1); };
                                   yylval.intval = atoi(yytext) ; almacenar_en_tabla_de_simbolos (yytext, "int", yytext);return CONST_INT; }
{CONST_FLOAT}+	                { if(verificar_rango_float()){ printf("- Linea %d: Constante float fuera de rango.\n",yylineno); exit(1); } yylval.floatval = atof(yytext) ; almacenar_en_tabla_de_simbolos (yytext, "float", yytext);return CONST_FLOAT; }

"\n"
"\t"
. 								{printf("- Linea %d: Error lexico, caracter no reconocido %s\n",yylineno,yytext); exit(1);} /* Es como el default en un switch */
%%

/*Seccion de codigo */

/* 
    Funcion que verifica si una variable entera se encuentra dentro del rango ( minimo y maximo ) permitido
    Retorna cero en caso de exito, de lo contrario uno
*/
int verificar_rango_int(void){

    int valor;

    valor = atoi(yytext);

    if(valor < 0  || valor > MAX_VAL_CONST_INT_16){
        return 1;
    }

    return 0;

}

/* 
    Funcion que verifica si una variable float se encuentra dentro del rango ( minimo y maximo ) permitido
    Retorna cero en caso de exito, de lo contrario uno
*/
int verificar_rango_float(void){

    float valor;

    valor = atof(yytext);

    if(valor < 0 || valor > MAX_VAL_CONST_FLOAT_32){
        return 1;
    }

    return 0;

}

/* 
    Funcion que verifica si la longitud de una variable ( ya sea const_string, identificador ) esta dentro del valor permitido
    Parametro: Recibe la longitud maxima que puede tener el tipo de variable que se esta analizando 
    Retorna cero en caso de exito, de lo contrario uno
*/
int verificar_longitud(int max_longitud){

    int longitud;

    // Tengo que restar 2 porque yytext incluye las comillas que encierran a la cadena
    longitud = strlen(yytext) - 2;

    if(longitud > max_longitud){
        return 1;
    }

    return 0;

}

/* 
    Funcion que se encarga de almacenar datos en la tabla de simbolos (Nombre, Tipo de dato, Valor, Longitud)
    Parametros: nombre, tipo y valor
*/
void almacenar_en_tabla_de_simbolos(char *nombre, char *tipo, char *valor){

    FILE    *pf, *pfaux;
	char	strline[100], straux[100], modo[3];
	
    /* Abro o creo el archivo txt */
	if (flag_primera_entrada_ts == 0) {
		sprintf(modo, "wt");
        pf = fopen("ts.txt", modo);
        fputs("NOMBRE           TIPO                VALOR                       LONGITUD\n",pf);
		flag_primera_entrada_ts = 1;
	}
	else {
		sprintf(modo, "at");
        pf = fopen("ts.txt", modo);
	}
	
   /* Completo la tabla */
    if ( strcmp(tipo,"string") == 0)
    {
        //El -2 en strlen es porque sino cuenta las comillas que encierran la cadena ( ej: strlen("Hola") retorna 6, pero deberia ser 4 )
        sprintf(straux, "_cte_s%-5d|%-20s|%-30s|%-10d\n", num_str, tipo, valor, strlen(valor) - 2);
        num_str++;
    }
	else
	{
		sprintf(straux, "_%-10s|%-20s|%-30s|\n", nombre, tipo, valor);
	}

    pfaux = fopen("ts.txt", "rt");
    while(fgets(strline,99,pfaux) != NULL)
    {
        if (strcmp(strline,straux) == 0)
        {
            fclose(pf);
            fclose(pfaux);
            return;
        }
    }
    
    fputs(straux,pf);
    fclose(pfaux);
    fclose(pf);
}
