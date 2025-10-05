# Task Decomposer - Quick Reference

## Installation (lazy.nvim)

```lua
{
  dir = "/path/to/task-decomposer.nvim",
  dependencies = { "kkharji/sqlite.lua" },
  config = function()
    require("task-decomposer").setup()
  end,
}
```

## Quick Start

1. **Add a task**: Position cursor, press `<leader>ta`, enter description
2. **View tasks**: Press `<leader>tt` to open tree view
3. **Mark done**: In tree, press `x` on a task
4. **Add subtask**: In tree, select parent, press `a`
5. **Jump to code**: In tree, press `g` on a task with location

## Global Keymaps

| Key | Action |
|-----|--------|
| `<leader>tt` | Toggle task tree |
| `<leader>ta` | Add task at cursor |

## Tree View Keymaps

| Key | Action |
|-----|--------|
| `<CR>` or `o` | Expand/collapse task |
| `x` | Toggle done/undone |
| `d` | Delete task + subtasks |
| `a` | Add new subtask |
| `r` | Set as root (filter) |
| `R` | Clear root filter |
| `g` or `<C-g>` | Jump to code location |
| `q` or `<ESC>` | Close tree view |

## Commands

- `:TaskToggle` - Toggle tree
- `:TaskAdd` - Add task at cursor
- `:TaskRefresh` - Refresh virtual text

## Icons

- `○` Incomplete task
- `✓` Completed task
- `▶` Collapsed (has subtasks)
- `▼` Expanded (has subtasks)
- `📋` Virtual text in code

## Workflow

### Planning
1. Open tree (`<leader>tt`)
2. Add high-level task (`a`)
3. Break it down into subtasks (select, press `a`)

### Coding
1. Navigate to relevant code
2. Add task at cursor (`<leader>ta`)
3. Task appears as virtual text

### Reviewing
1. Open tree (`<leader>tt`)
2. Navigate tasks with `j`/`k`
3. Jump to code with `g`
4. Mark complete with `x`
5. Delete when done with `d`

## Tips

✓ Tasks don't modify your code files
✓ Use root filter (`r`) to focus on one feature
✓ Add tasks without code references for planning
✓ Link tasks to code for implementation details
✓ Database: `~/.local/share/nvim/task-decomposer.db`
