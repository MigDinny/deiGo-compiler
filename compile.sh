#!/bin/sh

# run lex and compile the resulting C analyser
flex $1
clang-7 -o $2 lex.yy.c

# 'lex' and 'gcc' are commonly available too