# Task Decomposer Architecture

## Overview

Task Decomposer is a Neovim plugin that manages hierarchical tasks using SQLite for persistence and virtual text for display. This document explains the internal architecture.

## Component Structure

```
task-decomposer.nvim/
├── lua/task-decomposer/
│   ├── init.lua          # Plugin entry point and setup
│   ├── db.lua            # Database layer (SQLite operations)
│   ├── ui.lua            # Tree view interface
│   └── virtual_text.lua  # Virtual text management
├── plugin/
│   └── task-decomposer.lua  # Plugin guard
└── examples/
    └── lazy-config.lua   # Configuration example
```

## Module Responsibilities

### init.lua
- Plugin entry point
- Configuration management
- Global keymap setup
- User command registration
- Module initialization orchestration

**Key Functions:**
- `setup(opts)` - Initialize plugin with user config

### db.lua
- SQLite database abstraction
- CRUD operations for tasks
- Task hierarchy management
- Data persistence

**Schema:**
```sql
CREATE TABLE tasks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  parent_id INTEGER,
  description TEXT NOT NULL,
  file_path TEXT,
  line_number INTEGER,
  column_number INTEGER,
  completed INTEGER DEFAULT 0,
  created_at TEXT,
  position INTEGER DEFAULT 0
)
```

**Note:** The `created_at` timestamp is set programmatically in the `add_task()` function using `os.date("%Y-%m-%d %H:%M:%S")` since sqlite.lua doesn't support function defaults in schema definitions.

**Key Functions:**
- `setup()` - Initialize database
- `add_task(description, parent_id, file_path, line_number, column_number)`
- `get_task(id)`
- `get_children(parent_id)`
- `toggle_completed(id)`
- `delete_task(id)`
- `update_task(id, updates)`
- `get_tasks_for_file(file_path)`

### ui.lua
- Floating window management
- Tree rendering
- User interaction handling
- Task navigation

**State:**
- `buf` - Buffer handle for tree view
- `win` - Window handle for floating window
- `current_root` - Current root task for filtering
- `expanded` - Map of expanded task IDs
- `task_map` - Map of line numbers to tasks

**Key Functions:**
- `open()` - Open tree view
- `close()` - Close tree view
- `toggle()` - Toggle tree view
- `render()` - Render task tree
- `toggle_expand()` - Expand/collapse task
- `toggle_done()` - Mark task complete/incomplete
- `delete_current()` - Delete selected task
- `add_task_ui()` - Add task via UI
- `set_root()` - Filter to specific task
- `clear_root()` - Clear filter
- `jump_to_task()` - Jump to code location

### virtual_text.lua
- Virtual text display in buffers
- Auto-update on buffer events
- File-to-task mapping

**State:**
- `ns_id` - Namespace ID for extmarks
- `active_buffers` - Set of buffers with virtual text

**Key Functions:**
- `setup()` - Initialize autocmds
- `update_buffer(bufnr)` - Update virtual text for buffer
- `clear_buffer(bufnr)` - Clear virtual text
- `refresh_all()` - Refresh all buffers
- `add_task_at_cursor()` - Add task at current position

## Data Flow

### Adding a Task

```
User: <leader>ta
  ↓
virtual_text.add_task_at_cursor()
  ↓
vim.ui.input() [get description]
  ↓
db.add_task(description, nil, file_path, line_number, column_number)
  ↓
SQLite INSERT
  ↓
virtual_text.update_buffer()
  ↓
Display virtual text
```

### Viewing Tasks

```
User: <leader>tt
  ↓
ui.toggle()
  ↓
ui.open()
  ↓
Create floating window
  ↓
ui.render()
  ↓
db.get_children(parent_id) [recursive]
  ↓
Build line array with indentation
  ↓
Display in buffer
```

### Marking Task Complete

```
User: x (in tree view)
  ↓
ui.toggle_done()
  ↓
ui.get_current_task()
  ↓
db.toggle_completed(task_id)
  ↓
SQLite UPDATE
  ↓
ui.render()
  ↓
virtual_text.refresh_all()
  ↓
Hide completed tasks from code
```

### Jumping to Code

```
User: g (in tree view)
  ↓
ui.jump_to_task()
  ↓
ui.get_current_task()
  ↓
Check file_path exists
  ↓
ui.close()
  ↓
vim.cmd("edit " .. file_path)
  ↓
Set cursor position
```

## Event Flow

### Buffer Events

```
BufEnter / BufWritePost
  ↓
virtual_text.update_buffer()
  ↓
db.get_tasks_for_file()
  ↓
Clear old extmarks
  ↓
Set new extmarks with virtual text
```

### Tree Interaction

```
Keypress in tree buffer
  ↓
Check keymap
  ↓
Execute action (expand/complete/delete/etc)
  ↓
Update database if needed
  ↓
Re-render tree
  ↓
Update virtual text if needed
```

## Database Design

### Task Table

**Fields:**
- `id` - Auto-incrementing primary key
- `parent_id` - Foreign key to parent task (NULL for root tasks)
- `description` - Task description text
- `file_path` - Optional file path
- `line_number` - Optional line number
- `column_number` - Optional column position
- `completed` - 0 or 1 (boolean)
- `created_at` - Timestamp
- `position` - Sort order among siblings

**Relationships:**
- Self-referential: `parent_id` → `id`
- Tree structure with unlimited depth
- Orphan handling: deleting parent deletes children (cascade)

### Queries

**Get root tasks:**
```sql
SELECT * FROM tasks WHERE parent_id IS NULL ORDER BY position
```

**Get children:**
```sql
SELECT * FROM tasks WHERE parent_id = ? ORDER BY position
```

**Get tasks for file:**
```sql
SELECT * FROM tasks WHERE file_path = ? AND completed = 0
```

**Toggle completion:**
```sql
UPDATE tasks SET completed = (1 - completed) WHERE id = ?
```

## UI Design

### Tree Rendering

```
Root: Feature X
──────────────────────────────────────────────────
  ▼ Backend work
    ○ API endpoint (api.lua:45)
    ○ Database migration
  ▶ Frontend work
  ✓ Documentation
```

**Line Format:**
```
{indent}{icon} {status}{description}{location}
```

**Indent:** `"  "` repeated by depth level
**Icon:** 
- `○` incomplete task
- `✓` completed task
- `▶` collapsed with children
- `▼` expanded with children

**Status:** `[DONE] ` if completed
**Location:** `(filename:line)` if has file_path

### Virtual Text Format

```lua
local result = 0  📋 Implement calculation logic
```

Displayed as:
- Position: end of line (`virt_text_pos = "eol"`)
- Highlight: `Comment` group
- Icon: 📋 (clipboard emoji)

## Configuration

### Default Config Structure

```lua
{
  keymaps = {
    toggle_tree = "<leader>tt",
    add_task = "<leader>ta",
    -- ... tree view keymaps
  },
  ui = {
    width = 0.4,
    height = 0.8,
    border = "rounded",
  },
}
```

### Extension Points

Users can customize:
- All keymaps
- Window dimensions
- Border style

Future extension possibilities:
- Custom highlight groups
- Virtual text format
- Icon customization
- Task sorting methods

## Performance Considerations

### Optimizations
- Virtual text only updates on buffer enter/write
- Tree only renders when visible
- Lazy loading of task children
- Namespace isolation for extmarks

### Scalability
- SQLite handles thousands of tasks efficiently
- Tree rendering is O(n) where n = visible tasks
- Virtual text is O(m) where m = tasks in current file
- No polling or continuous updates

### Memory
- Minimal memory footprint
- Database connection pooled
- UI state only when tree open
- Extmarks managed by Neovim

## Error Handling

### Database Errors
- Handled by sqlite.lua
- Plugin degrades gracefully if DB unavailable
- User notified via vim.notify

### UI Errors
- Invalid task IDs handled
- Missing files handled on jump
- Window validation before operations

### Edge Cases
- Empty task descriptions prevented by required field
- Circular references impossible (parent must exist first)
- Completed tasks hidden from virtual text
- Invalid line numbers handled gracefully

## Testing Approach

### Manual Testing
1. Add tasks in code
2. View in tree
3. Add subtasks
4. Mark complete
5. Delete tasks
6. Jump to locations
7. Filter by root
8. Restart Neovim (test persistence)

### Test Scenarios
- Tasks with code references
- Tasks without code references
- Deep nesting (5+ levels)
- Many tasks in one file (50+)
- Tasks in deleted files
- Tasks on moved lines

## Future Architecture Considerations

### Possible Enhancements
1. **Project-specific databases**
   - Detect git root
   - Use project-specific DB file
   - Allow workspace switching

2. **Task metadata**
   - Add priority field
   - Add tags/labels
   - Add due dates
   - Add assignees

3. **Search and filter**
   - Full-text search in descriptions
   - Filter by completion status
   - Filter by file/directory
   - Filter by date

4. **Import/export**
   - JSON export
   - Markdown export
   - Import from TODO comments
   - Sync with external tools

5. **Advanced UI**
   - Task preview in tree
   - Inline editing
   - Drag-and-drop reordering
   - Multiple tree views

6. **Integration**
   - Git branch tracking
   - Issue tracker integration
   - Time tracking
   - Statistics dashboard
