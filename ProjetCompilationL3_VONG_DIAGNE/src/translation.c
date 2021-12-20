#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "abstract-tree.h"

void translate_start(FILE *file) {
	fprintf(file, "section .data\n");
	fprintf(file, "global _start\n\n");
}

void translate_end(FILE *file) {
	fprintf(file, "\n_start:\n");
	fprintf(file, "push rbp\n");
	fprintf(file, "mov rbp, rsp\n");
	fprintf(file, "call main\n");
	fprintf(file, "mov rax, 60\n");
	fprintf(file, "syscall \n");
}

void translate_declaration(FILE *file) {
	fprintf(file, "push 0\n");
}

void translate_declaration_fonction(FILE *file, char name[]) {
	fprintf(file, "\n%s:\npush rbp\n", name);
	fprintf(file, "mov rbp, rsp\n");
}

void translate_addsub_divstar(FILE *file, Kind operande) {
	switch(operande) {
		case Add:
			fprintf(file, "pop rcx\n");
			fprintf(file, "pop rax\n");
			fprintf(file, "add rax, rcx\n");
			fprintf(file, "push rax\n");
			break;
		case Sub:
			fprintf(file, "pop rcx\n");
			fprintf(file, "pop rax\n");
			fprintf(file, "sub rax, rcx\n");
			fprintf(file, "push rax\n");
			break;
		case Mult:
			fprintf(file, "pop rax\n");
			fprintf(file, "pop rcx\n");
			fprintf(file, "imul rax, rcx\n");
			fprintf(file, "push rax\n");
			break;
		case Division:
			fprintf(file, "pop rax\n");
			fprintf(file, "pop rcx\n");
			fprintf(file, "xor rdx, rdx\n");
			fprintf(file, "idiv rcx\n");
			fprintf(file, "push rax\n");
			break;
		default:
			break;
	}
}

void translate_assignment(FILE *file, char name[], int address_op) {
	if(address_op != -1) {
		fprintf(file, "pop QWORD [rbp - %d]\n", address_op);
	}
}
