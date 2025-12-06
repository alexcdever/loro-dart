/* Loro FFI Bindings */

#ifndef LORO_FFI_H
#define LORO_FFI_H

#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct loroLoroDoc loroLoroDoc;

struct loroLoroDoc *loro_doc_new(void);

void loro_doc_insert_text(struct loroLoroDoc *doc, const char *text);

char *loro_doc_get_text(const struct loroLoroDoc *doc);

void loro_doc_free(struct loroLoroDoc *doc);

void loro_string_free(char *s);

#endif  /* LORO_FFI_H */
