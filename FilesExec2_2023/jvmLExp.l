/*
Grammar with semantics and type checking.
Lexical Analyser
*/

%{
#include <stdlib.h>
#include <string.h>
int line = 1;
%}

NZDIGITS [1-9]
DIGITS [0-9]
LETTER [a-zA-Z]
NAME {LETTER}({LETTER}|{DIGITS}|"_")* 
FLOAT {DIGITS}+\.{DIGITS}+
INT  ({NZDIGITS}|0)+
NUMBER {INT}|{FLOAT}
newline \n|\x0A|\x0D\x0A
%%

"start"   {return T_START;}
"end"     {return T_END;}
"print"   {return T_PRINT;}
"forall"  {return T_FORALL;}
"in"      {return T_IN;}

"int" {yylval.tokentype = type_integer; return T_type;}
"float" {yylval.tokentype = type_real; return T_type;}

"(" {return '(';}
")" {return ')';} 
"[" {return '[';}
"]" {return ']';} 
"." {return '.';}

"+" {return '+';}
"*" {return '*';}


{NAME}    {yylval.lexical = strdup(yytext); return T_NAME;}
{NUMBER}  {yylval.lexical = strdup(yytext); return T_NUMBER;}
{newline}  { line++;}
[ \t] { /* nothing */ }
. {
	printf("Lexical Analysis: Unexpected String! :: %s. in line %d. \n",yytext,yylineno); }

%%
