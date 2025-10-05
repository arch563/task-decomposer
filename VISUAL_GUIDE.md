# Visual Guide - New Look & Feel

## In Your Buffer

### What You'll See

```lua
function login(user, pass)
    local valid = validate(user)    ○ Add validation [1.2]
    if valid then
        authenticate(user, pass)    ✓ Fix auth bug [1.1]
        create_session(user)        ○ Add session timeout [2.3.1]
    end
end
```

**Color Legend:**
- `○ Add validation` - **Translucent blue** (pending task)
- `✓ Fix auth bug` - **Translucent green** (completed task)
- `[1.2]` - **Subtle gray italic** (task number hint)

### How It Looks
```
your_code_here()    ○ task description [1.2.3]
                    │   │               │
                    │   │               └─ TaskHint (gray, italic)
                    │   └─ TaskPending (translucent blue)
                    └─ Status icon
```

## In The Tree Sidebar

### Tree Display (Unchanged)
```
╔═══ All Tasks ═══╗

[1] ○ [ ] Implement login @auth.lua:15
[1.1] ├─✓ [✓] Fix auth bug @auth.lua:42
[1.2] └─○ [ ] Add validation @auth.lua:30
[2] ○ [ ] Add features @main.lua:10
[2.1] ├─○ [ ] Feature A @feat.lua:5
[2.2] └─○ [ ] Feature B @feat.lua:20
[2.2.1]   └─○ [ ] Sub-feature @feat.lua:25
```

## New Keybindings in Action

### Quick Task Operations
```bash
# You're editing code, cursor on line 42

gta          → Prompt: "Task description:"
             → Type: "Fix this bug"
             → Task added at line 42

gtx          → Task at cursor toggles done/undone
             → ○ → ✓ or ✓ → ○

gts          → All completed tasks deleted
             → "Signed off 3 task(s)"
```

### With Root Context
```bash
# In tree, set "Implement login" as root

r            → "Root set to: Implement login"
q            → Close tree

# In buffer
gta          → Prompt: "Task (under 'Implement login'):"
             → Task auto-added as subtask
```

## Color Customization Examples

### Light Theme
```lua
-- After setup, customize for light background
vim.api.nvim_set_hl(0, "TaskPending", { 
  fg = "#3d59a1",  -- Darker blue
  blend = 20 
})
vim.api.nvim_set_hl(0, "TaskCompleted", { 
  fg = "#4a7c40",  -- Darker green
  blend = 40 
})
vim.api.nvim_set_hl(0, "TaskHint", { 
  fg = "#8c8c8c",  -- Medium gray
  italic = true 
})
```

### Dark Theme (Default)
```lua
-- Built-in colors work great with dark themes
TaskPending   = { fg = "#7aa2f7", blend = 30 }  -- Blue
TaskCompleted = { fg = "#9ece6a", blend = 50 }  -- Green
TaskHint      = { fg = "#565f89", italic = true } -- Gray
```

### High Contrast
```lua
vim.api.nvim_set_hl(0, "TaskPending", { 
  fg = "#00d7ff",  -- Bright cyan
  blend = 0        -- No transparency
})
vim.api.nvim_set_hl(0, "TaskCompleted", { 
  fg = "#00ff87",  -- Bright green
  blend = 30 
})
vim.api.nvim_set_hl(0, "TaskHint", { 
  fg = "#767676", 
  italic = true,
  bold = true 
})
```

## Comparison: Before vs After

### Before (Yellow/Todo)
```
function test() {
    doSomething();    [1.2.3] ○ Fix this function
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^
                     Bright yellow, task# first
}
```

### After (Translucent Blue)
```
function test() {
    doSomething();    ○ Fix this function [1.2.3]
                     ^   ^^^^^^^^^^^^^^^^  ^^^^^^^
                     |   Translucent blue  Subtle hint
                     Icon
}
```

## Tips for Best Visual Experience

🎨 **Adjust blend values** if colors are too transparent
```lua
blend = 20  -- More opaque
blend = 60  -- More transparent
```

🎨 **Match your colorscheme** by extracting colors
```lua
local colors = require("tokyonight.colors").setup()
vim.api.nvim_set_hl(0, "TaskPending", { 
  fg = colors.blue, 
  blend = 30 
})
```

🎨 **Disable transparency** for solid colors
```lua
vim.api.nvim_set_hl(0, "TaskPending", { 
  fg = "#7aa2f7", 
  blend = 0  -- Solid color
})
```

🎨 **Add background** for more contrast
```lua
vim.api.nvim_set_hl(0, "TaskPending", { 
  fg = "#7aa2f7", 
  bg = "#1a1b26",  -- Subtle background
  blend = 30 
})
```

