#include "structures.h"
// clang-format off


node_t* create_node(char* symbol, int line, int column);
node_t* create_literal_node(char *symbol, char *value, int line, int column);
void add_child(node_t *father, node_t *child);
void add_next(node_t *node, node_t *next);
void print_tree(node_t *root, int init_depth);
