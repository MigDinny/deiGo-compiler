#include "structures.h"
#include "functions.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

is_program* insert_program(is_vardec_list* ivl, is_statement_list* isl)
{
	is_program* ip=(is_program*)malloc(sizeof(is_program));

	ip->vlist=ivl;
	ip->slist=isl;

	return ip;
}

is_vardec_list* insert_vardec_list(is_vardec_list* head, is_vardec* iv)
{
        is_vardec_list* ivl=(is_vardec_list*)malloc(sizeof(is_vardec_list));
        is_vardec_list* tmp;

        ivl->val=iv;
        ivl->next=NULL;

        if(head==NULL)
                return ivl;

        for(tmp=head; tmp->next; tmp=tmp->next);
        tmp->next=ivl;

        return head;
}

is_vardec* insert_integer_dec(char* id)
{
	is_vardec* iv=(is_vardec*)malloc(sizeof(is_vardec));
	is_integer_dec* iid=(is_integer_dec*)malloc(sizeof(is_integer_dec));
	
	iid->id=(char*)strdup(id);  /* Por precaucao. Seria apenas necessario copiar o ponteiro, pois o strdup ja foi feito atras*/
	iv->disc_d=d_integer;
	iv->data_vardec.u_integer_dec=iid;
	
	//printf("Inserted a new integer var: %s\n", iv->data_vardec.u_integer_dec->id); 

	return iv;
}

is_vardec* insert_character_dec(char* id)
{
        is_vardec* iv=(is_vardec*)malloc(sizeof(is_vardec));
        is_character_dec* icd=(is_character_dec*)malloc(sizeof(is_character_dec));

        icd->id=(char*)strdup(id);  /* Por precaucao. Seria apenas necessario copiar o ponteiro, pois o strdup ja foi feito atras*/
        iv->disc_d=d_character;
        iv->data_vardec.u_character_dec=icd;

	//printf("Inserted a new char var: %s\n", iv->data_vardec.u_character_dec->id);

        return iv;
}

is_vardec* insert_double_dec(char* id)
{
        is_vardec* iv=(is_vardec*)malloc(sizeof(is_vardec));
        is_double_dec* idd=(is_double_dec*)malloc(sizeof(is_double_dec));

        idd->id=(char*)strdup(id);  /* Por precaucao. Seria apenas necessario copiar o ponteiro, pois o strdup ja foi feito atras*/
        iv->disc_d=d_double;
        iv->data_vardec.u_double_dec=idd;

	//printf("Inserted a new double var: %s\n", iv->data_vardec.u_double_dec->id);

        return iv;
}


is_statement_list* insert_statement_list(is_statement_list* head, is_statement* is)
{
	is_statement_list* isl=(is_statement_list*)malloc(sizeof(is_statement_list));
	is_statement_list* tmp;	

	isl->val=is;
	isl->next=NULL;

	if(head==NULL)
		return isl;

	for(tmp=head; tmp->next; tmp=tmp->next);
	tmp->next=isl;

	return head;
}

is_statement* insert_write_statement(char* id)
{
	is_statement* is=(is_statement*)malloc(sizeof(is_statement));
	is_write_statement* iws=(is_write_statement*)malloc(sizeof(is_write_statement));

	iws->id=(char*)strdup(id);
	is->disc_d=d_write;
	is->data_statement.u_write_statement=iws;

	return is;
	
}

void print_program(is_program * ip) {

	printf("Program\n");

	print_vardec_list(ip->vlist);

	print_statement_list(ip->slist);

}

void print_vardec_list(is_vardec_list * ivl) {

	printf(" Vardeclist\n");

	is_vardec_list* aux = ivl;

	for (; aux != NULL; aux = aux->next) print_vardec(aux->val);

}

void print_vardec(is_vardec* iv) {
	
	switch (iv->disc_d) {
		case d_integer:
			printf("  VardecInteger(%s)\n", iv->data_vardec.u_integer_dec->id);
			break;
		case d_character:
			printf("  VardecCharacter(%s)\n", iv->data_vardec.u_character_dec->id);
			break;
		case d_double:
			printf("  VardecDouble(%s)\n", iv->data_vardec.u_double_dec->id);
			break;
	}

}

void print_statement_list(is_statement_list* isl) {
	printf(" Statementlist\n");
	is_statement_list *aux = isl;

	for (; aux != NULL; aux = aux->next) {
		print_statement(aux->val);
	}
}

void print_statement(is_statement* is) {
	printf("  StatementWrite(%s)\n", is->data_statement.u_write_statement->id);
}