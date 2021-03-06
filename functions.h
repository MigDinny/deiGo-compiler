#include "structures.h"
// clang-format off


node_t* create_node(char* symbol, int line, int column);
node_t* create_block_node();
node_t* create_literal_node(char *symbol, char *value, int line, int column);
token_t* create_token(char* symbol, char * value, int line, int column);
void add_child(node_t *father, node_t *child);
void add_next(node_t *node, node_t *next);
void print_tree(node_t *root, int init_depth);
int count_children(node_t *first_child);

int insert_element(symtab_t *table, elem_t *new, node_t* origin);
symtab_t* create_table(symtab_t *global, elem_t *origin);
symtab_t* create_global_table();
elem_t* create_element(char *id, char *params, char *type, int isFunction);
void traverseAndPopulateTable(symtab_t *global, node_t *program);
char* traverseAndCheckTree(node_t *n, char *tabname, symtab_t *global);
void printNotedTree(node_t *root, int init_depth, symtab_t *global);
void printTables(symtab_t *global);
void printTableElements(elem_t * element);

elem_t* symtab_look(char *tabname, symtab_t *global, char *id, int ignoreIsDeclared);
int symtab_find_duplicate(symtab_t *tab, char *id);
void throwErrorDeclaredButNeverUsed(symtab_t *global);
char * toLowerFirstChar(char *s);
char * getOperator(char * symbol);
int validReturnType(char *tabname, char *type, symtab_t *global);
void setHits(node_t *n, char *tabname, symtab_t *global);