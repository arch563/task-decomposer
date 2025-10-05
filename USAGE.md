# Task Decomposer - Detailed Usage Guide

## Table of Contents
1. [Concept](#concept)
2. [Installation](#installation)
3. [Basic Usage](#basic-usage)
4. [Advanced Features](#advanced-features)
5. [Workflow Examples](#workflow-examples)
6. [Configuration](#configuration)
7. [Troubleshooting](#troubleshooting)

## Concept

Task Decomposer helps you manage TODO items without polluting your code with TODO comments. It solves several problems:

- **No code pollution**: Tasks are stored in SQLite, not in your code
- **PR-ready code**: No forgotten TODO comments to remove before commits
- **Hierarchical planning**: Break down complex tasks into subtasks
- **Visual feedback**: See tasks as virtual text (like LSP diagnostics)
- **Persistent**: Tasks survive across sessions and are project-independent

## Installation

### Prerequisites

You need:
- Neovim >= 0.8.0
- [sqlite.lua](https://github.com/kkharji/sqlite.lua) plugin

### With lazy.nvim

```lua
{
  dir = "/home/archie/workspace/task-decomposer.nvim",
  dependencies = {
    "kkharji/sqlite.lua",
  },
  config = function()
    require("task-decomposer").setup({
      -- Optional customization
      keymaps = {
        toggle_tree = "<leader>tt",
        add_task = "<leader>ta",
      },
    })
  end,
}
```

### With packer.nvim

```lua
use {
  "task-decomposer.nvim",
  requires = { "kkharji/sqlite.lua" },
  config = function()
    require("task-decomposer").setup()
  end,
}
```

## Basic Usage

### Adding Tasks

#### From Code (with location reference)

1. Navigate to the line where you want to add a task
2. Press `<leader>ta`
3. Enter your task description
4. The task appears as virtual text at the end of the line

Example:
```
function calculate() {
  local result = 0  📋 Implement actual calculation logic
  return result
}
```

#### From Tree View (without location)

1. Open the tree view with `<leader>tt`
2. Press `a` to add a task
3. Enter description
4. This creates a standalone task (useful for planning)

### Viewing Tasks

Press `<leader>tt` to open the tree view. You'll see:

```
All Tasks
──────────────────────────────────────────────────
○ Implement user authentication
  ○ Add login form (login.lua:45)
  ○ Add password validation
  ○ Add session management
○ Fix database queries
  ✓ Update user table schema
  ○ Add indexes (database.lua:123)
```

### Navigating the Tree

- Use `j`/`k` or arrow keys to move between tasks
- Press `<CR>` or `o` to expand/collapse tasks with subtasks
- Icons show task status:
  - `○` = incomplete
  - `✓` = completed
  - `▶` = collapsed (has subtasks)
  - `▼` = expanded (has subtasks)

### Managing Tasks

| Action | Key | Description |
|--------|-----|-------------|
| Mark done | `x` | Toggle completion status |
| Add subtask | `a` | Add a child task |
| Delete | `d` | Remove task and all children |
| Jump to code | `g` | Open file at task location |

### Completing Tasks

1. In tree view, navigate to the task
2. Press `x` to toggle completion
3. Completed tasks show `✓` and `[DONE]` label
4. Completed tasks are hidden from virtual text in code

### Deleting Tasks

1. Navigate to the task in tree view
2. Press `d`
3. Confirm deletion
4. The task and all its subtasks are removed

## Advanced Features

### Hierarchical Task Decomposition

Break down complex tasks into manageable pieces:

```
○ Build user profile page
  ○ Backend
    ○ Create API endpoint (api.lua:89)
    ○ Add database models (models.lua:34)
    ○ Add validation
  ○ Frontend
    ○ Design UI mockup
    ○ Implement form (profile.jsx:12)
    ○ Add error handling
```

To create this structure:
1. Add top-level task: "Build user profile page"
2. Select it and add subtask: "Backend"
3. Select "Backend" and add its subtasks
4. Repeat for "Frontend"

### Root Filtering

Focus on a specific task and its subtasks:

1. Navigate to a task in tree view
2. Press `r` to set it as root
3. View shows only that task and its descendants
4. Press `R` to return to full view

This is useful when working on a specific feature and you want to hide unrelated tasks.

### Code References vs Standalone Tasks

**Tasks with code references:**
- Created with `<leader>ta` while editing code
- Show in both tree view and as virtual text in code
- Include file path and line number
- Good for implementation details

**Standalone tasks:**
- Created with `a` in tree view
- Show only in tree view
- No file/line association
- Good for planning, documentation, design tasks

### Jumping to Code

When a task has a code reference:

1. Select task in tree view
2. Press `g` or `<C-g>`
3. File opens
4. Cursor moves to exact line
5. Tree view closes automatically

If task has no code reference, you'll see a warning.

## Workflow Examples

### Example 1: Feature Development

**Planning Phase:**
```
1. Open tree: <leader>tt
2. Add task: "Add dark mode support"
3. Break down:
   - "Update color scheme"
   - "Add toggle button"
   - "Save preference"
```

**Implementation Phase:**
```
1. Navigate to colors.lua
2. Add task at line: <leader>ta "Implement dark colors"
3. Code the feature
4. Mark task done: <leader>tt, navigate, x
```

**Review Phase:**
```
1. Open tree: <leader>tt
2. Review all incomplete tasks
3. Jump to each: g
4. Complete or delete tasks
```

### Example 2: Bug Fixing

```
1. Find bug location in code
2. Add task: <leader>ta "Fix null pointer in validation"
3. Add subtasks for investigation:
   - "Check input sanitization"
   - "Add unit test"
   - "Handle edge case"
4. Work through subtasks
5. Mark each complete: x
```

### Example 3: Refactoring

```
1. Plan in tree view:
   ○ Refactor authentication module
     ○ Extract validation logic
     ○ Simplify error handling
     ○ Add TypeScript types
2. Link to code locations:
   - Navigate to auth.ts
   - Add task: <leader>ta "Extract to validator.ts"
3. Execute refactoring
4. Mark tasks done as you go
```

## Configuration

### Full Configuration Options

```lua
require("task-decomposer").setup({
  keymaps = {
    -- Global keymaps
    toggle_tree = "<leader>tt",
    add_task = "<leader>ta",
    
    -- Tree view keymaps (applied when tree is open)
    tree_expand = "<CR>",
    tree_toggle_done = "x",
    tree_delete = "d",
    tree_add_subtask = "a",
    tree_set_root = "r",
    tree_clear_root = "R",
    tree_jump = "g",
    tree_close = "q",
  },
  ui = {
    width = 0.4,      -- 40% of screen width (0.1 to 1.0)
    height = 0.8,     -- 80% of screen height (0.1 to 1.0)
    border = "rounded", -- "none", "single", "double", "rounded", "solid", "shadow"
  },
})
```

### Custom Keymap Example

```lua
require("task-decomposer").setup({
  keymaps = {
    toggle_tree = "<leader>td",  -- Task Display
    add_task = "<leader>tn",     -- Task New
  },
})
```

### UI Customization Example

```lua
require("task-decomposer").setup({
  ui = {
    width = 0.5,       -- 50% width
    height = 0.9,      -- 90% height
    border = "single", -- Single line border
  },
})
```

## Troubleshooting

### Virtual Text Not Showing

1. Check if file is saved: `:w`
2. Force refresh: `:TaskRefresh`
3. Reopen file: `:e`

### Database Errors

The database is at `~/.local/share/nvim/task-decomposer.db`

To reset:
```bash
rm ~/.local/share/nvim/task-decomposer.db
```
Then restart Neovim.

### Tree Not Opening

1. Check if sqlite.lua is installed
2. Check for errors: `:messages`
3. Try reinstalling the plugin

### Keymaps Not Working

1. Check for conflicts: `:map <leader>tt`
2. Verify setup was called: `:lua print(vim.g.loaded_task_decomposer)`
3. Try different keymaps in config

### Tasks Not Persisting

1. Check database file exists: `ls ~/.local/share/nvim/task-decomposer.db`
2. Check file permissions
3. Check for SQLite errors: `:messages`

## Data Management

### Database Location

- Linux/macOS: `~/.local/share/nvim/task-decomposer.db`
- Windows: `~/AppData/Local/nvim-data/task-decomposer.db`

### Backup

```bash
cp ~/.local/share/nvim/task-decomposer.db ~/task-backup.db
```

### View Raw Data

```bash
sqlite3 ~/.local/share/nvim/task-decomposer.db "SELECT * FROM tasks;"
```

## Tips and Best Practices

1. **Start Small**: Add tasks as you find them, don't try to plan everything upfront
2. **Regular Cleanup**: Delete completed tasks periodically
3. **Use Hierarchy**: Break large tasks into 3-5 subtasks maximum per level
4. **Mix References**: Use code references for implementation, standalone for planning
5. **Focus Mode**: Use root filter (`r`) to concentrate on one feature
6. **Quick Capture**: Don't overthink - add a task and refine it later
7. **Review Regularly**: Open tree view to see what's pending
8. **Mark Done Often**: Keep completion status current

## Common Patterns

### Sprint Planning
```
○ Sprint 1
  ○ User Story 1
    ○ Task 1 (code ref)
    ○ Task 2 (code ref)
  ○ User Story 2
    ○ Task 1
    ○ Task 2
```

### Bug Tracking
```
○ Bugs
  ○ Critical
    ○ Login failure (auth.lua:45)
  ○ Medium
    ○ UI alignment (header.tsx:23)
  ○ Low
    ○ Typo in message
```

### Technical Debt
```
○ Tech Debt
  ○ Refactoring
    ○ Clean up util.lua
  ○ Documentation
    ○ Add README examples
  ○ Tests
    ○ Add integration tests
```
