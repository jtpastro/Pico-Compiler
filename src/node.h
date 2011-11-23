/** @file node.h
 *  @version 1.1
 */

#ifndef _NODE_H_
#define _NODE_H_

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

typedef int Node_type;

/* Serie de constantes que servirao para definir tipos de nos (na arvore). 
 * Essa serie pode ser completada ou alterada a vontade.
 */

#define code_node            298
#define declaracoes_node     299
#define declaracao_node      300
#define listadeclaracao_node 301
#define tipo_node            302
#define tipounico_node       303
#define tipolista_node       304
#define listadupla_node      305
#define acoes_node           306
#define comando_node         307
#define lvalue_node          308
#define listaexpr_node       309
#define expr_node            310
#define chamaproc_node       311
#define enunciado_node       312
#define fiminstcontrole_node 313
#define expbool_node         314

#define semicolon_node       315
#define colon_node           316
#define idf_node             317
#define comma_node           318
#define int_node             319
#define double_node          320
#define real_node            321
#define char_node            322
#define l_par_node           323
#define r_par_node           324
#define int_lit_node         325
#define equals_node          326
#define l_sqr_bracket_node   327
#define r_sqr_bracket_node   328
#define plus_node            329
#define minus_node           330
#define asterisk_node        331
#define slash_node           332
#define f_lit_node           333
#define if_node              334
#define then_node            335
#define while_node           336
#define l_brace_node         337
#define r_brace_node         338
#define end_node             339
#define else_node            340
#define true_node            341
#define false_node           342
#define and_node             343
#define or_node              344
#define not_node             345
#define greater_than_node    346
#define less_than_node       347
#define le_node              348
#define ge_node              349
#define eq_node              350
#define ne_node              351
#define print_node           352

#define int_type             500
#define double_type          501
#define real_type            502
#define char_type            503

#define int_array_type       504
#define double_array_type    505
#define real_array_type      506
#define char_array_type      507

#define int_size             4
#define double_size          8
#define real_size            4
#define char_size            1

/** Estrutura de dados parcial para o no da arvore.
 *
 */

typedef struct _node {
   int num_line; /**< numero de linha. */
   char* lexeme; /**< o lexema retornado pelo analizador lexical. */
   Node_type type; /**< Um dos valores definidos acima pelos # defines. */
   void* attribute; /**< Qualquer coisa por enquanto. */
   struct _node *first_child; /**< ponteiro para o primeiro filho */
   struct _node *next_sibling; /**< ponteiro para o proximo irmao */
} Node;

/**
 * Estruturas para o campo attribute do no da arvore
 */
typedef struct _code_attr {
    int varsTotalSize;
    int tmpsTotalSize;
    char* local;
    struct node_tac* code;
    char* desloc;
    char* array;
    int ndim;
} Code_attrib;

typedef struct _dim_info {
    int n;
    int linf;
    struct _dim_info *next;
} Dim_info;

typedef struct _type_attr {
    int type;
    int size;
    int width;
    Dim_info *dims;
} Type_attrib;

typedef struct _idf_attr {
    char* lexeme;
    struct _idf_attr *next;
} Idf_attrib;

typedef struct _list_attr {
    int numElements;
    Dim_info *dims;
} List_attrib;

typedef struct {
    int c;
    int width;
    int ndim;
    Dim_info *dims;
} array_info;

extern Node * syntax_tree;

/**
 *  * Node constructor.
 *
 * @param nl: line number where this token was found in the source code.
 * @param t: node type (one of the values #define'd above). Must abort
 *             the program if the type is not correct.
 * @param lexeme: whatever string you want associated to this node.
 * @param attr: a semantical attribute.
 * @param child0: first of a list of pointers to children Node*'s. See the
 * extra file 'exemplo_func_var_arg.c' for an example.
 * To create a leaf, use NULL as last argument to create_node().
 * @return a pointer to a new Node.
 */
Node* create_node(int nl, Node_type t,
        char* lexeme, Node* child0, ...);

/** accessor to the number of children of a Node.
 *  Must abort the program if 'n' is NULL.
 */
int nb_of_children(Node* n);

/** Tests if a Node is a leaf.
 *  Must abort the program if 'n' is NULL.
 *  @return 1 if n is a leaf, 0 else.
 */
int is_leaf(Node* n);

/** accessor to the i'th child of a Node.
 * @param n : the node to be consulted. Must abort the program if 'n' is NULL.
 * @param i : the number of the child that one wants. Must be lower 
 *       than the degree of the node and larger than or equal to 0. 
 *       Must abort the program if i is not correct.
 * @return a pointer on a Node.
 */
Node* child(Node* n, int i) ;

/** Destructor of a Node. Desallocates (recursively) all the tree rooted at
 * 'n'.
 */
int deep_free_node(Node* n) ;

/** returns the height of the tree rooted by 'n'.
 *  The height of a leaf is 1. 
 */
int height(Node *n) ;

/** Prints into a file the lexemes contained in the node rooted by 'n'.
 *  The impression must follow a depth-first order.
 *  @param outfile : the file to which the lexemes are printed.
 *  @param n : the root node of the tree. Must abort the program if 'n' is NULL.
 *
 */
void uncompile(FILE* outfile, Node *n) ;

#endif
