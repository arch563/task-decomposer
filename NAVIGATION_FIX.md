# Navigation Fix - Tree as Normal Window

## What Was Fixed

### 1. Reverted Custom Navigation
❌ **Removed**: Custom `<C-h>` and `<C-l>` keybindings
✅ **Now**: Tree is a normal Neovim window

### 2. Added Hidden Column to Database
❌ **Problem**: `hidden` column wasn't in actual database
✅ **Fixed**: Added `hidden INTEGER DEFAULT 0` to tasks table

### 3. How to Navigate Now

The tree sidebar is treated as a **normal Neovim window**, so use standard window navigation:

```bash
# Navigate between windows (standard Neovim)
<C-w>h    → Move to left window
<C-w>l    → Move to right window  
<C-w>j    → Move to window below
<C-w>k    → Move to window above

# Or use <C-w><C-w> to cycle through windows
<C-w><C-w>    → Next window
```

## Database Schema

The `hidden` column has been added to your database:

```sql
CREATE TABLE tasks (
  id INTEGER PRIMARY KEY,
  parent_id INTEGER,
  description TEXT,
  file_path TEXT,
  line_number INTEGER,
  column_number INTEGER,
  completed INTEGER DEFAULT 0,
  hidden INTEGER DEFAULT 0,    -- NEW!
  created_at TEXT,
  position INTEGER DEFAULT 0
);
```

## Current Status

✅ Database has `hidden` column
✅ Tasks should display in buffers
✅ Tree is normal window (use `<C-w>hjkl`)
✅ Hide/show functionality ready (`h` key in tree)

## Testing

To verify everything works:

1. **Open tree**: `<leader>tt`
2. **Navigate to tree**: `<C-w>l` (or `<C-w>h` if on right)
3. **Back to buffer**: `<C-w>h` (or `<C-w>l` if tree is on left)
4. **Test hide**: Navigate to task in tree, press `h`
5. **Check buffer**: Hidden task shouldn't show

## Quick Reference

| Action | Key |
|--------|-----|
| Toggle tree | `<leader>tt` |
| Navigate to tree | `<C-w>l` or `<C-w>h` |
| Navigate from tree | `<C-w>h` or `<C-w>l` |
| Cycle windows | `<C-w><C-w>` |
| Hide task (in tree) | `h` |
| Add task | `gta` |
| Toggle done | `gtx` |
| Sign off | `gts` |

