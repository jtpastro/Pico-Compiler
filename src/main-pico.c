#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "node.h"
#include "symbol_table.h"
#include "lista.h"

/* Programa principal do pico. */
char *progname;
int lineno;
extern FILE *yyin;
extern symbol_t *s_table;

int main(int argc, char* argv[]) 
{
    struct attr_expr *attrib;

    if (argc != 4) {
        printf("Uso: %s -o <output_file.tac> <input_file.pico>. Tente novamente!\n", argv[0]);
        exit(-1);
    }
    if (strcmp(argv[1],"-o") != 0) {
        printf("Uso: %s -o <output_file.tac> <input_file.pico>. Tente novamente!\n", argv[0]);
        exit(-1);
    }
    yyin = fopen(argv[3], "r");
    if (!yyin) {
        printf("Uso: %s <input_file>. Could not find %s. Tente novamente!\n", argv[0], argv[1]);
        exit(-1);
    }
	char *progname = (char *) malloc((strlen(argv[3])+1)*sizeof(char));
	char *tacFile = (char *) malloc((strlen(argv[2])+1)*sizeof(char));;

    strcpy(progname, argv[3]);
    strcpy(tacFile, argv[2]);

    syntax_tree = NULL;
    s_table = (symbol_t *) malloc(sizeof(symbol_t));
    init_table(s_table);
    if (!yyparse()) {
        attrib = (struct attr_expr *) syntax_tree->attribute;
        /*
        FILE* output = fopen(tacFile, "w");
        
        fprintf(output, "%d\n", attrib->varsSize);
        fprintf(output, "%d\n", attrib->tmpsSize);
        print_tac(output, attrib->code, *s_table);

        fclose(output);
        FILE* fTable = fopen("tablefile.txt", "w");
        print_file_table(fTable, *s_table);
        fclose(fTable);
        */
    } else {
        printf("ERROR.\n");
	    if (syntax_tree != NULL) {
            if (syntax_tree->type == int_node)
                printf("A AST se limita a uma folha rotulada por: %s\n", syntax_tree->lexeme);
            else
                printf("Something got wrong in the AST.\n");
        }
    }

    free_table(s_table);
    fclose(yyin);
    return(0);
}

void yyerror(char* s) {
    fprintf(stderr, "%s: %s", progname, s);
    fprintf(stderr, "line %d\n", lineno);
}
