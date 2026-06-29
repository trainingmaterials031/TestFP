grammar FlatFileSchema;

@header{
    package com.webmethods.flatfile.antlr;
}

// ─────────────────────────────────────────────────────────────────────────────
// Root rule
// ─────────────────────────────────────────────────────────────────────────────

flatFileDefinition
    : schemaDefinition
    | dictionaryDefinition
    ;

// ─────────────────────────────────────────────────────────────────────────────
// Schema Definition (Unified - supports both full and simplified syntax)
// ─────────────────────────────────────────────────────────────────────────────

schemaDefinition
    : 'flatfile' ('schema')? ID '{' schemaBody '}'
    ;

schemaBody
    : schemaProperty* (delimitersBlock | parserBlock | recordIdentifierBlock)* recordDefinition+
    ;

delimitersBlock
    : 'delimiters' '{' delimiterProperty+ '}'
    ;

delimiterProperty
    : 'record' '=' STRING_LITERAL
    | 'field' '=' STRING_LITERAL
    | 'subfield' '=' STRING_LITERAL
    | 'release' '=' STRING_LITERAL
    | 'quotedRelease' '=' STRING_LITERAL
    ;

parserBlock
    : 'parser' '{' parserProperty+ '}'
    ;

parserProperty
    : 'type' '=' STRING_LITERAL
    | 'recordSize' '=' INT
    ;

recordIdentifierBlock
    : 'recordIdentifier' '{' recordIdentifierProperty+ '}'
    ;

recordIdentifierProperty
    : 'type' '=' STRING_LITERAL
    | 'offset' '=' INT
    | 'values' '=' '[' stringList ']'
    | 'validateWithoutRecordIdentifier' '=' booleanLiteral
    ;

stringList
    : STRING_LITERAL (',' STRING_LITERAL)*
    ;

schemaProperty
    : 'type' ':' schemaType ';'
    | 'encoding' ':' STRING_LITERAL ';'
    | 'description' ':' STRING_LITERAL ';'
    | 'uses_dictionary' ':' qualifiedName ';'
    | 'validateWithoutRecordIdentifier' ':' booleanLiteral ';'
    ;

schemaType
    : 'DELIMITED'
    | 'FIXED_LENGTH'
    | 'VARIABLE_LENGTH'
    | 'EDI'
    ;

// ─────────────────────────────────────────────────────────────────────────────
// Dictionary Definition
// ─────────────────────────────────────────────────────────────────────────────

dictionaryDefinition
    : 'flatfile' 'dictionary' ID '{' dictionaryBody '}'
    ;

dictionaryBody
    : dictionaryProperty? dictionaryElement+
    ;

dictionaryProperty
    : 'description' ':' STRING_LITERAL ';'
    ;

dictionaryElement
    : fieldDefDefinition
    | recordDefDefinition
    | compositeDefDefinition
    ;

fieldDefDefinition
    : 'field_def' ID '{' fieldDefBody '}'
    ;

fieldDefBody
    : fieldProperty+
    ;

recordDefDefinition
    : 'record_def' ID '{' recordDefBody '}'
    ;

recordDefBody
    : recordProperty* recordElement+
    ;

compositeDefDefinition
    : 'composite_def' ID '{' compositeDefBody '}'
    ;

compositeDefBody
    : compositeProperty* compositeElement+
    ;

// ─────────────────────────────────────────────────────────────────────────────
// Record Definition
// ─────────────────────────────────────────────────────────────────────────────

recordDefinition
    : 'record' ID '{' recordBody '}'
    ;

recordBody
    : recordProperty* recordElement*
    ;

recordProperty
    : 'mandatory' ':' booleanLiteral ';'
    | 'ordered' ':' booleanLiteral ';'
    | 'max_repeat' ':' maxRepeatValue ';'
    | 'identifier' ':' '{' identifierBody '}'
    | 'area' ':' areaValue ';'
    | 'position' ':' positionValue ';'
    | 'allow_undefined' ':' booleanLiteral ';'
    | 'check_fields' ':' booleanLiteral ';'
    | 'validator' ':' qualifiedName ';'
    | 'description' ':' STRING_LITERAL ';'
    | 'alternate_name' ':' STRING_LITERAL ';'
    ;

maxRepeatValue
    : INT
    | 'unlimited'
    ;

identifierBody
    : 'field' ':' ID ';' 'value' ':' STRING_LITERAL ';' 'position' ':' INT ';'
    ;

areaValue
    : ID
    | 'not_used'
    ;

positionValue
    : INT
    | 'not_used'
    ;

recordElement
    : fieldDefinition
    | compositeDefinition
    | fieldReference
    | recordReference
    | compositeReference
    ;

// ─────────────────────────────────────────────────────────────────────────────
// Field Definition
// ─────────────────────────────────────────────────────────────────────────────

fieldDefinition
    : 'field' ID ':' dataType                              // Simplified: field name: Type
    | 'field' ID ':' dataType '{' fieldBody '}'            // With properties
    | 'field' ID '{' fieldBody '}'                         // Original syntax
    ;

fieldBody
    : fieldProperty* subfieldDefinition*
    ;

fieldProperty
    : 'data_type' ':' dataType ';'
    | 'mandatory' ':' booleanLiteral ';'
    | 'delimiter' ':' STRING_LITERAL ';'
    | 'position' ':' INT ';'
    | 'length' ':' INT ';'
    | 'index' ':' INT ';'                                 // Field index for delimited format
    | 'validator' ':' qualifiedName ';'
    | 'extractor' ':' qualifiedName ';'
    | 'format_service' ':' qualifiedName ';'
    | 'description' ':' STRING_LITERAL ';'
    | 'alternate_name' ':' STRING_LITERAL ';'
    | 'id_code' ':' STRING_LITERAL ';'
    | 'local_description' ':' STRING_LITERAL ';'
    | 'referencedDefinition' '=' STRING_LITERAL ';'       // New: for field aliases
    | 'position' '=' INT ';'                              // Alternative syntax with =
    | 'length' '=' INT ';'                                // Alternative syntax with =
    ;

dataType
    : 'String'
    | 'Integer'
    | 'Float'
    | 'Double'
    | 'Date'
    | 'DateTime'
    | 'Boolean'
    | 'Binary'
    | 'Decimal'
    | 'Long'
    | 'Short'
    | 'Byte'
    | ID  // Custom data type
    ;

// ─────────────────────────────────────────────────────────────────────────────
// Subfield Definition
// ─────────────────────────────────────────────────────────────────────────────

subfieldDefinition
    : 'subfield' ID '{' subfieldBody '}'
    ;

subfieldBody
    : subfieldProperty+
    ;

subfieldProperty
    : 'data_type' ':' dataType ';'
    | 'delimiter' ':' STRING_LITERAL ';'
    | 'position' ':' INT ';'
    | 'length' ':' INT ';'
    | 'mandatory' ':' booleanLiteral ';'
    | 'description' ':' STRING_LITERAL ';'
    ;

// ─────────────────────────────────────────────────────────────────────────────
// Composite Definition
// ─────────────────────────────────────────────────────────────────────────────

compositeDefinition
    : 'composite' ID '{' compositeBody '}'
    ;

compositeBody
    : compositeProperty* compositeElement+
    ;

compositeProperty
    : 'mandatory' ':' booleanLiteral ';'
    | 'max_repeat' ':' maxRepeatValue ';'
    | 'description' ':' STRING_LITERAL ';'
    | 'delimiter' ':' STRING_LITERAL ';'
    | 'index' ':' INT ';'                                    // Field index for delimited format
    ;

compositeElement
    : fieldDefinition
    | fieldReference
    | recordReference
    | compositeReference
    ;

// ─────────────────────────────────────────────────────────────────────────────
// References
// ─────────────────────────────────────────────────────────────────────────────

fieldReference
    : 'field_ref' ':' qualifiedName fieldReferenceOverride? ';'
    ;

recordReference
    : 'record_ref' ':' qualifiedName recordReferenceOverride? ';'
    ;

compositeReference
    : 'composite_ref' ':' qualifiedName compositeReferenceOverride? ';'
    ;

fieldReferenceOverride
    : '{' fieldProperty* '}'
    ;

recordReferenceOverride
    : '{' recordProperty* '}'
    ;

compositeReferenceOverride
    : '{' compositeProperty* '}'
    ;

// ─────────────────────────────────────────────────────────────────────────────
// Extension Points - Custom Types, Validators, Extractors
// ─────────────────────────────────────────────────────────────────────────────

customTypeDefinition
    : 'custom_type' ID '{' customTypeBody '}'
    ;

customTypeBody
    : 'base_type' ':' dataType ';'
      ('pattern' ':' STRING_LITERAL ';')?
      ('validator' ':' qualifiedName ';')?
    ;

validatorDefinition
    : 'validator' ID '{' validatorBody '}'
    ;

validatorBody
    : 'service' ':' STRING_LITERAL ';'
      ('parameters' ':' '{' parameterList '}' ';')?
    ;

extractorDefinition
    : 'extractor' ID '{' extractorBody '}'
    ;

extractorBody
    : 'service' ':' STRING_LITERAL ';'
      ('parameters' ':' '{' parameterList '}' ';')?
    ;

parameterList
    : parameter (',' parameter)*
    ;

parameter
    : ID ':' parameterValue
    ;

parameterValue
    : STRING_LITERAL
    | INT
    | booleanLiteral
    ;

// ─────────────────────────────────────────────────────────────────────────────
// Common Rules
// ─────────────────────────────────────────────────────────────────────────────

qualifiedName
    : ID ('.' ID)* (':' ID)?
    ;

booleanLiteral
    : 'true'
    | 'false'
    ;

// ─────────────────────────────────────────────────────────────────────────────
// Lexer Rules
// ─────────────────────────────────────────────────────────────────────────────

// Keywords (must come before ID to have priority)
// Schema types
DELIMITED       : 'DELIMITED' ;
FIXED_LENGTH    : 'FIXED_LENGTH' ;
VARIABLE_LENGTH : 'VARIABLE_LENGTH' ;
EDI             : 'EDI' ;

// Data types
STRING_TYPE     : 'String' ;
INTEGER_TYPE    : 'Integer' ;
FLOAT_TYPE      : 'Float' ;
DOUBLE_TYPE     : 'Double' ;
DATE_TYPE       : 'Date' ;
DATETIME_TYPE   : 'DateTime' ;
BOOLEAN_TYPE    : 'Boolean' ;
BINARY_TYPE     : 'Binary' ;
DECIMAL_TYPE    : 'Decimal' ;
LONG_TYPE       : 'Long' ;
SHORT_TYPE      : 'Short' ;
BYTE_TYPE       : 'Byte' ;

// Boolean literals
TRUE  : 'true' ;
FALSE : 'false' ;

// Special values
UNLIMITED : 'unlimited' ;
NOT_USED  : 'not_used' ;

// Identifiers and literals
ID             : [a-zA-Z_][a-zA-Z0-9_]* ;
INT            : [0-9]+ ;
FLOAT_LITERAL  : [0-9]+ '.' [0-9]+ ;

// String literals with escape sequences
STRING_LITERAL : '"' (~["\\] | '\\' .)* '"' ;

// Whitespace and comments
WS             : [ \t\r\n]+ -> skip ;
LINE_COMMENT   : '//' ~[\r\n]* -> skip ;
BLOCK_COMMENT  : '/*' .*? '*/' -> skip ;

// Error handling - catch any unexpected character
ERROR_CHAR     : . ;