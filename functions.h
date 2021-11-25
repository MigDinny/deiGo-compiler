#include "structures.h"
// clang-format off


node_t* create_node(char* symbol);
node_t* create_block_node();
node_t* create_literal_node(char *symbol, char *value);
void add_child(node_t *father, node_t *child);
void add_next(node_t *node, node_t *next);
void print_tree(node_t *root, int init_depth);
int count_children(node_t *first_child);

void insert_element(symtab *table, elem *new);
symtab* create_table(symtab *global, elem *origin);
elem* create_element(char *id, char *params, char *type, int isFunction);
void traverseAndPopulateTable(symtab *global);
void traverseAndCheckTree();
void printNotedTree(node_t *root, int init_depth);
void printTables(symtab *global);
void printTableElements(elem* element);