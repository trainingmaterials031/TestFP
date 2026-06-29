---
name: webMethods Deployment Actions
description: Deploy, validate, and manage FlowServices after generation
---

# webMethods Deployment Actions

This skill provides guidance for deploying and validating generated FlowServices to webMethods Integration Server.

## Available Actions

After generating a FlowService (.flow file), you can perform these actions:

### 1. Configure Server Connection

**Command**: `webMethods DSL: Configure Server`

**Purpose**: Set up connection to webMethods Integration Server

**When to use**: First time setup or when changing server details

**What it does**:
- Prompts for server URL (e.g., http://localhost:5555)
- Prompts for username (e.g., Administrator)
- Prompts for password (stored securely)
- Saves configuration for future deployments

**How to execute**:
- Open Command Palette (Cmd/Ctrl+Shift+P)
- Type: "webMethods DSL: Configure Server"
- Follow the prompts

---

### 2. Create Package and Folder

**Command**: `webMethods DSL: Create Package and Folder`

**Purpose**: Set up package structure on Integration Server

**When to use**: Before first deployment or when creating new package structure

**What it does**:
- Prompts to create new or use existing package
- Creates package on server (if new)
- Activates the package
- Creates folder within the package
- Remembers last used package/folder for convenience

**How to execute**:
- Open Command Palette (Cmd/Ctrl+Shift+P)
- Type: "webMethods DSL: Create Package and Folder"
- Choose "Create New" or "Use Existing"
- Enter package name
- Enter folder name

---

### 3. Validate FlowService

**Command**: `webMethods DSL: Validate FlowService`

**Purpose**: Check if FlowService syntax is valid before deployment

**When to use**: After generating or modifying a .flow file

**What it does**:
- Reads the .flow file content
- Sends to server for validation
- Reports syntax errors or confirms validity
- Shows detailed error messages if validation fails

**How to execute**:
- Right-click on .flow file → "Validate FlowService"
- OR: Open .flow file → Command Palette → "webMethods DSL: Validate FlowService"

---

### 4. Deploy FlowService

**Command**: `webMethods DSL: Deploy FlowService`

**Purpose**: Deploy FlowService to Integration Server

**When to use**: After validation passes and you're ready to deploy

**What it does**:
- Checks server configuration
- Sets up package and folder (if needed)
- Prompts for service name
- Deploys the FlowService to server
- Creates the service in specified package:folder

**How to execute**:
- Right-click on .flow file → "Deploy FlowService"
- OR: Open .flow file → Command Palette → "webMethods DSL: Deploy FlowService"

---

## Recommended Workflow

### First-Time Setup
1. **Configure Server** (one-time setup)
2. **Create Package and Folder** (one-time per package)
3. **Validate FlowService** (before each deployment)
4. **Deploy FlowService** (when ready)

### Subsequent Deployments
1. **Validate FlowService** (optional but recommended)
2. **Deploy FlowService** (uses saved configuration)

---

## Usage in Chat

When a user generates a FlowService, offer these next steps:

```
✅ FlowService generated successfully!

**Next Steps:**

Would you like to:
1. 🔧 **Configure Server** - Set up Integration Server connection
2. 📦 **Create Package/Folder** - Set up deployment structure
3. ✅ **Validate** - Check syntax before deployment
4. 🚀 **Deploy** - Deploy to Integration Server

**Quick Actions:**
- Right-click the .flow file for Validate/Deploy options
- Use Command Palette (Cmd/Ctrl+Shift+P) for all commands

Which action would you like to perform?
```

---

## Interactive Guidance

### If user says "validate"
```
To validate your FlowService:

**Option 1 - Context Menu:**
1. Right-click on the .flow file
2. Select "Validate FlowService"

**Option 2 - Command Palette:**
1. Open the .flow file
2. Press Cmd/Ctrl+Shift+P
3. Type: "webMethods DSL: Validate FlowService"
4. Press Enter

The validation will check syntax and report any errors.
```

### If user says "deploy"
```
To deploy your FlowService:

**Prerequisites:**
- Server must be configured (run "Configure Server" if not done)
- Package and folder should exist (run "Create Package and Folder" if needed)

**Deployment Steps:**
1. Right-click on the .flow file
2. Select "Deploy FlowService"
3. Follow the prompts:
   - Confirm/create package and folder
   - Enter service name (format: folderName:serviceName)
4. Wait for deployment confirmation

**Or use Command Palette:**
- Press Cmd/Ctrl+Shift+P
- Type: "webMethods DSL: Deploy FlowService"
```

### If user says "configure server"
```
To configure your Integration Server connection:

1. Open Command Palette (Cmd/Ctrl+Shift+P)
2. Type: "webMethods DSL: Configure Server"
3. Enter server details:
   - **URL**: http://localhost:5555 (or your server URL)
   - **Username**: Administrator (or your username)
   - **Password**: Your password (stored securely)

This is a one-time setup. The configuration is saved for future deployments.
```

### If user says "create package"
```
To create a package and folder structure:

1. Open Command Palette (Cmd/Ctrl+Shift+P)
2. Type: "webMethods DSL: Create Package and Folder"
3. Choose:
   - **Create New Package and Folder** - Creates new structure on server
   - **Use Existing Package and Folder** - Uses existing structure
4. Enter package name (e.g., "MyPackage")
5. Enter folder name (e.g., "services")

The extension will:
- Create the package on the server
- Activate the package
- Create the folder within the package
- Remember your choices for next time
```

---

## Troubleshooting

### "Server not configured"
→ Run: `webMethods DSL: Configure Server`

### "Package does not exist"
→ Run: `webMethods DSL: Create Package and Folder`

### "Validation failed"
→ Check the error details and fix syntax issues in the .flow file

### "Deployment failed"
→ Ensure server is running and credentials are correct
→ Check if package and folder exist
→ Verify service name format (folderName:serviceName)

---

## Command Reference

| Command | Shortcut Access | Purpose |
|---------|----------------|---------|
| Configure Server | Command Palette | Setup server connection |
| Create Package and Folder | Command Palette | Setup deployment structure |
| Validate FlowService | Right-click .flow file | Check syntax |
| Deploy FlowService | Right-click .flow file | Deploy to server |

---

## Best Practices

1. **Always validate before deploying** - Catch syntax errors early
2. **Use meaningful package names** - Organize services logically
3. **Follow naming conventions** - Use clear, descriptive service names
4. **Test in development first** - Validate workflow before production
5. **Keep credentials secure** - Extension uses VSCode SecretStorage

---

## Integration with Code Generation

When generating FlowServices, automatically suggest deployment actions:

```
[After generating code]

✅ **FlowService generated successfully!**

**File**: `myService.flow`

**What's next?**

I can help you:
- ✅ Validate the syntax
- 🚀 Deploy to Integration Server
- 📝 Explain the code
- 🔧 Modify the service

Just let me know what you'd like to do!
```

---

## Notes

- All commands are available in Command Palette
- Right-click context menu available for .flow files
- Server configuration is stored securely
- Package/folder preferences are remembered
- Deployment requires active Integration Server connection