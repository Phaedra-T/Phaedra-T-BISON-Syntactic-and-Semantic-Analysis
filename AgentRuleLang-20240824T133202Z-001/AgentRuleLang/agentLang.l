/* This is an example of a simple LL grammar implementation */
%{
#include <stdio.h>
#include <string.h>

/* ADD your token definitions here */ 
#define TK_name 300
#define TK_memcl 301
#define TK_detector 302
#define TK_Rel 303
#define TK_NUM 304
#define TK_implies 305 //=>
#define TK_LB 306 //left bracket
#define TK_RB 307 //right bracket
#define TK_SC 308 //semi-colon
#define TK_true 309
#define TK_forward 310
#define TK_turn 311
#define TK_right 312
#define TK_left 313
/* Needed for syntax analyser*/
#define LEXEND 0 

int line = 0;
%}

name [a-z]+
Rel (">"|"<"|"=")
detector ("left-laser"|"right-laser"|"front-sonar")
nzdigit [1-9]
T_NUM ({nzdigit}|0)+
newline \n|\x0A|\x0D|\x0A
ws [ \t]+

%%
{Rel}         {line++; return TK_Rel;}
{T_NUM}       {line++; return TK_NUM;}
"mem-clear"   {line++; return TK_memcl;}
"->"          {line++; return TK_implies;}
"["           {line++; return TK_LB;}
"]"           {line++; return TK_RB;}
";"           {line++; return TK_SC;}
"true"        {line++; return TK_true;}
"forward"     {line++; return TK_forward;}
"turn"        {line++; return TK_turn;}
"right"       {line++; return TK_right;}
"left"        {line++; return TK_left;}
{detector}    {line++; return TK_detector;}
{name}        {line++; return TK_name;}
{newline}     {line++;}
{ws}	      {/*Do Nothing*/}
%%

int token = 0;


/* Add your LL functions forward here */ 
void Agent(void);
void GuardedActions(void);
void GuardedActionsNEW(void);
void GuardedAct(void);
void Action(void);
void Direction(void);

void error_syntax(void);
void match(int tk);

/* Add your function implementations here. */
void Agent(){
	if (token==TK_name)
		{match(TK_name); match (TK_LB); GuardedActions();match (TK_RB);}
	else error_syntax();}

	
void GuardedActions(){
	if (token==TK_memcl)
		{match(TK_memcl); match (TK_SC); GuardedActionsNEW();}
	else error_syntax();}

void GuardedActionsNEW(){
	if (token == TK_detector)
		{match(TK_detector); GuardedAct(); GuardedActionsNEW();}
	else if (token == TK_true)
		{match(TK_true); GuardedAct(); GuardedActionsNEW();}
	else if (token!=TK_RB)
		error_syntax();}

	
void GuardedAct(){
	if (token == TK_Rel)
		{match(TK_Rel); match(TK_NUM); match(TK_implies); Action(); match(TK_SC);}
	else if (token == TK_implies)
		{ match(TK_implies); Action(); match(TK_SC);}
	else error_syntax();}

	
void Action() {
	if (token == TK_forward)
		{match(TK_forward); match(TK_NUM);}
	else if (token == TK_turn )
		{match(TK_turn); Direction();}
	else error_syntax();
}

void Direction() {
    if (token == TK_left)
        {match(TK_left); match(TK_NUM);}
    else if (token == TK_right)
    	{match(TK_right); match(TK_NUM);}
    else error_syntax();
}

void error_syntax(void){
   printf("Syntax Error reading %s at line %d of input. \n",yytext, line);
   exit(-1);
}

void match(int tk){

   if (token == tk) token = yylex();
   else  error_syntax();
}

int main(int argc, char **argv ){
   ++argv, --argc;  /* skip over program name */
   if ( argc > 0 )
       yyin = fopen( argv[0], "r" );
   else
      yyin = stdin;

   token = yylex(); 
   Agent();
   if (token == LEXEND) printf("\n Success! \n");
   else error_syntax();
   return 0;
}



