grammar FlowService;

@header{
	package com.webmethods.fsl.antlr;
}

// Top-level rule: optional interface declaration followed by service
flowService : interfaceDeclaration? 'service' ID signature? '{' step* '}' ;

// Interface declaration
interfaceDeclaration
    : 'interface' qualifiedInterfaceName ';'
    ;

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

signature : '(' signatureBlock* ')' ;

signatureBlock
    : 'input' '{' parameterDeclaration* '}' ';'?
    | 'output' '{' parameterDeclaration* '}' ';'?
    ;
mapSignatureBlock
    : 'mapSource' ('[' identifier ']')? '{' parameterDeclaration* '}'
    | 'mapTarget' ('[' identifier ']')? '{' parameterDeclaration* '}'
    ;

parameterDeclaration
    : fieldDeclaration
    | recordDeclaration
    | recordListDeclaration
    ;

fieldDeclaration
    : dataType ('[' ']')* identifier constraints? ';'
    ;

recordDeclaration
    : 'record' ('[' ']')* (qualifiedDocumentName | identifier) ('(' documentReference ')')? ('{' parameterDeclaration* '}')? constraints? ';'
    ;

documentReference
    : qualifiedDocumentName
    ;

qualifiedDocumentName
    : ID ('.' ID)* ':' ID
    ;

recordListDeclaration
    : 'recordList' (qualifiedDocumentName | identifier) ('(' documentReference ')')? ('{' parameterDeclaration* '}')? constraints? ';'
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

step
    : invokeStep
    | mapStep
    | loopStep
    | sequenceStep
    | branchStep
    | repeatStep
    | tryStep
    | exitStep
    | doUntilStep
    | ifThenStep
    | switchCaseStep
    | whileStep
    | continueStep
    | breakStep
    ;
    

stepProperty
    : 'comment' ':' STRING_LITERAL ';'
    | 'scope' ':' ID ';'
    | 'timeout' ':' INT ';'
    | 'label' ':' STRING_LITERAL ';'
    ;
    
// Qualified service name with support for keywords in package names
qualifiedServiceName : serviceNamePart ('.' serviceNamePart)* ':' ID ;

serviceNamePart
    : ID
    | 'service'
    | 'document'
    | 'input'
    | 'output'
    | 'record'
    | 'recordList'
    ;
// MAP step

mapStep
	: 'MAP' ('{' (stepProperty|mappingSetEntry|mappingCopyEntry|transformStep|dropStep|mapSignatureBlock)* '}')? ';'
	;
	
transformStep
    : 'TRANSFORM' qualifiedServiceName ('{' transformProperty* mappingBlock* '}')? ';'
    ;
dropStep
    : 'drop' (qualifiedDocumentName | identifier) ('/' pathSegment)*  ';'
    ;

// INVOKE Step
invokeStep
    : 'INVOKE' qualifiedServiceName ('{' stepProperty* invokeProperty* mappingBlock* '}')? ';'
    ;

mappingBlock
    : 'input'  '{' (mappingCopyEntry|mappingSetEntry|transformStep|dropStep|mapSignatureBlock)* '}' ';'?
    | 'output' '{' (mappingCopyEntry|mappingSetEntry|transformStep|dropStep|mapSignatureBlock)* '}' ';'?
    ;

mappingCopyEntry
    : 'copy' variableRef  '->' variableRef  ';'
    | 'copy-if' '(' expression ')' variableRef  '->' variableRef  ';'
    ;

variableRef
    : SPECIAL_VAR ('[' INT ']')? ('/' pathSegment)*
    | qualifiedDocumentName ('[' INT ']')? ('/' pathSegment)*
    | identifier ('[' INT ']')? ('/' pathSegment)*
    ;

pathSegment
    : identifier ('[' INT ']')?
    ;
    
mappingSetEntry
    : 'set' setAttributes? (qualifiedDocumentName | identifier) ('/' pathSegment)*  '=' value ';'
    ;

setAttributes
    : '(' setAttribute (',' setAttribute)* ')'
    ;

setAttribute
    : '!'? 'overwrite'
    | '!'? 'variable'
    | '!'? 'globalvariables'
    ;

// Allow certain keywords to be used as identifiers
// Also support qualified names with namespace prefix (e.g., tns:getInstallationDetails)
// Also support $ prefixed identifiers as field names (e.g., $filedata, $filestream)
identifier
    : qualifiedIdentifier
    | SPECIAL_VAR
    | 'input'
    | 'output'
    | 'count'
    | 'timeout'
    | 'pattern'
    | 'document'
    | 'repeatInterval'
    | 'repeatCount'
    | 'repeatOn'
    | 'service'
    | 'record'
    | 'recordList'
    ;

qualifiedIdentifier
    : identifierWithHyphen (':' identifierWithHyphen)?
    ;

// Support identifiers with hyphens (e.g., SOAP-FAULT) and @ or * prefixes (e.g., @resPANTransform, *field)
identifierWithHyphen
    : ('@' | '*' | '$')? ID ('-' ID)*
    ;
value
    : INT
    | FLOAT_LITERAL
    | STRING_LITERAL
    | MULTILINE_STRING
    | BOOL
    | arrayLiteral
    | jsonObject
    | ID  // Allow unquoted identifiers as values
    | expression
    ;

arrayLiteral
    : '[' (arrayElement (',' arrayElement)*)? ']'
    ;

arrayElement
    : STRING_LITERAL
    | INT
    | FLOAT_LITERAL
    | BOOL
    | NULL
    | arrayLiteral      // Nested arrays for 2D, 3D, etc.
    | jsonObject        // Objects within arrays
    ;

jsonObject
    : '{' (jsonPair (',' jsonPair)*)? '}'
    ;

jsonPair
    : STRING_LITERAL ':' jsonValue
    ;

jsonValue
    : STRING_LITERAL
    | INT
    | FLOAT_LITERAL
    | BOOL
    | NULL
    | jsonArray
    | jsonObject
    ;

jsonArray
    : '[' (jsonValue (',' jsonValue)*)? ']'
    ;

// Expression support for conditions and values
expression
    : primaryExpression (binaryOperator primaryExpression)*
    ;

primaryExpression
    : variableRef                            // Variable reference (with optional $ prefix)
    | '%' identifier '%'                     // Variable substitution syntax (%variable%)
    | ID ('.' ID)* ':' ID                   // Service reference
    | literal
    | '(' expression ')'                     // Parenthesized expression
    | unaryOperator primaryExpression        // Unary operations
    ;

literal
    : INT
    | FLOAT_LITERAL
    | STRING_LITERAL
    | MULTILINE_STRING
    | BOOL
    | 'null'
    ;

binaryOperator
    : '+'  | '-'  | '*'  | '/'  | '%'       // Arithmetic
    | '==' | '!=' | '<'  | '>'  | '<=' | '>=' // Comparison
    | '&&' | '||'                            // Logical
    ;

unaryOperator
    : '!' | '-'
    ;
invokeProperty
    : 'validateInput' ':' BOOL ';'
    | 'validateOutput' ':' BOOL ';'
    ;
transformProperty
    : 'invoke-order' ':' INT ';'
    ;

//LOOP Step

loopStep
    : 'LOOP' ('{' stepProperty* loopProperty* step* '}')? ';'
    ;
    
loopProperty
    : 'inputArray' ':' STRING_LITERAL ';'
    | 'outputArray' ':' STRING_LITERAL ';'
    ;

//SEQUENCE Step

sequenceStep
    : 'SEQUENCE' ('{' stepProperty* sequenceProperty* step* '}')? ';'
    ;
    
sequenceProperty
    : 'exitOn' ':' expression ';'
    ;

//TRY Step

tryStep
    : 'TRY' '{' (stepProperty| tryProperty)* step* '}' catchStep* finallyStep? ';'
    ;
    
tryProperty
    : 'exitOn' ':' expression ';'
    ;
    
//CATCH Step

catchStep
    : 'CATCH' ('{' stepProperty* catchProperty* step* '}')?
    ;
    
catchProperty
    : 'exitOn' ':' expression ';'
    | 'failures' ':' STRING_LITERAL ';'
    | 'selection' ':' expression ';'
    ;

//FINALLY Step

finallyStep
    : 'FINALLY' ('{' stepProperty* finallyProperty* step* '}')?
    ;
    
finallyProperty
    : 'exitOn' ':' expression ';'
    ;
    
//BRANCH Step

branchStep
    : 'BRANCH' ('{' stepProperty* branchProperty* step* '}')? ';'
    ;
    
branchProperty
    : 'switch' ':' expression ';'
    | 'evaluateLabels' ':' BOOL ';'
    ;

//REPEAT Step

repeatStep
    : 'REPEAT' ('{' stepProperty* repeatProperty* step* '}')? ';'
    ;
    
repeatProperty
    : 'count' ':' (INT | STRING_LITERAL) ';'
    | 'repeatInterval' ':' (INT | STRING_LITERAL) ';'
    | 'repeatOn' ':' expression ';'
    ;

//DO UNTIL Step

doUntilStep
    : 'DO' '{' doUntilProperty* step* '}' 'UNTIL' '(' expression ')' ';'
    ;
    
doUntilProperty
    : 'maxIteration' ':' ('-')? INT ';'
    ;

//IF THEN ELSE Step

ifThenStep
    : 'IF' '(' expression ')' '{' step* '}' elseIfBlock* elseBlock? ';'
    ;

elseIfBlock
    : 'ELSEIF' '(' expression ')' '{' step* '}'
    ;

elseBlock
    : 'ELSE' '{' step* '}'
    ;

//SWITCH CASE Step

switchCaseStep
    : 'SWITCH' '(' expression ')' '{' caseBlock+ '}' ';'
    ;

caseBlock
    : 'CASE' value ':' step*
    ;

//WHILE Step
whileStep
    : 'WHILE' '(' expression ')' ('{' stepProperty* doUntilProperty* step* '}')?
    ;
    
// EXIT Step

exitStep
    : 'EXIT' ('{' exitProperty* '}')? ';'
    ;
    
exitProperty
    : 'comment' ':' STRING_LITERAL ';'
    | 'label' ':' STRING_LITERAL ';'
    | 'signal' ':' STRING_LITERAL ';'
    | 'failureName' ':' STRING_LITERAL ';'
    | 'failureInstance' ':' STRING_LITERAL ';'
    | 'exitFrom' ':' STRING_LITERAL ';'
    | 'failureMessage' ':' STRING_LITERAL ';'
    ;
    
// CONTINUE Step

continueStep
    : 'CONTINUE' ('{' commentProperty* '}')? ';'
    ;
    
// BREAK Step

breakStep
    : 'BREAK' ('{' commentProperty* '}')? ';'
    ;

commentProperty
    : 'comment' ':' STRING_LITERAL ';'
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

// Operators (must come before ID to avoid conflicts)
PLUS  : '+' ;
MINUS : '-' ;
MULT  : '*' ;
DIV   : '/' ;
MOD   : '%' ;
EQ    : '==' ;
NEQ   : '!=' ;
LT    : '<' ;
GT    : '>' ;
LTE   : '<=' ;
GTE   : '>=' ;
AND   : '&&' ;
OR    : '||' ;
NOT   : '!' ;

// Literals and identifiers
BOOL : 'true' | 'false' ;
NULL : 'null' ;
SPECIAL_VAR : '$' [a-zA-Z_][a-zA-Z0-9_]* ;  // Special variables like $error, $last, $filedata, $filestream, etc.
ID    : [a-zA-Z_][a-zA-Z0-9_]* ;
INT   : [0-9]+ ;
FLOAT_LITERAL : [0-9]+ '.' [0-9]+ ;
MULTILINE_STRING : '"""' .*? '"""' ;  // Triple-quoted strings for XML/multi-line content
STRING_LITERAL : '"' (~["\\] | '\\' .)* '"' ;

// Whitespace and comments
WS    : [ \t\r\n]+ -> skip ;
LINE_COMMENT : '//' ~[\r\n]* -> skip ;
BLOCK_COMMENT : '/*' .*? '*/' -> skip ;

// Error handling - catch any unexpected character
ERROR_CHAR : . ;

