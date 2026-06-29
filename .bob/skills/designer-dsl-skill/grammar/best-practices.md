# webMethods DSL Best Practices

## General Guidelines

1. **Naming Conventions**
   - Use camelCase for service names, variables, and fields
   - Use descriptive names that indicate purpose
   - Avoid abbreviations unless widely understood
   - Example: `getUserData` not `getUsrDat`

2. **Service Structure**
   - Always include proper signature with input/output blocks
   - Define all required fields with `[required]` constraint
   - Use appropriate data types (String, Integer, Boolean, etc.)
   - Keep services focused on a single responsibility

3. **Error Handling**
   - Wrap risky operations in TRY/CATCH blocks
   - Always handle errors gracefully
   - Provide meaningful error messages
   - Use EXIT step with proper failure information

4. **Code Organization**
   - Use consistent indentation (4 spaces)
   - Add comments for complex logic
   - Group related operations together
   - Keep services modular and reusable

## FlowService Best Practices

### 1. Service Signature
```flow
service processOrder (
    input {
        String orderId [required];
        String customerId [required];
        record orderDetails {
            String productId;
            Integer quantity;
        }
    }
    output {
        String status;
        String message;
    }
) { ... }
```

### 2. Error Handling Pattern
```flow
TRY {
    // Main logic
    INVOKE service:operation;
}
CATCH {
    failures: "java.lang.Exception";
    
    MAP {
        copy $error -> errorMessage;
        set status = "FAILURE";
    };
    
    EXIT {
        signal: "FAILURE";
        failureMessage: "Operation failed";
    };
};
```

### 3. HTTP Client Pattern
```flow
INVOKE pub.client:http {
    input {
        set url = "https://api.example.com/endpoint";
        set method = "GET";
        set loadAs = "stream";
    }
    output {
        copy body/stream -> responseStream;
        copy statusCode -> statusCode;
    }
};
```

### 4. JSON Processing Pattern
```flow
// Parse JSON
INVOKE pub.json:jsonStringToDocument {
    input {
        copy jsonData -> jsonString;
    }
    output {
        copy document -> parsedData;
    }
};

// Generate JSON
INVOKE pub.json:documentToJSONString {
    input {
        copy data -> document;
    }
    output {
        copy jsonString -> result;
    }
};
```

### 5. Loop Pattern
```flow
LOOP {
    inputArray: "items";
    outputArray: "results";
    
    // Process each item
    INVOKE service:processItem {
        input {
            copy item -> inputItem;
        }
        output {
            copy result -> processedItem;
        }
    };
};
```

### 6. Conditional Logic Pattern
```flow
IF (status == "SUCCESS") {
    INVOKE service:handleSuccess;
}
ELSEIF (status == "ERROR") {
    INVOKE service:handleError;
}
ELSE {
    INVOKE service:handleUnknown;
};
```

### 7. Public Service Invocation from Metadata
When generating a FlowService that wraps or invokes a public service described by metadata:

1. **Use metadata as the contract authority**
   - Match the exact `serviceId`
   - Respect declared input/output names
   - Honor `mapRequired` and `allowExtraInputs`

2. **Map required inputs explicitly**
   - If metadata marks a field as required, ensure the generated FlowService either exposes it as a required input or sets it intentionally
   - Do not rely on implicit pipeline state

3. **Avoid extra inputs when disallowed**
   - If `allowExtraInputs` is `false`, do not pass helper variables, debug fields, or unrelated pipeline values into the INVOKE input block

4. **Handle generic and unknown types conservatively**
   - `Object` means keep the field generic
   - `null` means unknown structure; prefer a record/document-style placeholder and explain assumptions

5. **Copy outputs deliberately**
   - Only promote INVOKE outputs that are used later in the flow or returned by the wrapper service
   - Keep original metadata names unless the user requests renaming

6. **Protect public invocations with TRY/CATCH**
   - Built-in service calls can fail because of invalid input, missing pipeline state, or runtime conditions
   - Capture `$error` and return actionable failure details

#### Example
```flow
service countItems (
    input {
        Object items [required];
    }
    output {
        String itemCount;
        String errorMessage;
    }
) {
    TRY {
        INVOKE pub.list:sizeOfList {
            input {
                copy items -> fromList;
            }
            output {
                copy size -> itemCount;
            }
        };
    }
    CATCH {
        MAP {
            copy $error -> errorMessage;
        };
    };
}
```

## JDBC Adapter Best Practices

### 1. SELECT Query Pattern
```adapter
adapterService getUsers {
    connection: "DatabaseConnection";
    template: SelectSQL;
    
    SELECT {
        FROM {
            u: "users";
        }
        
        COLUMNS {
            u.id AS userId INTEGER;
            u.name AS userName VARCHAR;
            u.email AS userEmail VARCHAR;
        }
        
        WHERE {
            u.status = parameter(status);
            AND u.age >= parameter(minAge);
        }
        
        ORDER_BY {
            u.created_date DESC;
        }
        
        MAX_ROWS: 100;
        QUERY_TIMEOUT: 30;
    }
    
    signature {
        input {
            String status [required];
            Integer minAge;
        }
        output {
            recordList users {
                Integer userId;
                String userName;
                String userEmail;
            };
        }
    }
}
```

### 2. INSERT Pattern
```adapter
adapterService insertUser {
    connection: "DatabaseConnection";
    template: InsertSQL;
    
    INSERT {
        INTO: "users";
        
        COLUMNS {
            name VARCHAR FROM userName;
            email VARCHAR FROM userEmail;
            age INTEGER FROM userAge;
        }
        
        RESULT {
            field: "rowsInserted";
            fieldType: "Integer";
        }
    }
    
    signature {
        input {
            String userName [required];
            String userEmail [required];
            Integer userAge;
        }
        output {
            Integer rowsInserted;
        }
    }
}
```

### 3. UPDATE Pattern
```adapter
adapterService updateUser {
    connection: "DatabaseConnection";
    template: UpdateSQL;
    
    UPDATE {
        TABLE: "users";
        
        SET {
            name VARCHAR = parameter(newName);
            email VARCHAR = parameter(newEmail);
        }
        
        WHERE {
            id = parameter(userId);
        }
        
        RESULT {
            field: "rowsUpdated";
            fieldType: "Integer";
        }
    }
    
    signature {
        input {
            Integer userId [required];
            String newName;
            String newEmail;
        }
        output {
            Integer rowsUpdated;
        }
    }
}
```

## FlatFile Schema Best Practices

### 1. Choosing the Right Format Type

**Use DELIMITED when:**
- Fields are separated by delimiters (comma, pipe, tab)
- Field lengths vary
- Data is human-readable (CSV, TSV)
- Easy to edit and maintain

**Use FIXED_LENGTH when:**
- Fields have fixed positions and lengths
- Legacy system integration
- Performance is critical (faster parsing)
- Data format is strictly defined

### 2. Delimited Format Pattern

```flatfile
flatfile schema customer_csv {
    type: DELIMITED;
    
    // Clear delimiter configuration
    delimiters {
        record = "\n"           // Standard newline
        field = ","             // Comma-separated
        subfield = "|"          // For composite fields
        release = "\\"          // Escape character
        quotedRelease = "\""    // For quoted strings
    }
    
    // Record identifier for validation
    recordIdentifier {
        type = "NthField"
        offset = 0
        validateWithoutRecordIdentifier = true
    }
    
    record customer {
        // Use descriptive field names
        field customerId {
            data_type: String;
            index: 0;
            mandatory: true;
        }
        
        field customerName {
            data_type: String;
            index: 1;
            mandatory: true;
        }
        
        field email {
            data_type: String;
            index: 2;
        }
        
        field registrationDate {
            data_type: Date;
            index: 3;
        }
    }
}
```

### 3. Fixed-Length Format Pattern

```flatfile
flatfile schema fixed_customer {
    type: FIXED_LENGTH;
    
    // Specify exact record size
    parser {
        type = "FixedLength"
        recordSize = 100        // Total bytes per record
    }
    
    recordIdentifier {
        validateWithoutRecordIdentifier = true
    }
    
    record customer {
        // Document field positions clearly
        field recordType {
            data_type: String;
            position: 0;        // Starts at byte 0
            length: 2;          // 2 bytes
        }
        
        field customerId {
            data_type: String;
            position: 2;        // Starts at byte 2
            length: 10;         // 10 bytes
        }
        
        field customerName {
            data_type: String;
            position: 12;       // Starts at byte 12
            length: 30;         // 30 bytes (padded if needed)
        }
        
        field balance {
            data_type: String;
            position: 42;       // Starts at byte 42
            length: 15;         // 15 bytes
        }
    }
}
```

### 4. Composite Fields Pattern

For nested data structures:

```flatfile
flatfile schema employee_data {
    type: DELIMITED;
    
    delimiters {
        record = "\n"
        field = ","
        subfield = "|"          // Subfield delimiter
    }
    
    recordIdentifier {
        type = "NthField"
        offset = 0
        validateWithoutRecordIdentifier = true
    }
    
    record employee {
        field employeeId {
            data_type: String;
            index: 0;
        }
        
        field name {
            data_type: String;
            index: 1;
        }
        
        // Composite field for contact information
        composite contactInfo {
            index: 2;
            
            field phone {
                data_type: String;
                index: 0;
            }
            
            field email {
                data_type: String;
                index: 1;
            }
        }
    }
}
```

### 5. Multi-Record Type Pattern (Header-Detail-Trailer)

```flatfile
flatfile schema batch_file {
    type: DELIMITED;
    
    delimiters {
        record = "\n"
        field = "|"
    }
    
    // Record identifier to distinguish record types
    recordIdentifier {
        type = "NthField"
        offset = 0
        validateWithoutRecordIdentifier = false  // Strict validation
    }
    
    // Header record (appears once at start)
    record HDR {
        field batchId {
            data_type: String;
            index: 1;
        }
        
        field batchDate {
            data_type: Date;
            index: 2;
        }
    }
    
    // Detail records (repeating)
    record DTL {
        max_repeat: unlimited;
        
        field transactionId {
            data_type: String;
            index: 1;
        }
        
        field amount {
            data_type: String;
            index: 2;
        }
    }
    
    // Trailer record (appears once at end)
    record TLR {
        field batchId {
            data_type: String;
            index: 1;
        }
        
        field totalRecords {
            data_type: Integer;
            index: 2;
        }
        
        field totalAmount {
            data_type: String;
            index: 3;
        }
    }
}
```

### 6. Naming Conventions

**Schema Names:**
- Use descriptive names: `customer_data`, `invoice_records`
- Use snake_case for schema names
- Avoid abbreviations unless standard

**Field Names:**
- Use camelCase: `customerId`, `orderDate`
- Be descriptive: `emailAddress` not `email`
- Avoid single letters unless standard (e.g., `x`, `y` for coordinates)

**Record Names:**
- Use meaningful names: `customer`, `order`, `transaction`
- For multi-record files: `HDR`, `DTL`, `TLR` (standard abbreviations)
- Match business terminology

### 7. Data Type Selection

Choose appropriate data types:
- **String** - Text, codes, identifiers (most common)
- **Integer** - Whole numbers, counts, IDs
- **Date/DateTime** - Dates and timestamps
- **Float/Double** - Decimal numbers, amounts
- **Boolean** - true/false flags

### 8. Delimiter Selection Guidelines

**Record Delimiters:**
- Standard: `"\n"` (Unix), `"\r\n"` (Windows)
- Custom: Use unique characters not in data

**Field Delimiters:**
- Common: `","` (CSV), `"|"` (pipe), `"\t"` (tab)
- Avoid delimiters that appear in data
- Use escape characters if delimiter appears in data

**Subfield Delimiters:**
- Use different character from field delimiter
- Common: `"|"`, `":"`, `"~"`

### 9. Validation Best Practices

```flatfile
// For single record type files
recordIdentifier {
    validateWithoutRecordIdentifier = true  // More lenient
}

// For multi-record type files
recordIdentifier {
    type = "NthField"
    offset = 0
    values = ["HDR", "DTL", "TLR"]
    validateWithoutRecordIdentifier = false  // Strict validation
}
```

### 10. Documentation in Schemas

Add comments to explain:
- File format and structure
- Sample data location
- Field meanings and constraints
- Special handling requirements

```flatfile
// FlatFile Schema: customer_data
// Description: Customer master data in CSV format
// Sample Data: customer_data.csv
//
// Structure:
// - Format: Delimited (comma-separated)
// - Fields: customerId, name, email, registrationDate
// - Record delimiter: newline
// - Field delimiter: comma

flatfile schema customer_data {
    type: DELIMITED;
    // ... rest of schema
}
```

### 11. Common FlatFile Pitfalls

1. ❌ **Incorrect field positions** - Verify byte positions for fixed-length
2. ❌ **Wrong delimiter characters** - Match actual file delimiters
3. ❌ **Missing escape characters** - Handle special characters in data
4. ❌ **Incorrect record size** - Must match actual record length
5. ❌ **Wrong index values** - Use 0-based indexing
6. ❌ **Mismatched data types** - Choose appropriate types for data
7. ❌ **Missing mandatory fields** - Mark required fields appropriately

### 12. Testing FlatFile Schemas

1. **Validate with sample data** - Test with actual file samples
2. **Check edge cases** - Empty fields, special characters, max lengths
3. **Verify delimiters** - Ensure correct parsing of fields
4. **Test multi-record files** - Verify all record types parse correctly
5. **Check data types** - Ensure proper type conversion
6. **Validate field positions** - For fixed-length, verify byte alignment


## Common Pitfalls to Avoid

**FlowService & Adapter:**
1. ❌ **Missing semicolons** - All statements must end with `;`
2. ❌ **Unbalanced braces** - Every `{` must have matching `}`
3. ❌ **Invalid data types** - Use only supported types
4. ❌ **Missing required fields** - Mark required inputs with `[required]`
5. ❌ **Incorrect variable references** - Use proper path syntax: `parent/child`
6. ❌ **Wrong JDBC types** - Use correct type mappings (INTEGER, VARCHAR, etc.)
7. ❌ **Missing connection alias** - Always specify connection for adapters
8. ❌ **Improper error handling** - Always use TRY/CATCH for risky operations

**FlatFile Schema:**
9. ❌ **Incorrect field positions** - Verify byte positions for fixed-length formats
10. ❌ **Wrong delimiter characters** - Match actual file delimiters exactly
11. ❌ **Missing escape characters** - Handle special characters in data properly
12. ❌ **Incorrect record size** - Must match actual record length in bytes
13. ❌ **Wrong index values** - Use 0-based indexing for fields
14. ❌ **Mismatched data types** - Choose appropriate types for actual data
15. ❌ **Missing record identifiers** - Define identifiers for multi-record files

## Code Quality Checklist

**For FlowService & Adapter:**
- [ ] Service has proper signature with input/output
- [ ] All required fields are marked with `[required]`
- [ ] Appropriate data types are used
- [ ] Error handling is included (TRY/CATCH)
- [ ] All statements end with semicolons
- [ ] Braces are balanced
- [ ] Indentation is consistent (4 spaces)
- [ ] Variable names are descriptive
- [ ] Comments explain complex logic
- [ ] Built-in services are used correctly

**For FlatFile Schema:**
- [ ] Schema type is appropriate (DELIMITED or FIXED_LENGTH)
- [ ] Delimiters are correctly specified
- [ ] Field positions/indices are accurate
- [ ] Record size matches actual data (for fixed-length)
- [ ] Data types match actual data
- [ ] Record identifiers are defined (for multi-record files)
- [ ] Field names are descriptive
- [ ] Comments explain schema structure
- [ ] Sample data file is referenced
- [ ] Mandatory fields are marked appropriately

## Performance Tips

1. **Use appropriate timeouts** for database operations
2. **Limit result sets** with MAX_ROWS
3. **Use indexes** in WHERE clauses
4. **Avoid nested loops** when possible
5. **Cache frequently accessed data**
6. **Use SEQUENCE with exitOn** for early termination

## Security Considerations

1. **Validate all inputs** before processing
2. **Use parameterized queries** (not constants) for user input
3. **Handle sensitive data** appropriately
4. **Implement proper error messages** (don't expose internals)
5. **Use appropriate connection permissions**

## Documentation Standards

Add comments for:
- Complex business logic
- Non-obvious transformations
- Integration points
- Error handling strategies
- Performance considerations

Example:
```flow
// Validate email format before processing
IF (email == null || email == "") {
    EXIT {
        signal: "FAILURE";
        failureMessage: "Email is required";
    };
};
```

## Testing Recommendations

1. Test with valid inputs
2. Test with invalid/missing inputs
3. Test error scenarios
4. Test edge cases (empty arrays, null values)
5. Verify database operations with test data
6. Check timeout behavior
7. Validate output format

## DocumentType Best Practices

### 1. Document Structure

**Always include interface declaration:**
```wmdoc
interface com.example.customer;

document Customer {
    String customerId;
    String name;
};
```

**Use meaningful document names:**
- PascalCase for document names: `CustomerProfile`, `OrderDetails`
- camelCase for field names: `customerId`, `firstName`, `orderDate`
- Descriptive names that indicate purpose

### 2. Field Organization

**Group related fields using records:**
```wmdoc
document Customer {
    // Basic information
    String customerId [required];
    String name [required];
    String email;
    
    // Address information
    record Address {
        String street;
        String city;
        String state;
        String zipCode;
    };
    
    // Contact information
    record ContactInfo {
        String phone;
        String mobile;
        String fax;
    };
};
```

**Order fields logically:**
1. Required fields first
2. Optional fields next
3. Complex types (records) after simple types
4. Arrays at the end

### 3. Data Type Selection

**Choose appropriate data types:**
```wmdoc
document Order {
    String orderId;           // Use String for IDs
    DateTime orderDate;       // Use DateTime for dates
    Integer quantity;         // Use Integer for counts
    Double totalAmount;       // Use Double for currency
    Boolean isProcessed;      // Use Boolean for flags
};
```

**Avoid using Object unless necessary:**
- Use specific types (String, Integer, etc.) when structure is known
- Use Object only for truly dynamic content
- Document the expected structure in comments

### 4. Constraints Usage

**Always add required constraints:**
```wmdoc
document User {
    String userId [required];
    String email [required];
    String firstName [required];
    String lastName [required];
    String middleName [optional];  // Explicitly mark optional
};
```

**Use validation constraints:**
```wmdoc
document Registration {
    String email [required, pattern="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"];
    String username [required, minLength=3, maxLength=20];
    String password [required, minLength=8];
    String zipCode [pattern="^[0-9]{5}(-[0-9]{4})?$"];
};
```

**Provide sensible defaults:**
```wmdoc
document Configuration {
    String environment [default="development"];
    Integer timeout [default=30];
    Boolean debugMode [default=false];
    String logLevel [default="INFO"];
};
```

### 5. Array Usage

**Use arrays for repeating data:**
```wmdoc
document Customer {
    String customerId;
    String[] emailAddresses;      // Multiple emails
    String[] phoneNumbers;        // Multiple phones
    String[] tags;                // Multiple tags
};
```

**Use record arrays for complex repeating structures:**
```wmdoc
document Order {
    String orderId;
    record[] items {
        String productId [required];
        String productName;
        Integer quantity [required];
        Double unitPrice [required];
        Double lineTotal;
    };
};
```

### 6. Nested Records

**Keep nesting to reasonable depth (max 3 levels):**
```wmdoc
// Good - 2 levels
document Order {
    String orderId;
    record customer {
        String customerId;
        String name;
    };
};

// Avoid - too deep
document Order {
    record customer {
        record address {
            record location {
                record coordinates {
                    // Too deep!
                };
            };
        };
    };
};
```

**Extract complex nested structures to separate documents:**
```wmdoc
// Instead of deep nesting, reference other documents
document Order {
    String orderId;
    record customer (com.example:CustomerDocument) {
        String customerId;
    };
};
```

### 7. Documentation

**Add comments for complex structures:**
```wmdoc
interface com.example.order;

/**
 * Order document for e-commerce transactions
 * Contains order details, customer info, and line items
 */
document Order {
    // Order identification
    String orderId [required];
    DateTime orderDate [required];
    
    // Customer reference
    String customerId [required];
    
    // Line items - products ordered
    record[] items {
        String productId [required];
        Integer quantity [required];
        Double price [required];
    };
    
    // Calculated totals
    Double subtotal;
    Double tax;
    Double total;
};
```

### 8. Naming Conventions

**Follow consistent naming patterns:**
```wmdoc
document Customer {
    // IDs - use "Id" suffix
    String customerId;
    String accountId;
    
    // Dates - use "Date" or "DateTime" suffix
    DateTime createdDate;
    DateTime lastModifiedDate;
    
    // Booleans - use "is" or "has" prefix
    Boolean isActive;
    Boolean hasSubscription;
    
    // Counts - use "count" or "total" suffix
    Integer orderCount;
    Integer totalPurchases;
    
    // Amounts - use "amount" or "total" suffix
    Double totalAmount;
    Double discountAmount;
};
```

### 9. Reusability

**Create reusable document structures:**
```wmdoc
// Common address structure
interface com.example.common;

document Address {
    String street [required];
    String city [required];
    String state [required];
    String zipCode [required];
    String country [default="USA"];
};

// Use in other documents
interface com.example.customer;

document Customer {
    String customerId;
    record billingAddress (com.example.common:Address) {};
    record shippingAddress (com.example.common:Address) {};
};
```

### 10. Validation Patterns

**Common validation patterns:**
```wmdoc
document ValidationExamples {
    // Email validation
    String email [pattern="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"];
    
    // Phone number (international format)
    String phone [pattern="^\\+?[1-9]\\d{1,14}$"];
    
    // US ZIP code
    String zipCode [pattern="^[0-9]{5}(-[0-9]{4})?$"];
    
    // US State code
    String state [minLength=2, maxLength=2, pattern="^[A-Z]{2}$"];
    
    // Credit card (basic)
    String creditCard [pattern="^[0-9]{13,19}$"];
    
    // URL
    String website [pattern="^https?://[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}.*$"];
    
    // UUID
    String uuid [pattern="^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"];
};
```

### 11. Performance Considerations

**Avoid excessive nesting:**
- Deep nesting impacts parsing performance
- Keep structure flat when possible
- Use document references for complex types

**Limit array sizes in constraints:**
```wmdoc
document LimitedList {
    String[] tags [maxLength=50];  // Limit array size
    record[] items [maxLength=100];
};
```

### 12. Error Prevention

**Use constraints to prevent common errors:**
```wmdoc
document SafeDocument {
    // Prevent empty strings
    String name [required, minLength=1];
    
    // Ensure valid ranges
    Integer age [required, minLength=0, maxLength=150];
    
    // Prevent null in critical fields
    String status [required, default="PENDING"];
    
    // Validate format
    String code [required, pattern="^[A-Z]{3}[0-9]{3}$"];
};
```

### 13. Testing Patterns

**Create test-friendly documents:**
```wmdoc
document TestableOrder {
    // Include test identifiers
    String orderId [required];
    String testFlag [default="false"];  // For test data identification
    
    // Include timestamps for debugging
    DateTime createdAt;
    DateTime updatedAt;
    
    // Include version for tracking
    String version [default="1.0"];
};
```

### 14. Migration Considerations

**Design for evolution:**
```wmdoc
document EvolvableDocument {
    // Version field for schema evolution
    String schemaVersion [default="1.0"];
    
    // Use optional for new fields
    String newField [optional];
    
    // Provide defaults for backward compatibility
    Boolean newFeature [default=false];
    
    // Keep deprecated fields with comments
    String oldField [optional];  // Deprecated: use newField instead
};
```

### 15. Common Anti-Patterns to Avoid

**❌ Don't use generic names:**
```wmdoc
// Bad
document Data {
    String field1;
    String field2;
};

// Good
document CustomerProfile {
    String customerId;
    String customerName;
};
```

**❌ Don't omit constraints:**
```wmdoc
// Bad - no validation
document User {
    String email;
    String password;
};

// Good - with validation
document User {
    String email [required, pattern="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"];
    String password [required, minLength=8];
};
```

**❌ Don't create flat structures for complex data:**
```wmdoc
// Bad - flat structure
document Order {
    String orderId;
    String customerName;
    String customerEmail;
    String customerPhone;
    String shippingStreet;
    String shippingCity;
    String shippingState;
};

// Good - organized with records
document Order {
    String orderId;
    record customer {
        String name;
        String email;
        String phone;
    };
    record shipping {
        String street;
        String city;
        String state;
    };
};
```

### 16. Complete Example Following Best Practices

```wmdoc
interface com.example.ecommerce;

/**
 * Complete order document following all best practices
 * Version: 1.0
 * Last Updated: 2024-01-15
 */
document Order {
    // Schema metadata
    String schemaVersion [default="1.0"];
    
    // Order identification
    String orderId [required, minLength=5, maxLength=50];
    String orderNumber [required];
    DateTime orderDate [required];
    String status [required, default="PENDING"];
    
    // Customer information
    record customer {
        String customerId [required];
        String email [required, pattern="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"];
        String firstName [required, minLength=1];
        String lastName [required, minLength=1];
        String phone [pattern="^\\+?[1-9]\\d{1,14}$"];
    };
    
    // Shipping address
    record shippingAddress {
        String street [required];
        String city [required];
        String state [required, minLength=2, maxLength=2];
        String zipCode [required, pattern="^[0-9]{5}(-[0-9]{4})?$"];
        String country [default="USA"];
    };
    
    // Billing address (optional, defaults to shipping)
    record billingAddress {
        String street;
        String city;
        String state;
        String zipCode;
        String country [default="USA"];
    };
    
    // Order items
    record[] items {
        String itemId [required];
        String productId [required];
        String productName [required];
        String sku [required];
        Integer quantity [required, minLength=1];
        Double unitPrice [required];
        Double discount [default=0.0];
        Double lineTotal [required];
    };
    
    // Payment information
    record payment {
        String paymentMethod [required];
        String transactionId;
        DateTime paymentDate;
        String status [default="PENDING"];
    };
    
    // Order totals
    Double subtotal [required];
    Double tax [required];
    Double shipping [required];
    Double discount [default=0.0];
    Double total [required];
    
    // Metadata
    DateTime createdAt [required];
    DateTime updatedAt;
    String createdBy;
    String updatedBy;
    
    // Flags
    Boolean isGift [default=false];
    Boolean requiresSignature [default=false];
    Boolean isExpressShipping [default=false];
    
    // Notes and tags
    String customerNotes [optional];
    String internalNotes [optional];
    String[] tags;
};
```

This comprehensive example demonstrates:
- Clear organization and grouping
- Appropriate data types
- Comprehensive constraints
- Meaningful names
- Proper documentation
- Reusable structure
- Validation patterns
- Metadata tracking
- Default values
- Optional fields marked explicitly


Follow these best practices to generate high-quality, maintainable DSL code.