%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Flex Declarations
/* Just for being able to show the line number were the error occurs.*/
extern int line;
extern FILE *yyout;
int yylex();
/* Error Related Functions and Macros*/
int yyerror(const char *);
int no_errors;
/* Error Messages Macros*/
#define ERR_VAR_DECL(VAR,LINE) fprintf(stderr,"Variable :: %s on line %d. ",VAR,LINE); yyerror("Var already defined")
#define ERR_VAR_MISSING(VAR,LINE) fprintf(stderr,"Variable %s NOT declared, n line %d.",VAR,LINE); yyerror("Variable Declation fault.")

// Type Definitions and JVM command related Functions
#include "jvmLangTypesFunctions.h"
// Symbol Table definitions and Functions
#include "symbolTable.h"
/* Defining the Symbol table. A simple linked list. */
ST_TABLE_TYPE symbolTable;
#include "codeFacilities.h"

%}
/* Output informative error messages (bison Option) */
%define parse.error verbose

%union{
   char *lexical;
   struct {
	    ParType type;
	    char * place;} se;
  RelationType relopIndex;
  struct {
       NUMBER_LIST_TYPE trueLbl;
       NUMBER_LIST_TYPE falseLbl;
    } condLabels;

}

/* Token declarations and their respective types */

%token <lexical> T_NAME
%token <lexical> T_NUMBER

%token '('
%token ')'
%token '['
%token ']'
%token '.'

%token <tokentype> T_type
%token T_start "start"
%token T_end "end"
%token T_forall "forall"
%token T_print "print"
%token T_in "in"
%token T_NAME "name"
%token T_NUMBER "number"

%left '+'
%left '*'

%type<se> MATH  // add types for non-terminal symbols

%%
program: "start" T_NAME {create_preample($2); symbolTable=NULL; }
			BODY "end"
			{insertINSTRUCTION("return");
       insertINSTRUCTION(".end method\n");}
	;

BODY: /* empty */
	|'(' BODY BODY ')' BODY {/* nothing */}
	| ARRAY {/* nothing */}
	| PRINT {/* nothing */}
	| CAST  {/* nothing */}
	| MATH  {/* nothing */}
	;
    
    
PRINT:/* empty */
	|"print" BODY
	{if (!lookup(symbolTable,UNKNOWN) ) {ERR_VAR_MISSING(UNKNOWN,line);}
	 $$ = lookup_type(symbolTable,UNKNOWN);}
    	;  
    
CONV: "int" BODY //check for int and float if T_NAME/T_NUM are already of the right type, if not change its type
        |"float" BODY
        ;
    
MATH: /* empty */
	| MATH MATH '+' {$$.type = typeDefinition($1.type,$2.type);
			insertOPERATION($$.type, "add");}
	| MATH MATH '*' {$$.type = typeDefinition($1.type,$2.type);
			insertOPERATION($$.type, "mul");}
	| T_NUMBER {($$.type = type_integer; int x; x = atoi($1); pushInteger(x);)}
    
	| T_NAME {if (!($$.type = lookup_type(symbolTable,$1)))
		{ERR_VAR_MISSING($1,line);}
		insertLOAD($$.type,
		lookup_position(symbolTable,$1));};
	|ARRAY 
	;
	
ARRAY:  /* empty */
        |"[" "forall" T_NAME "in" T_NUMBER ".""." T_NUMBER "]" //if T_NUMBER T_type != int then error
        {if ($$.type != type_integer; }
        | T_NAME '[' T_NUMBER ']' {if (!($$.type lookup_type(symbolTable,$1)))
		{ERR_VAR_MISSING($1,line);}
		insertLOAD($$.type,
		lookup_position(symbolTable,$1));};
        ;  
    
%%



/* The usual yyerror */
int yyerror (const char * msg)
{
  fprintf(stderr, "PARSE ERROR: %s.on line %d.\n ", msg,line);
  no_errors++;
}

/* Other error Functions*/
/* The lexer... */
#include "jvmLExp.lex.c"

/* Main */
int main(int argc, char **argv ){

   ++argv, --argc;  /* skip over program name */
   if ( argc > 0 && (yyin = fopen( argv[0], "r")) == NULL)
    {
      fprintf(stderr,"File %s NOT FOUND in current directory.\n Using stdin.\n",argv[0]);
      yyin = stdin;
    }
   if ( argc > 1) {yyout = fopen(argv[1], "w");}
   else {
      fprintf(stderr,"No second argument defined. Output to screen.\n\n");
      yyout = stdout;
    }

    // Calling the parser
   int result = yyparse();

   fprintf(stderr,"Errors found %d.\n",no_errors);
   if (no_errors == 0)
      {print_int_code(yyout);}
   fclose(yyout);
   /// Need to remove even empty file.
   if (no_errors != 0 && yyout != stdout) {
     remove(argv[1]);
      fprintf(stderr,"No Code Generated.\n");}
   print_symbol_table(symbolTable); /* uncomment for debugging. */

  return result;
}
