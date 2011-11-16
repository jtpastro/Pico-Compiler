#include "node.h"
#include <stdarg.h>


/**
 * Exemplo de implementação de uma função variádica.
 *
 * A chamada
 *     print_strings("oi", "teste", "123", NULL);
 * imprime as seguintes linhas:
 *     Recebi um 'oi'
 *     Recebi um 'teste'
 *     Recebi um '123'
 *     Recebi ao todo 3 args.
 *
 * @param arg0: First argument of a NULL-terminated
 *      variadic list of char* arguments.
 * @return Nothing.
 */
void print_strings(const char* arg0, ...) {
    va_list ap;
    va_start(ap, arg0);

    int n_args = 0;
    const char* arg;
    for (arg = arg0;  arg != NULL;  arg = va_arg(ap, const char*)) {
        printf("Recebi um '%s'\n", arg);
        n_args ++;
    }
    printf("Recebi ao todo %d args.\n", n_args);
    va_end(ap);
}
