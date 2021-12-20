/* abstract-tree.c */
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "abstract-tree.h"
extern int yylineno;       /* from lexer */

static const char *StringFromKind[] = {
  "Program",
  "VarDeclList",
  "IntLiteral",
  "CharLiteral",
  "Identifier",
  "Return",
  "Add",
  "Sub",
  "Mult",
  "Division",
  "Type",
  "Var",
  "FuncDeclList",
  "FuncDec",
  "Affectation",
  "ListParam",
  "ListArg",
  "Void",
  "Corps",
  "InstrList",
  "Or",
  "And",
  "Equals",
  "Different",
  "If",
  "Then",
  "Else",
  "While",
  "Print",
  "GreaterThan",
  "GreaterOrEqual",
  "LesserThan",
  "LesserOrEqual",
  "Struct",
  "StructName",
  "CreateStruct",
  "CorpsStruct",
  "AppelFonction",
  "Reade",
  "Readc",
  /* and all other node labels */
  /* The list must coincide with the enum in abstract-tree.h */
  /* To avoid listing them twice, see https://stackoverflow.com/a/10966395 */
};

#define MAXSYMBOLS 256
int STmax = MAXSYMBOLS; /* maximum size of symbol table */

Node *makeNode(Kind kind) {
  Node *node = malloc(sizeof(Node));
  if (!node) {
    printf("Run out of memory\n");
    exit(1);
  }
  node->kind = kind;
  node-> firstChild = node->nextSibling = NULL;
  node->lineno=yylineno;
  return node;
}

void addSibling(Node *node, Node *sibling) {
  Node *curr = node;
  while (curr->nextSibling != NULL) {
    curr = curr->nextSibling;
  }
  curr->nextSibling = sibling;
}

void addChild(Node *parent, Node *child) {
  if (parent->firstChild == NULL) {
    parent->firstChild = child;
  }
  else {
    addSibling(parent->firstChild, child);
  }
}

void deleteTree(Node *node) {
  if (node->firstChild) {
    deleteTree(node->firstChild);
  }
  if (node->nextSibling) {
    deleteTree(node->nextSibling);
  }
  free(node);
}

void printTree(Node *node) {
  static bool rightmost[128]; // current node is rightmost sibling
  static int depth = 0;       // depth of current node
  //printf("Test: \n");
  for (int i = 1; i < depth; i++) { // 2502 = vertical line
    printf(rightmost[i] ? "    " : "\u2502   ");
  }
  if (depth > 0) { // 2514 = up and right; 2500 = horiz; 251c = vertical and right 
    printf(rightmost[depth] ? "\u2514\u2500\u2500 " : "\u251c\u2500\u2500 ");
  }
  printf("%s", StringFromKind[node->kind]);
  switch (node->kind) {
    case IntLiteral: printf(": %d", node->u.integer); break;
    case CharLiteral: printf(": '%c'", node->u.character); break;
    case Identifier: printf(": %s", node->u.identifier); break;
	case Type: printf(": %s", node->u.identifier); break;
	case StructName: printf(": %s", node->u.identifier); break;
    default: break;
  }
  printf("\n");
  depth++;
  for (Node *child = node->firstChild; child != NULL; child = child->nextSibling) {
    rightmost[depth] = (child->nextSibling) ? false : true;
    printTree(child);
  }
  depth--;
}

void addVar(STentry *table, const char name[], char *type) {
    int count;
    for (count = 0; count < table->STsize; count++) {
        if (!strcmp(table[count].name, name)) {
            printf("semantic error, redefinition of variable %s near line %d\n", name, yylineno);
            return;
        }
    }
    if (++table->STsize > STmax) {
        printf("too many variables near line %d\n", yylineno);
        exit(1);
    }
    table[table->STsize-1].var_fonc = 0;
    strcpy(table[table->STsize-1].name, name);
    strcpy(table[table->STsize-1].type, type);
}

void printSymbolTable(STentry *table) {
    for (int i = 0; i < table->STsize; i++) {
      switch(table[i].var_fonc) {
        case 0: printf("VAR  | %s | %s\n", table[i].name, table[i].type); break;
        case 1: printf("FONC | %s | %s\n", table[i].name, table[i].type); break;
        case 2: printf("PAR | %s | %s\n", table[i].name, table[i].type); break;
        case 3: printf("STRUCT | %s | %s\n", table[i].name, table[i].type); break;
      }
    }
}

char* find_type(STentry *table, char name[]) {
	for (int i = 0; i < table->STsize; i++) {
		if(strcmp(table[i].name, name) == 0)
			return table[i].type;
	}
	return "null";
}

STentry *createSymbolTable() {
  STentry *symbolTable = malloc(STmax*sizeof*symbolTable);
  if (!symbolTable) {
    printf("Run out of memory (STentry)\n");
    exit(3);
  }
  symbolTable->var_fonc = 0;
  symbolTable->STsize = 0;
  return symbolTable;
}

STsymbol *createSymbol() {
  STsymbol *symbol = malloc(STmax*sizeof*symbol);
  if (!symbol) {
    printf("Run out of memory (STsymbol)\n");
    exit(3);
  }
  symbol->symbolTable = createSymbolTable();
  return symbol;
}

// Fonction pour une partie des erreurs sémantique
int checkSame(STentry *global, STentry *table) {
  if (global == table)
    return 0;
  for (int i = 0; i < table->STsize; i++) {
    for (int j = 0; j < global->STsize; j++) {
      if (strcmp(table[i].name, global[j].name) == 0 &&
          strcmp(table[i].type, global[j].type) == 0)
        return 1;
    }
  }
  return 0;
}

// Fonction pour une partie des erreurs sémantiques
int checkIn(const char name[], STentry *table, char *type) {
  for (int i = 0; i < table->STsize; i++) {
    if (strcmp(table[i].name, name) == 0 && strcmp(table[i].type, type) == 0)
      return 1;
  }
  return 0;
}


// Fonction pour une partie des erreurs sémantiques
int checkExist(STentry *table, char *var) {
  for (int i = 0; i < table->STsize; i++) {
    if (strcmp(var, table[i].name) == 0)
      return 1;
  }
  return 0;
}


int checkVariable_Variable(char* variable_type1, char* variable_type2) {
	if(strcmp(variable_type1, variable_type2) != 0)
		return 0;
	return 1;
}


int checkValue_Value(Kind value, Kind value2) {
	if(value == CharLiteral && value2 == CharLiteral) {
		return 1;
	}
	else if (value == IntLiteral && value2 == IntLiteral) {
		return 1;
	}
	return 0;
}

int checkVariable_Value(char* variable_type, Kind value) {
	if(strcmp(variable_type, "char") == 0) {
		if(value != CharLiteral)
			return 0;
	}
	else if(strcmp(variable_type, "int") == 0) {
		if(value != IntLiteral)
			return 0;
	}
	else if(strstr(variable_type, "struct") != NULL) {
		return 2;
	}
	return 1;
}


int clearTable(STsymbol *table, int pos) {
  STsymbol tmp;
  int count = 0;
  for (int i = 0; i < pos; i++) {
    for (int j = 0; j < pos - 1; j++) {
      if (table[j].symbolTable->STsize == 0 && table[j+1].symbolTable->STsize != 0) {
        tmp = table[j];
        table[j] = table[j+1];
        table[j+1] = tmp;
      }
    }
  }

  for (int k = 0; k < pos; k++) {
    if (table[k].symbolTable->STsize == 0)
      count += 1;
  }
  return pos - count;
}
