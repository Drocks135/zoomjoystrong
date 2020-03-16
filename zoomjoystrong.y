%{
	#include <stdio.h>
	#include "zoomjoystrong.h"
	#include <SDL2/SDL.h>
	void yyerror(const char* msg);
	int checkRGB(int r, int g, int b);
	int checkBounds(int x, int y);
	int checkCircleBounds(int x, int y, int r);
	int yylex();
%}

%define parse.error verbose
%start statement_list

%union {int i; char* str; float f;}

%token END
%token END_STATEMENT
%token POINT
%token LINE
%token CIRCLE
%token RECTANGLE
%token SET_COLOR
%token INT
%token FLOAT

%type<i> INT
%type<f> FLOAT

%%

statement_list: statement
	|	statement_list statement
	|	error END_STATEMENT	{yyerrok; } 
;

statement: point
	| line
	| circle
	| rectangle
	| set_color
	| eof
;

point:		POINT INT INT END_STATEMENT
     		{ 
		if(checkBounds($2, $3) == 0)
			point($2, $3);
		else
			yyerror("Invalid Point Range");
		}
;

line:		LINE INT INT INT INT END_STATEMENT
    		{ 	
		if(checkBounds($2, $3) == 0 && checkBounds($4, $5) == 0)
			line($2, $3, $4, $5);
		else
			yyerror("Invalid Line Range"); 
		}		
;

circle:		CIRCLE INT INT INT END_STATEMENT
      		{ 
		if(checkCircleBounds($2, $3, $4))
			circle($2, $3, $4);
		else
			yyerror("Invalid Circle Dimensions"); 
		}
;

rectangle:	RECTANGLE INT INT INT INT END_STATEMENT
	 	{ 
		if(checkBounds($2, $3) == 0 && checkBounds($4, $5) == 0)
			rectangle($2, $3, $4, $5);
		else
			yyerror("Invalid Rectangle Dimensions"); 
		}
;

set_color:	SET_COLOR INT INT INT END_STATEMENT
	 	{ 
		if(checkRGB($2, $3, $4) == 0)
			set_color($2, $3, $4);
		else
			yyerror("Invalid RGB Values"); 
		}
;

eof:		END
   		{ exit(0); }
;

%%

int main(int argc, char** argv){
	setup();
	yyparse();
	return 0;
}

int checkRGB(int r, int g, int b){
	if(r <= 255 && r >= 0 && b <= 255 && b >= 0 && g <= 255 && g >= 0)
		return 0;
	return 1;
}

int checkBounds(int x, int y){
	if(x >= 0 && x <= WIDTH && y >= 0 && y <= HEIGHT)
		return 0;
	return 1;
}

int checkCircleBounds(int x, int y, int r){
	if(x - r > 0 && y -r > 0 && x + r < WIDTH && y + r > HEIGHT)
		return 0;
	return 1;
}	

void yyerror(const char* msg){
	fprintf(stderr, "Error! %s\n\n" ,msg);
}
