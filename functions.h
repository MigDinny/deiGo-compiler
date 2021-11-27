#include "structures.h"
// clang-format off


node_t* create_node(char* symbol);
node_t* create_block_node();
node_t* create_literal_node(char *symbol, char *value);
void add_child(node_t *father, node_t *child);
void add_next(node_t *node, node_t *next);
void print_tree(node_t *root, int init_depth);
int count_children(node_t *first_child);

void insert_element(symtab_t *table, elem_t *new);
symtab_t* create_table(symtab_t *global, elem_t *origin);
symtab_t* create_global_table();
elem_t* create_element(char *id, char *params, char *type, int isFunction);
void traverseAndPopulateTable(symtab_t *global, node_t *program);
char* traverseAndCheckTree(node_t *n, char *tabname, symtab_t *global);
void printNotedTree(node_t *root, int init_depth, symtab_t *global);
void printTables(symtab_t *global);
void printTableElements(elem_t * element);

elem_t* symtab_look(char *tabname, symtab_t *global, char *id);
int symtab_find_duplicate(symtab_t *tab, char *id);
void throwErrorDeclaredButNeverUsed(symtab_t *global);
char * toLowerFirstChar(char *s);