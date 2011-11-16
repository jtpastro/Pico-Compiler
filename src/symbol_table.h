/** @file symbol_table.h
 *  @version 1.1
 */
#ifndef _SYMBOL_TABLE_H_
#define _SYMBOL_TABLE_H_

#include <stdio.h>
#include <stdlib.h>

#define PRIME 211 // 9901

/**
 * Tipo abstrato das entradas na tabela de Hash. (Obs.: futuramente, os campos
 * dessa struct poderao vir a ser alterados em funcao das necessidades.)
 * Na Etapa 1, nao e necessario entender o conteudo desses campos.
 * Sempre vao ser inseridos na tabela, e recuperado dela, ponteiros sobre tais
 * estruturas de dados abstratas.
 */
typedef struct {
   char* name;  /**< um string que representa o nome de uma variavel. */
   int type;    /**< representacao do tipo da variavel. */
   int size;    /**< numero de Bytes necessarios para armazenamento. */
   int desloc;  /**< Endereco da proxima variavel. */
   void* extra; /**< qualquer informacao extra. */
} entry_t ;



/** \brief Nodo da lista encadeada de entradas da tabela de simbolos
 *
 * Para cada hash calculado, a tabela de simbolos possui uma lista encadeada.
 * Seriam as entradas que dão conflito, todas mapeadas no indice certo da tabela.
 *
 */
struct table_node_entry {
   entry_t * entry_data;
   struct table_node_entry * next;
};

/** \brief Encapsulacao de um tipo abstrato que se chamara 'symbol_t'
 *
 * Voce deve inserir, entre o 'typedef' e o 'symbol_t', a estrutura de dados
 * abstrata que voce ira implementar.
 *
 */
typedef struct {
    struct table_node_entry * entries[PRIME];
} symbol_t ;

/** \brief Inicializar a tabela de Hash.
 *
 * @param table, uma referencia sobre uma tabela de simbolos.
 * @return o valor 0 se deu certo.
 */
int init_table(symbol_t* table) ;

/** \brief Destruir a tabela de Hash.
 *
 * 'free_table' eh o destrutor da estrutura de dados. Deve ser chamado pelo 
 * usuario no fim de seu uso de uma tabela de simbolos.
 * @param table, uma referencia sobre uma tabela de simbolos.
 */
void free_table(symbol_t* table) ;

/** \brief Retornar um ponteiro sobre a entrada associada a 'name'.
 *
 * Essa funcao deve consultar a tabela de simbolos para verificar se se encontra
 * nela uma entrada associada a um char* (string) fornecido em entrada. Para
 * a implementacao, sera necessario usar uma funcao que mapeia um char* a
 * um numero inteiro. Aconselha-se, por exemplo, consultar o livro do dragao
 * (Aho/Sethi/Ulman), Fig. 7.35 e a funcao HPJW.
 *
 * @param table, uma tabela de simbolos.
 * @param name, um char* (string).
 * @return um ponteiro sobre a entrada associada a 'name', ou NULL se 'name'
 *         nao se encontrou na tabela.
 */
entry_t* lookup(symbol_t table, char* name) ;

/** \brief Inserir uma entrada em uma tabela.
 *
 * @param table, uma tabela de simbolos.
 * @param entry, uma entrada.
 * @return um numero negativo se nao se conseguiu efetuar a insercao, zero se
 *   deu certo.
 */
int insert(symbol_t* table, entry_t* entry) ;

/** \brief Imprimir o conteudo de uma tabela.
 *
 * A formatacao exata e deixada a carga do programador. Deve-se listar todas
 * as entradas contidas na tabela atraves de seu nome (char*). Deve retornar
 * o numero de entradas na tabela.
 *
 * @param table, uma tabela de simbolos.
 * @return o numero de entradas na tabela.
 */
int print_table(symbol_t table);

/** \brief Imprimir o conteudo de uma tabela em um arquivo.
 *
 * A formatacao exata e deixada a carga do programador. Deve-se listar todas
 * as entradas contidas na tabela atraves de seu nome (char*). Deve retornar
 * o numero de entradas na tabela. A saida deve ser dirigida para um arquivo,
 * cujo descritor e passado em parametro.
 *
 * @param out, um descrito de arquivo (FILE*).
 * @param table, uma tabela de simbolos.
 * @return o numero de entradas na tabela.
 */
int print_file_table(FILE* out, symbol_t table);

#endif
