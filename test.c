#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "structures.h"
#include "functions.h"

int main(int argc, char **argv) {


    node_t *myprogram = create_node("Program", 0, 0);

    node_t *func = create_node("Function", 0, 0);

    node_t *params1 = create_node("Params1", 0, 0);
    node_t *params2 = create_node("Params2", 0, 0);

    add_child(myprogram, func);
    add_child(myprogram, params1);
    add_child(func, params2);

    node_t *id = create_literal_node("Id", "main", 0, 0);

    add_child(func, id);

    print_tree(myprogram, 0);

    return 0;
}