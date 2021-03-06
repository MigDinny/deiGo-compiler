#include "structures.h"
#include "functions.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

extern int yycolumnno_aux;
extern int yylineno_aux;
extern int errorsSemanticNo;
extern int flagS;

int searchFunctionFlag = 0; // tells the symlook that we're searching for a function, not a variable, when looking for an id

node_t* create_node(char* symbol, int line, int column) {

	node_t *n = (node_t*) malloc(sizeof(node_t));
	token_t *t = (token_t*) malloc(sizeof(token_t));

	t->symbol = symbol;
	n->noted_type = NULL;
	n->children = NULL;
	n->next 	= NULL;
	n->token = t;
	n->literal = 0;
	n->line = line;
	n->column = column;
	n->isCallFunction = 0;
	
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

node_t* create_literal_node(char *symbol, char *value, int line, int column) {

	node_t *n = (node_t*) malloc(sizeof(node_t));
	token_t *t = (token_t*) malloc(sizeof(token_t));

	t->symbol = symbol;
	t->value  = value;

	n->noted_type = NULL;
	n->children = NULL;
	n->next 	= NULL;
	n->token = t;
	n->literal = 1;
	n->line = line;
	n->column = column;

	return n;
}

token_t* create_token(char* symbol, char * value, int line, int column){
	token_t *t = (token_t *)malloc(sizeof(token_t));
	t->symbol = symbol;
	t->value = value;
    t->line = line;
    t->column = column;
    return t;
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

returns 1 if sucess
0 if duplicate
*/
int insert_element(symtab_t *table, elem_t *new, node_t * origin) {
	
	new->line = origin->line;
	new->column = origin->column; 

	if (symtab_find_duplicate(table, new->id) == 1) {
		// throw error ALREADY EXISTS
		printf("Line %d, column %d: Symbol %s already defined\n", origin->line, origin->column, new->id);
		errorsSemanticNo++;
		return 0;
	}

	if (table->first_element == NULL)
		table->first_element = new;
	else {
		elem_t *last_element = table->first_element;
		for (; last_element->next != NULL; last_element = last_element->next);
		
		last_element->next = new;
	}

	return 1;
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
	e->isDeclared = 0;
	e->isFunction = isFunction;
	
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

			// printf("\n\nINSERT ELEMENT\nNODE -> Line: %d, Column: %d\nELEMENT -> Line %d, Column: %d\n\n", current_node->children->next->line, current_node->children->next->column, new->line, new->column);
			insert_element(tab, new, current_node->children->next);
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
			params_buffer[0] = 0;
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
					params_buffer = (char *) realloc(params_buffer, params_buffer_alloc_size + 10);
					params_buffer_alloc_size += 10;
				}

				sprintf(params_buffer + strlen(params_buffer), ",%s", toLowerFirstChar(params_node->children->token->symbol));
			}

			sprintf(params_buffer + strlen(params_buffer), ")");
			

			// build new element
			elem_t *new = create_element(id, params_buffer, type, 1);

			// insert it
			int status = insert_element(tab, new, current_node->children->children);

			if (status == 1) {
				// create new table for this function
				symtab_t *newtab = create_table(tab, new);


				// get funcbody and call RECURSION for the params and then for the func body
				node_t *funcbody = current_node->children->next;
				traverseAndPopulateTable(newtab, params_node_father);
				traverseAndPopulateTable(newtab, funcbody);
			} else {
				free(new);
				current_node->invalidFuncDecl = 1;
				//setHits(current_node->children->next, current_node->children->children->token->value, tab);
			}
						
		} else if (strcmp(current_node->token->symbol, "ParamDecl") == 0) {
			// PARAMDECL: 1st child > type
			//	  		  2nd child > id

			char *type = current_node->children->token->symbol;
			char *id   = current_node->children->next->token->value;

			elem_t *new = create_element(id, NULL, type, 0);
			new->tparam = 1;
			new->isDeclared = 1;

			insert_element(tab, new, current_node->children->next);
		}
	}

}

// CALL traverseAndCheckTree(myprogram, NULL, global);
char* traverseAndCheckTree(node_t *n, char *tabname, symtab_t *global) {
	// nodes to be ignored and stop child processing!
	if (strcmp(n->token->symbol, "VarDecl") == 0 || strcmp(n->token->symbol, "ParamDecl") == 0 || strcmp(n->token->symbol, "FuncHeader") == 0) {
		if (strcmp(n->token->symbol, "VarDecl") == 0) {
					//printf("<%s>ready; \n", n->children->next->token->value);

			elem_t *look = symtab_look(tabname, global, n->children->next->token->value, 1);
			//printf("[%s]", look);
			// if it's a variable, set declared to true
			if (look == NULL) return NULL;
			look->isDeclared = 1;
			//printf("<%s>declared; \n", n->children->next->token->value);
		}

		return NULL;
	} 

	// specific nodes which require specific actions 
	//TODO: adicionar casos "ParseArgs" (erro em "errors_parseargs.out") e "Print" (erro em "statements_expressions.out")
	if (strcmp(n->token->symbol, "Id") == 0) {
		// symtab_look() here, EXISTS >> fine DOESNT >> throw error
		elem_t *look = symtab_look(tabname, global, n->token->value, 0);
		n->funcTabName = tabname;
		//printf("<%s|%s>", look->id, look->type);
		if (look == NULL) {
			// ERROR NOT DEFINED
			printf("Line %d, column %d: Cannot find symbol %s\n", n->line, n->column, n->token->value);
			errorsSemanticNo++;
			n->noted_type = "undef";
			return "undef";
		}

		// note type on tree
		n->noted_type = look->type;
		look->hits++;
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
	} else if (strcmp(n->token->symbol, "Sub") == 0 || strcmp(n->token->symbol, "Mul") == 0 || strcmp(n->token->symbol, "Div") == 0 || strcmp(n->token->symbol, "Mod") == 0)  { 
		// both types must be equal and must be INT or FLOAT32
		char *type1 = traverseAndCheckTree(n->children, tabname, global);
		char *type2 = traverseAndCheckTree(n->children->next, tabname, global);
		
		if ( (strcmp(type1, "int") == 0 && strcmp(type2, "int") == 0) || (strcmp(type1, "float32") == 0 && strcmp(type2, "float32") == 0) ) {
			// INT-INT or FLOAT-FLOAT	
			n->noted_type = type1;
			return n->noted_type;
		}

		// the types dont meet the above requirements
		printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n", n->line, n->column, getOperator(n->token->symbol), type1, type2);
		errorsSemanticNo++;
		n->noted_type = "undef";
		return n->noted_type;
	} else if (strcmp(n->token->symbol, "Add") == 0) {

		// both types must be equal and must be INT or FLOAT32 or STRING
		char *type1 = traverseAndCheckTree(n->children, tabname, global);
		char *type2 = traverseAndCheckTree(n->children->next, tabname, global);
		
		if ( (strcmp(type1, "int") == 0 && strcmp(type2, "int") == 0) || (strcmp(type1, "float32") == 0 && strcmp(type2, "float32") == 0) || (strcmp(type1, "string") == 0 && strcmp(type2, "string") == 0) ) {
			// INT-INT or FLOAT-FLOAT or STRING-STRING
			n->noted_type = type1;
			return n->noted_type;
		}

		// the types dont meet the above requirements
		printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n", n->line, n->column, getOperator(n->token->symbol), type1, type2);
		errorsSemanticNo++;
		n->noted_type = "undef";
		return n->noted_type;

	} else if (strcmp(n->token->symbol, "Call") == 0) {
		//printf("CALL isCallFunction: %d\n", n->children->isCallFunction);
		node_t *first_child = n->children;
		// call recursively on params first
		for (first_child = first_child->next; first_child != NULL; first_child = first_child->next) traverseAndCheckTree(first_child, tabname, global);

		first_child = n->children;
		
		searchFunctionFlag = 1; // turn on flag
		elem_t *look = symtab_look(tabname, global, first_child->token->value, 0);
		searchFunctionFlag = 0; // turn off flag

		if (look == NULL) {
			// ERROR NOT DEFINED
			first_child = n->children;
			first_child->noted_type = "undef";
			//TODO: o erro "cannot find symbol" est?? printar "g(int, none)" em vez de "g(int,none") ; tirar esse espa??o
			printf("Line %d, column %d: Cannot find symbol %s(", first_child->line, first_child->column, first_child->token->value);
			errorsSemanticNo++;
			first_child = n->children->next;

			for (; first_child != NULL; first_child = first_child->next) {
				if (first_child->next == NULL ) printf("%s", first_child->noted_type);
				else printf("%s,", first_child->noted_type);
			}
			printf(")\n");

			n->noted_type = "undef";
			n->children->noted_type = "undef";
			return "undef";
		}
		n->children->printFuncParams = 1;
		
		// check each parameter against declared parameters
		char *substring = (char *) malloc(strlen(look->params));
		substring[0] = 0;
		//printf("$%s$\n", look->params);
		strncpy(substring, look->params + 1, strlen(look->params)-2);

		
		char *declared_param = strtok(substring, ",");
		node_t *param_node = n->children->next; // first parameter called

		int errors = 0;

		char *called_parameters_buffer = (char *) malloc(20);
		called_parameters_buffer[0] = 0;
		int called_parameters_buffer_alloc_size = 20;

		

		while (declared_param != NULL) {
			// number of called params and declared params dont match
			if (param_node == NULL) { errors++; break;}

			// parameter types and declared parameter types dont match
			if ( strcmp(param_node->noted_type, declared_param) != 0 ) { /*printf("|<%s>-<%s>|\n", param_node->noted_type, declared_param);*/ errors++; }

			// append to called_parameters_buffer the noted_type
			
			// check if needs realloc
			if (strlen(called_parameters_buffer) + strlen(param_node->noted_type) + 3 >= called_parameters_buffer_alloc_size - 1) {
				called_parameters_buffer = (char *) realloc(called_parameters_buffer, called_parameters_buffer_alloc_size + 20);
				called_parameters_buffer_alloc_size += 20;
			}
			
			sprintf(called_parameters_buffer + strlen(called_parameters_buffer), ",%s", param_node->noted_type);
		
			param_node = param_node->next; 
			declared_param = strtok(NULL, ",");
		}

		if (param_node != NULL) {
			errors++;

			while (param_node != NULL) {
				// check if needs realloc
				if (strlen(called_parameters_buffer) + strlen(param_node->noted_type) + 3 >= called_parameters_buffer_alloc_size - 1) {
					called_parameters_buffer = (char *) realloc(called_parameters_buffer, called_parameters_buffer_alloc_size + 20);
					called_parameters_buffer_alloc_size += 20;
				}
				
				sprintf(called_parameters_buffer + strlen(called_parameters_buffer), ",%s", param_node->noted_type);

				param_node = param_node->next;
			}
		}

		n->children->noted_params = look->params;

		if (errors > 0) {
			//printf("<<%s>>\n", param_node->token->symbol);
			printf("Line %d, column %d: Cannot find symbol %s(%s)\n", n->children->line, n->children->column, n->children->token->value, called_parameters_buffer + 1);
			errorsSemanticNo++;
			n->noted_type = "undef";
			n->children->noted_type = "undef";
			//look->params = "(undef)";
			n->children->noted_params = "undef";
			//printf("<%s,%s>", n->children->token->value, n->children->noted_params);
			return "undef";
		}
		
		// type is the returned type of the first child (function)
		n->noted_type = look->type;
		n->children->noted_type = look->type;
		return n->noted_type;
	} else if (strcmp(n->token->symbol, "Lt") == 0 || strcmp(n->token->symbol, "Gt") == 0 || strcmp(n->token->symbol, "Le") == 0 || strcmp(n->token->symbol, "Ge") == 0 ) {
		// these require to be BOTH INT or BOTH FLOAT32
		char *type1 = traverseAndCheckTree(n->children, tabname, global);
		char *type2 = traverseAndCheckTree(n->children->next, tabname, global);
	
		if (  (strcmp(type1, "int") == 0 && strcmp(type2, "int") == 0)  || (strcmp(type1, "float32") == 0 && strcmp(type2, "float32") == 0) ) {
			// both types are int
			n->noted_type = "bool";
			return n->noted_type;
		}

		// both types are not INT or FLOAT32, throw error
		printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n", n->line, n->column, getOperator(n->token->symbol), type1, type2);
		errorsSemanticNo++;
		n->noted_type = "bool";
		return n->noted_type;
	} else if ( strcmp(n->token->symbol, "Eq") == 0 || strcmp(n->token->symbol, "Ne") == 0 ) {
		
		// these require to be BOTH INT or BOTH FLOAT32 or BOTH BOOL
		char *type1 = traverseAndCheckTree(n->children, tabname, global);
		char *type2 = traverseAndCheckTree(n->children->next, tabname, global);
	
		if (  (strcmp(type1, "int") == 0 && strcmp(type2, "int") == 0)  || (strcmp(type1, "float32") == 0 && strcmp(type2, "float32") == 0) || (strcmp(type1, "bool") == 0 && strcmp(type2, "bool") == 0) ) {
			// both types are int
			n->noted_type = "bool";
			return n->noted_type;
		}

		// both types are not INT or FLOAT32, throw error
		printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n", n->line, n->column, getOperator(n->token->symbol), type1, type2);
		errorsSemanticNo++;
		n->noted_type = "bool";
		return n->noted_type;

	} else if (strcmp(n->token->symbol, "Or") == 0 || strcmp(n->token->symbol, "And") == 0 ) {
		// OR and AND require both children to be BOOL

		char *type1 = traverseAndCheckTree(n->children, tabname, global);
		char *type2 = traverseAndCheckTree(n->children->next, tabname, global);

		if (strcmp(type1, "bool") == 0 && strcmp(type2, "bool") == 0) {
			// both types are BOOL, proceed
			n->noted_type = "bool";
			return n->noted_type;
		}

		// both types are NOT bool, throw error
		printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n", n->line, n->column, getOperator(n->token->symbol), type1, type2);
		errorsSemanticNo++;
		n->noted_type = "bool";
		return n->noted_type;
	} else if (strcmp(n->token->symbol, "Not") == 0) {
		// the only child must be bool
		char *type1 = traverseAndCheckTree(n->children, tabname, global);
		
		// child is bool
		if (strcmp(type1, "bool") == 0) {
			n->noted_type = "bool";
			return n->noted_type;
		}

		// child is not bool
		printf("Line %d, column %d: Operator %s cannot be applied to type %s\n", n->line, n->column, getOperator(n->token->symbol), type1);
		errorsSemanticNo++;
		n->noted_type = "bool";
		return n->noted_type;

	} else if (strcmp(n->token->symbol, "Assign") == 0) {
		// assigned type must be the same as the variable's type receiving the value
		char *type1 = traverseAndCheckTree(n->children, tabname, global);
		char *type2 = traverseAndCheckTree(n->children->next, tabname, global);

		// the types are not equal or one of them is UNDEF, throw error
		if (strcmp(type1, type2) != 0 || strcmp(type1, "undef") == 0 || strcmp(type2, "undef") == 0) {
			printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n", n->line, n->column, getOperator(n->token->symbol), type1, type2);
			errorsSemanticNo++;
		}
		// no need to set noted_type
		n->noted_type = type1;
		return n->noted_type;
	} else if (strcmp(n->token->symbol, "For") == 0 || strcmp(n->token->symbol, "If") == 0) {
		// process children first
		for (node_t *first_child = n->children; first_child != NULL; first_child = first_child->next) traverseAndCheckTree(first_child, tabname, global);

		if (n->children->noted_type == NULL) return NULL;

		// expression inside FOR and IF must be BOOL
		if (strcmp(n->children->noted_type, "bool") != 0) {
			printf("Line %d, column %d: Incompatible type %s in %s statement\n", n->children->line, n->children->column, n->children->noted_type, toLowerFirstChar(n->token->symbol));
			errorsSemanticNo++;
		} 

		// return NULL anyways, because FOR doesn't have any noted_type
		return NULL;
	} else if (strcmp(n->token->symbol, "Minus") == 0 || strcmp(n->token->symbol, "Plus") == 0) {
		// process child
		char *type1 = traverseAndCheckTree(n->children, tabname, global);

		if (strcmp(type1, "float32") != 0 && strcmp(type1, "int") != 0) {
			printf("Line %d, column %d: Operator %s cannot be applied to type %s\n", n->line, n->column, getOperator(n->token->symbol), type1);
			errorsSemanticNo++;
			n->noted_type = "undef";
		} else n->noted_type = n->children->noted_type;

		
		return n->noted_type;
	} else if (strcmp(n->token->symbol, "ParseArgs") == 0) {
		char *type1 = traverseAndCheckTree(n->children, tabname, global);
		char *type2 = traverseAndCheckTree(n->children->next, tabname, global);
		
		// the types are not equal, throw error
		if (strcmp(type1, "int") != 0 || strcmp(type2, "int") != 0) {
			printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n", n->line, n->column, getOperator(n->token->symbol), type1, type2);
			errorsSemanticNo++;
		}
		
		n->noted_type = "int";
		return n->noted_type;
	} else if (strcmp(n->token->symbol, "Print") == 0) {
		char *type1 = traverseAndCheckTree(n->children, tabname, global);

		if (strcmp(type1, "undef") == 0) {
			// incompatible type
			printf("Line %d, column %d: Incompatible type %s in %s statement\n", n->line, n->column, n->children->noted_type, getOperator(n->token->symbol));
			errorsSemanticNo++;
		}

		return NULL;
	} else if (strcmp(n->token->symbol, "Return") == 0) {
		if (n->children == NULL) return NULL;
		
		traverseAndCheckTree(n->children, tabname, global);

		// check if return type is the same as required by the function
		int valid = validReturnType(tabname, n->children->noted_type, global);

		if (valid == 0) { 
			printf("Line %d, column %d: Incompatible type %s in %s statement\n", n->children->line, n->children->column, n->children->noted_type, getOperator(n->token->symbol));
			errorsSemanticNo++;
		}

		return NULL;
	} else {
		
		// it's not a NOTED NODE AND does not require any specific action
		// but needs to process its children
		// if this node is FuncDecl, change tab reference to this function's table
		// if this node is an invalid funcdecl, dont process its children
		if (strcmp(n->token->symbol, "FuncDecl") == 0 && n->invalidFuncDecl == 1) return NULL;
		if (strcmp(n->token->symbol, "FuncDecl") == 0) tabname = n->children->children->token->value;
		for (node_t *first_child = n->children; first_child != NULL; first_child = first_child->next) traverseAndCheckTree(first_child, tabname, global);
	}

	// we may never get here, but if we do, we have a problem...
	return NULL;
}

void printTables(symtab_t *global){

	if (global == NULL) return;

    if (global->name == NULL && global->params == NULL) printf("===== Global Symbol Table =====\n");
    else if (global->params == NULL) printf("===== Function %s() Symbol Table =====\n", global->name);
    else printf("===== Function %s%s Symbol Table =====\n", global->name, global->params);

	printTableElements(global->first_element);

	printf("\n"); 
	printTables(global->next);

}

void printTableElements(elem_t * element){

	if (element == NULL) return;

    // tparam = 0 -> n??o se mete param ?? frente
	if (element->isFunction == 1) printf("%s\t%s\t%s", element->id, element->params, element->type);
	else if (element->tparam == 0) printf("%s\t\t%s", element->id, element->type);
	else if (element->tparam == 1) printf("%s\t\t%s\tparam", element->id, element->type);
	//printf("  > %d", element->hits);

	printf("\n");

	printTableElements(element->next);

}

void printNotedTree(node_t *root, int init_depth, symtab_t *global){

    int depth = init_depth;

    for (int i = 0; i < depth; i++) printf("..");

    if (root->noted_type == NULL){
        if (root->literal == 0) printf("%s\n", root->token->symbol);
        else if (strcmp(root->token->symbol, "StrLit") == 0) printf("StrLit(\"%s\")\n", root->token->value);
        else printf("%s(%s)\n", root->token->symbol, root->token->value);
    } else {
		if (strcmp(root->token->symbol, "Call") == 0 && strcmp(root->noted_type, "none") == 0) printf("Call\n");
        else if (root->literal == 0) printf("%s - %s\n", root->token->symbol, root->noted_type);
        else if (strcmp(root->token->symbol, "StrLit") == 0) printf("StrLit(\"%s\") - %s\n", root->token->value, root->noted_type);
        else { // ?? literal
			if (strcmp(root->token->symbol, "Id") == 0){
				//printf("FLAG isCallFunction: %d\n", root->isCallFunction);
				if (root->isCallFunction == 1) searchFunctionFlag = 1;
				elem_t * look = symtab_look(root->funcTabName, global, root->token->value, 0);
				searchFunctionFlag = 0;

				if (look == NULL) printf("%s(%s) - undef\n", root->token->symbol, root->token->value);
				else {
					if (root->printFuncParams == 0) printf("%s(%s) - %s\n", root->token->symbol, root->token->value, root->noted_type); // ?? vari??vel
					else {
						//printf("%s(%s) - %s\n", root->token->symbol, root->token->value, look->params);						  // ?? funcao
						printf("%s(%s) - %s\n", root->token->symbol, root->token->value, root->noted_params);	
					}
				}
			}
			else printf("%s(%s) - %s\n", root->token->symbol, root->token->value, root->noted_type);
			
		}
    }

    if (root->children != NULL) printNotedTree(root->children, depth+1, global);
    if (root->next != NULL)     printNotedTree(root->next, depth, global);
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
elem_t* symtab_look(char *tabname, symtab_t *global, char *id, int ignoreIsDeclared) {
	symtab_t *func = global->next;
	elem_t *found;
	
	//printf("FIND: <%s><%s>", id, tabname);

	if (tabname != NULL) {
		while (func != NULL) {
			if (strcmp(func->name, tabname) == 0) break;
			func = func->next;
		}
		if (func == NULL) return NULL; // appears to be element not found but in reality is func not found. should raise some kind of exception, because this shouldnt never happen. 

		found = func->first_element;

		while (found != NULL) {

			// if we are looking for a variable OR a function
			if (searchFunctionFlag == 0) {
				if (strcmp(found->id, id) == 0 && found->isFunction == 0 && (found->isDeclared == 1 || ignoreIsDeclared == 1)) break;
			} else {
				if (strcmp(found->id, id) == 0 && found->isFunction == 1) break;
			}

			found = found->next;
		
		}
		if (found != NULL) return found; // element found
	}

	found = global->first_element;
	while (found != NULL) {
			//printf("(%s)\n", found->id);

		// if we are looking for a variable OR a function
		if (searchFunctionFlag == 0) {
			if (strcmp(found->id, id) == 0 && found->isFunction == 0 && (found->isDeclared == 1 || ignoreIsDeclared == 1)) break;
		} else {
			if (strcmp(found->id, id) == 0 && found->isFunction == 1) break;
		}

		found = found->next;
	}

	return found; // will return NULL if not found in global, will return the element if it is found

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
	symtab_t * global_aux = global->next;

	if (global_aux == NULL) return; // no need to continue, we dont throw errors in global table and there are no other tables

	elem_t * global_aux_element = NULL;
	global_aux_element = global_aux->first_element;

	// printf("\n\n--- MAIN -> THROW_ERROR_DECLARED_BUT_NEVER_USED ---\n\n");
	while (global_aux != NULL){
			while (global_aux_element != NULL) {
				//printf("<%s>", global_aux_element->id);
				
				// printf("Element id: %s -- params %s -- type %s -- line %d -- column %d\n", global_aux_element->id, global_aux_element->params, global_aux_element->type, global_aux_element->line, global_aux_element->column);
				if (global_aux_element->hits == 0 && global_aux_element->params == NULL && global_aux_element->tparam == 0 && strcmp(global_aux_element->id, "return") != 0) {
					printf("Line %d, column %d: Symbol %s declared but never used\n", global_aux_element->line, global_aux_element->column, global_aux_element->id);
					errorsSemanticNo++;
				}

				global_aux_element = global_aux_element->next;
		}
		global_aux = global_aux->next;
		if (global_aux != NULL) global_aux_element = global_aux->first_element->next;
	}

}

char * toLowerFirstChar(char *s) {
	char *sdup = strdup(s);
	if (s[0] >= 65 && s[0] <= 90) sdup[0] += 32;
	return sdup;
}

char * getOperator(char * symbol){
	if (strcmp(symbol, "Or") == 0) return "||";
	else if (strcmp(symbol, "And") == 0) return "&&";
	else if (strcmp(symbol, "Lt") == 0) return "<";
	else if (strcmp(symbol, "Gt") == 0) return ">";
	else if (strcmp(symbol, "Assign") == 0) return "=";
	else if (strcmp(symbol, "Eq") == 0) return "==";
	else if (strcmp(symbol, "Ne") == 0) return "!=";
	else if (strcmp(symbol, "Ge") == 0) return ">=";
	else if (strcmp(symbol, "Le") == 0) return "<=";
	else if (strcmp(symbol, "Not") == 0) return "!";
	else if (strcmp(symbol, "Add") == 0 || strcmp(symbol, "Plus") == 0) return "+";
	else if (strcmp(symbol, "Sub") == 0 || strcmp(symbol, "Minus") == 0) return "-";
	else if (strcmp(symbol, "Div") == 0) return "/";
	else if (strcmp(symbol, "Mul") == 0) return "*";
	else if (strcmp(symbol, "Mod") == 0) return "%";
	else if (strcmp(symbol, "ParseArgs") == 0) return "strconv.Atoi";
	else if (strcmp(symbol, "Return") == 0) return "return";
	else if (strcmp(symbol, "Print") == 0) return "fmt.Println";
	else return symbol;
}

int validReturnType(char *tabname, char *type, symtab_t *global) {

	elem_t *elem = global->first_element;

	while (elem != NULL) {
		if (elem->isFunction == 1) {
			if (strcmp(elem->id, tabname) == 0 && strcmp(elem->type, type) == 0) return 1;
		}

		elem = elem->next;
	}

	return 0;
}

void setHits(node_t *n, char *tabname, symtab_t *global) {
	if (n == NULL) return;
	if (strcmp(n->token->symbol, "VarDecl") == 0) return;
	
	if ( strcmp(n->token->symbol, "Id") == 0) {
		elem_t *look = symtab_look(tabname, global, n->token->value, 0);
		if (look != NULL) look->hits++;
	} 

	// continue to next node and children node
	setHits(n->children, tabname, global);
	setHits(n->next, tabname, global);
}