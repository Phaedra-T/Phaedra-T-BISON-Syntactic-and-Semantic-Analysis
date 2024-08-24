//meros A

%{
#include <stdio.h>
#include <stdlib.h>
// To remove persistent warning..
int yylex();
void yyerror (const char * msg);
%}

%define parse.error verbose

//token declarations
%token    '('
%token    ')'
%token   ','

%token   '+'
%token   '-'
%token   '.'
%token   ':'
%token   ';' 


%token     '!'
%token     '?'
%token     '&'
%token     '|'

%token     '=' 
%token     '<' 
%token     '>'

%token T_ASS   "<-"
%token T_GE    ">="
%token T_LE    "=<"

%token T_TRUE  "true"
%token T_NOT   "not"

%token T_VAR   "Var"
%token T_Atom  "Atom"
%token T_NUM   "Number"
%%

agent : beliefs plans
;

beliefs : /*empty*/
	| beliefs belief 
	;
	
belief : predicate '.'
	|error '?'
;

predicate : "Atom" '(' terms ')'
;

plans :  /*empty*/
	| plans plan 
	;
	
plan : trig_event ':' context "<-" body '.'
;

trig_event : '+' predicate | '-' predicate
	   | '+' goal | '-' goal
	   ;
	   
context : "true" 
	| cliterals
	;
	
cliterals : literal 
	  | literal '&' cliterals
	  ;
	  
literal : predicate
	| "not" '(' predicate ')'
	| boolExpr
	;
	
goal : '!' predicate 
	| '?' predicate
	;
	
body : "true"
	| actions
	;
	
actions :action 
	| action ';' actions
	;
	
action : predicate 
	| goal 
	| belief_update
	;
	
belief_update : '+' predicate 
	      | '-' predicate
	      ;
	      
terms : term 
	| term ',' terms
	;
	
term : "Var"
     |"Atom"
     |"Number"
     |"Atom" '(' terms ')'
     ;
     
boolExpr : boolE 
	 | boolExpr '|' boolE
	 ;
	 
boolE : boolarg relOp boolarg
;
boolarg : "Number" 
	| "Var"
	;
	
relOp : '>' 
      | '<' 
      | '=' 
      | ">=" 
      | "=<"
      ;
      
%%


#include "agentSpeak.lex.c"

void yyerror (const char * msg)
{
   printf("Error(line %d) : %s\n",line, msg); 
 
}

int main(int argc, char **argv ){
   ++argv, --argc;  /* skip over program name */
   if ( argc > 0 )
       yyin = fopen( argv[0], "r" );
   else
      yyin = stdin;

   int result = yyparse();

   if (result == 0 && yynerrs == 0)
      printf("Syntax OK!\n");
   else
      printf("There were %d errors in code. Failure!\n", yynerrs);
   return result;
}








