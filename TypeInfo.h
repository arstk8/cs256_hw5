#ifndef TYPE_INFO_H
#define TYPE_INFO_H

#define FUNCTION       -5
#define INT            -4
#define STR            -3
#define INT_or_STR     -2
#define UNDEFINED      -1
#define NOT_APPLICABLE -1

typedef struct {
    int type;
    int numParams;
    int returnType;
    int intVal;
    char* stringVal;
} TYPE_INFO;

#endif