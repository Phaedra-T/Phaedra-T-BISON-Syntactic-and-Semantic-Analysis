%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
int line=1;
%}

D [0-9]
REAL {D}+\.{D}+
NUM {D}+|{REAL}
CAPLETTER [A-Z]
LOWLETTER [a-z]
LETTER {CAPLETTER}|{LOWLETTER}
VARIABLE {CAPLETTER}({LETTER}|{D}|"_")*
ATOM {LOWLETTER}({LETTER}|{D}|"_")*
ws [ \t]+
newline \n|\x0A|\x0D\x0A

%%


"+" {return '+';}
"-" {return '-';}
"." {return '.';}
"," {return ',';}
":" {return ':';}
";" {return ';';}

"(" {return '(';}
")" {return ')';}

"!" {return '!';}
"?" {return '?';}
"&" {return '&';}
"|" {return '|';}

"="  {return '=';}
">" {return '>';}
"<" {return '<';}

"<-" {return T_ASS;}
">=" {return T_GE;}
"=<" {return T_LE;}

"true" {return T_TRUE;}
"not" {return T_NOT;}



{VARIABLE} {return T_VAR;}
{ATOM} {return T_Atom;}
{NUM} {return T_NUM;}
{newline} { line++;}
{ws} { /*Do nothing */ }
. {   /*Do nothing */  } 

%%


