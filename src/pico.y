%error-verbose
%{
  /* Aqui, pode-se inserir qualquer codigo C necessario ah compilacao
   * final do parser. Sera copiado tal como esta no inicio do y.tab.c
   * gerado por Yacc.
   */
  #include <stdio.h>
  #include <stdlib.h>
  #include "node.h"

%}

%union {
  char* cadeia;
  struct _node * no;
}


%token INT
%token DOUBLE
%token REAL
%token CHAR
%token STRING
%token QUOTE
%token LE
%token GE
%token EQ
%token NE
%token AND
%token OR
%token NOT
%token IF
%token THEN
%token ELSE
%token FOR
%token NEXT
%token WHILE
%token END
%token TRUE
%token FALSE

%token PRINTF

%token<cadeia> IDF
%token CONST
%token STR_LIT
%token<cadeia> INT_LIT
%token<cadeia> F_LIT

%left OR
%left AND
%left NOT
%left '+' '-'
%left '*' '/'

%type<no> code
%type<no> declaracoes
%type<no> declaracao
%type<no> listadeclaracao
%type<no> tipo
%type<no> tipounico
%type<no> tipolista
%type<no> listadupla
%type<no> acoes
%type<no> comando
%type<no> lvalue
%type<no> listaexpr
%type<no> expr
%type<no> chamaproc
%type<no> enunciado
%type<no> fiminstcontrole
%type<no> expbool


%start code

%%
code: declaracoes acoes {
                            $$ = create_node(@1.first_line, code_node, NULL, $1, $2, NULL);
                            syntax_tree = $$;
                        }
    | acoes { $$ = $1; syntax_tree = $$; }
    ;

declaracoes: declaracao ';' {
                                Node *semiColonNode = create_node(@2.first_line, semicolon_node, ";", NULL);
                                $$ = create_node(@1.first_line, declaracoes_node, NULL, $1, semiColonNode, NULL);
                            }
           | declaracoes declaracao ';' {
                                            Node *semiColonNode = create_node(@3.first_line, semicolon_node, ";", NULL);
                                            $$ = create_node(@1.first_line, declaracoes_node, NULL, $1, $2, semiColonNode, NULL);
                                        }
           ;

declaracao: tipo ':' listadeclaracao {
                                         Node *colonNode = create_node(@2.first_line, colon_node, ":", NULL);
                                         $$ = create_node(@1.first_line, declaracao_node, NULL, $1, colonNode, $3, NULL);
                                     }
          ;

listadeclaracao: IDF { $$ = create_node(@1.first_line, idf_node, $1, NULL); }
               | IDF ',' listadeclaracao {
                                             Node *idfNode = create_node(@1.first_line, idf_node, $1, NULL);
                                             Node *commaNode = create_node(@2.first_line, comma_node, ",", NULL);
                                             $$ = create_node(@1.first_line, listadeclaracao_node, NULL, idfNode, commaNode, $3, NULL);
                                         }
               ;

tipo: tipounico { $$ = $1; }
    | tipolista { $$ = $1; }
    ;

tipounico: INT { $$ = create_node(@1.first_line, int_node, "int", NULL); }
         | DOUBLE { $$ = create_node(@1.first_line, double_node, "double", NULL); }
         | REAL { $$ = create_node(@1.first_line, real_node, "real", NULL); }
         | CHAR { $$ = create_node(@1.first_line, char_node, "char", NULL); }
         ;

tipolista: INT '(' listadupla ')' {
                                      Node *intNode = create_node(@1.first_line, int_node, "int", NULL);
                                      Node *lParNode = create_node(@2.first_line, l_par_node, "(", NULL);
                                      Node *rParNode = create_node(@4.first_line, r_par_node, ")", NULL);
                                      $$ = create_node(@1.first_line, tipolista_node, NULL, intNode, lParNode, $3, rParNode, NULL);
                                  }
         | DOUBLE '(' listadupla ')' {
                                         Node *doubleNode = create_node(@1.first_line, double_node, "double", NULL);
                                         Node *lParNode = create_node(@2.first_line, l_par_node, "(", NULL);
                                         Node *rParNode = create_node(@4.first_line, r_par_node, ")", NULL);
                                         $$ = create_node(@1.first_line, tipolista_node, NULL, doubleNode, lParNode, $3, rParNode, NULL);
                                     }
         | REAL '(' listadupla ')' {
                                       Node *realNode = create_node(@1.first_line, real_node, "real", NULL);
                                       Node *lParNode = create_node(@2.first_line, l_par_node, "(", NULL);
                                       Node *rParNode = create_node(@4.first_line, r_par_node, ")", NULL);
                                       $$ = create_node(@1.first_line, tipolista_node, NULL, realNode, lParNode, $3, rParNode, NULL);
                                   }
         | CHAR '(' listadupla ')' {
                                       Node *charNode = create_node(@1.first_line, char_node, "char", NULL);
                                       Node *lParNode = create_node(@2.first_line, l_par_node, "(", NULL);
                                       Node *rParNode = create_node(@4.first_line, r_par_node, ")", NULL);
                                       $$ = create_node(@1.first_line, tipolista_node, NULL, charNode, lParNode, $3, rParNode, NULL);
                                   }
         ;

listadupla: INT_LIT ':' INT_LIT {
                                    Node *intLitNode1 = create_node(@1.first_line, int_lit_node, $1, NULL);
                                    Node *colonNode = create_node(@2.first_line, colon_node, ":", NULL);
                                    Node *intLitNode2 = create_node(@3.first_line, int_lit_node, $3, NULL);
                                    $$ = create_node(@1.first_line, listadupla_node, NULL, intLitNode1, colonNode, intLitNode2, NULL);
                                }
          | INT_LIT ':' INT_LIT ',' listadupla {
                                                   Node *intLitNode1 = create_node(@1.first_line, int_lit_node, $1, NULL);
                                                   Node *colonNode = create_node(@2.first_line, colon_node, ":", NULL);
                                                   Node *intLitNode2 = create_node(@3.first_line, int_lit_node, $3, NULL);
                                                   Node *commaNode = create_node(@4.first_line, comma_node, ",", NULL);
                                                   $$ = create_node(@1.first_line, listadupla_node, NULL, intLitNode1, colonNode, intLitNode2,
                                                       commaNode, $5, NULL);
                                               }
          ;

acoes: comando ';' {
                       Node *semiColonNode = create_node(@2.first_line, semicolon_node, ";", NULL);
                       $$ = create_node(@1.first_line, acoes_node, NULL, $1, semiColonNode, NULL);
                   }
    | comando ';' acoes {
                            Node *semiColonNode = create_node(@2.first_line, semicolon_node, ";", NULL);
                            $$ = create_node(@1.first_line, acoes_node, NULL, $1, semiColonNode, $3, NULL);
                        }
    ;

comando: lvalue '=' expr {
                             Node *equalsNode = create_node(@2.first_line, equals_node, "=", NULL);
                             $$ = create_node(@1.first_line, comando_node, NULL, $1, equalsNode, $3, NULL);
                         }
       | enunciado { $$ = $1;}
       ;

lvalue: IDF { $$ = create_node(@1.first_line, idf_node, $1, NULL); }
      | IDF '[' listaexpr ']' {
                                  Node *idfNode = create_node(@1.first_line, idf_node, $1, NULL);
                                  Node *lSqrBracketNode = create_node(@2.first_line, l_sqr_bracket_node, "[", NULL);
                                  Node *rSqrBracketNode = create_node(@4.first_line, r_sqr_bracket_node, "]", NULL);
                                  $$ = create_node(@1.first_line, lvalue_node, NULL, idfNode, lSqrBracketNode, $3, rSqrBracketNode, NULL);
                              }
      ;

listaexpr: expr { $$ = $1; }
	   | expr ',' listaexpr {
	                            Node *commaNode = create_node(@2.first_line, comma_node, ",", NULL);
	                            $$ = create_node(@1.first_line, listaexpr_node, NULL, $1, commaNode, $3, NULL);
	                        }
	   ;

expr: expr '+' expr {
                        Node *plusNode = create_node(@2.first_line, plus_node, "+", NULL);
                        $$ = create_node(@1.first_line, expr_node, NULL, $1, plusNode, $3, NULL);
                    }
    | expr '-' expr {
                        Node *minusNode = create_node(@2.first_line, minus_node, "-", NULL);
                        $$ = create_node(@1.first_line, expr_node, NULL, $1, minusNode, $3, NULL);
                    }
    | expr '*' expr {
                        Node *asteriskNode = create_node(@2.first_line, asterisk_node, "*", NULL);
                        $$ = create_node(@1.first_line, expr_node, NULL, $1, asteriskNode, $3, NULL);
                    }
    | expr '/' expr {
                        Node *slashNode = create_node(@2.first_line, asterisk_node, "/", NULL);
                        $$ = create_node(@1.first_line, expr_node, NULL, $1, slashNode, $3, NULL);
                    }
    | '(' expr ')' {
                       Node *lParNode = create_node(@1.first_line, l_par_node, "(", NULL);
                       Node *rParNode = create_node(@3.first_line, r_par_node, ")", NULL);
                       $$ = create_node(@1.first_line, expr_node, NULL, lParNode, $2, rParNode, NULL);
                   }
    | INT_LIT  { $$ = create_node(@1.first_line, int_lit_node, $1, NULL); } 
    | F_LIT { $$ = create_node(@1.first_line, f_lit_node, $1, NULL); }
    | lvalue { $$ = $1; }
    | chamaproc { $$ = $1; }
    ;

chamaproc: IDF '(' listaexpr ')' {
                                     Node *idfNode = create_node(@1.first_line, idf_node, $1, NULL);
                                     Node *lParNode = create_node(@2.first_line, l_par_node, "(", NULL);
                                     Node *rParNode = create_node(@4.first_line, r_par_node, ")", NULL);
                                     $$ = create_node(@1.first_line, chamaproc_node, NULL, idfNode, lParNode, $3, rParNode, NULL);
                                 }
         ;

enunciado: expr { $$ = $1; }
         | IF '(' expbool ')' THEN acoes fiminstcontrole {
                                                             Node *ifNode = create_node(@1.first_line, if_node, "if", NULL);
                                                             Node *lParNode = create_node(@2.first_line, l_par_node, "(", NULL);
                                                             Node *rParNode = create_node(@4.first_line, r_par_node, ")", NULL);
                                                             Node *thenNode = create_node(@5.first_line, then_node, "then", NULL);
                                                             $$ = create_node(@1.first_line, enunciado_node, NULL, ifNode, lParNode, $3,
                                                                 rParNode, thenNode, $6, $7, NULL);
                                                         }
         | WHILE '(' expbool ')' '{' acoes '}' {
                                                   Node *whileNode = create_node(@1.first_line, while_node, "while", NULL);
                                                   Node *lParNode = create_node(@2.first_line, l_par_node, "(", NULL);
                                                   Node *rParNode = create_node(@4.first_line, r_par_node, ")", NULL);
                                                   Node *lBraceNode = create_node(@5.first_line, l_brace_node, "{", NULL);
                                                   Node *rBraceNode = create_node(@7.first_line, r_brace_node, "}", NULL);
                                                   $$ = create_node(@1.first_line, enunciado_node, NULL, whileNode, lParNode, $3, rParNode,
                                                       lBraceNode, $6, rBraceNode, NULL);
                                               }
         | PRINTF '(' expr ')' {
                                   Node *printNode = create_node(@1.first_line, print_node, "print", NULL);
                                   Node *lParNode = create_node(@2.first_line, l_par_node, "(", NULL);
                                   Node *rParNode = create_node(@4.first_line, r_par_node, ")", NULL);
                                   $$ = create_node(@1.first_line, enunciado_node, NULL, printNode, lParNode, $3, rParNode, NULL);
                               }
         ;

fiminstcontrole: END { $$ = create_node(@1.first_line, end_node, "end", NULL); }
               | ELSE acoes END {
                                    Node *elseNode = create_node(@1.first_line, else_node, "else", NULL);
                                    Node *endNode = create_node(@3.first_line, end_node, "end", NULL);
                                    $$ = create_node(@1.first_line, fiminstcontrole_node, NULL, elseNode, $2, endNode, NULL);
                                }
               ;

expbool: TRUE { $$ = create_node(@1.first_line, true_node, "true", NULL); }
       | FALSE { $$ = create_node(@1.first_line, false_node, "false", NULL); }
       | '(' expbool ')' {
                             Node *lParNode = create_node(@1.first_line, l_par_node, "(", NULL);
                             Node *rParNode = create_node(@3.first_line, r_par_node, ")", NULL);
                             $$ = create_node(@1.first_line, expbool_node, NULL, lParNode, $2, rParNode, NULL);
                         }
       | expbool AND expbool {
                                 Node *andNode = create_node(@2.first_line, and_node, "&", NULL);
                                 $$ = create_node(@1.first_line, expbool_node, NULL, $1, andNode, $3, NULL);
                             }
       | expbool OR expbool {
                                Node *orNode = create_node(@2.first_line, or_node, "|", NULL);
                                $$ = create_node(@1.first_line, expbool_node, NULL, $1, orNode, $3, NULL);
                            }
       | NOT expbool {
                         Node *notNode = create_node(@1.first_line, not_node, "!", NULL);
                         $$ = create_node(@1.first_line, expbool_node, NULL, notNode, $2, NULL);
                     }
       | expr '>' expr {
                           Node *greaterThanNode = create_node(@2.first_line, greater_than_node, ">", NULL);
                           $$ = create_node(@1.first_line, expbool_node, NULL, $1, greaterThanNode, $3, NULL);
                       }
       | expr '<' expr {
                           Node *lessThanNode = create_node(@2.first_line, less_than_node, "<", NULL);
                           $$ = create_node(@1.first_line, expbool_node, NULL, $1, lessThanNode, $3, NULL);
                       }
       | expr LE expr {
                          Node *lessOrEqualNode = create_node(@2.first_line, le_node, "<=", NULL);
                          $$ = create_node(@1.first_line, expbool_node, NULL, $1, lessOrEqualNode, $3, NULL);
                      }
       | expr GE expr {
                          Node *greaterOrEqualNode = create_node(@2.first_line, ge_node, ">=", NULL);
                          $$ = create_node(@1.first_line, expbool_node, NULL, $1, greaterOrEqualNode, $3, NULL);
                      }
       | expr EQ expr {
                          Node *equalsNode = create_node(@2.first_line, eq_node, "==", NULL);
                          $$ = create_node(@1.first_line, expbool_node, NULL, $1, equalsNode, $3, NULL);
                      }
       | expr NE expr {
                          Node *notEqualNode = create_node(@2.first_line, ne_node, "<>", NULL);
                          $$ = create_node(@1.first_line, expbool_node, NULL, $1, notEqualNode, $3, NULL);
                      }
       ;
%%
 /* A partir daqui, insere-se qlqer codigo C necessario.
  */
