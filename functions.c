#include "structures.h"
#include "functions.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

node_t* create_node(char* symbol) {

	node_t *n = (node_t*) malloc(sizeof(node_t));
	token_t *t = (token_t*) malloc(sizeof(token_t));

	t->symbol = symbol;
	n->noted_type = NULL;
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
	n->noted_type = NULL;
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

	n->noted_type = NULL;
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




/*
VarDecl
FuncDecl
*/
void insert_element(symtab_t *table, elem_t *new) {
	if (symtab_find_duplicate(table, new->id) == 1) {
		// throw error ALREADY EXISTS
		// TODO: 3 - already defined
	}

	if (table->first_element == NULL)
		table->first_element = new;
	else {
		elem_t *last_element = table->first_element;
		for (; last_element->next != NULL; last_element = last_element->next);
		
		last_element->next = new;
	}
}


symtab_t* create_table(symtab_t *global, elem_t *origin) {
	symtab_t *t = (symtab_t*) malloc(sizeof(symtab_t));
	
	t->name = origin->id;
	t->params = origin->params;
	t->first_element = create_element("return", NULL, origin->type, 0);
	t->next = NULL;

	
	if (global->next == NULL)
		global->next = t;
	else {
		symtab_t *last_table = global->next;
		for (; last_table->next != NULL; last_table = last_table->next);
		
		last_table->next = t;
	}
	

	return t;
}

symtab_t* create_global_table() {
	symtab_t *t = (symtab_t*) malloc(sizeof(symtab_t));

	t->name = NULL;
	t->params = NULL;
	t->first_element = NULL;
	t->next = NULL;

	return t;
}

elem_t* create_element(char *id, char *params, char *type, int isFunction) {
	elem_t *e = (elem_t*) malloc(sizeof(elem_t));
	
	e->id = id;
	e->hits = 0;
	e->line = 0;
	e->column = 0;
	e->params = params;

	if (type == NULL) e->type = "none";
	else e->type = (char*) toLowerFirstChar(type);

	e->next = NULL;
	
	return e;
}


// CALL LIKE THIS: traverseAndPopulateTable(global, program);
void traverseAndPopulateTable(symtab_t *tab, node_t *node) {
	if (tab == NULL || node == NULL) return;
	
	// iterate over all children of CURRENT NODE
	for (node_t *current_node = node->children; current_node != NULL; current_node = current_node->next) {
		// is this a VarDecl or FuncDecl?
		// YES: insert into current table.
			// if it's a FuncDecl, create a new table
			// if it's a ParamDecl, set a flag
		// NO: do nothing!
		if (strcmp(current_node->token->symbol, "VarDecl") == 0) {
			// VARDECL: 1st child > type    2nd child > id
			char *id = current_node->children->next->token->value;
			char *type = current_node->children->token->symbol;

			elem_t *new = create_element(id, NULL, type, 0);

			insert_element(tab, new);
		} else if (strcmp(current_node->token->symbol, "FuncDecl") == 0) {
			// FUNCDECL: 1st child > header
			//           header: 1st child > id   2nd child > returned type    3rd child > funcparams
			//			 funcparams: 1st child > first ParamDecl   .... traverseAndPopulateTable(functab, 1st child of funcparams)
			// 			 2nd child > funcbody ... traverseAndPopulateTable(functab, 1st child of funcbody)

			// get id, type and build params buffer allocating memory when necessary
			char *id = current_node->children->children->token->value;
			char *type = current_node->children->children->next->token->symbol;

			if (current_node->children->children->next->next == NULL) type = NULL; // it means there is only 2 children in FuncHeader, which means type is NULL

		
			// get params nodes 
			node_t *params_node;
			node_t *params_node_father;

			if (type != NULL) {
				params_node = current_node->children->children->next->next->children;
				params_node_father = current_node->children->children->next->next;
			} else {
				params_node = current_node->children->children->next->children;
				params_node_father = current_node->children->children->next;
			}


			// building + allocation
			char *params_buffer = NULL;
			params_buffer = (char*) malloc(10);
			int params_buffer_alloc_size = 10;	

			if (params_node == NULL)
				sprintf(params_buffer, "(");
			else {
				sprintf(params_buffer, "(%s", toLowerFirstChar(params_node->children->token->symbol));
				params_node = params_node->next;
			}
			
			for (; params_node != NULL; params_node = params_node->next) {
				// len params + len next param + 3 chars (comma, space, closing parenthesis)
				if (strlen(params_buffer) + strlen(params_node->children->token->symbol) + 3  >=  params_buffer_alloc_size-1) {
					params_buffer = (char *) realloc(params_buffer, 10);
					params_buffer_alloc_size += 10;
				}

				sprintf(params_buffer + strlen(params_buffer), ", %s", toLowerFirstChar(params_node->children->token->symbol));
			}

			sprintf(params_buffer + strlen(params_buffer), ")");
			

			// build new element
			elem_t *new = create_element(id, params_buffer, type, 1);

			// insert it
			insert_element(tab, new);


			// create new table for this function
			symtab_t *newtab = create_table(tab, new);


			// get funcbody and call RECURSION for the params and then for the func body
			node_t *funcbody = current_node->children->next;
			traverseAndPopulateTable(newtab, params_node_father);
			traverseAndPopulateTable(newtab, funcbody);
						
		} else if (strcmp(current_node->token->symbol, "ParamDecl") == 0) {
			// PARAMDECL: 1st child > type
			//	  		  2nd child > id

			char *type = current_node->children->token->symbol;
			char *id   = current_node->children->next->token->value;

			elem_t *new = create_element(id, NULL, type, 0);
			new->tparam = 1;

			insert_element(tab, new);
		}
	}

}

// CALL traverseAndCheckTree(myprogram, NULL, global);
char* traverseAndCheckTree(node_t *n, char *tabname, symtab_t *global) {
	// nodes to be ignored and stop child processing!
	if (strcmp(n->token->symbol, "VarDecl") == 0 || strcmp(n->token->symbol, "ParamDecl") == 0 || strcmp(n->token->symbol, "FuncHeader") == 0) return NULL; 

	

	// specific nodes which require specific actions 
	if (strcmp(n->token->symbol, "Id") == 0) {
		// symtab_look() here, EXISTS >> fine DOESNT >> throw error
		elem_t *look = symtab_look(tabname, global, n->token->value);
		if (look == NULL) {
			// ERROR NOT DEFINED
			// TODO: 1 - throw not defined error
			n->noted_type = "undef";
			return "undef";
		}

		// note type on tree
		n->noted_type = look->type;

		// return Id type
		return n->noted_type;
	} else if (strcmp(n->token->symbol, "IntLit") == 0) {
		
		// note type on tree
		n->noted_type = "int";
		
		// return INT type
		return n->noted_type;
	} else if (strcmp(n->token->symbol, "RealLit") == 0) {
		// note type on tree
		n->noted_type = "float32";
		// return Float32 type
		return n->noted_type;
	} else if (strcmp(n->token->symbol, "StrLit") == 0) {
		// note type on tree
		n->noted_type = "string";
		// return string type
		return n->noted_type;
	} else if (strcmp(n->token->symbol, "Add") == 0 || strcmp(n->token->symbol, "Sub") == 0 || strcmp(n->token->symbol, "Mul") == 0 || strcmp(n->token->symbol, "Div") == 0 || strcmp(n->token->symbol, "Mod") == 0)  { 
		char *type1 = traverseAndCheckTree(n->children, tabname, global);
		char *type2 = traverseAndCheckTree(n->children->next, tabname, global);
		// compare if both types are equal. YES >> return type of Sub and note type on tree NO >> throw error

		n->noted_type = "operation";
		// return string type
		return n->noted_type;
	} else if (strcmp(n->token->symbol, "Call") == 0) {
		// type is the returned type of the first child (function)

		n->noted_type = "call";
		// return string type
		return n->noted_type;
	} else if (strcmp(n->token->symbol, "Or") == 0 || strcmp(n->token->symbol, "And") == 0  || strcmp(n->token->symbol, "Lt") == 0|| strcmp(n->token->symbol, "Gt") == 0 || strcmp(n->token->symbol, "Eq") == 0 || strcmp(n->token->symbol, "Ne") == 0 || strcmp(n->token->symbol, "Le") == 0 || strcmp(n->token->symbol, "Ge") == 0 ) {
		// return bool type (compares two tokens)
	} else if (strcmp(n->token->symbol, "Not") == 0) {
		// return bool type (only one token)
		// -> NÃO TENHO A CERTEZA QUANTO A ESTE pq não há casos de teste suficientes que mostrem um<-
	} else {
		// it's not a NOTED NODE AND does not require any specific action
		// but needs to process its children
		// if this node is FuncDecl, change tab reference to this function's table
		if (strcmp(n->token->symbol, "FuncDecl") == 0) tabname = n->children->children->token->value;
		for (node_t *first_child = n->children; first_child != NULL; first_child = first_child->next) traverseAndCheckTree(first_child, tabname, global);
	}

}


void printTables(symtab_t *global){

	if (global == NULL) return;

    if (global->name == NULL && global->params == NULL) printf("==== Global Symbol Table ====\n");
    else if (global->params == NULL) printf("==== Function %s() Symbol Table =====\n", global->name);
    else printf("==== Function %s%s Symbol Table =====\n", global->name, global->params);

	printTableElements(global->first_element);

	printf("\n"); 
	printTables(global->next);

}

void printTableElements(elem_t * element){

	if (element == NULL) return;

    // tparam = 0 -> não se mete param à frente

	if (element->params == NULL && element->tparam == 0) printf("%s\t\t%s", element->id, element->type);
	else if (element->params == NULL && element->tparam == 1) printf("%s\t\t%s\tparam", element->id, element->type);
	else if (element->tparam == 0) printf("%s\t%s\t%s", element->id, element->params, element->type);
	else printf("%s\t%s\t%s\tparam", element->id, element->params, element->type);

	printf("\n");

	printTableElements(element->next);

}


void printNotedTree(node_t *root, int init_depth){

    int depth = init_depth;

    for (int i = 0; i < depth; i++) printf("..");

	//printf(":%s:", root->token->symbol);
	//if (root->noted_type == NULL) printf(":NULL:");

    if (root->noted_type == NULL){
        if (root->literal == 0) printf("%s\n", root->token->symbol);
        else if (strcmp(root->token->symbol, "StrLit") == 0) printf("StrLit(\"%s\")\n", root->token->value);
        else printf("%s(%s)\n", root->token->symbol, root->token->value);
    } else {

        if (root->literal == 0) printf("%s - %s\n", root->token->symbol, root->noted_type);
        else if (strcmp(root->token->symbol, "StrLit") == 0) printf("StrLit(\"%s\") - %s\n", root->token->value, root->noted_type);
        else printf("%s(%s) - %s\n", root->token->symbol, root->token->value, root->noted_type);
		
		
		//printf(":::%s:::", root->noted_type);
    }

    if (root->children != NULL) printNotedTree(root->children, depth+1);
    if (root->next != NULL)     printNotedTree(root->next, depth);
}

/* 
	Args: 
		- table to look on
		- global table reference
		- id to find
	
	Return:
		- element found
		- NULL if no element found
*/
elem_t* symtab_look(char *tabname, symtab_t *global, char *id) {
	
	symtab_t * global_aux = global;	
	symtab_t * func_aux = global_aux->next;		
	elem_t * global_aux_element = global->first_element;									
	elem_t * func_aux_element = func_aux->first_element;

	while (strcmp(func_aux->name, tabname) != 0){
		func_aux = func_aux->next;
	}

	// se não há tabela de função, percorre a global
	if (func_aux == NULL){															
		while (global_aux_element != NULL) {
			if ((strcmp(global_aux_element->id, id) != 0)) global_aux_element = global_aux_element->next;
			else if (strcmp(global_aux_element->id, id) == 0) return global_aux_element;
		}
		return NULL;
	}

	// percorre a tabela de função
	else {
		while (func_aux_element != NULL) {
			if (strcmp(func_aux_element->id, id) != 0) func_aux_element = func_aux_element->next;
			else if (strcmp(func_aux_element->id, id) == 0) return func_aux_element;
		}
		while (global_aux_element != NULL) {
			if ((strcmp(global_aux_element->id, id) != 0)) global_aux_element = global_aux_element->next;
			else if (strcmp(global_aux_element->id, id) == 0) return global_aux_element;
		}
		return NULL;
	}	
}

/*
	Args:
		- table to look on
		- id to find duplicate
	
	Return: 
		- 1 > exists
		- 0 > does not exist
*/
int symtab_find_duplicate(symtab_t *tab, char *id) {
		
	symtab_t * func_aux = tab;													
	elem_t * func_aux_element = func_aux->first_element;

	if (func_aux == NULL) return 0;													
	else {
		while (func_aux_element != NULL) {
			if (strcmp(func_aux_element->id, id) != 0) func_aux_element = func_aux_element->next;
			else if (strcmp(func_aux_element->id, id) == 0) return 1;
		}
		return 0;
	}
}

/*
	Args:
		- table global
*/
void throwErrorDeclaredButNeverUsed(symtab_t *global) {		

	symtab_t * global_aux = global;
	elem_t * global_aux_element = global->first_element;

	//TODO: 2 - line, column

	/*
	while (global_aux != NULL){
			while (global_aux_element != NULL) {
				if (global_aux_element->hits == 0) printf("Line %d, column %d: Symbol %s declared but never used\n", line, column, global_aux_element->id);
				global_aux_element = global_aux_element->next;
		}
		global_aux = global_aux->next;
	}
	*/
}

char * toLowerFirstChar(char *s) {
	char *sdup = strdup(s);
	if (s[0] >= 65 && s[0] <= 90) sdup[0] += 32;
	return sdup;
}