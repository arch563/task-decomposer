# Updated Keybindings and Highlights

## New Keybindings (No More `<leader>` for Tasks!)

### Why the Change?
Using `<leader>` for frequently-used task operations was cumbersome. The new `gt` prefix (mnemonic: "**g**o **t**ask") provides:
- ✅ Faster access - no leader key needed
- ✅ Logical grouping - all task ops start with `gt`
- ✅ Easy to remember - `gta` = go task add, `gtx` = go task cross-off

### New Keybindings

| Old Binding | New Binding | Action | Mnemonic |
|-------------|-------------|--------|----------|
| `<leader>ta` | **`gta`** | Add task at cursor | **G**o **T**ask **A**dd |
| `<leader>tx` | **`gtx`** | Toggle task done/undone | **G**o **T**ask cross (**X**) off |
| `<leader>ts` | **`gts`** | Sign off completed tasks | **G**o **T**ask **S**ign-off |
| `<leader>tt` | `<leader>tt` | Toggle tree (unchanged) | - |

### Quick Reference

```bash
# Task Operations (gt prefix)
gta          # Add task at cursor
gtx          # Toggle task completion
gts          # Sign off completed tasks

# Tree Operations (unchanged)
<leader>tt   # Toggle task tree sidebar
```

## New Highlight System

### Translucent Colors
Tasks now use subtle, translucent colors instead of bright yellow:

**Pending Tasks** (`TaskPending`):
- Color: Translucent blue (`#7aa2f7`)
- Blend: 30% transparency
- Usage: Incomplete tasks

**Completed Tasks** (`TaskCompleted`):
- Color: Translucent green (`#9ece6a`)
- Blend: 50% transparency (more subtle)
- Usage: Finished tasks

**Task Number Hint** (`TaskHint`):
- Color: Dimmed gray (`#565f89`)
- Style: Italic
- Usage: Task index numbers

### Display Format

**In Buffer (Virtual Text):**
```
your code here    ○ Fix validation [1.2.3]
                  ^   ^             ^
                  |   |             └─ Task number (TaskHint)
                  |   └─ Description (TaskPending/Completed)
                  └─ Status icon
```

**In Tree (Unchanged):**
```
[1.2.3] ├─○ [ ] Fix validation @file.lua:42
```

### Customization

You can override the highlights in your config:

```lua
require("task-decomposer").setup({
  highlights = {
    task_pending = "YourPendingHL",    -- Custom highlight for pending
    task_completed = "YourCompletedHL", -- Custom highlight for completed
    task_hint = "YourHintHL",          -- Custom highlight for numbers
  }
})
```

Or set them directly after setup:

```lua
vim.api.nvim_set_hl(0, "TaskPending", { fg = "#your_color", blend = 40 })
vim.api.nvim_set_hl(0, "TaskCompleted", { fg = "#your_color", blend = 60 })
vim.api.nvim_set_hl(0, "TaskHint", { fg = "#your_color", italic = true })
```

## Visual Comparison

### Before:
```
your code here    [1.2.3] ○ Fix validation
                  ^^^^^^^^^^^^^^^^^^^^^^^
                  All in bright yellow/todo color
```

### After:
```
your code here    ○ Fix validation [1.2.3]
                  ^                 ^
                  Translucent blue  Subtle gray hint
```

## Benefits

✨ **Less Visual Noise** - Translucent colors blend with your colorscheme
✨ **Better Organization** - Task number in diagnostic-style hint
✨ **Easier to Spot** - Completed tasks are more subtle (green + transparent)
✨ **Faster Workflow** - `gt` prefix is quicker than `<leader>`

## Migration Guide

If you have custom keybindings, update them:

```lua
-- Old
vim.keymap.set("n", "<leader>ta", ...)

-- New
vim.keymap.set("n", "gta", ...)
```

Or use your own prefix in config:

```lua
require("task-decomposer").setup({
  keymaps = {
    add_task = "gta",      -- or your preferred key
    toggle_task = "gtx",   -- or your preferred key
    sign_off_tasks = "gts", -- or your preferred key
  }
})
```

