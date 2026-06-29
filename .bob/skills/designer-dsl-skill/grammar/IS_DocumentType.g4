grammar FlowDocument;

@header{
	package com.webmethods.dsl.doc.antlr;
}

// Root rule for a document file: optional interface declaration followed by document
document : interfaceDeclaration? 'document' ID '{' parameterDeclaration* '}' ';'? EOF ;

// Interface declaration
interfaceDeclaration
    : 'interface' qualifiedInterfaceName ';'
    ;

// Qualified interface name (e.g., abc.test, CwWLR3InventoryServices.service.pub)
// Allow keywords to be used as part of interface names
qualifiedInterfaceName
    : interfaceNamePart ('.' interfaceNamePart)*
    ;

interfaceNamePart
    : ID
    | 'service'
    | 'document'
    | 'input'
    | 'output'
    | 'record'
    | 'recordList'
    ;

qualifiedName : ID ('.' ID)* ':' ID ;

parameterDeclaration
    : fieldDeclaration
    | recordDeclaration
    | recordListDeclaration
    ;

fieldDeclaration
    : dataType ('[' ']')* identifier constraints? ';'
    ;

recordDeclaration
    : 'record' ('[' ']')* identifier ('(' documentReference ')')? ('{' parameterDeclaration* '}')? constraints? ';'
    ;

recordListDeclaration
    : 'recordList' identifier ('(' documentReference ')')? ('{' parameterDeclaration* '}')? constraints? ';'
    ;

documentReference
    : qualifiedDocumentName
    ;

qualifiedDocumentName
    : ID ('.' ID)* ':' ID
    ;

dataType
    : STRING_TYPE
    | OBJECT_TYPE
    | INTEGER_TYPE
    | FLOAT_TYPE
    | DOUBLE_TYPE
    | BOOLEAN_TYPE
    | DATETIME_TYPE
    | DOCUMENT_TYPE
    | BYTE_TYPE
    | CHAR_TYPE
    | LONG_TYPE
    | SHORT_TYPE
    | BIGINTEGER_TYPE
    | BIGDECIMAL_TYPE
    | XOPOBJECT_TYPE
    | BYTE_PRIMITIVE
    | CHAR_PRIMITIVE
    | INT_PRIMITIVE
    | LONG_PRIMITIVE
    | SHORT_PRIMITIVE
    | FLOAT_PRIMITIVE
    | DOUBLE_PRIMITIVE
    | BOOLEAN_PRIMITIVE
    ;

constraints
    : '[' constraint (',' constraint)* ']'
    ;

constraint
    : 'required'
    | 'optional'
    | 'default' '=' value
    | 'minLength' '=' INT
    | 'maxLength' '=' INT
    | 'pattern' '=' STRING_LITERAL
    ;

// Allow certain keywords to be used as identifiers
// Also support qualified names with namespace prefix (e.g., tns:getInstallationDetails)
identifier
    : qualifiedIdentifier
    | 'input'
    | 'output'
    ;

qualifiedIdentifier
    : identifierWithHyphen (':' identifierWithHyphen)?
    ;

// Support identifiers with hyphens (e.g., SOAP-FAULT)
identifierWithHyphen
    : ID ('-' ID)*
    ;

value
    : INT
    | FLOAT_LITERAL
    | STRING_LITERAL
    | BOOL
    | NULL
    ;

// Keywords (must come before ID to have priority)
STRING_TYPE     : 'String' ;
OBJECT_TYPE     : 'Object' ;
INTEGER_TYPE    : 'Integer' ;
FLOAT_TYPE      : 'Float' ;
DOUBLE_TYPE     : 'Double' ;
BOOLEAN_TYPE    : 'Boolean' ;
DATETIME_TYPE   : 'DateTime' ;
DOCUMENT_TYPE   : 'Document' ;
BYTE_TYPE       : 'Byte' ;
CHAR_TYPE       : 'Char' ;
LONG_TYPE       : 'Long' ;
SHORT_TYPE      : 'Short' ;
BIGINTEGER_TYPE : 'BigInteger' ;
BIGDECIMAL_TYPE : 'BigDecimal' ;
XOPOBJECT_TYPE  : 'XOPObject' ;

// Primitive types (lowercase)
BYTE_PRIMITIVE    : 'byte' ;
CHAR_PRIMITIVE    : 'char' ;
INT_PRIMITIVE     : 'int' ;
LONG_PRIMITIVE    : 'long' ;
SHORT_PRIMITIVE   : 'short' ;
FLOAT_PRIMITIVE   : 'float' ;
DOUBLE_PRIMITIVE  : 'double' ;
BOOLEAN_PRIMITIVE : 'boolean' ;

// Literals and identifiers
BOOL : 'true' | 'false' ;
NULL : 'null' ;
ID    : [a-zA-Z_][a-zA-Z0-9_]* ;
INT   : [0-9]+ ;
FLOAT_LITERAL : [0-9]+ '.' [0-9]+ ;
STRING_LITERAL : '"' (~["\\] | '\\' .)* '"' ;

// Whitespace and comments
WS    : [ \t\r\n]+ -> skip ;
LINE_COMMENT : '//' ~[\r\n]* -> skip ;
BLOCK_COMMENT : '/*' .*? '*/' -> skip ;

// Error handling - catch any unexpected character
ERROR_CHAR : . ;