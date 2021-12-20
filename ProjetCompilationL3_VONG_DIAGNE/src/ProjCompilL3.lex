%{
#include "ProjCompilL3.tab.h"
#include <string.h>
unsigned int charno = 0; /* Numéro de caractère sur lequel pointe couramment l'analyseur. */
char *text; /* Variable globable qui stocke la ligne couramment parcouru */
int text_complete; /* Variable globale qui vérifie si la ligne a été entièrement copiée */

%}

%option nounput
%option noinput
%option noyywrap
%option yylineno

character \'.\'
ident [a-zA-Z_][a-zA-Z0-9_]*
type "int"|"char"
eq "=="|"!="
order "<"|"<="|">"|">="
addsub "+"|"-"
divstar "*"|"/"|"%"
or "||"
and "&&"

void "void"
print "print"
return "return"
if "if"
else "else"
while "while"
reade "reade"
readc "readc"
struct "struct"
num [0-9]+
%x LINE
%x BLOCK

%%

<LINE>\n BEGIN INITIAL;
<BLOCK>\*\/ {BEGIN INITIAL;}
<LINE,BLOCK>.|\n ;
\/\/ BEGIN LINE;
\/\* BEGIN BLOCK;

^.+ { 
	  if(!text_complete) {
	      free(text);
		  text = strdup(yytext); 
		  text_complete = 1;
	  }
	  REJECT;
	}

\n {text_complete = 0; charno = 0;}

{struct} {
		for(int i = 0; i < yyleng; i++) {
			charno++; 
		}
		return STRUCT;}

{type}  {strcpy(yylval.type, yytext);
			for(int i = 0; i < yyleng; i++) {
				charno++; 
			}
			return TYPE;}

{or} {strcpy(yylval.order, yytext);
		for(int i = 0; i < yyleng; i++) {
			charno++; 
		}
		return OR;}

{and} {strcpy(yylval.order, yytext);
		for(int i = 0; i < yyleng; i++) {
			charno++; 
		}
		return AND;}

{eq} {strcpy(yylval.order, yytext);	
		for(int i = 0; i < yyleng; i++) {
			charno++; 
		}
		return EQ;}

{order} {strcpy(yylval.order, yytext);
			for(int i = 0; i < yyleng; i++) {
				charno++; 
			}
			return ORDER;}

{addsub} {yylval.operation = yytext[0];
			for(int i = 0; i < yyleng; i++) {
				charno++; 
			}
			return ADDSUB;}

{divstar} {yylval.operation = yytext[0];
			for(int i = 0; i < yyleng; i++) {
				charno++; 
			}
			return DIVSTAR;}

{void} {
			for(int i = 0; i < yyleng; i++) {
				charno++; 
			}
		 	return VOID;}

{print} {
			for(int i = 0; i < yyleng; i++) {
				charno++; 
			}
			return PRINT;}

{num} {yylval.num = atoi(yytext);
		for(int i = 0; i < yyleng; i++) {
			charno++; 
		}
	  	return NUM;}

{character} {yylval.character = yytext[1];
				for(int i = 0; i < yyleng; i++) {
					charno++; 
				}
				return CHARACTER;}

{return} {
			for(int i = 0; i < yyleng; i++) {
				charno++; 
			}
			return RETURN;}

{if} {
		for(int i = 0; i < yyleng; i++) {
			charno++; 
		} 
		return IF;}

{else} {
		for(int i = 0; i < yyleng; i++) {
			charno++; 
		}
		return ELSE;}

{while} {
		for(int i = 0; i < yyleng; i++) {
			charno++; 
		}
		return WHILE;}

{reade} {
		for(int i = 0; i < yyleng; i++) {
			charno++; 
		}
		return READE;}

{readc} {
		for(int i = 0; i < yyleng; i++) {
			charno++; 
		}
		return READC;}

{ident} { strcpy(yylval.type, yytext);
		for(int i = 0; i < yyleng; i++) {
			charno++; 
		}
		return IDENT;}

" "|\t\r|\t { if(yytext[0] == '\t') { charno += 8; } else { charno++; } } /* On incrémente le nombre de caractère de 8 dans le cas des tabulations pour */
									  /* éviter que la flèche verticale se décale (8 est la largeur de tabulation par */
									  /* défaut sur le terminal) */
. {charno++; return yytext[0];}

<<EOF>> {return 0;}
%%
