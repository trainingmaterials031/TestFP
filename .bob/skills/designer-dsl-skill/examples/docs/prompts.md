# webMethods JDBC Adapter Service DSL - User Prompts Guide

This guide provides example prompts you can use with AI assistants (like Claude, ChatGPT, etc.) to generate webMethods JDBC Adapter Service DSL files (`.adsl`) from SQL queries.

## 📋 Table of Contents

1. [Quick Start](#quick-start)
2. [SelectSQL Prompts](#selectsql-prompts)
3. [InsertSQL Prompts](#insertsql-prompts)
4. [UpdateSQL Prompts](#updatesql-prompts)
5. [DeleteSQL Prompts](#deletesql-prompts)
6. [CustomSQL Prompts](#customsql-prompts)
7. [Advanced Prompts](#advanced-prompts)

---

## Quick Start

**Sample Files Location**: `commons/com.webmethods.is.dsl/samples/jdbc/`

Available samples:
- `getStudentsByGenderAndClass.adsl` - SelectSQL with JOIN
- `insertStudent.adsl` - InsertSQL with multiple columns
- `updateStudent.adsl` - UpdateSQL with SET and WHERE
- `deleteStudent.adsl` - DeleteSQL with WHERE condition
- `customSqlStudents.adsl` - CustomSQL with parameters

---

## SelectSQL Prompts

### Example 1: Basic SELECT with JOIN

**Reference Sample**: [`getStudentsByGenderAndClass.adsl`](./getStudentsByGenderAndClass.adsl)

**Prompt:**
```
Generate a webMethods JDBC Adapter Service DSL file for the following SELECT query:

SELECT 
    s.student_id,
    s.first_name,
    s.last_name,
    s.gender,
    c.class_name
FROM ldev.student s
INNER JOIN ldev.class c 
    ON s.class_id = c.class_id
WHERE s.gender = ?
AND c.class_name = ?;

Requirements:
- Connection: abc:mysql
- Service name: getStudentsByGenderAndClass
- Template: SelectSQL
- Use parameters for WHERE clause (not constants)
- Include pipeline signature with input/output fields
```

**Expected Output Structure:**
```adsl
adapterService getStudentsByGenderAndClass {
    connection : "abc:mysql";
    template   : SelectSQL;
    
    SELECT {
        FROM {
            s : "ldev.<current schema>.student";
            c : "ldev.<current schema>.class";
        }
        JOIN {
            INNER s.class_id = c.class_id;
        }
        COLUMNS {
            s.student_id AS student_id INTEGER;
            s.first_name AS first_name VARCHAR;
            // ... more columns
        }
        WHERE {
            s.gender = constant("?");
            AND c.class_name = constant("?");
        }
        MAX_ROWS : 0;
        QUERY_TIMEOUT : -1;
    }
    
    signature {
        input {
            String gender;
            String class_name;
        }
        output {
            recordList results { /* ... */ }
        }
    }
}
```

### Example 2: SELECT with Multiple JOINs

**Prompt:**
```
Create a JDBC Adapter DSL for a SELECT query with multiple JOINs:

SELECT 
    s.student_id,
    s.first_name,
    c.class_name,
    t.teacher_name,
    sub.subject_name
FROM ldev.student s
INNER JOIN ldev.class c ON s.class_id = c.class_id
INNER JOIN ldev.teacher t ON c.teacher_id = t.teacher_id
LEFT JOIN ldev.subject sub ON c.subject_id = sub.subject_id
WHERE s.gender = ?
AND c.class_name = ?;

Connection: mydb:mysql
Service name: getStudentFullDetails
Max rows: 100
Query timeout: 30 seconds
```

---

## InsertSQL Prompts

### Example 1: INSERT with Multiple Columns

**Reference Sample**: [`insertStudent.adsl`](./insertStudent.adsl)

**Prompt:**
```
Generate a JDBC Adapter DSL for inserting a student record:

INSERT INTO ldev.student 
    (first_name, last_name, gender, date_of_birth, email, phone, address, enrollment_date, class_id) 
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);

Requirements:
- Connection: connections:jdbcconn
- Service name: insertStudent
- Template: InsertSQL
- All values from pipeline parameters
- Include pipeline signature with [required] and [optional] annotations
- Output field: rowsAffected (Integer)
```

**Expected Output Structure:**
```adsl
adapterService insertStudent {
    connection : "connections:jdbcconn";
    template   : InsertSQL;
    
    INSERT {
        INTO : "ldev.student";
        COLUMNS {
            first_name      VARCHAR FROM first_name;
            last_name       VARCHAR FROM last_name;
            gender          VARCHAR FROM gender;
            date_of_birth   DATE    FROM date_of_birth;
            // ... more columns
        }
    }
    
    signature {
        input {
            String first_name [required];
            String last_name  [required];
            // ... more fields
        }
        output {
            Integer rowsAffected;
        }
    }
}
```

### Example 2: Simple INSERT

**Prompt:**
```
Create InsertSQL DSL for adding a new class:

INSERT INTO ldev.class (class_name, teacher_id, room_number) 
VALUES (?, ?, ?);

Connection: mydb:mysql
Service name: insertClass
Include RESULT block with field name "insertCount"
```

---

## UpdateSQL Prompts

### Example 1: UPDATE with Multiple Columns

**Reference Sample**: [`updateStudent.adsl`](./updateStudent.adsl)

**Prompt:**
```
Generate JDBC Adapter DSL for updating student contact information:

UPDATE ldev.student
SET email = ?,
    phone = ?,
    address = ?,
    class_id = ?
WHERE student_id = ?;

Requirements:
- Connection: connections:jdbcconn
- Service name: updateStudent
- Template: UpdateSQL
- All values from pipeline parameters
- Include pipeline signature
- Output field: rowsAffected (Integer)
```

**Expected Output Structure:**
```adsl
adapterService updateStudent {
    connection : "connections:jdbcconn";
    template   : UpdateSQL;
    
    UPDATE {
        TABLE : "ldev.student";
        SET {
            email    VARCHAR = parameter(email_1);
            phone    VARCHAR = parameter(phone_1);
            address  TEXT    = parameter(address_1);
            class_id INTEGER = parameter(class_id_1);
        }
        WHERE {
            student_id = parameter(student_id_1);
        }
    }
    
    signature {
        input {
            Integer student_id_1 [required];
            String  email_1      [optional];
            // ... more fields
        }
        output {
            Integer rowsAffected;
        }
    }
}
```

### Example 2: UPDATE with Complex WHERE

**Prompt:**
```
Create UpdateSQL DSL for bulk class assignment:

UPDATE ldev.student
SET class_id = ?
WHERE gender = ?
AND enrollment_date >= ?;

Connection: mydb:mysql
Service name: bulkUpdateStudentClass
Include RESULT block with field "updateCount"
```

---

## DeleteSQL Prompts

### Example 1: Simple DELETE

**Reference Sample**: [`deleteStudent.adsl`](./deleteStudent.adsl)

**Prompt:**
```
Generate JDBC Adapter DSL for deleting a student:

DELETE FROM ldev.student 
WHERE student_id = ?;

Requirements:
- Connection: connections:jdbcconn
- Service name: deleteStudent
- Template: DeleteSQL
- Parameter: student_id (Integer)
- Output field: rowsAffected (Integer)
```

**Expected Output Structure:**
```adsl
adapterService deleteStudent {
    connection : "connections:jdbcconn";
    template   : DeleteSQL;
    
    DELETE {
        FROM : "ldev.student";
        WHERE {
            student_id = parameter(student_id_1);
        }
    }
    
    signature {
        input {
            Integer student_id_1 [required];
        }
        output {
            Integer rowsAffected;
        }
    }
}
```

### Example 2: DELETE with Multiple Conditions

**Prompt:**
```
Create DeleteSQL DSL for removing inactive students:

DELETE FROM ldev.student
WHERE enrollment_date < ?
AND class_id IS NULL;

Connection: mydb:mysql
Service name: deleteInactiveStudents
Include RESULT block with field "deletedRows"
```

---

## CustomSQL Prompts

### Example 1: Custom SELECT with JOIN

**Reference Sample**: [`customSqlStudents.adsl`](./customSqlStudents.adsl)

**Prompt:**
```
Generate CustomSQL JDBC Adapter DSL for this query:

SELECT 
    s.student_id,
    s.first_name,
    s.last_name,
    s.gender,
    c.class_name
FROM ldev.student s
INNER JOIN ldev.class c ON s.class_id = c.class_id
WHERE s.gender = ?
AND c.class_name = ?
ORDER BY s.last_name ASC;

Requirements:
- Connection: connections:jdbcconn
- Service name: customSqlStudents
- Template: CustomSQL
- Input parameters: gender_1 (VARCHAR), class_name_2 (VARCHAR)
- Output fields: student_id (INTEGER), first_name, last_name, gender, class_name (all VARCHAR)
- Max rows: 0 (unlimited)
```

**Expected Output Structure:**
```adsl
adapterService customSqlStudents {
    connection : "connections:jdbcconn";
    template   : CustomSQL;
    
    CUSTOM_SQL {
        sql : "SELECT s.student_id, s.first_name, s.last_name, s.gender, c.class_name FROM ldev.student s INNER JOIN ldev.class c ON s.class_id = c.class_id WHERE s.gender = ? AND c.class_name = ? ORDER BY s.last_name ASC";
        
        INPUT_PARAMS {
            gender_1     VARCHAR;
            class_name_2 VARCHAR;
        }
        
        OUTPUT_PARAMS {
            student_id INTEGER;
            first_name VARCHAR;
            last_name  VARCHAR;
            gender     VARCHAR;
            class_name VARCHAR;
        }
        
        MAX_ROWS : 0;
    }
    
    signature {
        input {
            String gender_1     [required];
            String class_name_2 [required];
        }
        output {
            recordList results { /* ... */ }
        }
    }
}
```

### Example 2: Custom Query with Aggregation

**Prompt:**
```
Create CustomSQL DSL for student statistics:

SELECT 
    c.class_name,
    COUNT(s.student_id) as student_count,
    AVG(YEAR(CURDATE()) - YEAR(s.date_of_birth)) as avg_age
FROM ldev.class c
LEFT JOIN ldev.student s ON c.class_id = s.class_id
WHERE c.teacher_id = ?
GROUP BY c.class_id, c.class_name
HAVING COUNT(s.student_id) > ?;

Connection: mydb:mysql
Service name: getClassStatistics
Input: teacher_id (INTEGER), min_students (INTEGER)
Output: class_name (VARCHAR), student_count (INTEGER), avg_age (DOUBLE)
```

### Example 3: Stored Procedure Call

**Prompt:**
```
Generate CustomSQL DSL for calling a stored procedure:

CALL sp_generate_student_report(?, ?, ?);

Connection: mydb:mysql
Service name: generateStudentReport
Input parameters: 
  - start_date (DATE)
  - end_date (DATE)
  - class_id (INTEGER)
Output fields:
  - report_id (INTEGER)
  - report_status (VARCHAR)
  - record_count (INTEGER)
```

---

## Advanced Prompts

### Generate Complete CRUD Set

**Prompt:**
```
Generate a complete CRUD set of JDBC Adapter DSL files for the ldev.student table:

Table structure:
- student_id (INTEGER, PRIMARY KEY, AUTO_INCREMENT)
- first_name (VARCHAR, NOT NULL)
- last_name (VARCHAR, NOT NULL)
- gender (VARCHAR)
- date_of_birth (DATE)
- email (VARCHAR)
- phone (VARCHAR)
- address (TEXT)
- enrollment_date (DATE)
- class_id (INTEGER, FOREIGN KEY)

Connection: connections:jdbcconn

Generate 4 services:
1. getStudents.adsl (SelectSQL) - Get all students with optional filters
2. insertStudent.adsl (InsertSQL) - Insert new student
3. updateStudent.adsl (UpdateSQL) - Update student by ID
4. deleteStudent.adsl (DeleteSQL) - Delete student by ID

Include:
- RESULT blocks for INSERT/UPDATE/DELETE
- Pipeline signatures with [required]/[optional] annotations
- Proper JDBC type mappings
- Comments explaining each section
```

### Convert Existing SQL to DSL

**Prompt:**
```
I have an existing SQL query that I want to convert to webMethods JDBC Adapter DSL:

[Paste your SQL query here]

Please generate the appropriate DSL file with:
- Connection: [your connection name]
- Service name: [your service name]
- Appropriate template (SelectSQL, InsertSQL, UpdateSQL, DeleteSQL, or CustomSQL)
- Include pipeline signature with input/output fields
- Add comments explaining the query logic
- Use proper JDBC type mappings
```

### Optimize Query with DSL

**Prompt:**
```
Review and optimize this SQL query, then generate the JDBC Adapter DSL:

SELECT * FROM ldev.student s, ldev.class c 
WHERE s.class_id = c.class_id 
AND s.gender = 'Male';

Requirements:
- Convert implicit JOIN to explicit INNER JOIN
- Select only necessary columns (not *)
- Add query timeout: 30 seconds
- Limit results to 1000 rows
- Use parameters instead of hardcoded values
- Include proper JDBC type mappings
- Add comments explaining optimizations
```

---

## 💡 Tips for Better Prompts

### 1. Be Specific About Requirements
```
✅ Good: "Connection: connections:jdbcconn, Service name: getStudents, Template: SelectSQL"
❌ Bad: "Create a service to get students"
```

### 2. Include Schema Information
```
✅ Good: "FROM ldev.student s INNER JOIN ldev.class c"
❌ Bad: "FROM student JOIN class"
```

### 3. Specify Data Types
```
✅ Good: "student_id (INTEGER), first_name (VARCHAR), date_of_birth (DATE)"
❌ Bad: "student_id, first_name, date_of_birth"
```

### 4. Request Specific Features
```
✅ Good: "Include RESULT block with field 'rowCount' (java.lang.Integer)"
✅ Good: "Max rows: 100, Query timeout: 30 seconds"
✅ Good: "Use parameters for WHERE clause (not constants)"
```

### 5. Ask for Documentation
```
✅ Good: "Add comments explaining each section"
✅ Good: "Include pipeline signature with [required]/[optional] annotations"
```

### 6. Provide Context
```
✅ Good: "This service will be used for bulk student enrollment processing"
✅ Good: "Query should handle NULL values in optional fields"
```

---

## 📚 Reference

### Sample Files
All sample files are located in: `commons/com.webmethods.is.dsl/samples/jdbc/`

- **SelectSQL**: [`getStudentsByGenderAndClass.adsl`](./getStudentsByGenderAndClass.adsl)
- **InsertSQL**: [`insertStudent.adsl`](./insertStudent.adsl)
- **UpdateSQL**: [`updateStudent.adsl`](./updateStudent.adsl)
- **DeleteSQL**: [`deleteStudent.adsl`](./deleteStudent.adsl)
- **CustomSQL**: [`customSqlStudents.adsl`](./customSqlStudents.adsl)

### Grammar File
`commons/com.webmethods.is.dsl/src/main/java/com/webmethods/adapter/jdbc/antlr/AdapterService.g4`

### JDBC Type Mappings

| JDBC Type | Java Type | SQL Type |
|-----------|-----------|----------|
| VARCHAR | java.lang.String | VARCHAR(255) |
| INTEGER | java.lang.Integer | INT NOT NULL |
| BIGINT | java.lang.Long | BIGINT |
| DATE | java.sql.Date | DATE |
| TIMESTAMP | java.sql.Timestamp | TIMESTAMP |
| FLOAT | java.lang.Float | FLOAT |
| DOUBLE | java.lang.Double | DOUBLE |
| BOOLEAN | java.lang.Boolean | BOOLEAN |
| TEXT | java.lang.String | TEXT |

---

## 🎯 Common Use Cases

### 1. Simple CRUD Operations
Use **SelectSQL**, **InsertSQL**, **UpdateSQL**, **DeleteSQL** templates for standard database operations.

### 2. Complex Queries with JOINs
Use **SelectSQL** for queries with multiple table joins and complex WHERE conditions.

### 3. Custom Business Logic
Use **CustomSQL** for:
- Stored procedure calls
- Complex aggregations
- Queries with functions (CONCAT, COUNT, AVG, etc.)
- Queries that don't fit standard templates

### 4. Bulk Operations
Use **UpdateSQL** or **DeleteSQL** with multiple WHERE conditions for bulk updates/deletes.

### 5. Reporting Queries
Use **CustomSQL** with aggregations, GROUP BY, and HAVING clauses.

---

**Last Updated**: 2026-03-03  
**Version**: 1.0  
**Maintained by**: webMethods ESB Designer Team