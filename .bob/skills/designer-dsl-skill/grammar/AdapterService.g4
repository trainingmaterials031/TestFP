grammar AdapterService;

@header{
    package com.webmethods.adapter.jdbc.antlr;
}

// ─────────────────────────────────────────────────────────────────────────────
// Root rule
// ─────────────────────────────────────────────────────────────────────────────

adapterService
    : 'adapterService' ID '{'
        connectionDecl
        templateDecl
        templateBlock
        signatureBlock?
      '}'
    ;

// ─────────────────────────────────────────────────────────────────────────────
// Adapter-level declarations
// ─────────────────────────────────────────────────────────────────────────────

connectionDecl
    : 'connection' ':' STRING_LITERAL ';'
    ;

templateDecl
    : 'template' ':' templateName ';'
    ;

templateName
    : 'SelectSQL'
    | 'InsertSQL'
    | 'UpdateSQL'
    | 'DeleteSQL'
    | 'CustomSQL'
    ;

// ─────────────────────────────────────────────────────────────────────────────
// Template block dispatcher
// ─────────────────────────────────────────────────────────────────────────────

templateBlock
    : selectBlock
    | insertBlock
    | updateBlock
    | deleteBlock
    | customSqlBlock
    ;

// ─────────────────────────────────────────────────────────────────────────────
// SELECT template  (SelectSQL)
// ─────────────────────────────────────────────────────────────────────────────

selectBlock
    : 'SELECT' '{'
        fromClause
        joinClause?
        columnsClause
        whereClause?
        orderByClause?
        maxRowsDecl?
        queryTimeoutDecl?
      '}'
    ;

fromClause
    : 'FROM' '{' tableEntry+ '}'
    ;

tableEntry
    : ID ':' STRING_LITERAL ';'
    ;

joinClause
    : 'JOIN' '{' joinEntry+ '}'
    ;

joinEntry
    : joinType ID '.' ID '=' ID '.' ID ';'
    ;

joinType
    : 'INNER'
    | 'LEFT'
    | 'RIGHT'
    | 'FULL'
    ;

columnsClause
    : 'COLUMNS' '{' columnEntry+ '}'
    ;

columnEntry
    : columnRef 'AS' ID jdbcType? ';'
    ;

columnRef
    : ID '.' ID
    ;

whereClause
    : 'WHERE' '{' whereEntry+ '}'
    ;

whereEntry
    : logicalOp? columnRef operator whereValue ';'
    ;

logicalOp
    : 'AND'
    | 'OR'
    ;

operator
    : '='
    | '!='
    | '<'
    | '>'
    | '<='
    | '>='
    | 'LIKE'
    ;

whereValue
    : 'constant' '(' STRING_LITERAL ')'
    | 'parameter' '(' ID ')'
    ;

orderByClause
    : 'ORDER_BY' '{' orderEntry+ '}'
    ;

orderEntry
    : columnRef sortDir? ';'
    ;

sortDir
    : 'ASC'
    | 'DESC'
    ;

maxRowsDecl
    : 'MAX_ROWS' ':' INT ';'
    ;

queryTimeoutDecl
    : 'QUERY_TIMEOUT' ':' signedInt ';'
    ;

signedInt
    : '-'? INT
    ;

// ─────────────────────────────────────────────────────────────────────────────
// RESULT declaration  (InsertSQL / UpdateSQL / DeleteSQL)
// Maps the row-count output to a named pipeline field.
// ─────────────────────────────────────────────────────────────────────────────

// The result field name is a STRING_LITERAL so that reserved words (e.g. "output",
// "input", "result") can be used as pipeline field names without parse errors.
resultDecl
    : 'RESULT' '{'
        'field'     ':' STRING_LITERAL ';'
        'fieldType' ':' STRING_LITERAL ';'
      '}'
    ;

// ─────────────────────────────────────────────────────────────────────────────
// INSERT template  (InsertSQL)
// ─────────────────────────────────────────────────────────────────────────────

// Note: InsertSQL always uses Query Time Out = -1 (hardcoded by the adapter editor).
// There is no user-configurable QUERY_TIMEOUT for InsertSQL — the spinner is
// rendered automatically by the generator with value -1.
insertBlock
    : 'INSERT' '{'
        'INTO' ':' STRING_LITERAL ';'
        insertColumnsClause
        resultDecl?
      '}'
    ;

insertColumnsClause
    : 'COLUMNS' '{' insertColumnEntry+ '}'
    ;

insertColumnEntry
    : ID jdbcType? 'FROM' ID ';'
    ;

// ─────────────────────────────────────────────────────────────────────────────
// UPDATE template  (UpdateSQL)
// ─────────────────────────────────────────────────────────────────────────────

// Note: UpdateSQL always uses Query Time Out = -1 (hardcoded by the adapter editor).
// There is no user-configurable QUERY_TIMEOUT for UpdateSQL — the spinner is
// rendered automatically by the generator with value -1.
updateBlock
    : 'UPDATE' '{'
        'TABLE' ':' STRING_LITERAL ';'
        setClause
        whereClause?
        resultDecl?
      '}'
    ;

setClause
    : 'SET' '{' setEntry+ '}'
    ;

setEntry
    : ID jdbcType? '=' whereValue ';'
    ;

// ─────────────────────────────────────────────────────────────────────────────
// DELETE template  (DeleteSQL)
// ─────────────────────────────────────────────────────────────────────────────

deleteBlock
    : 'DELETE' '{'
        'FROM' ':' STRING_LITERAL ';'
        whereClause?
        queryTimeoutDecl?
        resultDecl?
      '}'
    ;

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM SQL template  (CustomSQL)
// ─────────────────────────────────────────────────────────────────────────────

customSqlBlock
    : 'CUSTOM_SQL' '{'
        'sql' ':' STRING_LITERAL ';'
        inputParamsClause?
        outputParamsClause?
        maxRowsDecl?
        queryTimeoutDecl?
      '}'
    ;

inputParamsClause
    : 'INPUT_PARAMS' '{' paramEntry+ '}'
    ;

outputParamsClause
    : 'OUTPUT_PARAMS' '{' paramEntry+ '}'
    ;

paramEntry
    : ID jdbcType? ';'
    ;

// ─────────────────────────────────────────────────────────────────────────────
// Service signature  (pipeline input / output fields)
// ─────────────────────────────────────────────────────────────────────────────

signatureBlock
    : 'signature' '{'
        inputSignature?
        outputSignature?
      '}'
    ;

inputSignature
    : 'input' '{' signatureField* '}'
    ;

outputSignature
    : 'output' '{' signatureField* '}'
    ;

signatureField
    : fieldDeclaration
    | recordDeclaration
    | recordListDeclaration
    ;

fieldDeclaration
    : dataType ID constraints? ';'
    ;

recordDeclaration
    : 'record' ID ('{' signatureField* '}')? constraints? ';'
    ;

recordListDeclaration
    : 'recordList' ID ('{' signatureField* '}')? constraints? ';'
    ;

constraints
    : '[' constraint (',' constraint)* ']'
    ;

constraint
    : 'required'
    | 'optional'
    ;

// ─────────────────────────────────────────────────────────────────────────────
// JDBC type hint  (used for column type mapping)
// ─────────────────────────────────────────────────────────────────────────────

jdbcType
    : 'INTEGER'
    | 'BIGINT'
    | 'VARCHAR'
    | 'CHAR'
    | 'TEXT'
    | 'LONGVARCHAR'
    | 'DATE'
    | 'TIMESTAMP'
    | 'FLOAT'
    | 'DOUBLE'
    | 'BOOLEAN'
    ;

// ─────────────────────────────────────────────────────────────────────────────
// Data types for signature fields
// ─────────────────────────────────────────────────────────────────────────────

dataType
    : 'String'
    | 'Integer'
    | 'Object'
    | 'Boolean'
    | 'DateTime'
    | 'Double'
    | 'Float'
    | 'Long'
    ;

// ─────────────────────────────────────────────────────────────────────────────
// Lexer rules
// ─────────────────────────────────────────────────────────────────────────────

ID             : [a-zA-Z_][a-zA-Z0-9_]* ;
INT            : [0-9]+ ;
STRING_LITERAL : '"' (~["\\] | '\\' .)* '"' ;

WS             : [ \t\r\n]+ -> skip ;
LINE_COMMENT   : '//' ~[\r\n]* -> skip ;
BLOCK_COMMENT  : '/*' .*? '*/' -> skip ;

ERROR_CHAR     : . ;