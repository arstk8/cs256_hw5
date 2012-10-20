/* 
 schradera.l
 Author:  Andrew Schrader
 Purpose: A lex specification file for the MFPL programming language
 
 To create the syntax analyzer:
 
 flex schradera.l
 bison schradera.y
 g++ schradera.tab.c -o parser
 parser < inputFileName
 */
%{

%}
/* Definitions of regular expressions go here */
 
WSPACE		    [ \t\r]+
NEWLINE          \n
LO_ALPHA		[a-z]
HI_ALPHA		[A-Z]
LETTER			{LO_ALPHA}|{HI_ALPHA}
DIGIT             [0-9]
ALPHANUM		{LETTER}|{DIGIT}
UNDERSCORE		_

IDENT			({UNDERSCORE}|{LETTER})({ALPHANUM}|{UNDERSCORE})*

NEG_INTCONST	"-"[0-9]+
POS_INTCONST	("+")?[0-9]+
INTCONST          {NEG_INTCONST}|{POS_INTCONST}

DOUBLE_QUOTE      \"
STRCONST          {DOUBLE_QUOTE}[^\"^\n]*{DOUBLE_QUOTE}  

COMMENT           "%".*$

%% 
"let" {
    printf("TOKEN: LET       LEXEME: %s\n", yytext);
    beginScope();
    return T_LET;
}
"if" {
    printf("TOKEN: IF        LEXEME: %s\n", yytext);
    return T_IF;
}
"lambda" {
    printf("TOKEN: LAMBDA    LEXEME: %s\n", yytext);
    beginScope();
    id_list_len = 0;
    return T_LAMBDA;
}
"print" {
    printf("TOKEN: PRINT     LEXEME: %s\n", yytext);
    return T_PRINT;
}
"input" {
    printf("TOKEN: INPUT     LEXEME: %s\n", yytext);
    return T_INPUT;
}
"+" {
    yylval.text = strdup(yytext);
    printf("TOKEN: ADD       LEXEME: %s\n", yytext);
    return T_ADD;
}
"-" {
    yylval.text = strdup(yytext);
    printf("TOKEN: SUB       LEXEME: %s\n", yytext);
    return T_SUB;
}
"*" {
    yylval.text = strdup(yytext);
    printf("TOKEN: MULT      LEXEME: %s\n", yytext);
    return T_MULT;
}
"/" {
    yylval.text = strdup(yytext);
    printf("TOKEN: DIV       LEXEME: %s\n", yytext);
    return T_DIV;
}
"(" {
    printf("TOKEN: LPAREN    LEXEME: %s\n", yytext);
    return T_LPAREN;
}
")" {
    printf("TOKEN: RPAREN    LEXEME: %s\n",yytext);
    return T_RPAREN;
}
{INTCONST} {
    yylval.intVal = atoi(yytext);
    printf("TOKEN: INTCONST  LEXEME: %s\n", yytext);
    return T_INTCONST;
}
{IDENT}	{
    yylval.text = strdup(yytext);
    printf("TOKEN: IDENT     LEXEME: %s\n", yytext);
    return T_IDENT;
}
{STRCONST} {
    yylval.stringVal = strdup(yytext);
    printf("TOKEN: STRCONST  LEXEME: %s\n", yytext);
    return T_STRCONST;
}
{NEWLINE} {
    currentLine++;
}
{WSPACE} { }
{COMMENT} { }
.   {
    printf("TOKEN: UNKNOWN     LEXEME: %s\n", yytext);
    return T_UNKNOWN;
}
%%











