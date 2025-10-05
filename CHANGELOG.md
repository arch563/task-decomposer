# Changelog

All notable changes to task-decomposer.nvim will be documented in this file.

## [1.0.1] - 2024-10-05

### Fixed
- Added `set_db()` call to properly bind table to database before checking existence
- Removed function default for `created_at` field (sqlite.lua doesn't support function defaults)
- Timestamp now set explicitly in `add_task()` function
- Added nil checks to all database functions to prevent errors when called before initialization
- Fixed nil parent_id handling in `add_task()` - convert to vim.NIL before using in where() clause
- Fixes "db object is not set" error on plugin initialization
- Fixes "attempt to concatenate local 'v' (a function value)" error in schema parsing
- Fixes "attempt to index a nil value" error when autocmds fire before database is ready
- Fixes "incomplete input" SQL error when adding tasks with nil parent_id

## [1.0.0] - 2024-10-05

### Initial Release

#### Features

- **Hierarchical Task Management**
  - Create tasks with unlimited nesting levels
  - Decompose complex tasks into subtasks
  - Organize tasks in a tree structure

- **SQLite Storage**
  - Persistent storage across Neovim sessions
  - Database stored in Neovim data directory
  - No modification to source code files

- **Virtual Text Display**
  - Tasks displayed as virtual text in code (like LSP diagnostics)
  - Non-intrusive visual indicators
  - Automatically hidden when tasks are completed

- **Interactive Tree View**
  - Floating window with task hierarchy
  - Expand/collapse task branches
  - Filter view by setting a root task
  - Visual indicators for task status

- **Code References**
  - Link tasks to specific file locations
  - Jump directly from tree to code
  - Optional - tasks can exist without code references

- **Task Management**
  - Add tasks from code or tree view
  - Mark tasks as complete/incomplete
  - Delete tasks and subtasks
  - Reorder tasks (via position field)

- **Lazy.nvim Integration**
  - Full support for lazy.nvim plugin manager
  - Proper dependency management
  - Configurable keymaps

#### Keymaps

**Global:**
- `<leader>tt` - Toggle task tree
- `<leader>ta` - Add task at cursor

**Tree View:**
- `<CR>` or `o` - Expand/collapse
- `x` - Toggle done
- `d` - Delete task
- `a` - Add subtask
- `r` - Set as root
- `R` - Clear root
- `g` - Jump to code
- `q` - Close tree

#### Commands

- `:TaskToggle` - Toggle tree view
- `:TaskAdd` - Add task at cursor
- `:TaskRefresh` - Refresh virtual text

#### Dependencies

- Neovim >= 0.8.0
- kkharji/sqlite.lua

#### Files

- `lua/task-decomposer/init.lua` - Main entry point
- `lua/task-decomposer/db.lua` - SQLite database operations
- `lua/task-decomposer/ui.lua` - Tree view interface
- `lua/task-decomposer/virtual_text.lua` - Virtual text management
- `plugin/task-decomposer.lua` - Plugin initialization

#### Documentation

- `README.md` - Main documentation
- `USAGE.md` - Detailed usage guide
- `QUICKSTART.md` - Quick reference
- `examples/lazy-config.lua` - Configuration example
- `demo.lua` - Demo file for testing

### Known Limitations

- Requires sqlite.lua dependency
- Virtual text only shows on line ends
- No multi-project workspace support (tasks are global)
- No task priorities or tags yet
- No task due dates or reminders

### Future Considerations

- Task priorities
- Tags/labels
- Due dates
- Search/filter functionality
- Export/import tasks
- Project-specific task databases
- Task statistics and reports
- Integration with git branches
