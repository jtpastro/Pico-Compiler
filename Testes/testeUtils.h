extern int status_saida;

#define exit(status) status_saida = status; return NULL
