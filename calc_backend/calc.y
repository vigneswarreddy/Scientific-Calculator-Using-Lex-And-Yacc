%{
#include<stdlib.h>
#include<stdio.h>
#include<math.h>
#include<alloca.h>
#include<stddef.h>
#include<string.h>

int yylex(void);
int m=0, count;
int flag=0;
double sym[52];
void yyerror(char *s)			
{      
           printf("%s\n",s);
           flag=1;
}
%}
%union {
double p;
char id;
}
%token OPEN_BRACKET CLOSE_BRACKET ASSIGN PRINT
%token<p>num
%token<id>VARIABLE
%token ADD SUB MUL DIV POW EXP SQRT MOD PI E 
%token COS SIN TAN ASIN ACOS ATAN COT SEC COSEC LOG LN 
%left SUB ADD
%left MUL DIV MOD
%left POW SQRT
%left OPEN_BRACKET CLOSE_BRACKET
%type<p>exp
%type<p>constant
%%
ss : VARIABLE ASSIGN exp {
	sym[$1] = $3; 
	}
     |PRINT OPEN_BRACKET VARIABLE CLOSE_BRACKET { 
	if (flag==0) { 
    	printf("Result: %.10f\n", sym[$3]); 
    	}
    	}
     |exp { if (flag==0) { 
    	printf("Result: %.10f\n",$1); 
    	}
    	}
exp : exp ADD exp {
	$$=$1+$3;
	}
     |exp SUB exp {
     	$$=$1-$3;
     	}
     |exp MUL exp {
     	$$=$1*$3;
     	}
     |exp DIV exp {
     	if ($3!=0) {
     	$$=$1/$3;
     	}
     	else {
     	yyerror("Divide Error:Cannot divide by 0\n");
     	}
     	}
     |SUB exp {
     	$$=-$2;
     	}
     |exp POW exp {
     	$$=pow($1,$3);
     	}
     |exp MOD exp {
     	if($3!=0){
     	$$=fmod($1,$3);
     	}
     	else {
     	yyerror("Modulo Error:Cannot divide by 0\n");
     	}
     	}
     |LOG OPEN_BRACKET exp CLOSE_BRACKET {
     	$$=log10($3);
     	}
     |LN OPEN_BRACKET exp CLOSE_BRACKET {
     	$$=log($3);
     	}
     |SQRT OPEN_BRACKET exp CLOSE_BRACKET {
     	$$=sqrt($3);
     	}
     |SIN OPEN_BRACKET exp CLOSE_BRACKET {
     	$$= m==1 ? sin($3*M_PI/180) : sin($3);
     	}
     |COS OPEN_BRACKET exp CLOSE_BRACKET {
     	$$= m==1 ? cos($3*M_PI/180) : cos($3);
     	}
     |TAN OPEN_BRACKET exp CLOSE_BRACKET {
     	$$= m==1 ? tan($3*M_PI/180) : tan($3);
     	}
     |COSEC OPEN_BRACKET exp CLOSE_BRACKET {
     	$$= m==1 ? 1/sin($3*M_PI/180) : 1/sin($3);
     	}
     |SEC OPEN_BRACKET exp CLOSE_BRACKET {
     	$$= m==1 ? 1/cos($3*M_PI/180) : 1/cos($3);
     	}
     |COT OPEN_BRACKET exp CLOSE_BRACKET {
     	$$= m==1 ? 1/tan($3*M_PI/180) : 1/tan($3);
     	}
     |ASIN OPEN_BRACKET exp CLOSE_BRACKET {
     	if($3<=1&&$3>=-1) {
     	$$= m==1 ? asin($3)*180/M_PI : asin($3);
     	}
     	else {
     	yyerror("ASIN ERROR: Out of Range\n");
     	}
     	}
     |ACOS OPEN_BRACKET exp CLOSE_BRACKET {
     	if($3<=1&&$3>=-1) {
     	$$= m==1 ? acos($3)*180/M_PI : acos($3);
     	}
     	else {
     	yyerror("ACOS ERROR: Out of Range\n");
     	}
     	}
     |ATAN OPEN_BRACKET exp CLOSE_BRACKET {
     	if($3<=1&&$3>=-1) {
     	$$= m==1 ? atan($3)*180/M_PI : atan($3);
     	}
     	}
     |OPEN_BRACKET exp CLOSE_BRACKET {
     	$$=$2;
     	}
     |num {
     	$$=$1;
     	}
     |constant	
    	;
constant : PI {
	 $$=M_PI;
	 }
	 | E {
	 $$=M_E;
	 };
%%
extern int yyparse();
extern void yy_scan_string(const char *);

// Remove the old `void main()` and replace it with this:
int main(int argc, char *argv[])
{
    if (argc < 2) {
        printf("Usage: %s <expression>\n", argv[0]);
        return 1;
    }

    // Build a temporary input file for lex/yacc
    FILE *fp = fopen("temp_input.txt", "w");
    if (!fp) {
        perror("Error creating temp file");
        return 1;
    }
    fprintf(fp, "%s\n", argv[1]);
    fclose(fp);

    // Redirect stdin to read from the file
    freopen("temp_input.txt", "r", stdin);

    flag = 0;
    yyparse();

    remove("temp_input.txt");  // clean up
    return 0;
}



