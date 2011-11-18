#include <stdio.h>
#include <string.h>
#include "symbol_table.h"
#include "lista.h"

#define INT_TYPE 10
#define INT_SIZE 4
#define MAX 5

symbol_t *s_table;

int main(void) {
    s_table = (symbol_t *) malloc(sizeof(symbol_t));
    FILE *test_file = NULL;
    char *varNames[] = {"x", "y", "z", "var1", "@tmp1"};
    entry_t *entry[MAX];
    int i, desloc = 0;
    
    struct node_tac *code = NULL;
    struct tac *inst = NULL;
    
    if (init_table(s_table) != 0) {
        printf("Erro na inicializacao da tabela de simbolos!\n");
        exit(EXIT_FAILURE);
    }
    
    if (NULL == (test_file = fopen("tac_teste.txt", "w"))) {
        printf("Erro na criacao/abertura do arquivo tac_teste.txt!\n");
        exit(EXIT_FAILURE);
    }
    
    for (i = 0; i < MAX; i++) {
        entry[i] = (entry_t *) malloc(sizeof(entry_t));
        entry[i]->name = varNames[i];
        entry[i]->type = INT_TYPE;
        entry[i]->size = INT_SIZE;
        entry[i]->desloc = desloc;
        if (insert(s_table, entry[i]) != 0) {
            printf("Erro na insercao da entrada '%s' na tabela de simbolos!\n", varNames[i]);
            exit(EXIT_FAILURE);
        }
        desloc = desloc + INT_SIZE;
    }
    
    print_table(*s_table);
    inst = create_inst_tac("", "@tmp1", "PRINT", "");
    print_inst_tac(test_file, *inst);
    
    append_inst_tac(&code, inst);
    print_tac(test_file, code);
    
    fclose(test_file);
    free_table(s_table);
    return 0;
}
