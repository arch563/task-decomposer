# Shared Root Context Feature

## Overview

The task tree root is now **shared across the entire plugin**. When you set a task as root in the tree view, it persists and affects task creation from buffers.

## How It Works

### Setting a Root Task

**In Tree View:**
1. Navigate to a task
2. Press `r` to set it as root
3. The tree now shows only that task and its subtasks
4. A notification confirms: "Root set to: [task description]"

### Adding Tasks with Active Root

**From Buffer (`<leader>ta`):**
- If no root is set: Creates top-level task
- If root is set: Creates subtask under the root task
- The prompt shows: `Task (under 'root-task-name'):`

### Example Workflow

```
1. Open tree with <leader>tt
2. Navigate to "Feature X" task
3. Press 'r' to set as root
4. Close tree with 'q'
5. Go to any buffer, press <leader>ta
6. Prompt shows: "Task (under 'Feature X'):"
7. New task is automatically a subtask of Feature X
```

## Benefits

✅ **Focus on specific features** - Set a feature/epic as root  
✅ **Auto-organize subtasks** - All new tasks go under the root  
✅ **Work without tree open** - Root persists across the session  
✅ **Clear context** - Prompt shows which task you're adding to  

## Commands

| Command | Description |
|---------|-------------|
| `:TaskShowRoot` | Display current root task |
| `:TaskClearRoot` | Clear root (show all tasks) |
| `:TaskSetRoot <text>` | Set root by searching task description |

## Keymaps

| Key | Where | Action |
|-----|-------|--------|
| `r` | Tree | Set current task as root |
| `R` | Tree | Clear root (show all) |

## Example Session

```bash
# In tree, set "Implement login" as root
# Tree now shows:
╔═══ Root: Implement login ═══╗

[1] ○ [ ] Add auth endpoint @api.lua:15
[2] ○ [ ] Create login form @ui.lua:20

# Go to buffer, press <leader>ta
# Prompt: "Task (under 'Implement login'):"
# Enter: "Add validation"

# New task is automatically child of "Implement login"
# Tree updates to:
╔═══ Root: Implement login ═══╗

[1] ○ [ ] Add auth endpoint @api.lua:15
[2] ○ [ ] Create login form @ui.lua:20
[3] ○ [ ] Add validation @buffer.lua:42
```

## Implementation Details

### Shared State Module
- `lua/task-decomposer/state.lua` - Stores current root
- `state.get_root()` - Returns current root ID or nil
- `state.set_root(id)` - Sets the root task
- `state.clear_root()` - Clears the root

### Integration
- UI module uses shared state for rendering
- Virtual text module uses shared state when adding tasks
- Both stay in sync automatically

## Tips

🔸 **Check current root** - Use `:TaskShowRoot` anytime  
🔸 **Clear to see all** - Press `R` in tree or `:TaskClearRoot`  
🔸 **Search and set** - Use `:TaskSetRoot login` to find and set root  
🔸 **Notification feedback** - All root changes show notifications  

