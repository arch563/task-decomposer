# Task Decomposer - New Features

## UI Improvements

### Sidebar Layout
- **Right sidebar** instead of popup window (25% of screen width)
- **Full height** for better task visibility
- **Persistent layout** - stays open while you work

### Tree Visualization
- **Pipe characters** (`├─`, `└─`, `│`) for clear hierarchy
- **Hierarchical indexing** - Tasks show their position (e.g., `[1.2.3]`)
- **Metadata display**:
  - `[1.2.3]` - Task index in hierarchy
  - `[✓]` or `[ ]` - Completion status
  - `@file:line` - File location reference

### Example Display
```
╔═══ All Tasks ═══╗

[1] ○ [ ] Main task @file.lua:10
[1.1] ├─○ [ ] Subtask one @file.lua:15
[1.2] └─○ [ ] Subtask two @file.lua:20
[2] ✓ [✓] Completed task @other.lua:5
[2.1] └─○ [ ] Child of completed
```

## New Features

### Sign Off Tasks Outside Tree
You can now manage tasks without opening the tree view:

- **Toggle task completion**: `<leader>tx` - Toggle task done/undone at cursor
- **Sign off completed tasks**: `<leader>ts` - Remove all completed tasks from current file

### Enhanced Virtual Text
Tasks now show in virtual text with:
- Hierarchical index `[1.2.3]`
- Status icon `✓` or `○`
- Task description

### Snacks.nvim Integration
If snacks.nvim is available, it will be used for input prompts with a nicer UI.
Falls back to `vim.ui.input` if not available.

## Commands

| Command | Description |
|---------|-------------|
| `:TaskToggle` | Toggle task tree sidebar |
| `:TaskAdd` | Add task at cursor |
| `:TaskDone` | Toggle task completion at cursor |
| `:TaskSignOff` | Sign off completed tasks in file |
| `:TaskRefresh` | Refresh all task displays |

## Keymaps

### Global (Outside Tree)
| Key | Action |
|-----|--------|
| `<leader>tt` | Toggle task tree |
| `<leader>ta` | Add task at cursor |
| `<leader>tx` | Toggle task at cursor |
| `<leader>ts` | Sign off completed tasks |

### Tree View
| Key | Action |
|-----|--------|
| `<CR>` / `o` | Expand/collapse task |
| `a` | Add subtask to current task |
| `x` | Toggle task done/undone |
| `d` | Delete task and subtasks |
| `g` | Jump to task location |
| `r` | Set current task as root |
| `R` | Clear root (show all) |
| `q` / `<ESC>` | Close sidebar |
| `?` | Show help |

## Configuration

```lua
require("task-decomposer").setup({
  keymaps = {
    toggle_tree = "<leader>tt",
    add_task = "<leader>ta",
    toggle_task = "<leader>tx",
    sign_off_tasks = "<leader>ts",
  },
  ui = {
    width = 0.25, -- Sidebar width (25% of screen)
    position = "right", -- "left" or "right"
    border = "rounded",
  },
})
```

## Workflow Example

1. **Add tasks while coding**: 
   - Place cursor on line, press `<leader>ta`
   - Enter task description
   - Task appears as virtual text

2. **Complete tasks**:
   - Press `<leader>tx` on task line to mark done
   - Or open tree with `<leader>tt` and press `x`

3. **Sign off completed work**:
   - Press `<leader>ts` to remove all completed tasks
   - Clean up your workspace

4. **Organize with hierarchy**:
   - Open tree, select a task, press `a` to add subtask
   - Tasks show hierarchy: `[1.2.3]` means 3rd subtask of 2nd subtask of 1st task

