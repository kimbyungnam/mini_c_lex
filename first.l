%{
#include <string.h>
#include <stdio.h>

#define MAX_LEN 4096

char symbol_arr[MAX_LEN][MAX_LEN];
char string_arr[MAX_LEN][MAX_LEN];
int symbol_idx = 1;
int string_idx = 1;

void comment(char* token, char* text){
	printf("<%s, >\t\t%s\n",token, text);
}
void comment_double(char* token, char* spec, char* text){
	printf("<%s, %s>\t\t%s\n",token, spec, text);
}
void comment_int(char* token, char* spec, char* text){
	printf("<%s, %s>\t\t%s\n", token, &spec[((int)strlen(spec)-10 < 0 ? 0 : (int)strlen(spec)-10)], text);
}
void comment_id(char* token, int spec, char* text){
	printf("<%s, %d>\t\t%s\n",token, spec, text);
}
int check(char*, char[MAX_LEN][MAX_LEN], int*);
int insert(char*, char[MAX_LEN][MAX_LEN], int*);
%}
int int
double double
if if
while while
return return
str str
else else
print print
INTEGER -?[0-9]+
Operators \+|-|\*|\/|>|>=|<|<=|==|!=
ASSIGN =
LPAREN \(
RPAREN \)
COMM ,
SEMI ;
LBRACK \{
RBRACK \}
SPACE [\t\n ]+
STRING \"(\\\n|[^\"])*\"
ID [a-zA-Z][a-zA-Z0-9_]*
E ([Ee][+-]?[0-9]+)
FS (f|F|l|L)
%%
"/*"([^\*]|\*[^/])*"*/" {comment("comment",yytext);}
"//".* {comment("comment", yytext);}
{SPACE} ;
{print} {comment("print", yytext);}
{else} {comment("else", yytext);}
{str} {comment("str", yytext);}
{int} {comment("int", yytext);}
-?[0-9]+"."[0-9]*{E}?{FS}? {comment_double("DOUBLE", yytext, yytext);}
-?[0-9]+{E}{FS}? {comment_double("DOUBLE", yytext, yytext);}
-?[0-9]*"."[0-9]+{E}?{FS}? {comment_double("DOUBLE", yytext, yytext);}
{if} {comment("if", yytext);}
{while} {comment("while", yytext);}
{return} {comment("return", yytext);}
{INTEGER} {comment_int("INTEGER", yytext, yytext);}
{double} {comment_double("double", yytext, yytext);}
{Operators} {comment("Operators", yytext);}
{LPAREN} {comment("LPAREN", yytext);}
{RPAREN} {comment("RPAREN", yytext);}
{COMM} {comment("COMM", yytext);}
{SEMI} {comment("SEMI", yytext);}
{LBRACK} {comment("LBRACK", yytext);}
{RBRACK} {comment("RBRACK", yytext);}
{ASSIGN} {comment("ASSIGN", yytext);}
{STRING} {comment_id("STRING", insert(yytext, string_arr, &string_idx),yytext);}
{ID} {comment_id("ID", insert(yytext, symbol_arr, &symbol_idx), yytext);}
%%
int check(char* val, char arr[MAX_LEN][MAX_LEN], int* idx){
	for(int i=1; i<*idx; i++){
		if(!strncmp(arr[i], val, 16))
			return i;
	}
	return 0;
}
int insert(char* val, char arr[MAX_LEN][MAX_LEN], int* idx){
	int result = check(val, arr, idx);
	if(result == 0){
		strcpy(arr[*idx],val);
		result = (*idx)++;
	}
	return result;
}
int main(int argc, char **argv){
	FILE* fd;
	fd = fopen(argv[1], "r");
	if(!fd){
		fprintf(stderr,"could not open the file\n");
		exit(0);
	}
	yyin=fd;
	yylex();
	printf("\nindex|symbol\n");
	for(int i=1; i<symbol_idx; i++){
		printf("%3d  |  %s\n",i,symbol_arr[i]);
	}
	printf("\nindex|strings\n");
	for(int i=1; i<string_idx; i++){
		printf("%3d  |  %s\n", i, string_arr[i]);
	}
	return(0);
}
int yywrap(){
	return(1);
}
