#include <stdlib.h>
#include <string.h>
#include "lista.h"
#include "symbol_table.h"

extern symbol_t *s_table;

char* idf_to_tac(char *idf);

/** \brief  Construtor de Instrucao TAC 
 *
 * Para testes, pode-se usar qualquer string em argumentos.
 * @param res um char*.
 * @param arg1 um char*.
 * @param op um char*.
 * @param arg2 um char*.
 * @ return um ponteiro sobre uma 'struct tac'.
 */
struct tac* create_inst_tac(const char* res,
        const char* arg1, const char* op, const char* arg2) {
    struct tac *newTac = (struct tac *) malloc(sizeof(struct tac));
    
    newTac->op = (char *) malloc((strlen(op)+1)*sizeof(char));
    strcpy(newTac->op, op);
    
    newTac->res = (char *) malloc((strlen(res)+1)*sizeof(char));
    strcpy(newTac->res, res);
    
    newTac->arg1 = (char *) malloc((strlen(arg1)+1)*sizeof(char));
    strcpy(newTac->arg1, arg1);
    
    newTac->arg2 = (char *) malloc((strlen(arg2)+1)*sizeof(char));
    strcpy(newTac->arg2, arg2);

    return newTac;
}

/** \brief Funcao que imprime o conteudo de uma instrucao TAC 
 *
 * @param out um ponteiro sobre um arquivo (aberto) aonde ira ser escrita a instrucao.
 * @param i a instrucao a ser impressa.
 */
void print_inst_tac(FILE* out, struct tac i) {
    if (strcmp(i.op, "PRINT") == 0) { // operacao PRINT
        fprintf(out, "PRINT %s\n", idf_to_tac(i.arg1));
    } else { // operacoes aritmeticas
        fprintf(out, "%s := %s", idf_to_tac(i.res), idf_to_tac(i.arg1));
        if (strlen(i.op) > 0) {
            fprintf(out, " %s %s", i.op, idf_to_tac(i.arg2));
        }
        fprintf(out, "\n");
    }
}

/** \brief Imprime no arquivo apontado por 'out' o conteudo da lista apontada
 * por 'code'.
 *
 * @param out um ponteiro sobre um arquivo (aberto) aonde ira ser escrita a lista (uma linha por elemento).
 * @param code o ponteiro para a lista a ser impressa.
 *
 * Obs.: cada linha impressa no arquivo deve comecar por um numero inteiro
 * (3 digitos) seguido de ':'. O numero deve ser o numero da linha.
 * Exemplo:
 *   001:  instrucao_qualquer
 *   002:  outra_instrucao
 *    .....
 *   999:  ultima_instrucao
 *   000:  agora_tem_instrucao_demais
 */
void print_tac(FILE* out, struct node_tac * code) {
    struct node_tac *currentNode = code;
    while (currentNode != NULL) {
        fprintf(out, "%03d:   ", currentNode->number);
        print_inst_tac(out, *(currentNode->inst));
        currentNode = currentNode->next;
    }
}

/** Insere no fim da lista 'code' o elemento 'inst'. 
 * @param code lista (possivelmente vazia) inicial, em entrada. Na saida, contem
 *         a mesma lista, com mais um elemento inserido no fim.
 * @inst  o elemento inserido no fim da lista.
 */
void append_inst_tac(struct node_tac ** code, struct tac * inst) {
    struct node_tac *newCode = (struct node_tac *) malloc(sizeof(struct node_tac));
    if (newCode == NULL)
        exit(EXIT_FAILURE);

    newCode->number = 0;
    newCode->inst = inst;
    newCode->next = NULL;
    newCode->prev = NULL;

    if (*code == NULL) {
        *code = newCode;
    } else {
        struct node_tac *lastNode = *code;
        
        while (lastNode->next != NULL) // caminha ate o fim da lista
            lastNode = lastNode->next;

        lastNode->next = newCode;
        newCode->prev = lastNode;
        newCode->number = lastNode->number + 1;
    }
}

/** Concatena a lista 'code_a' com a lista 'code_b'.
 * @param code_a lista (possivelmente vazia) inicial, em entrada. Na saida, contem 
 *         a mesma lista concatenada com 'code_b'.
 * @param code_b a lista concatenada com 'code_a'.
 */
void cat_tac(struct node_tac ** code_a, struct node_tac ** code_b) {
    if (*code_a == NULL) {
        *code_a = *code_b;
    } else {
        struct node_tac *aux, *lastNode = *code_a;
        int offset;
        
        while (lastNode->next != NULL) // caminha ate o fim da lista
            lastNode = lastNode->next;
        
        lastNode->next = *code_b;
        
        if (*code_b != NULL)
            (*code_b)->prev = lastNode;
        
        // atualiza o campo number dos nodos
        aux = lastNode->next;
        offset = lastNode->number + 1;
        while (aux != NULL) {
            aux->number = aux->number + offset;
            aux = aux->next;
        }
    }
}

char* idf_to_tac(char *idf) {
    entry_t *entry;
    char *result = NULL;
    if (strchr(idf,'[') != NULL && strchr(idf,']') != NULL) {
        char *local = idf_to_tac(strtok(idf, "["));
        char *desloc = idf_to_tac(strtok(NULL, "]"));
        result = (char *) malloc((strlen(local)+strlen(desloc)+2+1)*sizeof(char));
        sprintf(result, "%s(%s)", desloc, local);
        return result;
    }
    
    entry = lookup(*s_table, idf);
    if (entry == NULL) { // se nao estah na tabela de simbolos        
        result = (char *) malloc((strlen(idf)+1)*sizeof(char));
        strcpy(result, idf); // eh uma constante
    } else {
        result = (char *) malloc(8*sizeof(char));
        if (entry->name[0] == '@') // se for uma variavel temporaria
            sprintf(result, "%03d(Rx)", entry->desloc);
        else // senao, eh uma variavel declarada
            sprintf(result, "%03d(SP)", entry->desloc);
    }
    return result;
}
