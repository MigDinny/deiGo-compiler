#include "structures.h"
#include "functions.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

node_t* create_node(char* symbol) {

	node_t *n = (node_t*) malloc(sizeof(node_t));
	token_t *t = (token_t*) malloc(sizeof(token_t));

	t->symbol = symbol;
	//n->type = type;
	n->children = NULL;
	n->next 	= NULL;
	n->token = t;
	n->literal = 0;
	
	return n;
}

node_t* create_block_node() {

	node_t *n = (node_t*) malloc(sizeof(node_t));
	token_t *t = (token_t*) malloc(sizeof(token_t));

	t->symbol = "Block";
	//n->type = type;
	n->children = NULL;
	n->next 	= NULL;
	n->token = t;
	n->literal = 0;
	
	return n;
}

node_t* create_literal_node(char *symbol, char *value) {

	node_t *n = (node_t*) malloc(sizeof(node_t));
	token_t *t = (token_t*) malloc(sizeof(token_t));

	t->symbol = symbol;
	t->value  = value;

	//n->type = type;
	n->children = NULL;
	n->next 	= NULL;
	n->token = t;
	n->literal = 1;

	return n;
}

void add_child(node_t *father, node_t *child) {

	if (father->children == NULL) {
		// create the first child
		father->children = child;
	} else {
		// append to the child list
		node_t *last_child = father->children;
		for (; last_child->next != NULL; last_child = last_child->next);
		last_child->next = child;
	}

}

void add_next(node_t *node, node_t *next) {

	if (node == NULL || next == NULL) return;

	for (; node->next != NULL; node = node->next); // last brother

	node->next = next;
}

void print_tree(node_t *root, int init_depth) {

	int depth = init_depth;

	for (int i = 0; i < depth; i++) printf("..");

	if (root->literal == 0) printf("%s\n", root->token->symbol);
	else if (strcmp(root->token->symbol, "StrLit") == 0) printf("StrLit(\"%s\")\n", root->token->value);
	else printf("%s(%s)\n", root->token->symbol, root->token->value);

	if (root->children != NULL) print_tree(root->children, depth+1);
	if (root->next != NULL) 	print_tree(root->next, depth);

}

int count_children(node_t *first_child) {
	int n = 0;
	for (; first_child != NULL; first_child = first_child->next, n++);
	return n;
}