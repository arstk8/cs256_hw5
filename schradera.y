/*
 schradera.y
 Author:  Andrew Schrader
 Purpose: A bison specification for the MFPL grammar
 
 To create the syntax analyzer:
 
     flex schradera.l
     bison schradera.y
     g++ schradera.tab.c -o parser
     parser < inputFileName
*/

%{
#include<iostream>
#include<stdio.h>
#include<stack>
#include<string>
#include"SymbolTable.h"

int currentLine = 1;
int id_list_len = 0;
int param_count = 0;
int param_expect = 0;
stack<SYMBOL_TABLE> scopeStack;

void printRule(const char *lhs, const char *rhs);
int yyerror(const char *s);
void beginScope();
void endScope();
bool findEntryInAnyScope(string theName);
TYPE_INFO getTypeInfo(string theName);
bool isIntCompatible( const int type );
bool isIntStrCompatible( const int type );
    
extern "C" {
    int yyparse(void);
    int yylex(void);
    int yywrap() { return 1; }
}

%}

%union {
    char* text;
    TYPE_INFO typeInfo;
    int intVal;
    char* stringVal;
}

/* Token declarations */
%token T_LET T_LAMBDA T_INPUT T_PRINT T_IF T_LPAREN T_RPAREN T_ADD T_MULT T_DIV T_SUB T_IDENT T_INTCONST T_STRCONST T_UNKNOWN

%type<text> T_IDENT T_ADD T_SUB T_MULT T_DIV N_OP
%type<typeInfo> N_EXPR N_PARENTHESIZED_EXPR N_ARITHMETIC_EXPR N_IF_EXPR N_LAMBDA_EXPR N_PRINT_EXPR N_INPUT_EXPR N_EXPR_LIST N_LET_EXPR
%type<intVal> T_INTCONST
%type<stringVal> T_STRCONST

/* Starting point */
%start N_START

/* Translation rules */
%%
N_START         : N_EXPR
                  {
                      printRule("START", "EXPR");
                      printf("\n---- Completed parsing ----\n\n");
                      printf("\nValue of the expression is: ");
                      
                      if($1.type == INT)
                      {
                          printf("%d\n", $1.intVal);
                      }
                      else if($1.type == STR)
                      {
                          printf("%s\n", $1.stringVal);
                      }
                      return 0;
                  }
                ;
N_EXPR          : T_INTCONST
                  {
                      char blank[] = "\0";
                      printRule("EXPR", "INTCONST");
                      $$.type = INT;
                      $$.numParams = NOT_APPLICABLE;
                      $$.returnType = NOT_APPLICABLE;
                      $$.intVal = $1;
                      $$.stringVal = blank;
                  }
                | T_STRCONST
                  {
                      printRule("EXPR", "STRCONST");
                      $$.type = STR;
                      $$.numParams = NOT_APPLICABLE;
                      $$.returnType = NOT_APPLICABLE;
                      $$.stringVal = strdup($1);
                      $$.intVal = 0;
                  }
                | T_IDENT
                  {
                      printRule("EXPR", "ID");
                      bool found = findEntryInAnyScope(string($1));
                      
                      TYPE_INFO t = getTypeInfo(string($1));
                      $$.type = t.type;
                      $$.numParams = t.numParams;
                      $$.returnType = t.returnType;
                      $$.stringVal = strdup(t.stringVal);
                      $$.intVal = t.intVal;
                      
                      if(!found)
                      {
                          yyerror("Undefined identifier");
                      }
                  }
                | T_LPAREN N_PARENTHESIZED_EXPR T_RPAREN
                  {
                      printRule("EXPR", "( PARENTHESIZED_EXPR )");
                      
                      $$.type = $2.type;
                      $$.numParams = $2.numParams;
                      $$.returnType = $2.returnType;
                      $$.stringVal = strdup($2.stringVal);
                      $$.intVal = $2.intVal;
                  }
                ;
N_PARENTHESIZED_EXPR : N_ARITHMETIC_EXPR
                       {
                           printRule("PARENTHESIZED_EXPR", "ARITHMETIC_EXPR");
                           char empty[] = "\0";
                           $$.type = $1.type;
                           $$.numParams = $1.numParams;
                           $$.returnType = $1.returnType;
                           $$.stringVal = empty;
                           $$.intVal = $1.intVal;
                       }
                     | N_IF_EXPR
                       {
                           printRule("PARENTHESIZED_EXPR", "IF_EXPR");
                           
                           $$.type = $1.type;
                           $$.numParams = $1.numParams;
                           $$.returnType = $1.returnType;
                           $$.stringVal = strdup($1.stringVal);
                           $$.intVal = $1.intVal;
                       }
                     | N_LET_EXPR
                       {
                           printRule("PARENTHESIZED_EXPR", "LET_EXPR");
                           
                           $$.type = $1.type;
                           $$.numParams = $1.numParams;
                           $$.returnType = $1.returnType;
                           $$.stringVal = strdup($1.stringVal);
                           $$.intVal = $1.intVal;
                       }
                     | N_LAMBDA_EXPR
                       {
                           printRule("PARENTHESIZED_EXPR", "LAMBDA_EXPR");
                           char empty[] = "\0";
                           $$.type = $1.type;
                           $$.numParams = $1.numParams;
                           $$.returnType = $1.returnType;
                           $$.stringVal = empty;
                           $$.intVal = $1.intVal;
                       }
                     | N_PRINT_EXPR
                       {
                           printRule("PARENTHESIZED_EXPR", "PRINT_EXPR");
                           
                           $$.type = $1.type;
                           $$.numParams = $1.numParams;
                           $$.returnType = $1.returnType;
                           $$.stringVal = strdup($1.stringVal);
                           $$.intVal = $1.intVal;
                       }
                     | N_INPUT_EXPR
                       {
                           printRule("PARENTHESIZED_EXPR", "INPUT_EXPR");
                           
                           $$.type = $1.type;
                           $$.numParams = $1.numParams;
                           $$.returnType = $1.returnType;
                           $$.stringVal = strdup($1.stringVal);
                           $$.intVal = $1.intVal;
                       }
                     | N_EXPR_LIST
                       {
                           printRule("PARENTHESIZED_EXPR", "EXPR_LIST");
                           
                           $$.type = $1.type;
                           $$.numParams = $1.numParams;
                           $$.returnType = $1.returnType;
                           $$.stringVal = strdup($1.stringVal);
                           $$.intVal = $1.intVal;
                       }
                     ;
N_ARITHMETIC_EXPR : N_OP N_EXPR N_EXPR
                    {
                        printRule("ARITHMETIC_EXPR", "OP EXPR EXPR");
                        
                        if(!isIntCompatible($2.type))
                        {
                            yyerror("Arg 1 must be of type integer");
                        }
                        
                        if(!isIntCompatible($3.type))
                        {
                            yyerror("Arg 2 must be of type integer");
                        }

                        $$.type = INT;
                        $$.numParams = NOT_APPLICABLE;
                        $$.returnType = NOT_APPLICABLE;

                        if($1[0] == '+')
                        {
                            $$.intVal = $2.intVal + $3.intVal;
                        }
                        else if($1[0] == '-')
                        {
                            $$.intVal = $2.intVal - $3.intVal;
                        }
                        else if($1[0] == '*')
                        {
                            $$.intVal = $2.intVal * $3.intVal;
                        }
                        else if($1[0] == '/')
                        {
                            if($3.intVal == 0)
                            {
                                yyerror("Attempted division by zero");
                            }
                            
                            $$.intVal = $2.intVal / $3.intVal;
                        }
                    }
                  ;
N_IF_EXPR : T_IF N_EXPR N_EXPR N_EXPR
            {
                printRule("IF_EXPR", "if EXPR EXPR EXPR");
                
                if(!isIntCompatible($2.type))
                {
                    yyerror("Arg 1 must be of type integer");
                }
                
                if(!isIntStrCompatible($3.type))
                {
                    yyerror("Arg 2 must be of type integer or string");
                }
                
                if(!isIntStrCompatible($4.type))
                {
                    yyerror("Arg 3 must be of type integer or string");
                }
                
                $$.type = INT_or_STR;
                $$.numParams = NOT_APPLICABLE;
                $$.returnType = NOT_APPLICABLE;
                
                if($2.intVal == 0)
                {
                    $$.intVal = $4.intVal;
                    $$.stringVal = strdup($4.stringVal);
                    $$.type = $4.type;
                }
                else
                {
                    $$.intVal = $3.intVal;
                    $$.stringVal = strdup($3.stringVal);
                    $$.type = $3.type;
                }
            }
          ;
N_LET_EXPR : T_LET T_LPAREN N_ID_EXPR_LIST T_RPAREN N_EXPR
             {
                 printRule("LET_EXPR", "let ( ID_EXPR_LIST ) EXPR");
                 
                 endScope();
                 
                 if(!isIntStrCompatible($5.type))
                 {
                     yyerror("Arg 2 must be of type integer or string");
                 }
                 
                 $$.type = $5.type;
                 $$.numParams = $5.numParams;
                 $$.returnType = $5.returnType;
                 $$.stringVal = strdup($5.stringVal);
                 $$.intVal = $5.intVal;
             }
           ;
N_ID_EXPR_LIST : /* epsilon */
                 {
                     printRule("ID_EXPR_LIST", "epsilon");
                 }
               | N_ID_EXPR_LIST T_LPAREN T_IDENT N_EXPR T_RPAREN
                 {
                     printRule("ID_EXPR_LIST", "ID_EXPR_LIST ( ID EXPR )");
                     bool success = scopeStack.top().addEntry(SYMBOL_TABLE_ENTRY(string($3), $4.type, $4.numParams, $4.returnType, $4.stringVal, $4.intVal ));
                     
                     printf("___Adding %s to symbol table\n", $3);

                     if(!success)
                     {
                         yyerror("Multiply defined identifier");
                     }
                 }
               ;
N_LAMBDA_EXPR : T_LAMBDA T_LPAREN N_ID_LIST T_RPAREN N_EXPR
                {
                    printRule("LAMBDA_EXPR", "lambda ( ID_LIST ) EXPR");
                    
                    endScope();
                    
                    if(!isIntStrCompatible($5.type))
                    {
                        yyerror("Arg 2 must be of type integer or string");
                    }
                    
                    $$.type = FUNCTION;
                    $$.numParams = id_list_len;
                    $$.returnType = $5.type;
                    
                }
              ;
N_ID_LIST     : /* epsilon */
                {
                    printRule("ID_LIST", "epsilon");
                }
              | N_ID_LIST T_IDENT
                {
                    char blank[] = {'\0'};
                    printRule("ID_LIST", "ID_LIST ID");
                    bool success = scopeStack.top().addEntry(SYMBOL_TABLE_ENTRY(string($2), INT, UNDEFINED, UNDEFINED, blank, 0));
                    printf("___Adding %s to symbol table\n", $2);
                    
                    if(!success)
                    {
                        yyerror("Multiply defined identifier");
                    }
                    
                    id_list_len++;
                }
              ;
N_PRINT_EXPR : T_PRINT N_EXPR
               {
                   printRule("PRINT_EXPR", "print EXPR");
                   
                   if(!isIntStrCompatible($2.type))
                   {
                       yyerror("Arg 1 must be of type integer or string");
                   }
                   
                   $$.type = $2.type;
                   $$.numParams = NOT_APPLICABLE;
                   $$.returnType = NOT_APPLICABLE;
                   $$.stringVal = strdup($2.stringVal);
                   $$.intVal = $2.intVal;
                   
                   if( $2.type == INT )
                   {
                       printf("%d\n", $2.intVal);
                   }
                   else if($2.type == STR)
                   {
                       printf("%s\n", $2.stringVal);
                   }
               }
             ;
N_INPUT_EXPR : T_INPUT
               {
                   char tempString[256];
                   printRule("INPUT_EXPR", "input");
                   std::cin.getline (tempString, 256);

                   if(tempString[0] == '+' || tempString[0] == '-' || isdigit(tempString[0]))
                   {
                       $$.intVal = atoi(tempString);
                       $$.type = INT;
                       char empty[] = "\0";
                       $$.stringVal = empty;
                   }
                   else
                   {
                       $$.stringVal = strdup(tempString);
                       $$.type = STR;
                       $$.intVal = 0;
                   }
               }
             ;
N_EXPR_LIST : N_EXPR N_EXPR_LIST
              {
                  printRule("EXPR_LIST", "EXPR EXPR_LIST");
                  if( $1.type == FUNCTION )
                  {
                      if(param_count > $1.numParams)
                      {
                          yyerror("Too many parameters in function call");
                      }
                      else if(param_count < $1.numParams)
                      {
                          yyerror("Too few parameters in function call");
                      }
                      
                      param_count = 0;
                      param_expect = $1.numParams;
                      
                      $$.type = $1.returnType;
                      $$.numParams = NOT_APPLICABLE;
                      $$.returnType = NOT_APPLICABLE;
                      $$.intVal = $2.intVal;
                      $$.stringVal = strdup($2.stringVal);
                  }
                  else
                  {
                      param_count++;
                      
                      $$.type = $1.type;
                      $$.numParams = NOT_APPLICABLE;
                      $$.returnType = NOT_APPLICABLE;
                      $$.intVal = $2.intVal;
                      $$.stringVal = strdup($2.stringVal);
                  }
              }
            | N_EXPR
              {
                  printRule("EXPR_LIST", "EXPR");
                  if( $1.type != FUNCTION )
                  {
                      param_count++;
                      $$.type = $1.type;
                      $$.numParams = NOT_APPLICABLE;
                      $$.returnType = NOT_APPLICABLE;
                      $$.intVal = $1.intVal;
                      $$.stringVal = strdup($1.stringVal);
                  }
                  else
                  {
                      $$.type = $1.returnType;
                      $$.numParams = NOT_APPLICABLE;
                      $$.returnType = NOT_APPLICABLE;
                      $$.intVal = $1.intVal;
                      $$.stringVal = strdup($1.stringVal);
                  }
              }
            ;
N_OP : T_ADD
       {
           printRule("OP", "+");
           $$ = strdup($1);
       }
     | T_SUB
       {
           printRule("OP", "-");
           $$ = strdup($1);
       }
     | T_MULT
       {
           printRule("OP", "*");
           $$ = strdup($1);
       }
     | T_DIV
       {
           printRule("OP", "/");
           $$ = strdup($1);
       }
     ;
%%

#include "lex.yy.c"
extern FILE *yyin;

void printRule(const char *lhs, const char *rhs)
{
    printf("%s -> %s\n", lhs, rhs);
    return;
}

int yyerror(const char *s)
{
    printf("Line %d: %s\n", currentLine, s);
    exit(1);
}

void beginScope()
{
    scopeStack.push(SYMBOL_TABLE());
    printf("\n___Entering new scope...\n\n");
}

void endScope()
{
    scopeStack.pop();
    printf("\n___Exiting scope...\n\n");
}

bool findEntryInAnyScope(string theName)
{
    if(scopeStack.empty())
    {
        return false;
    }
    bool found = scopeStack.top().findEntry(theName);
    
    if(found)
    {
        return true;
    }
    else
    {
        SYMBOL_TABLE symbolTable = scopeStack.top();
        scopeStack.pop();
        found = findEntryInAnyScope(theName);
        scopeStack.push(symbolTable);
        return found;
    }
}

TYPE_INFO getTypeInfo(string theName)
{
    if(scopeStack.empty())
    {
        TYPE_INFO t;
        t.type = -1;
        t.numParams = -1;
        t.returnType = -1;
        return t;
    }
    bool found = scopeStack.top().findEntry(theName);
    
    if(found)
    {
        return scopeStack.top().getTypeInfo(theName);
    }
    else
    {
        TYPE_INFO retVal;
        SYMBOL_TABLE symbolTable = scopeStack.top();
        scopeStack.pop();
        retVal = getTypeInfo(theName);
        scopeStack.push(symbolTable);
        return retVal;
    }
}

bool isIntCompatible( const int type )
{
    return ( type == INT || type == INT_or_STR );
}

bool isIntStrCompatible( const int type )
{
    return ( isIntCompatible(type) || type == STR );
}

int main(int argc, char** argv)
{
    if(argc < 2)
    {
        printf("You must specify a file in the command line!\n");
        exit(1);
    }
    
    yyin = fopen(argv[1], "r");
    do
    {
        yyparse();
    } while(!feof(yyin));

    return 0;
}














