#if !(defined __HTML_H__)
#define __HTML_H__ 1

#include "Client.h"

const int BUF_SIZE = 1024;
typedef int (*onTagFunc)(Client *, const char * const);
extern void parseHTML(Client *client, onTagFunc onTag);
#endif
