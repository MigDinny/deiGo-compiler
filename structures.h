#ifndef STRUCTURES_H
#define STRUCTURES_H

// needs to be completed with all available types
//typedef enum {PROGRAM, DECLARATION, VARDECLARATION, IF, ELSE} type_e;

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
	//type_e type;
	struct node *children;
	struct node *next;
} node_t;


typedef struct elem_t {
	
	char *id;
	char *params;
	char *type;
	char *tparam;
	
	struct elem_t *next;
	
} elem;


typedef struct symtab_t {
	char *name; // table name
	char *params;
	
	struct symtab_t *next;
	struct elem_t   *first_child;
} symtab;

#endif
