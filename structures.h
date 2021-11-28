#ifndef STRUCTURES_H
#define STRUCTURES_H

// this is a token, with a symbol (ID, FUNC, VARDECL etc) and with an optional value (for intlit, strlit etc)
typedef struct token {
	char *symbol;
	char *value;
	int column, line;
} token_t;

// a node has:
//		token [optional]
//		type  [from enum]
// 		children [pointer to the first child (list of nodes associated with this node)]
// 		next	 [pointer to the next child of the same father]
typedef struct node {
	int literal;
	token_t *token;
	char *noted_type;
	struct node *children;
	struct node *next;
} node_t;


typedef struct elem {
	
	char *id;
	char *params;
	char *type;
	int tparam;
	int hits; // # of times this element was accessed for reading
	int column, line;
	int printFuncParams;

	struct elem *next;
	
} elem_t;


typedef struct symtab {
	char *name; // table name
	char *params;
	
	struct symtab *next;
	struct elem   *first_element;
} symtab_t;

#endif
