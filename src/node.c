#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include "node.h"


Node *syntax_tree;

Node *create_node(int nl, Node_type t,
        char* lexeme, Node* child0, ...) {
    Node *newNode;
    Node *currentChild;
    va_list ap;
    
    newNode = (Node *) malloc(sizeof(Node));

    if (newNode != NULL) {
        /* inicializa os campos do nodo criado */
        newNode->num_line = nl;
        if (t < code_node || t > print_node) {
            exit(EXIT_FAILURE); // termina se o Node_type nao eh valido
        } else {
            newNode->type = t;
        }
        if (lexeme != NULL) {
            newNode->lexeme = (char *) malloc((strlen(lexeme)+1)*sizeof(char)); // aloca memoria para a string
            strcpy(newNode->lexeme, lexeme); // copia o lexema para o campo lexeme do nodo
        } else {
            newNode->lexeme = NULL;
        }
        newNode->next_sibling = NULL; // o nodo criado nao tem irmaos

        /* inclui os filhos do nodo criado */
        newNode->first_child = child0; // o primeiro filho eh o primeiro parametro

        /* liga os filhos do nodo em uma lista encadeada */
        currentChild = newNode->first_child;
        va_start(ap, child0);
        while (currentChild != NULL) {
            currentChild->next_sibling = va_arg(ap, Node*);
            currentChild = currentChild->next_sibling;
        }
        va_end(ap);
    }

    return newNode;
}

int nb_of_children(Node* n) {
    int count = 0;
    Node *nodeAux;

    if (n == NULL) {
        exit(EXIT_FAILURE);
    } else {
        nodeAux = n->first_child;
        while (nodeAux != NULL) {
            count++;
            nodeAux = nodeAux->next_sibling; // aponta para o proximo filho do noh n
        }
    }

    return count;
}

int is_leaf(Node* n) {
    if (n == NULL) {
        exit(EXIT_FAILURE);
    }
    return (n->first_child == NULL);
}

Node* child(Node* n, int i) {
    int degree;
    int count;
    Node *child;

    if (n == NULL) {
        exit(EXIT_FAILURE);
    }
    degree = nb_of_children(n);
    if (i < 0 || i >= degree) {
        exit(EXIT_FAILURE);
    }

    child = n->first_child;
    for (count = 0; count != i; count++) {
        child = child->next_sibling;
    }

    return child;
}

int deep_free_node(Node* n) {
    if (!is_leaf(n)) {
        deep_free_node(n->first_child);
    }
    if (n->next_sibling != NULL) {
        deep_free_node(n->next_sibling);
    }
    free(n);
    return 0;
}

int height(Node *n) {
    Node *firstChild;
    Node *nextChild;
    int maxChildHeight;
    int nextChildHeight;

    if (is_leaf(n)) {
        return 1;
    } else {
        firstChild = n->first_child;
        maxChildHeight = height(firstChild);
        nextChild = firstChild->next_sibling;
        while (nextChild != NULL) {
            nextChildHeight = height(nextChild);
            if (nextChildHeight > maxChildHeight) {
                maxChildHeight = nextChildHeight;
            }
            nextChild = nextChild->next_sibling;
        }
        return 1 + maxChildHeight;
    }
}

void uncompile(FILE* outfile, Node *n) {
    Node *nodeAux;

    if (n == NULL) {
        exit(EXIT_FAILURE);
    }

    nodeAux = n;
    if (is_leaf(nodeAux)) {
        fprintf(outfile, "%s ", nodeAux->lexeme); // os lexemas estao nas folhas da arvore
    } else {
        nodeAux = nodeAux->first_child;
        do {
            uncompile(outfile, nodeAux);
            nodeAux = nodeAux->next_sibling;
        } while (nodeAux != NULL);
    }
}
