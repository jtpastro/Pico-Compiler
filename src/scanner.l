 /**
  * \file scanner.l
  * Arquivo de entrada para o (F)lex. Neste arquivo definimos as expressoes regulares
  * dos tokens para gerar um analisador lexical.
  * \author Cassiano Rocha Kuplich
  * \author Jonata Teixeira Pastro
  * \author Leandro Bombassaro
  */

 /* Secao das declaracoes */

%option noyywrap
  /* Sera copiado no .c final */
%{
    #include <stdlib.h>
    #include <string.h>
   
    /** Inclui a definicao dos tokens */
    #include "tokens.h"

    int VAL_INT;
    double VAL_DOUBLE;
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
[ \t\n]+                    { printf("SPACE"); }
[a-z_]({letra}|{digito}|_)* { printf("%s", yytext); return( IDF ); }
[A-Z](_|[A-Z]|{digito})*    { printf("%s", yytext); return( CONST ); }
\"({letra}|{digito}|" ")*\" { printf("%s", yytext); return( STR_LIT ); }
{digito}+                   { VAL_INT = atoi(yytext); return( INT_LIT ); }
{digito}*\.{digito}+([eE][+-]?{digito}+)? { VAL_DOUBLE = atof(yytext); return( F_LIT ); }

  /* Tratamento dos erros lexicais: a regra seguinte pega tudo o que nao
   * fechou com uma Regexp anterior.
   */
. { printf("Erro lexical - caractere nao reconhecido: %c.\n", yytext[0]);
    exit(-1); }
%%
 /* Secao dos  Procedimentos auxiliares */

 /*
  * Para redefinir a entrada padrao do LEX. 
  * Redefinir a variavel 'yyin' para ler de um arquivo. Por exemplo:
  *  yyin = fopen("Meu_programa.c", "r");
  * ira mandar ler o programa a ser compilado pelo analisador lexical
  * em 'Meu_programa.c'.
  * O default eh ler da entrada standard (o teclado).
  */


extern FILE *yyin;

 /**
  * main
  * \brief Função principal do analisador lexical.
  * Redefine a entrada padrao do (F)lex para ler de um arquivo.
  * \param[in] argc Conta o numero de parametros da linha de comando.
  * \param[in] argv Vetor de parametros, onde o segundo elemento eh o nome do arquivo de entrada.
  * \return Nada.
  */
int main(int argc, char* argv[]) {
   int token;
   if (argc != 2) {
     printf("uso: %s <input_file>. Try again!\n", argv[0]);
     exit(-1);
   }
   yyin = fopen(argv[1], "r");
   if (!yyin) {
     printf("Uso: %s <input_file>. Could not find %s. Try again!\n", 
         argv[0], argv[1]);
     exit(-1);
   }
  /* agora a entrada padrao eh o arquivo especificado como 1o argumento ao
   * executavel (argv[1]).
   * Soh chama o analisador lexical default fornecido pelo output do Flex:
   */
  while (token=yylex()) { 
     /* neste laco, obtem-se "palavra por palavra" os tokens reconhecidos
      * pelo scanner fornecido pelo Lex. Poderia ser feita a analise
      * sintatica... Sera feito depois!
      */
     printf("Meu analisador lexical reconheceu o token %d\n", token);
  }
  return(0);
}
