#ifndef SYMBOL_TABLE_ENTRY_H
#define SYMBOL_TABLE_ENTRY_H

#include <string>
#include "TypeInfo.h"
using namespace std;


class SYMBOL_TABLE_ENTRY {
private:
  // Member variables
  string name;
  TYPE_INFO typeInfo;
  

public:
  // Constructors
  SYMBOL_TABLE_ENTRY( ) { 
      char blank[] = { '\0' };
      name = ""; 
      typeInfo.type = UNDEFINED;
      typeInfo.numParams = NOT_APPLICABLE;
      typeInfo.returnType = NOT_APPLICABLE;
      typeInfo.stringVal = blank;
      typeInfo.intVal = 0;
   }

  SYMBOL_TABLE_ENTRY(const string theName, const int theType, const int num_params, const int return_type, char* stringValue, const int intValue) {
    name = theName;
    typeInfo.type = theType;
    typeInfo.numParams = num_params;
    typeInfo.returnType = return_type;
    typeInfo.stringVal = strdup(stringValue);
    typeInfo.intVal = intValue;
  }

  // Accessors
  string getName() const { return name; }
  TYPE_INFO getTypeInfo() const { return typeInfo; }
    
};

#endif  // SYMBOL_TABLE_ENTRY_H
