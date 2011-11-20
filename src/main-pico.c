#include <stdio.h>
#include <stdlib.h>

#include "node.h"
//teste
/* Programa principal do pico. */
char* progname;
int lineno;
extern FILE* yyin;

void imprime(Node *n) {
    Node *nodeAux;

    if (n == NULL) {
        exit(EXIT_FAILURE);
    }

    nodeAux = n;
    if (is_leaf(nodeAux)) {
        printf("%d - %s \n ", nodeAux->num_line, nodeAux->lexeme); // os lexemas estao nas folhas da arvore
    } else {
        nodeAux = nodeAux->first_child;
        do {
            imprime(nodeAux);
            nodeAux = nodeAux->next_sibling;
        } while (nodeAux != NULL);
    }
}

int main(int argc, char* argv[]) 
{
    if (argc != 2) {
        printf("uso: %s <input_file>. Try again!\n", argv[0]);
        exit(-1);
    }
    yyin = fopen(argv[1], "r");
    if (!yyin) {
        printf("Uso: %s <input_file>. Could not find %s. Try again!\n", argv[0], argv[1]);
        exit(-1);
    }

    progname = argv[1];

    syntax_tree = NULL;

    if (!yyparse()) {
        printf("OKAY.\n");
        imprime(syntax_tree);
        FILE* output = fopen("../Testes/output.txt", "w");
        uncompile(output, syntax_tree);
        fclose(output);
    } else {
        printf("ERROR.\n");
	    if (syntax_tree != NULL) {
            if (syntax_tree->type == int_node)
                printf("A AST se limita a uma folha rotulada por: %s\n", syntax_tree->lexeme);
            else
                printf("Something got wrong in the AST.\n");
        }
    }

    fclose(yyin);
    return(0);
}

void yyerror(char* s) {
    fprintf(stderr, "%s: %s", progname, s);
    fprintf(stderr, "line %d\n", lineno);
}
