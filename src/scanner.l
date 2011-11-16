 /**
  * \file scanner.l
  * Arquivo de entrada para o (F)lex. Neste arquivo definimos as expressoes regulares
  * dos tokens para gerar um analisador lexical.
  * \author Cassiano Rocha Kuplich
  * \author Jonata Teixeira Pastro
  * \author Leandro Bombassaro
  */

 /* Secao das declaracoes */

%option yylineno

%option noyywrap
  /* Sera copiado no .c final */
%{
    #include <stdlib.h>
    #include <string.h>
   
    /** Inclui a definicao dos tokens */
    #include "tokens.h"
    #define YY_USER_ACTION yylloc.first_line = yylineno;
%}

  /* Definicoes regulares */
digito     [0-9]
letra      [A-Za-z]

%%

 /* Secao das Regras de traducao */
 /** Expressoes regulares dos Tokens simples. */

int    { return( INT ); }
double { return( DOUBLE ); }
real   { return( REAL ); }
char   { return( CHAR ); }
string { return( STRING ); }
"*"    { return( '*' ); }
"+"    { return( '+' ); }
"-"    { return( '-' ); }
"/"    { return( '/' ); }
","    { return( ',' ); }
";"    { return( ';' ); }
":"    { return( ':' ); }
"'"    { return( QUOTE ); }
"("    { return( '(' ); }
")"    { return( ')' ); }
"["    { return( '[' ); }
"]"    { return( ']' ); }
"{"    { return( '{' ); }
"}"    { return( '}' ); }
"<"    { return( '<' ); }
">"    { return( '>' ); }
"="    { return( '=' ); }
"<="   { return( LE ); }
">="   { return( GE ); }
"=="   { return( EQ ); }
"<>"   { return( NE ); }
"&"    { return( AND ); }
"|"    { return( OR ); }
"!"    { return( NOT ); }
if     { return( IF ); }
then   { return( THEN ); }
else   { return( ELSE ); }
for    { return( FOR ); }
next   { return( NEXT ); }
while  { return( WHILE ); }
end    { return( END ); }
true   { return( TRUE ); }
false  { return( FALSE ); }

 /** Expressoes regulares dos outros tokens. */
[ \t\n]+
[a-z_]({letra}|{digito}|_)* {
                                yylval.cadeia = (char *) malloc((strlen(yytext)+1)*sizeof(char));
                                strcpy(yylval.cadeia, yytext);
                                return( IDF );
                            }
[A-Z](_|[A-Z]|{digito})*    { return( CONST ); }
\"({letra}|{digito}|" ")*\" { return( STR_LIT ); }
{digito}+                   {
                                yylval.cadeia = (char *) malloc((strlen(yytext)+1)*sizeof(char));
                                strcpy(yylval.cadeia, yytext);
                                return( INT_LIT );
                            }
{digito}*\.{digito}+([eE][+-]?{digito}+)? {
                                              yylval.cadeia = (char *) malloc((strlen(yytext)+1)*sizeof(char));
                                              strcpy(yylval.cadeia, yytext);
                                              return( F_LIT );
                                          }

  /* Tratamento dos erros lexicais: a regra seguinte pega tudo o que nao
   * fechou com uma Regexp anterior.
   */
. { printf("Erro lexical - caractere nao reconhecido: %c.\n", yytext[0]);
    exit(-1); }
%%
 /* Secao dos  Procedimentos auxiliares */

