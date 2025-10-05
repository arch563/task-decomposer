# task-decomposer.nvim

A hierarchical task decomposition plugin for Neovim that helps you manage TODO items without cluttering your code. Tasks are stored in a local SQLite database and displayed as virtual text (like LSP diagnostics) at their code locations.

## Features

- **Hierarchical Tasks**: Create tasks with unlimited levels of subtasks
- **Progress Indicators**: Visual checkboxes show subtask completion status at a glance
- **Virtual Text Display**: Tasks appear as virtual text at code locations (no actual TODO comments in your code)
- **SQLite Storage**: Persistent storage across sessions using SQLite
- **Tree View**: Interactive tree interface with colored icons and progress tracking
- **Code References**: Link tasks to specific files and line numbers
- **Flexible Organization**: Tasks can exist with or without code references
- **Easy Navigation**: Jump from tree view directly to task locations in code
- **Snacks.nvim Integration**: Enhanced input dialogs positioned near your cursor

## Requirements

- Neovim >= 0.8.0
- [kkharji/sqlite.lua](https://github.com/kkharji/sqlite.lua) - SQLite bindings for Lua

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "task-decomposer.nvim",
  dependencies = {
    "kkharji/sqlite.lua",
  },
  config = function()
    require("task-decomposer").setup({
      -- Optional: customize keymaps
      keymaps = {
        toggle_tree = "<leader>tt",
        add_task = "<leader>ta",
      },
    })
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "task-decomposer.nvim",
  requires = { "kkharji/sqlite.lua" },
  config = function()
    require("task-decomposer").setup()
  end,
}
```

## Usage

### Global Keymaps (default)

- `gtt` - Toggle the task tree view
- `gta` - Add a task at the current cursor position
- `gtx` - Toggle task completion at cursor
- `gts` - Sign off completed tasks in current file

### Tree View Keymaps

When the task tree is open:

- `<CR>` or `o` - Expand/collapse task (if it has subtasks)
- `x` - Toggle task completion status
- `h` - Toggle hide/show task
- `d` - Delete task and all its subtasks
- `a` - Add a new subtask under the current task
- `r` - Set current task as the root (filter view to show only this task and its subtasks)
- `u` - Clear root filter (show all tasks)
- `g` or `<C-g>` - Jump to the task's location in code
- `q` or `<ESC>` - Close the tree view
- `?` - Show help

### Commands

- `:TaskToggle` - Toggle the task tree view
- `:TaskAdd` - Add a task at cursor position
- `:TaskRefresh` - Refresh virtual text in all buffers

### Workflow Examples

#### Adding a task while coding

1. Position your cursor on the line you want to reference
2. Press `<leader>ta`
3. Enter your task description
4. The task appears as virtual text at the end of the line

#### Breaking down a task

1. Open the tree view with `<leader>tt`
2. Navigate to the task you want to decompose
3. Press `a` to add a subtask
4. Enter the subtask description
5. Repeat to create multiple subtasks

#### Managing task hierarchy

1. Open the tree view
2. Use `r` on a task to focus only on that task and its subtasks
3. Use `R` to return to the full task list
4. Use `<CR>` to expand/collapse tasks with subtasks

#### Completing tasks

1. In the tree view, navigate to a completed task
2. Press `x` to mark it as done
3. Completed tasks show with a ✓ icon and [DONE] label

#### Navigating to task locations

1. In the tree view, select a task with a code reference
2. Press `g` to jump to that location
3. Your file opens and cursor moves to the exact line

## Configuration

### Default Configuration

```lua
require("task-decomposer").setup({
  keymaps = {
    toggle_tree = "<leader>tt",
    add_task = "<leader>ta",
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
    width = 0.4,  -- 40% of screen width
    height = 0.8, -- 80% of screen height
    border = "rounded",
  },
})
```

### Customization Example

```lua
require("task-decomposer").setup({
  keymaps = {
    toggle_tree = "<leader>td",
    add_task = "<leader>tn",
  },
  ui = {
    width = 0.5,
    height = 0.9,
    border = "single",
  },
})
```

## How It Works

1. **Storage**: All tasks are stored in an SQLite database at `~/.local/share/nvim/task-decomposer.db`
2. **Virtual Text**: Tasks linked to code locations are displayed as virtual text (similar to LSP diagnostics) at the end of the line
3. **No Code Modification**: Your actual code files are never modified - tasks exist only in the database
4. **Persistence**: Tasks persist across Neovim sessions
5. **Hierarchy**: Tasks can have unlimited nesting levels for detailed decomposition

## Task Properties

Each task can have:
- **Description**: The task text
- **Parent**: Optional parent task for hierarchy
- **File Location**: Optional file path, line number, and column number
- **Completion Status**: Whether the task is done
- **Position**: Order among sibling tasks

## Icons

- `○` - Incomplete task
- `✓` - Completed task
- `▶` - Collapsed task with subtasks
- `▼` - Expanded task with subtasks
- `📋` - Virtual text indicator in code

## Database Location

The SQLite database is stored at:
- Linux/macOS: `~/.local/share/nvim/task-decomposer.db`
- Windows: `~/AppData/Local/nvim-data/task-decomposer.db`

## Tips

- Use tasks without code references for high-level planning
- Link tasks to code for implementation details
- Use the root filter (`r`) to focus on specific features
- Mark tasks as done (`x`) to track progress
- Delete completed tasks regularly to keep your list clean

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.
