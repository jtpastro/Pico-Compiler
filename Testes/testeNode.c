#include <stdlib.h>
#include <string.h>
#include <CUnit/Basic.h>

/*
  Variavel para verificar saida de funcoes que abortam o programa.
  Ver node.h gerado na pasta Testes pelo Makefile */
int status_saida = EXIT_SUCCESS;

/* teste de unidade de node.h */
#include "node.h"

Node *arvore = NULL;
Node *filho1 = NULL;
Node *filho2 = NULL;

/* funcoes de inicializacao e termino da suite de testes */
int inicializarSuite() {
    filho1 = create_node(1, int_node, "10", NULL);
    filho2 = create_node(1, int_node, "20", NULL);
    arvore = create_node(1, code_node, NULL, filho1, filho2, NULL);
    if (arvore == NULL) {
        return 1;
    } else {
        return 0;
    }
}

int terminarSuite() {
    return deep_free_node(arvore);
}

/* funcoes de teste */
void testar_create_node() {
    Node *raiz, *folha2;
	Node *folha1 = create_node(1, int_node, "10", NULL);

	/* testa criacao da folha1 */
	CU_ASSERT( folha1->num_line == 1 );
	CU_ASSERT( folha1->type == int_node );
	CU_ASSERT( strcmp(folha1->lexeme, "10") == 0 );
	CU_ASSERT( folha1->first_child == NULL );
	CU_ASSERT( folha1->next_sibling == NULL );

    /* testa um noh com dois filhos (folhas) */
    if (folha1 != NULL) {
        folha2 = create_node(1, int_node, "20", NULL);
	    raiz = create_node(2, code_node, NULL, folha1, folha2, NULL);
	    CU_ASSERT( raiz->num_line == 2 );
	    CU_ASSERT( raiz->type == code_node );
	    CU_ASSERT( raiz->lexeme == NULL );
	    CU_ASSERT_PTR_EQUAL( raiz->first_child, folha1 );
	    CU_ASSERT( raiz->next_sibling == NULL );
	}

    /* testa criacao de noh com tipo invalido */
	raiz = create_node(25, 500, "15", NULL);
	CU_ASSERT( status_saida == EXIT_FAILURE );
	status_saida = EXIT_SUCCESS;
}

void testar_nb_of_children() {
    Node *folha = create_node(1, int_node, "5", NULL);
    CU_ASSERT( nb_of_children(folha) == 0 );
    
    CU_ASSERT( nb_of_children(arvore) == 2 );
    
    nb_of_children(NULL);
    CU_ASSERT( status_saida == EXIT_FAILURE );
    status_saida = EXIT_SUCCESS;
}

void testar_is_leaf() {
    //Node *folha = create_node(1, int_node, "10", NULL);
    CU_ASSERT_TRUE( is_leaf(filho1) );
    
    CU_ASSERT_FALSE( is_leaf(arvore) );
    
    is_leaf(NULL);
    CU_ASSERT( status_saida == EXIT_FAILURE );
    status_saida = EXIT_SUCCESS;
}

void testar_child() {
    CU_ASSERT_PTR_EQUAL( child(arvore, 0), filho1 );
    
    CU_ASSERT_PTR_EQUAL( child(arvore, 1), filho2 );
    
    child(NULL, 0);
    CU_ASSERT( status_saida == EXIT_FAILURE );
    status_saida = EXIT_SUCCESS;
    
    child(arvore, -1);
    CU_ASSERT( status_saida == EXIT_FAILURE );
    status_saida = EXIT_SUCCESS;
    
    child(arvore, 2);
    CU_ASSERT( status_saida == EXIT_FAILURE );
    status_saida = EXIT_SUCCESS;
    
    child(filho1, 0);
    CU_ASSERT( status_saida == EXIT_FAILURE );
    status_saida = EXIT_SUCCESS;
}

void testar_deep_free_node() {
    CU_ASSERT( deep_free_node(arvore) == 0 );
}

void testar_height() {
    CU_ASSERT( height(filho1) == 1 );
    
    CU_ASSERT( height(arvore) == 2 );
}

/* executa os testes */
int main() {
    /* inicializa o array de testes */
    CU_TestInfo testes[] = {
        //{ "testando nomeFuncao()", testar_nomeFuncao },
        { "testando create_node()", testar_create_node },
        { "testando nb_of_children()", testar_nb_of_children },
        { "testando is_leaf()", testar_is_leaf },
        { "testando child()", testar_child },
        { "testando deep_free_node()", testar_deep_free_node },
        { "testando height()", testar_height },
        CU_TEST_INFO_NULL
    };

    /* inicializa o array de suites */
    CU_SuiteInfo suites[] = {
        { "Suite1", inicializarSuite, terminarSuite, testes },
        //{ "Suite1", NULL, NULL, testes },
        CU_SUITE_INFO_NULL
    };

    /* inicializa o registro */
    if (CUE_SUCCESS != CU_initialize_registry()) {
        return CU_get_error();
    }

    /* registra o array de suites */
    if (CUE_SUCCESS != CU_register_suites(suites)) {
        CU_cleanup_registry();
        return CU_get_error();
    }

    /* executa todos os testes */
    CU_basic_set_mode(CU_BRM_VERBOSE);
    CU_basic_run_tests();
    CU_cleanup_registry();

    return CU_get_error();
}
