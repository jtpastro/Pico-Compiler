%error-verbose
%{
    /* Aqui, pode-se inserir qualquer codigo C necessario ah compilacao
     * final do parser. Sera copiado tal como esta no inicio do y.tab.c
     * gerado por Yacc.
     */
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "node.h"
    #include "symbol_table.h"
    #include "lista.h"

    #define UNDEFINED_SYMBOL_ERROR -21
    #define DEFINED_SYMBOL_ERROR   -22
    #define ARRAY_INDEX_ERROR      -23
    #define ARRAY_DIMENSION_ERROR  -24

    symbol_t *s_table;
    int deslocVar = 0;
    int deslocTmp = 0;
    
    int tmpNum = 0;
    char* new_tmp();
    char* c(char *arrayName);
    char* width(char *arrayName);
    char* limit(char *arrayName, int dim);
%}

%union {
  char *cadeia;
  struct _node *no;
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
                            Code_attrib *attrib, *declAttrib, *acoesAttrib;
                            
                            $$ = create_node(@1.first_line, code_node, NULL, $1, $2, NULL);
                            
                            $$->attribute = (Code_attrib *) malloc(sizeof(Code_attrib));
                            attrib = (Code_attrib *) $$->attribute;
                            declAttrib = $1->attribute;
                            acoesAttrib = $2->attribute;
                            
                            attrib->varsTotalSize = deslocVar;
                            attrib->tmpsTotalSize = deslocTmp;
                            attrib->local = NULL;
                            attrib->code = acoesAttrib->code;
                            
                            syntax_tree = $$;
                        }
    | acoes { $$ = $1; syntax_tree = $$; }
    ;

declaracoes: declaracao ';' {
                                Node *semiColonNode = create_node(@2.first_line, semicolon_node, ";", NULL);
                                Code_attrib *attrib, *declAttrib;
                                
                                $$ = create_node(@1.first_line, declaracoes_node, NULL, $1, semiColonNode, NULL);
                                
                                $$->attribute = (Code_attrib *) malloc(sizeof(Code_attrib));
                                attrib = (Code_attrib *) $$->attribute;
                                declAttrib = $1->attribute;
                                
                                attrib->local = NULL;
                                attrib->code = NULL;
                            }
           | declaracoes declaracao ';' {
                                            Node *semiColonNode = create_node(@3.first_line, semicolon_node, ";", NULL);
                                            Code_attrib *attrib, *decl1, *decl2;
                                            
                                            $$ = create_node(@1.first_line, declaracoes_node, NULL, $1, $2, semiColonNode, NULL);
                                            
                                            $$->attribute = (Code_attrib *) malloc(sizeof(Code_attrib));
                                            attrib = (Code_attrib *) $$->attribute;
                                            decl1 = $1->attribute;
                                            decl2 = $2->attribute;
                                            
                                            attrib->local = NULL;
                                            attrib->code = NULL;
                                        }
           ;

declaracao: tipo ':' listadeclaracao {
                                         Node *colonNode = create_node(@2.first_line, colon_node, ":", NULL);
                                         Code_attrib *attrib;
                                         Type_attrib *typeAttrib;
                                         Idf_attrib *currentIdf;
                                         int type, size;
                                         
                                         $$ = create_node(@1.first_line, declaracao_node, NULL, $1, colonNode, $3, NULL);
                                         
                                         $$->attribute = (Code_attrib *) malloc(sizeof(Code_attrib));
                                         attrib = (Code_attrib *) $$->attribute;
                                         attrib->local = NULL;
                                         attrib->code = NULL;
                                         
                                         typeAttrib = (Type_attrib *) $1->attribute;
                                         type = typeAttrib->type;
                                         size = typeAttrib->size;

                                         currentIdf = $3->attribute;
                                         while (currentIdf != NULL) {
                                             entry_t *entry = (entry_t *) malloc(sizeof(entry_t));
                                             entry->type = type;
                                             entry->size = size;
                                             entry->desloc = deslocVar;
                                             entry->name = (char *) malloc((strlen(currentIdf->lexeme)+1)*sizeof(char));
                                             strcpy(entry->name, currentIdf->lexeme);
                                             
                                             if (type >= int_array_type && type <= char_array_type) {
                                                 array_info *arrInfo;
                                                 Dim_info *dimInfo;
                                                 int c, ndim;
                                                 
                                                 arrInfo = (array_info *) malloc(sizeof(array_info));
                                                 arrInfo->width = typeAttrib->width;
                                                 dimInfo = typeAttrib->dims;
                                                 c = dimInfo->linf;
                                                 ndim = 1;
                                                 dimInfo = dimInfo->next;
                                                 while (dimInfo != NULL) {
                                                     c = c * dimInfo->n + dimInfo->linf;
                                                     ndim = ndim + 1;
                                                     dimInfo = dimInfo->next;
                                                 }
                                                 c = - c * arrInfo->width;
                                                 arrInfo->c = c;
                                                 arrInfo->dims = typeAttrib->dims;
                                                 arrInfo->ndim = ndim;
                                                 entry->extra = arrInfo;
                                             }
                                             
                                             if (insert(s_table, entry) == 0) {
                                                 deslocVar = deslocVar + size;
                                                 currentIdf = currentIdf->next;
                                             } else {
                                                 printf("ERRO. A variável %s ja foi declarada.", entry->name);
                                                 return DEFINED_SYMBOL_ERROR;
                                             }
                                         }
                                     }
          ;

listadeclaracao: IDF {
                         Idf_attrib *attrib;
                         
                         $$ = create_node(@1.first_line, idf_node, $1, NULL);
                         
                         $$->attribute = (Idf_attrib *) malloc(sizeof(Idf_attrib));
                         attrib = (Idf_attrib *) $$->attribute;
                         
                         attrib->lexeme = (char *) malloc((strlen($1)+1)*sizeof(char));
                         strcpy(attrib->lexeme, $1);
                         attrib->next = NULL;
                     }
               | IDF ',' listadeclaracao {
                                             Node *idfNode = create_node(@1.first_line, idf_node, $1, NULL);
                                             Node *commaNode = create_node(@2.first_line, comma_node, ",", NULL);
                                             Idf_attrib *attrib;
                                             
                                             $$ = create_node(@1.first_line, listadeclaracao_node, NULL, idfNode, commaNode, $3, NULL);
                                             
                                             $$->attribute = (Idf_attrib *) malloc(sizeof(Idf_attrib));
                                             attrib = (Idf_attrib *) $$->attribute;
                                             
                                             attrib->lexeme = (char *) malloc((strlen($1)+1)*sizeof(char));
                                             strcpy(attrib->lexeme, $1);
                                             attrib->next = $3->attribute;
                                         }
               ;

tipo: tipounico { $$ = $1; }
    | tipolista { $$ = $1; }
    ;

tipounico: INT {
                   Type_attrib *attrib;
                   
                   $$ = create_node(@1.first_line, int_node, "int", NULL);
                   
                   $$->attribute = (Type_attrib *) malloc(sizeof(Type_attrib));
                   attrib = (Type_attrib *) $$->attribute;
                   
                   attrib->type = int_type;
                   attrib->size = int_size;
               }
         | DOUBLE { 
                      Type_attrib *attrib;
                      
                      $$ = create_node(@1.first_line, double_node, "double", NULL);
                      
                      $$->attribute = (Type_attrib *) malloc(sizeof(Type_attrib));
                      attrib = (Type_attrib *) $$->attribute;

                      attrib->type = double_type;
                      attrib->size = double_size;
                  }
         | REAL {
                    Type_attrib *attrib;
                    
                    $$ = create_node(@1.first_line, real_node, "real", NULL);
                    
                    $$->attribute = (Type_attrib *) malloc(sizeof(Type_attrib));
                    attrib = (Type_attrib *) $$->attribute;

                    attrib->type = real_type;
                    attrib->size = real_size;
                }
         | CHAR {
                    Type_attrib *attrib;
                    
                    $$ = create_node(@1.first_line, char_node, "char", NULL);
                    
                    $$->attribute = (Type_attrib *) malloc(sizeof(Type_attrib));
                    attrib = (Type_attrib *) $$->attribute;

                    attrib->type = char_type;
                    attrib->size = char_size;
                }
         ;

tipolista: INT '(' listadupla ')' {
                                      Node *intNode = create_node(@1.first_line, int_node, "int", NULL);
                                      Node *lParNode = create_node(@2.first_line, l_par_node, "(", NULL);
                                      Node *rParNode = create_node(@4.first_line, r_par_node, ")", NULL);
                                      Type_attrib *attrib;
                                      List_attrib *list;
                                      
                                      $$ = create_node(@1.first_line, tipolista_node, NULL, intNode, lParNode, $3, rParNode, NULL);
                                      
                                      $$->attribute = (Type_attrib *) malloc(sizeof(Type_attrib));
                                      attrib = (Type_attrib *) $$->attribute;
                                      list = $3->attribute;
                                      
                                      attrib->type = int_array_type;
                                      attrib->size = list->numElements * int_size;
                                      attrib->width = int_size;
                                      attrib->dims = list->dims;
                                  }
         | DOUBLE '(' listadupla ')' {
                                         Node *doubleNode = create_node(@1.first_line, double_node, "double", NULL);
                                         Node *lParNode = create_node(@2.first_line, l_par_node, "(", NULL);
                                         Node *rParNode = create_node(@4.first_line, r_par_node, ")", NULL);
                                         Type_attrib *attrib;
                                         List_attrib *list;
                                         
                                         $$ = create_node(@1.first_line, tipolista_node, NULL, doubleNode, lParNode, $3, rParNode, NULL);
                                         
                                         $$->attribute = (Type_attrib *) malloc(sizeof(Type_attrib));
                                         attrib = (Type_attrib *) $$->attribute;
                                         list = $3->attribute;

                                         attrib->type = double_array_type;
                                         attrib->size = list->numElements * double_size;
                                         attrib->width = double_size;
                                         attrib->dims = list->dims;
                                     }
         | REAL '(' listadupla ')' {
                                       Node *realNode = create_node(@1.first_line, real_node, "real", NULL);
                                       Node *lParNode = create_node(@2.first_line, l_par_node, "(", NULL);
                                       Node *rParNode = create_node(@4.first_line, r_par_node, ")", NULL);
                                       Type_attrib *attrib;
                                       List_attrib *list;
                                       
                                       $$ = create_node(@1.first_line, tipolista_node, NULL, realNode, lParNode, $3, rParNode, NULL);
                                       
                                       $$->attribute = (Type_attrib *) malloc(sizeof(Type_attrib));
                                       attrib = (Type_attrib *) $$->attribute;
                                       list = $3->attribute;
                                       
                                       attrib->type = real_array_type;
                                       attrib->size = list->numElements * real_size;
                                       attrib->width = real_size;
                                       attrib->dims = list->dims;
                                   }
         | CHAR '(' listadupla ')' {
                                       Node *charNode = create_node(@1.first_line, char_node, "char", NULL);
                                       Node *lParNode = create_node(@2.first_line, l_par_node, "(", NULL);
                                       Node *rParNode = create_node(@4.first_line, r_par_node, ")", NULL);
                                       Type_attrib *attrib;
                                       List_attrib *list;
                                       
                                       $$ = create_node(@1.first_line, tipolista_node, NULL, charNode, lParNode, $3, rParNode, NULL);
                                       
                                       $$->attribute = (Type_attrib *) malloc(sizeof(Type_attrib));
                                       attrib = (Type_attrib *) $$->attribute;
                                       list = $3->attribute;
                                       
                                       attrib->type = char_array_type;
                                       attrib->size = list->numElements * char_size;
                                       attrib->width = char_size;
                                       attrib->dims = list->dims;
                                   }
         ;

listadupla: INT_LIT ':' INT_LIT {
                                    Node *intLitNode1 = create_node(@1.first_line, int_lit_node, $1, NULL);
                                    Node *colonNode = create_node(@2.first_line, colon_node, ":", NULL);
                                    Node *intLitNode2 = create_node(@3.first_line, int_lit_node, $3, NULL);
                                    List_attrib *attrib;
                                    
                                    $$ = create_node(@1.first_line, listadupla_node, NULL, intLitNode1, colonNode, intLitNode2, NULL);
                                    
                                    $$->attribute = (List_attrib *) malloc(sizeof(List_attrib));
                                    attrib = (List_attrib *) $$->attribute;

                                    attrib->numElements = atoi($3) - atoi($1) + 1;
                                    if (attrib->numElements < 1) {
                                        printf("ARRAY INDEX ERROR. O limite superior eh menor que o limite inferior.");
                                        return ARRAY_INDEX_ERROR;
                                    } else {
                                        Dim_info *dimInfo;
                                        dimInfo = (Dim_info *) malloc(sizeof(Dim_info));
                                        dimInfo->n = attrib->numElements;
                                        dimInfo->linf = atoi($1);
                                        dimInfo->next = NULL;
                                        attrib->dims = dimInfo;
                                    }
                                }
          | INT_LIT ':' INT_LIT ',' listadupla {
                                                   Node *intLitNode1 = create_node(@1.first_line, int_lit_node, $1, NULL);
                                                   Node *colonNode = create_node(@2.first_line, colon_node, ":", NULL);
                                                   Node *intLitNode2 = create_node(@3.first_line, int_lit_node, $3, NULL);
                                                   Node *commaNode = create_node(@4.first_line, comma_node, ",", NULL);
                                                   List_attrib *attrib, *list;
                                                   int numElements;
                                                   
                                                   $$ = create_node(@1.first_line, listadupla_node, NULL, intLitNode1, colonNode, intLitNode2,
                                                       commaNode, $5, NULL);
                                                   
                                                   $$->attribute = (List_attrib *) malloc(sizeof(List_attrib));
                                                   attrib = (List_attrib *) $$->attribute;
                                                   list = $5->attribute;
                                                   
                                                   numElements = atoi($3) - atoi($1) + 1;
                                                   if (numElements < 1) {
                                                       printf("ARRAY INDEX ERROR. O limite superior eh menor que o limite inferior.");
                                                       return ARRAY_INDEX_ERROR;
                                                   } else {
                                                       Dim_info *dimInfo;
                                                       attrib->numElements = numElements * list->numElements;
                                                       dimInfo = (Dim_info *) malloc(sizeof(Dim_info));
                                                       dimInfo->n = numElements;
                                                       dimInfo->linf = atoi($1);
                                                       dimInfo->next = list->dims;
                                                       attrib->dims = dimInfo;
                                                   }
                                               }
          ;

acoes: comando ';' {
                       Node *semiColonNode = create_node(@2.first_line, semicolon_node, ";", NULL);
                       Code_attrib *attrib, *comandoAttrib;
                       
                       $$ = create_node(@1.first_line, acoes_node, NULL, $1, semiColonNode, NULL);
                       
                       $$->attribute = (Code_attrib *) malloc(sizeof(Code_attrib));
                       attrib = (Code_attrib *) $$->attribute;
                       comandoAttrib = $1->attribute;
                       
                       attrib->local = NULL;
                       attrib->code = comandoAttrib->code;
                   }
    | comando ';' acoes {
                            Node *semiColonNode = create_node(@2.first_line, semicolon_node, ";", NULL);
                            Code_attrib *attrib, *comandoAttrib, *acoesAttrib;
                            
                            $$ = create_node(@1.first_line, acoes_node, NULL, $1, semiColonNode, $3, NULL);
                            
                            $$->attribute = (Code_attrib *) malloc(sizeof(Code_attrib));
                            attrib = (Code_attrib *) $$->attribute;
                            comandoAttrib = $1->attribute;
                            acoesAttrib = $3->attribute;
                            
                            attrib->local = NULL;
                            attrib->code = comandoAttrib->code;
                            cat_tac(&(attrib->code), &(acoesAttrib->code));
                        }
    ;

comando: lvalue '=' expr {
                             Node *equalsNode = create_node(@2.first_line, equals_node, "=", NULL);
                             Code_attrib *attrib, *lvalueAttrib, *exprAttrib;
                             struct tac *newCode;
                             char *arrVar;
                             
                             $$ = create_node(@1.first_line, comando_node, NULL, $1, equalsNode, $3, NULL);
                             
                             $$->attribute = (Code_attrib *) malloc(sizeof(Code_attrib));
                             attrib = (Code_attrib *) $$->attribute;
                             lvalueAttrib = $1->attribute;
                             exprAttrib = $3->attribute;
                             
                             attrib->local = NULL;
                             attrib->code = lvalueAttrib->code;
                             cat_tac(&(attrib->code), &(exprAttrib->code));
                             if (lvalueAttrib->desloc == NULL) {
                                 newCode = create_inst_tac(lvalueAttrib->local, exprAttrib->local, "", "");
                                 append_inst_tac(&(attrib->code), newCode);
                             } else {
                                 struct tac *newCode1, *newCode2;
                                 char* tmp = new_tmp();
                                 newCode1 = create_inst_tac(tmp, lvalueAttrib->local, "ADD", lvalueAttrib->desloc);
                                 append_inst_tac(&(attrib->code), newCode1);
                                 arrVar = (char *) malloc((strlen(tmp)+strlen(lvalueAttrib->array)+2+1)*sizeof(char));
                                 sprintf(arrVar, "%s[%s]", lvalueAttrib->array, tmp);
                                 newCode2 = create_inst_tac(arrVar, exprAttrib->local, "", "");
                                 append_inst_tac(&(attrib->code), newCode2);
                             }
                         }
       | enunciado { $$ = $1; }
       ;

lvalue: IDF {
                Code_attrib *attrib;
                
                $$ = create_node(@1.first_line, idf_node, $1, NULL);
                
                $$->attribute = (Code_attrib *) malloc(sizeof(Code_attrib));
                attrib = (Code_attrib *) $$->attribute;

                if (lookup(*s_table, $1) == NULL) {
                    printf("UNDEFINED SYMBOL. A variavel %s nao foi declarada.\n", $1);
                    return UNDEFINED_SYMBOL_ERROR;
                } else {
                    attrib->local = (char *) malloc((strlen($1)+1)*sizeof(char));
                    strcpy(attrib->local, $1);
                    attrib->code = NULL;
                    attrib->desloc = NULL;
                }
            }
      | listaexpr ']' {
                          Node *rSqrBracketNode = create_node(@2.first_line, r_sqr_bracket_node, "]", NULL);
                          Code_attrib *attrib, *listaAttrib;
                          struct tac *newCode1, *newCode2;
                          
                          $$ = create_node(@1.first_line, lvalue_node, NULL, $1, rSqrBracketNode, NULL);
                          
                          $$->attribute = (Code_attrib *) malloc(sizeof(Code_attrib));
                          attrib = (Code_attrib *) $$->attribute;
                          listaAttrib = $1->attribute;
                          
                          attrib->local = new_tmp();
                          attrib->desloc = new_tmp();
                          attrib->code = listaAttrib->code;
                          newCode1 = create_inst_tac(attrib->local, c(listaAttrib->array), "", "");
                          append_inst_tac(&(attrib->code), newCode1);
                          newCode2 = create_inst_tac(attrib->desloc, listaAttrib->local, "MUL", width(listaAttrib->array));
                          append_inst_tac(&(attrib->code), newCode2);
                          attrib->array = (char *) malloc((strlen(listaAttrib->array)+1)*sizeof(char));
                          strcpy(attrib->array, listaAttrib->array);
                      }
      ;

listaexpr: listaexpr ',' expr {
                                  Node *commaNode = create_node(@2.first_line, comma_node, ",", NULL);
                                  Code_attrib *attrib, *listaAttrib, *exprAttrib;
                                  char *tmp;
                                  int m;
                                  struct tac *newCode1, *newCode2;
                                  
                                  $$ = create_node(@1.first_line, listaexpr_node, NULL, $1, commaNode, $3, NULL);
                                  
                                  $$->attribute = (Code_attrib *) malloc(sizeof(Code_attrib));
                                  attrib = (Code_attrib *) $$->attribute;
                                  listaAttrib = $1->attribute;
                                  exprAttrib = $3->attribute;
                                  
                                  tmp = new_tmp();
                                  m = listaAttrib->ndim + 1;
                                  
                                  attrib->code = listaAttrib->code;
                                  cat_tac(&(attrib->code), &(exprAttrib->code));
                                  
                                  newCode1 = create_inst_tac(tmp, listaAttrib->local, "MUL", limit(listaAttrib->array, m));
                                  append_inst_tac(&(attrib->code), newCode1);
                                  
                                  newCode2 = create_inst_tac(tmp, tmp, "ADD", exprAttrib->local);
                                  append_inst_tac(&(attrib->code), newCode2);
                                  
                                  attrib->array = (char *) malloc((strlen(listaAttrib->array)+1)*sizeof(char));
                                  strcpy(attrib->array, listaAttrib->array);
                                  attrib->local = tmp;
                                  attrib->ndim = m;
                              }
         | IDF '[' expr {
                            Node *idfNode = create_node(@1.first_line, idf_node, $1, NULL);
                            Node *lSqrBracketNode = create_node(@2.first_line, l_sqr_bracket_node, "[", NULL);
                            Code_attrib *attrib, *exprAttrib;
                            
                            $$ = create_node(@1.first_line, listaexpr_node, NULL, idfNode, lSqrBracketNode, $3, NULL);
                            
                            $$->attribute = (Code_attrib *) malloc(sizeof(Code_attrib));
                            attrib = (Code_attrib *) $$->attribute;
                            exprAttrib = $3->attribute;
                            
                            if (lookup(*s_table, $1) == NULL) {
                                printf("UNDEFINED SYMBOL. A variavel %s nao foi declarada.\n", $1);
                                return UNDEFINED_SYMBOL_ERROR;
                            } else {
                                attrib->array = (char *) malloc((strlen($1)+1)*sizeof(char));
                                strcpy(attrib->array, $1);
                                attrib->local = (char *) malloc((strlen(exprAttrib->local)+1)*sizeof(char));
                                strcpy(attrib->local, exprAttrib->local);
                                attrib->ndim = 1;
                                attrib->code = exprAttrib->code;
                                attrib->desloc = NULL;
                            }
                        }
	     ;

expr: expr '+' expr {
                        Node *plusNode = create_node(@2.first_line, plus_node, "+", NULL);
                        Code_attrib *attrib, *expr1, *expr2;
                        struct tac *newCode;
                        
                        $$ = create_node(@1.first_line, expr_node, NULL, $1, plusNode, $3, NULL);
                        
                        $$->attribute = (Code_attrib *) malloc(sizeof(Code_attrib));
                        attrib = (Code_attrib *) $$->attribute;
                        expr1 = $1->attribute;
                        expr2 = $3->attribute;
                        
                        attrib->local = new_tmp();
                        attrib->code = expr1->code;
                        cat_tac(&(attrib->code), &(expr2->code));
                        newCode = create_inst_tac(attrib->local, expr1->local, "ADD", expr2->local);
                        append_inst_tac(&(attrib->code), newCode);
                    }
    | expr '-' expr {
                        Node *minusNode = create_node(@2.first_line, minus_node, "-", NULL);
                        Code_attrib *attrib, *expr1, *expr2;
                        struct tac *newCode;
                        
                        $$ = create_node(@1.first_line, expr_node, NULL, $1, minusNode, $3, NULL);
                        
                        $$->attribute = (Code_attrib *) malloc(sizeof(Code_attrib));
                        attrib = (Code_attrib *) $$->attribute;
                        expr1 = $1->attribute;
                        expr2 = $3->attribute;
                        
                        attrib->local = new_tmp();
                        attrib->code = expr1->code;
                        cat_tac(&(attrib->code), &(expr2->code));
                        newCode = create_inst_tac(attrib->local, expr1->local, "SUB", expr2->local);
                        append_inst_tac(&(attrib->code), newCode);
                    }
    | expr '*' expr {
                        Node *asteriskNode = create_node(@2.first_line, asterisk_node, "*", NULL);
                        Code_attrib *attrib, *expr1, *expr2;
                        struct tac *newCode;
                        
                        $$ = create_node(@1.first_line, expr_node, NULL, $1, asteriskNode, $3, NULL);
                        
                        $$->attribute = (Code_attrib *) malloc(sizeof(Code_attrib));
                        attrib = (Code_attrib *) $$->attribute;
                        expr1 = $1->attribute;
                        expr2 = $3->attribute;
                        
                        attrib->local = new_tmp();
                        attrib->code = expr1->code;
                        cat_tac(&(attrib->code), &(expr2->code));
                        newCode = create_inst_tac(attrib->local, expr1->local, "MUL", expr2->local);
                        append_inst_tac(&(attrib->code), newCode);
                    }
    | expr '/' expr {
                        Node *slashNode = create_node(@2.first_line, slash_node, "/", NULL);
                        Code_attrib *attrib, *expr1, *expr2;
                        struct tac *newCode;
                        
                        $$ = create_node(@1.first_line, expr_node, NULL, $1, slashNode, $3, NULL);
                        
                        $$->attribute = (Code_attrib *) malloc(sizeof(Code_attrib));
                        attrib = (Code_attrib *) $$->attribute;
                        expr1 = $1->attribute;
                        expr2 = $3->attribute;
                        
                        attrib->local = new_tmp();
                        attrib->code = expr1->code;
                        cat_tac(&(attrib->code), &(expr2->code));
                        newCode = create_inst_tac(attrib->local, expr1->local, "DIV", expr2->local);
                        append_inst_tac(&(attrib->code), newCode);
                    }
    | '(' expr ')' {
                       Node *lParNode = create_node(@1.first_line, l_par_node, "(", NULL);
                       Node *rParNode = create_node(@3.first_line, r_par_node, ")", NULL);
                       Code_attrib *attrib, *attribExpr;
                       
                       $$ = create_node(@1.first_line, expr_node, NULL, lParNode, $2, rParNode, NULL);
                       
                       $$->attribute = (Code_attrib *) malloc(sizeof(Code_attrib));
                       attrib = (Code_attrib *) $$->attribute;
                       attribExpr = $2->attribute;
                       
                       attrib->local = (char *) malloc((strlen(attribExpr->local)+1)*sizeof(char));
                       strcpy(attrib->local, attribExpr->local);
                       attrib->code = attribExpr->code;
                   }
    | INT_LIT  {
                   Code_attrib *attrib;
                   
                   $$ = create_node(@1.first_line, int_lit_node, $1, NULL);
                   
                   $$->attribute = (Code_attrib *) malloc(sizeof(Code_attrib));
                   attrib = (Code_attrib *) $$->attribute;
                   
                   attrib->local = (char *) malloc((strlen($1)+1)*sizeof(char));
                   strcpy(attrib->local, $1);
                   attrib->code = NULL;
               }
    | F_LIT { $$ = create_node(@1.first_line, f_lit_node, $1, NULL); }
    | lvalue { 
                 Code_attrib *attrib, *lvalueAttrib;
                 struct tac *newCode1, *newCode2;
                 char *arrVar = "";
                 
                 lvalueAttrib = $1->attribute;
                 if (lvalueAttrib->desloc == NULL) {
                     $$ = $1;
                 } else {
                     $$ = create_node(@1.first_line, lvalue_node, NULL, $1, NULL);
                     
                     $$->attribute = (Code_attrib *) malloc(sizeof(Code_attrib));
                     attrib = (Code_attrib *) $$->attribute;
                     
                     attrib->local = new_tmp();
                     attrib->code = lvalueAttrib->code;
                     newCode1 = create_inst_tac(attrib->local, lvalueAttrib->local, "ADD", lvalueAttrib->desloc);
                     append_inst_tac(&(attrib->code), newCode1);
                     arrVar = (char *) malloc((strlen(attrib->local)+strlen(lvalueAttrib->array)+2+1)*sizeof(char));
                     sprintf(arrVar, "%s[%s]", lvalueAttrib->array, attrib->local);
                     newCode2 = create_inst_tac(attrib->local, arrVar, "", "");
                     append_inst_tac(&(attrib->code), newCode2);
                 }
             }
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
                                   Code_attrib *attrib, *exprAttrib;
                                   struct tac *newCode;
                                   
                                   $$ = create_node(@1.first_line, enunciado_node, NULL, printNode, lParNode, $3, rParNode, NULL);
                                   
                                   $$->attribute = (Code_attrib *) malloc(sizeof(Code_attrib));
                                   attrib = (Code_attrib *) $$->attribute;
                                   exprAttrib = $3->attribute;
                                   
                                   attrib->local = NULL;
                                   attrib->code = exprAttrib->code;
                                   newCode = create_inst_tac("", exprAttrib->local, "PRINT", "");
                                   append_inst_tac(&(attrib->code), newCode);
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

/**
 * Funcao utilitaria que retorna o numero de digitos de um numero inteiro
 */
int num_digits(int n) {
    int count = 1;
    int signal = 0;
    
    if (n < 0) signal = 1;
    while (n != 0) {
        n = n / 10;
        ++count;
    }
    return count + signal;
}

/**
 * Gera uma nova variavel temporaria e a insere na tabela de simbolos
 */
char* new_tmp() {
    char *newTmp;
    entry_t *entry;
    newTmp = (char *) malloc((4+num_digits(tmpNum)+1)*sizeof(char));
    sprintf(newTmp, "@tmp%d", tmpNum);
    tmpNum = tmpNum + 1;
    
    // insere na tabela de simbolos
    entry = (entry_t *) malloc(sizeof(entry_t));
    entry->name = (char *) malloc((strlen(newTmp)+1)*sizeof(char));
    strcpy(entry->name, newTmp);
    entry->type = int_type;
    entry->size = int_size;
    entry->desloc = deslocTmp;
    if (insert(s_table, entry) != 0) {
        printf("Erro ao inserir uma variavel temporaria na tabela de simbolos!\n");
        exit(EXIT_FAILURE);
    }
    deslocTmp = deslocTmp + int_size;

    return newTmp;
}

/**
 * Retorna a constante c usada no cálculo de endereço de um elemento de array
 */
char* c(char *arrayName) {
    char *constant;
    entry_t *entry;
    array_info *arrInfo;

    entry = lookup(*s_table, arrayName);
    if (entry == NULL) {
        printf("UNDEFINED SYMBOL. A variavel %s nao foi declarada.\n", arrayName);
        exit(UNDEFINED_SYMBOL_ERROR);
    }
    arrInfo = (array_info *) entry->extra;
    constant = (char *) malloc((num_digits(arrInfo->c)+1)*sizeof(char));
    sprintf(constant, "%d", arrInfo->c);
    return constant;
}

/**
 * Retorna o tamanho de um elemento do array
 */
char* width(char *arrayName) {
    char *elemSize;
    entry_t *entry;
    array_info *arrInfo;
    
    entry = lookup(*s_table, arrayName);
    if (entry == NULL) {
        printf("UNDEFINED SYMBOL. A variavel %s nao foi declarada.\n", arrayName);
        exit(UNDEFINED_SYMBOL_ERROR);
    }
    arrInfo = (array_info *) entry->extra;
    elemSize = (char *) malloc((num_digits(arrInfo->width)+1)*sizeof(char));
    sprintf(elemSize, "%d", arrInfo->width);
    return elemSize;
}

/**
 * Retorna o tamanho da dimensao dim do array
 */
char* limit(char *arrayName, int dim) {
    char *dimSize;
    entry_t *entry;
    array_info *arrInfo;
    Dim_info *currentDim;
    int i;
    
    entry = lookup(*s_table, arrayName);
    if (entry == NULL) {
        printf("UNDEFINED SYMBOL. A variavel %s nao foi declarada.\n", arrayName);
        exit(UNDEFINED_SYMBOL_ERROR);
    }
    arrInfo = (array_info *) entry->extra;
    if (dim > arrInfo->ndim) {
        printf("ARRAY DIMENSION ERROR. O array %s possui apenas %d dimensoes.\n", arrayName, arrInfo->ndim);
        exit(ARRAY_DIMENSION_ERROR);
    }
    currentDim = arrInfo->dims;
    i = 1;
    while (currentDim != NULL && i < dim) {
        currentDim = currentDim->next;
        i = i + 1;
    }
    if (currentDim == NULL) {
        printf("Dimensao %d nao encontrada no array %s!\n", dim, arrayName);
        exit(EXIT_FAILURE);
    }
    dimSize = (char *) malloc((num_digits(currentDim->n)+1)*sizeof(char));
    sprintf(dimSize, "%d", currentDim->n);
    return dimSize;
}
