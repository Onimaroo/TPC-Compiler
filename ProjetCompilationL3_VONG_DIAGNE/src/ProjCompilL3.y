%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <unistd.h>
	#include <string.h>
	#include <fcntl.h>
    #include "abstract-tree.h"
	#include "translation.h"
	int yyparse();
	int yylex();
	int yyerror(char *);
	extern int charno;
	extern char *text;
	extern int yylineno;
	extern void warning(int error_code);
	extern void semantic_error(int error_code);	
	int pos = 0;
	int pos_glob = 0;
	int check_file = 0;
	int check_warning = 0;
	int check_tree = 0;
	int check_systab = 0;
	int check_help = 0;
	int check_error = 0;
	int is_glob = 0;
	STsymbol symbolArray[256];
	STsymbol tmp;
	int nbr_param = 0;
	int nbr_arg = 0;
	char saveType[64];
	char typeStruct[64] = "struct ";
	FILE* file;
%}

%union {
    int num;
	char character;
	char type[5];
    char order[3];
	char operation;
    char identifier[64];
	struct Node* test;
}

%token CHARACTER DIVSTAR
%token ADDSUB
%token NUM
%token IDENT
%token ORDER EQ
%token OR
%token AND
%token VOID
%token PRINT
%token RETURN
%token IF
%token ELSE
%token WHILE
%token READE
%token READC
%token STRUCT
%token TYPE

%type <num> NUM; 
%type <character> CHARACTER;
%type <type> TYPE;
%type <order> EQ OR AND ORDER
%type <operation> ADDSUB DIVSTAR;
%type <identifier> IDENT;
%type <test> Prog ListTypVar EnTeteFonct DeclFonct DeclVarsFonction SuiteInstr Struct Arguments ListExp CorpsStruct Corps DeclVars Type DeclFoncts Parametres Declarateurs F Instr Exp TB FB M E T LValue STRUCT IF WHILE RETURN VOID PRINT READC READE;

%left THEN
%right ELSE

%%
Prog		: {translate_start(file);} DeclVars DeclFoncts {$$ = makeNode(Program); addChild($$, $2); addChild($$, $3); if(check_tree == 1) {printf("\n||| ARBRE ABSTRAIT |||\n\n"); printTree($$); translate_end(file);}}
			;

/* Règle de grammaire qui gère la déclaration des structures */
Struct		: STRUCT IDENT IDENT {$$ = makeNode(StructName); strcpy($$->u.identifier, $2); Node *n = makeNode(Identifier); strcpy(n->u.identifier, $3); addSibling($$, n);
			  strcpy(saveType, $2);
			  if(!checkIn($3, symbolArray[pos_glob].symbolTable, strcat(typeStruct, saveType))
			  	&& !checkIn($3, symbolArray[pos].symbolTable, typeStruct)) {
			  	addVar(symbolArray[pos].symbolTable, $3, typeStruct);
			  	strcpy(typeStruct, "struct ");
			  }
			  else {
			  	strcpy(typeStruct, "struct ");
			  	semantic_error(1);
			  }
			}
			
			| Struct ',' IDENT {$$ = makeNode(Identifier); strcpy($$->u.identifier, $3); addSibling($$, $1);
			  if(!checkIn($3, symbolArray[pos_glob].symbolTable, strcat(typeStruct, saveType))
			  	&& !checkIn($3, symbolArray[pos].symbolTable, typeStruct)) {
		  		addVar(symbolArray[pos].symbolTable, $3, typeStruct);
		  		strcpy(typeStruct, "struct ");
			  }
			  else {
			  	strcpy(typeStruct, "struct ");
			  	semantic_error(1);
			  }
			}
			;

Type: TYPE {$$ = makeNode(Type); strcpy($$->u.identifier, $1); strcpy(saveType, $1); /* printTree($$); */};

/* Règle qui gère le corps des structures durant sa création */
CorpsStruct : CorpsStruct Declarateurs ';' {addChild($1, $2); symbolArray[++pos] = *createSymbol(); pos_glob++;}
			| Declarateurs ';' {$$ = makeNode(CorpsStruct), addChild($$, $1);}
			;

DeclVars	: DeclVars Type Declarateurs ';' {addChild($2, $3); addChild($1, $2); 
			  if(!checkIn($3->u.identifier, symbolArray[pos_glob].symbolTable, $2->u.identifier)
			  	&& !checkIn($3->u.identifier, symbolArray[pos].symbolTable, $2->u.identifier)) {
				addVar(symbolArray[pos].symbolTable, $3->u.identifier, $2->u.identifier);
			  }
			  else
			  		semantic_error(1);
			}
			
			| DeclVars STRUCT IDENT '{' CorpsStruct '}' ';' {Node *n2 = makeNode(CreateStruct); Node *n = makeNode(StructName); strcpy(n->u.identifier, $3); addChild(n2, n); addChild(n2, $5); addChild($1, n2);
			  strcpy(symbolArray[pos-1].tableName, strcat(typeStruct, $3)); strcpy(typeStruct, "struct "); }
			
			| DeclVars Struct ';' {Node *n = makeNode(Type); strcpy(n->u.identifier, "struct"); addChild(n, $2); addChild($1, n);}
			
			| {$$ = makeNode(VarDeclList);};

Declarateurs: Declarateurs ',' IDENT {$$ = makeNode(Identifier); strcpy($$->u.identifier, $3); addSibling($$, $1); 
				if(!checkIn($1->u.identifier, symbolArray[pos_glob].symbolTable, saveType)
					&& !checkIn($1->u.identifier, symbolArray[pos].symbolTable, saveType)) {
					addVar(symbolArray[pos].symbolTable, $1->u.identifier, saveType);
				} 
				else
			  		semantic_error(1);
				translate_declaration(file);
			}
		   
		    | IDENT {$$ = makeNode(Identifier); strcpy($$->u.identifier, $1); translate_declaration(file);}
    	   
    	    | Type IDENT {$$ = $1; Node *n = makeNode(Identifier); strcpy(n->u.identifier, $2); addChild($$, n);
    	   		if(!checkIn($2, symbolArray[pos_glob].symbolTable, $1->u.identifier)
    	   			&& !checkIn($2, symbolArray[pos].symbolTable, $1->u.identifier)) {
    	   			addVar(symbolArray[pos].symbolTable, $2, $1->u.identifier);	
    	   		} 
    	   		else
			  		semantic_error(1);
				translate_declaration(file);
    	   	  }
    	   	;

DeclFoncts	: DeclFoncts DeclFonct {addChild($1, $2);}
    	    | DeclFonct {$$ = makeNode(FuncDeclList), addChild($$, $1);};

DeclFonct 	: EnTeteFonct Corps {$$ = makeNode(FuncDec); addSibling($1, $2); addChild($$, $1); symbolArray[++pos] = *createSymbol();} ;

EnTeteFonct	: Type IDENT '(' Parametres ')' {$$ = makeNode(Identifier); strcpy($$->u.identifier, $2); addSibling($$, $1); addSibling($$, $4);
			  if(!checkIn($2, symbolArray[pos_glob].symbolTable, $1->u.identifier)
			  	&& !checkIn($2, symbolArray[pos].symbolTable, $1->u.identifier)) {
			  	addVar(symbolArray[pos_glob].symbolTable, $2, $1->u.identifier);
			  	symbolArray[pos_glob].symbolTable[symbolArray[pos_glob].symbolTable->STsize-1].var_fonc = 1;
			  	strcpy(symbolArray[pos].tableName, $2);
			  }
			  else
			  		semantic_error(1);
			  translate_declaration_fonction(file, $$->u.identifier);
			  symbolArray[pos_glob].symbolTable[symbolArray[pos_glob].symbolTable->STsize-1].nbre_parametres = nbr_param;
			  nbr_param = 0;
			  
			}

    	    | VOID IDENT '(' Parametres ')' {$$ = makeNode(Identifier); strcpy($$->u.identifier, $2); Node *n = makeNode(Type); strcpy(n->u.identifier, "void");
    	   	  if(!checkIn($2, symbolArray[pos_glob].symbolTable, "void")
    	   	  	&& !checkIn($2, symbolArray[pos].symbolTable, "void")) {
    	   	  	addVar(symbolArray[pos_glob].symbolTable, $2, "void");
    	   	  	symbolArray[pos_glob].symbolTable[symbolArray[pos_glob].symbolTable->STsize-1].var_fonc = 1;
    	   	  	strcpy(symbolArray[pos].tableName, $2);
    	   	  }
    	   	  else
			  		semantic_error(1);
    	   	  addSibling($$, n); addSibling($$, $4);
			  translate_declaration_fonction(file, $$->u.identifier);
			  symbolArray[pos_glob].symbolTable[symbolArray[pos_glob].symbolTable->STsize-1].nbre_parametres = nbr_param;
			  nbr_param = 0;
    	   	}

		    | STRUCT IDENT IDENT '(' Parametres ')' {$$ = makeNode(Identifier); strcpy($$->u.identifier, $3); Node *n = makeNode(Type); strcpy(n->u.identifier, "struct "); Node *n2 = makeNode(StructName); 
		      strcpy(n2->u.identifier, $2); addChild(n, n2); addSibling($$, n); addSibling($$, $5);
		      char structu[100] = "struct ";
		      if(!checkIn($3, symbolArray[pos_glob].symbolTable, strcat(structu, $2))
		      	&& !checkIn($3, symbolArray[pos_glob].symbolTable, structu)) {
		      	addVar(symbolArray[pos_glob].symbolTable, $3, structu);
		      	symbolArray[pos_glob].symbolTable[symbolArray[pos_glob].symbolTable->STsize-1].var_fonc = 1;
		      	strcpy(symbolArray[pos].tableName, $3);
		      }
		      else
			  		semantic_error(1);
			  translate_declaration_fonction(file, $$->u.identifier);
			  symbolArray[pos_glob].symbolTable[symbolArray[pos_glob].symbolTable->STsize-1].nbre_parametres = nbr_param;
			  
			  nbr_param = 0;
		    }
		    ; 

DeclVarsFonction: DeclVarsFonction Type Declarateurs ';' {addChild($2, $3); addChild($1, $2);
					if(!checkIn($3->u.identifier, symbolArray[pos_glob].symbolTable, $2->u.identifier)
						&& !checkIn($3->u.identifier, symbolArray[pos].symbolTable, $2->u.identifier)) {
						addVar(symbolArray[pos].symbolTable, $3->u.identifier, $2->u.identifier);
					}
					else
			  			semantic_error(1);
				  }
				| DeclVarsFonction Struct ';' {Node *n = makeNode(Type); strcpy(n->u.identifier, "struct"); addChild(n, $2); addChild($1, n);}
				| {$$ = makeNode(Var);}
				;

Parametres	: VOID {$$ = makeNode(ListParam); Node *n = makeNode(Void); addChild($$, n); symbolArray[++pos] = *createSymbol(); nbr_param = 0;}
    	   |  ListTypVar ;

ListTypVar	: ListTypVar ',' Type IDENT {Node *n = makeNode(Identifier); strcpy(n->u.identifier, $4); addChild($1, $3); addChild($3, n);
				if(!checkIn($4, symbolArray[pos_glob].symbolTable, $3->u.identifier)
					&& !checkIn($4, symbolArray[pos].symbolTable, $3->u.identifier)) {
					addVar(symbolArray[pos].symbolTable, $4, $3->u.identifier);
					symbolArray[pos].symbolTable[symbolArray[pos].symbolTable->STsize-1].var_fonc = 2;
				}
				else
			  		semantic_error(1);
			  nbr_param++;
			  }
		   
		    | ListTypVar ',' STRUCT IDENT IDENT {Node *n = makeNode(Identifier); strcpy(n->u.identifier, $5); Node *n2 = makeNode(Type); strcpy(n2->u.identifier, "struct"); addChild($1, n2); addChild(n2, n); 
		   	  Node *n3 = makeNode(StructName); strcpy(n3->u.identifier, $4); addChild(n2, n3); strcpy(saveType, $4);
		   	  if(!checkIn($5, symbolArray[pos_glob].symbolTable, strcat(typeStruct, saveType))
		   	  	&& !checkIn($5, symbolArray[pos].symbolTable, typeStruct)) {
				addVar(symbolArray[pos].symbolTable, $5, typeStruct);
				strcpy(typeStruct, "struct ");
				symbolArray[pos].symbolTable[symbolArray[pos].symbolTable->STsize-1].var_fonc = 2;
		   	  }
		   	  else {
		   	  	strcpy(typeStruct, "struct ");
			  	semantic_error(1);
		   	  }
			 nbr_param++;
		   	}
    	   
    	    | Type IDENT {$$ = makeNode(ListParam); Node *n = makeNode(Identifier); strcpy(n->u.identifier, $2); addChild($$, $1); addChild($1, n);
    	      symbolArray[++pos] = *createSymbol();
    	      if(!checkIn($2, symbolArray[pos_glob].symbolTable, $1->u.identifier)
    	      	&& !checkIn($2, symbolArray[pos].symbolTable, $1->u.identifier)) {
  	  	      	addVar(symbolArray[pos].symbolTable, $2, $1->u.identifier);
  	  	      	symbolArray[pos].symbolTable[symbolArray[pos].symbolTable->STsize-1].var_fonc = 2;
    	      }
    	      else
			  		semantic_error(1);
			  nbr_param = 1;
    	  	}
		   
		    | STRUCT IDENT IDENT {$$ = makeNode(ListParam); Node *n = makeNode(Identifier); strcpy(n->u.identifier, $3); Node *n2 = makeNode(Type); strcpy(n2->u.identifier, "struct"); addChild($$, n2); Node *n3 = makeNode(StructName); strcpy(n3->u.identifier, $2);
		   	  addChild(n2, n3); addChild(n2, n); strcpy(saveType, $2); 
		   	  symbolArray[++pos] = *createSymbol();
		   	  if(!checkIn($3, symbolArray[pos_glob].symbolTable, strcat(typeStruct, saveType))
		   	  	&& !checkIn($3, symbolArray[pos].symbolTable, typeStruct)) {
		   	  	addVar(symbolArray[pos].symbolTable, $3, typeStruct);
		   	  	strcpy(typeStruct, "struct ");
		   	  	symbolArray[pos].symbolTable[symbolArray[pos].symbolTable->STsize-1].var_fonc = 2;
		   	  }
		   	  else {
		   	  	strcpy(typeStruct, "struct ");
			  	semantic_error(1);
		   	  }
			  nbr_param = 1;
		   	}
		   	; 

Corps		: '{' DeclVarsFonction SuiteInstr '}'{$$ = makeNode(Corps); addSibling($2, $3); addChild($$, $2); } ;

SuiteInstr 	: SuiteInstr Instr {addChild($1, $2);}
    	   | {$$ = makeNode(InstrList);} ;

Instr 	   :  LValue '=' Exp ';' {$$ = makeNode(Affectation); addChild($$, $1); addChild($$, $3); translate_assignment(file, $1->u.identifier, *($1->u.identifier));
			 if(strstr(find_type(symbolArray[pos].symbolTable, $3->u.identifier), "struct") != NULL) {
				 semantic_error(4);
			 }
			 }
	       |  READE '(' IDENT ')' ';' {$$ = makeNode(Reade); Node *n = makeNode(Identifier); strcpy(n->u.identifier, $3); addChild($$, n); if(checkExist(symbolArray[pos].symbolTable, n->u.identifier) == 0) { semantic_error(0);} if(strcmp(find_type(symbolArray[pos].symbolTable, $3), "int") != 0) { warning(5); }}
	       |  READC '(' IDENT ')' ';' {$$ = makeNode(Readc); Node *n = makeNode(Identifier); strcpy(n->u.identifier, $3); addChild($$, n); if(checkExist(symbolArray[pos].symbolTable, n->u.identifier) == 0) { semantic_error(0);} if(strcmp(find_type(symbolArray[pos].symbolTable, $3), "char") != 0) { warning(4); }}
	       |  PRINT '(' Exp ')' ';' {$$ = makeNode(Print); addChild($$, $3);}
	       |  IF '(' Exp ')' Instr %prec THEN {$$ = makeNode(If); addChild($$, $3); Node *n = makeNode(Then); addChild(n, $5); addChild($$, n);}
	       |  IF '(' Exp ')' Instr ELSE Instr {$$ = makeNode(If); addChild($$, $3); Node *n = makeNode(Then); Node *n2 = makeNode(Else); addChild(n, $5); addChild($$, n); addChild(n2, $7); addChild($$, n2);}
   	       |  WHILE '(' Exp ')' Instr {$$ = makeNode(While); addChild($$, $3); addChild($$, $5);}
	       |  IDENT '(' Arguments  ')' ';' {$$ = makeNode(AppelFonction); addChild($$, $3); if(checkExist(symbolArray[pos_glob].symbolTable, $1) == 0) {semantic_error(5);} 
	for (int i = 0; i < symbolArray[pos_glob].symbolTable->STsize; i++) {
		if(strcmp(symbolArray[pos_glob].symbolTable[i].name, $1) == 0) {
			if(symbolArray[pos_glob].symbolTable[i].nbre_parametres != nbr_arg) {
				semantic_error(6);
			}
		}
	}; nbr_arg = 0;}
	       |  RETURN Exp ';' {$$ = makeNode(Return); addChild($$, $2); 
			  if (strcmp(symbolArray[pos_glob].symbolTable[symbolArray[pos_glob].symbolTable->STsize-1].type, "int") != 0) {
		      	 if($2->kind == Identifier) {
					 if(strcmp(symbolArray[pos_glob].symbolTable[symbolArray[pos_glob].symbolTable->STsize-1].type, find_type(symbolArray[pos].symbolTable, $2->u.identifier)) != 0)
					warning(3); 
				 }
			  	 else if ($2->kind == CharLiteral) {
					if(strcmp(symbolArray[pos_glob].symbolTable[symbolArray[pos_glob].symbolTable->STsize-1].type, "char") != 0)
						warning(3); 
			     } 
			  	 else if ($2->kind == IntLiteral) {
					if(strcmp(symbolArray[pos_glob].symbolTable[symbolArray[pos_glob].symbolTable->STsize-1].type, "int") != 0)
						warning(3); 
			     } 
			   } }
	       |  RETURN ';' {$$ = makeNode(Return);}
	       |  '{' SuiteInstr '}' {$$ = $2;}
	       |  ';'  {$$ = 0;} ;

Exp 		:  Exp OR TB {$$ = makeNode(Or); addChild($$, $1); addChild($$, $3);}
    	   |  TB  ;

TB  		:  TB AND FB {$$ = makeNode(And); addChild($$, $1); addChild($$, $3);}
           |  FB  ;

FB          :  FB EQ M {
					if (strcmp($2, "==") == 0)
						$$ = makeNode(Equals); 
					else 
						$$ = makeNode(Different); 
					addChild($$, $1); 
					addChild($$, $3); 
					if($1->kind == Identifier && $3->kind == Identifier) {
						if(checkVariable_Variable(find_type(symbolArray[pos].symbolTable, $1->u.identifier), find_type(symbolArray[pos].symbolTable, $3->u.identifier)) == 0) {
							warning(2);
						}
					}	
					else if($1->kind != Identifier && $3->kind != Identifier) {
						if(checkValue_Value($1->kind , $3->kind) == 0) {
							warning(2);
						}
					}
					else if($1->kind == Identifier) {
						if(checkVariable_Value(find_type(symbolArray[pos].symbolTable, $1->u.identifier), $3->kind) == 0) {
							warning(2);
						}
						else if(checkVariable_Value(find_type(symbolArray[pos].symbolTable, $1->u.identifier), $3->kind) == 2) {
							semantic_error(4);
						}
					}	 
				}
           |  M  ;

M           :  M ORDER E {
					if (strcmp($2, "<=") == 0)
						$$ = makeNode(LesserOrEqual); 
					else if (strcmp($2, "<") == 0)
						$$ = makeNode(LesserThan); 
                    else if (strcmp($2, ">=") == 0)
						$$ = makeNode(GreaterOrEqual); 
					else
						$$ = makeNode(GreaterThan);                    
					addChild($$, $1); 
					addChild($$, $3);
					if($1->kind == Identifier && $3->kind == Identifier) {
						if(checkVariable_Variable(find_type(symbolArray[pos].symbolTable, $1->u.identifier), find_type(symbolArray[pos].symbolTable, $3->u.identifier)) == 0) {
							warning(2);
						}
					}	
					else if($1->kind != Identifier && $3->kind != Identifier) {
						if(checkValue_Value($1->kind , $3->kind) == 0) {
							warning(2);
						}
					}
					else if($1->kind == Identifier) {
						if(checkVariable_Value(find_type(symbolArray[pos].symbolTable, $1->u.identifier), $3->kind) == 0) {
							warning(2);
						}
						else if(checkVariable_Value(find_type(symbolArray[pos].symbolTable, $1->u.identifier), $3->kind) == 2) {
							semantic_error(4);
						}
					}	  
				}
           |  E  ;

E   :  E ADDSUB T {
		if ($2 == '+') { 
			$$ = makeNode(Add); 
			addChild($$, $1); 
			addChild($$, $3);
			if($1->kind == Identifier && $3->kind == Identifier) {
				if(checkVariable_Variable(find_type(symbolArray[pos].symbolTable, $1->u.identifier), find_type(symbolArray[pos].symbolTable, $3->u.identifier)) == 0) {
					warning(2);
				}
			}	
			else if($1->kind != Identifier && $3->kind != Identifier) {
				if(checkValue_Value($1->kind , $3->kind) == 0) {
					warning(2);
				}
			}
			else if($1->kind == Identifier) {
				if(checkVariable_Value(find_type(symbolArray[pos].symbolTable, $1->u.identifier), $3->kind) == 0) {
					warning(2);
				}
				else if(checkVariable_Value(find_type(symbolArray[pos].symbolTable, $1->u.identifier), $3->kind) == 2) {
					semantic_error(4);
				}
			}		
			translate_addsub_divstar(file, Add);
		} 
		else { 
			$$ = makeNode(Sub); 
			addChild($$, $1); 
			addChild($$, $3);
			if($1->kind == Identifier && $3->kind == Identifier) {
				if(checkVariable_Variable(find_type(symbolArray[pos].symbolTable, $1->u.identifier), find_type(symbolArray[pos].symbolTable, $3->u.identifier)) == 0) {
					warning(2);
				}
			}	
			else if($1->kind != Identifier && $3->kind != Identifier) {
				if(checkValue_Value($1->kind , $3->kind) == 0) {
					warning(2);
				}
			}	
			else if($1->kind == Identifier) {
				if(checkVariable_Value(find_type(symbolArray[pos].symbolTable, $1->u.identifier), $3->kind) == 0) {
					warning(2);
				}
				else if(checkVariable_Value(find_type(symbolArray[pos].symbolTable, $1->u.identifier), $3->kind) == 2) {
					semantic_error(4);
				}
			}	
			translate_addsub_divstar(file, Sub);
		} }
    |  T
    ;
T   :  T DIVSTAR F {
		if ($2 == '*') { 
			$$ = makeNode(Mult); 
			addChild($$, $1); 
			addChild($$, $3); 
			if($1->kind == Identifier && $3->kind == Identifier) {
				if(checkVariable_Variable(find_type(symbolArray[pos].symbolTable, $1->u.identifier), find_type(symbolArray[pos].symbolTable, $3->u.identifier)) == 0) {
					warning(2);
				}
			}	
			else if($1->kind != Identifier && $3->kind != Identifier) {
				if(checkValue_Value($1->kind , $3->kind) == 0) {
					warning(2);
				}
			}	
			else if($1->kind == Identifier) {
				if(checkVariable_Value(find_type(symbolArray[pos].symbolTable, $1->u.identifier), $3->kind) == 0) {
					warning(2);
				}
				else if(checkVariable_Value(find_type(symbolArray[pos].symbolTable, $1->u.identifier), $3->kind) == 2) {
					semantic_error(4);
				}
			}		
			translate_addsub_divstar(file, Mult);
		} 
		else { 
			if ($3 != 0) {
				$$ = makeNode(Division); 
				addChild($$, $1); 
				addChild($$, $3); 
				if($1->kind == Identifier && $3->kind == Identifier) {
					if(checkVariable_Variable(find_type(symbolArray[pos].symbolTable, $1->u.identifier), find_type(symbolArray[pos].symbolTable, $3->u.identifier)) == 0) {
						warning(2);
					}
				}
				else if($1->kind != Identifier && $3->kind != Identifier) {
					if(checkValue_Value($1->kind , $3->kind) == 0) {
						warning(2);
					}
				}	
				else if($1->kind == Identifier) {
					if(checkVariable_Value(find_type(symbolArray[pos].symbolTable, $1->u.identifier), $3->kind) == 0) {
						warning(2);
					}
					else if(checkVariable_Value(find_type(symbolArray[pos].symbolTable, $1->u.identifier), $3->kind) == 2) {
						semantic_error(4);
					}
				}
				translate_addsub_divstar(file, Division);
			} 
			else { 
				printf("Impossible: Division par zéro. \n"); 
			} 
		} }
    |  F
    ;

F           :  ADDSUB F {if ($1 == '-') {
						 	if ($2->kind == IntLiteral) {
								$2->u.integer = -$2->u.integer;
								$$ = $2; 
							}
							else {
								$$ = makeNode(Sub); 
								addChild($$, $2);
							}
						}
						else {
							$$ = $2;
						} }	 					
           |  '!' F {Node *n = makeNode($2->kind); $$ = makeNode($2->kind); addChild($$, n);}
           |  '(' Exp ')' {$$ = $2;}
           |  NUM {$$ = makeNode(IntLiteral); $$->u.integer = $1;}
           |  CHARACTER {$$ = makeNode(CharLiteral); $$->u.character = $1;}
           |  LValue {$$ = $1;} 
           |  IDENT '(' Arguments  ')' {$$ = makeNode(AppelFonction); Node *n = makeNode(Identifier); strcpy(n->u.identifier, $1); addChild($$, n); addChild($$, $3); if(checkExist(symbolArray[pos_glob].symbolTable, $1) == 0) { semantic_error(5);} 	
	for (int i = 0; i < symbolArray[pos_glob].symbolTable->STsize; i++) {
		if(strcmp(symbolArray[pos_glob].symbolTable[i].name, $1) == 0) {
			if(symbolArray[pos_glob].symbolTable[i].nbre_parametres != nbr_arg) {
				semantic_error(6);
			}
		}
	}; nbr_arg = 0;};

LValue      : IDENT  {$$ = makeNode(Identifier); strcpy($$->u.identifier, $1); if(checkExist(symbolArray[pos].symbolTable, $1) == 0 && checkExist(symbolArray[pos_glob].symbolTable, $1) == 0) { semantic_error(0);}};

Arguments   : ListExp 
           | {$$ = 0;} ;

ListExp     : ListExp ',' Exp {addChild($1, $3); nbr_arg++;}
           |  Exp  {$$ = makeNode(ListArg), addChild($$, $1); nbr_arg = 1;};
%%

/* Fonction qui dessine la flèche verticale en fonction de la variable globale prenant le nombre de caractères parcouru dans la ligne courante. */
void draw_arrow(){
	int i;
	for (i = 0; i < charno - 1; i++) {
		fprintf(stderr, " ");
	}
	fprintf(stderr, "^\n");
}

/* Fonction qui écrit la ligne d'erreur (dans le cas où il y en a une) */
void draw_text(){
	fprintf(stderr, "%s", text);
	fprintf(stderr, "\n");
}

/* Fonction appelée quand une erreur est présente */
int yyerror(char *s){
	fprintf(stderr, "%s near line %d and character %d.\n", s, yylineno, charno);
	draw_text();
	draw_arrow();
	return 1;
}

void semantic_error(int error_code) {
	if (error_code == 0) {
		fprintf(stderr, "Semantic error near line %d and character %d: Variable is not declared. \n", yylineno, charno);
	}
	else if (error_code == 1) {
		fprintf(stderr, "Semantic error near line %d and character %d: Redefinition of variable. \n", yylineno, charno);
	}
	else if (error_code == 4) {
		fprintf(stderr, "Semantic error near line %d and character %d: Structures cannot be used for operations. \n", yylineno, charno);
	}
	else if (error_code == 5) {
		fprintf(stderr, "Semantic error near line %d and character %d: Function is not declared. \n", yylineno, charno);
	}
	else if (error_code == 6) {
		fprintf(stderr, "Semantic error near line %d and character %d: Too little/many arguments in function call. \n", yylineno, charno);
	}
	check_error = 1;
	draw_text();
	draw_arrow();
}

void warning(int error_code) {
	if (error_code == 2) {
		fprintf(stderr, "Warning near line %d and character %d: Conflicting types. \n", yylineno, charno);
	}
	else if (error_code == 3) {
		fprintf(stderr, "Warning near line %d and character %d: Wrong return value type. \n", yylineno, charno);
	}
	else if (error_code == 4) {
		fprintf(stderr, "Warning near line %d and character %d: Wrong argument type for Readc. \n", yylineno, charno);
	}
	else if (error_code == 5) {
		fprintf(stderr, "Warning near line %d and character %d: Wrong argument type for Reade. \n", yylineno, charno);
	}
	check_warning = 1;
	draw_text();
	draw_arrow();
}


int main(int argc, char **argv) {
	symbolArray[pos] = *createSymbol();
	int var;
	char buf[100];
	for(int i = 1; i < argc; i++) {
		if(argv[i][0] == '-') {
			switch(argv[i][1]) {
				case 't': check_tree = 1; break;
				case 's': check_systab = 1; break;
				case 'h': check_help = 1; printf("Liste des options: \n\n -t = Affichage de l'arbre abstrait. \n -s = Affichage de la table des symboles. \n\n"); break;
				default: check_help = 1; printf("Option inconnue.\n"); return 3; break;
			}
		}
		else {
			for(int j = 0; j < strlen(argv[i]); j++) {
				if(argv[i][j] == '.' && (j > 1)) {
					break;
				}
				else {
					buf[j] = argv[i][j];
				}
			}
			strcat(buf, ".asm");
			file = fopen(buf, "w");
			var = open(argv[i], O_RDONLY);
			dup2(var, STDIN_FILENO);
			check_file = 1;
		}
			
	}
	if(check_help == 0) {
		if(check_file == 0) {
			file = fopen("_anonymous.asm", "w");
		}
		printf("\n||| LISTE DES ERREURS PROBABLES |||\n\n");
		int n = yyparse();
		strcpy(symbolArray[pos_glob].tableName, "global");
		if(n == 0) {
			pos = clearTable(symbolArray, pos);
			if(check_systab == 1) {
		  		printf("\n||| TABLE DES SYMBOLES |||\n\n");
				for (int i = 0; i < pos; i++) {
					printSymbolTable(symbolArray[i].symbolTable);
					printf("fin table: %s\n\n", symbolArray[i].tableName);
				}
			}
			if(check_error == 1) {
				printf("Des erreurs sémantiques sont présentes.\n");
				return 2;
			}
			if(check_warning == 1) {
				printf("Aucune erreur sémantique n'est présente, mais des avertissements sont présentes.\n");
				return 0;
			}
			printf("Aucune erreur sémantique ni avertissement n'est présente.\n");
			return 0;
		}
	}
	return -1;
}
