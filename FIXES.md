# Bug Fixes

## Version 1.0.1 - Bug Fixes

### Bug #1: Database Object Not Set

**Error:**
```
sqlite.lua: tasks's db object is not set. set it with `tasks:set_db(db)` and try again.
```

**Cause:** The table schema was created but not bound to the database connection before attempting to check if it exists.

**Fix:** Added `M.tasks:set_db(M.db)` on line 30 of `lua/task-decomposer/db.lua` to bind the table to the database before calling `exists()`.

```lua
-- Before
M.tasks = tbl("tasks", {...})
if not M.tasks:exists() then  -- Error: no db object!
  M.tasks:create()
end

-- After
M.tasks = tbl("tasks", {...})
M.tasks:set_db(M.db)  -- Bind table to database
if not M.tasks:exists() then  -- Now works!
  M.tasks:create()
end
```

### Bug #2: Function Default in Schema

**Error:**
```
attempt to concatenate local 'v' (a function value)
```

**Cause:** sqlite.lua doesn't support function values in the `default` field of schema definitions. We had:

```lua
created_at = { "text", default = function() return os.date("%Y-%m-%d %H:%M:%S") end }
```

**Fix:** 
1. Changed schema to simple field: `created_at = "text"`
2. Set timestamp explicitly in `add_task()` function:

```lua
local task = {
  -- ... other fields ...
  created_at = os.date("%Y-%m-%d %H:%M:%S"),
}
```

### Bug #3: Nil Database Access

**Error:**
```
attempt to index a nil value
```

**Cause:** Autocmds (BufEnter, BufWritePost) were firing and calling database functions before the database was initialized during plugin setup.

**Fix:** Added nil checks to all database functions that are called by autocmds:

```lua
function M.get_tasks_for_file(file_path)
  if not M.tasks then
    return {}  -- Return empty table instead of crashing
  end
  return M.tasks:where({...}):get()
end

function M.get_children(parent_id)
  if not M.tasks then
    return {}  -- Safe default
  end
  -- ... rest of function
end

function M.add_task(...)
  if not M.tasks then
    vim.notify("Task database not initialized", vim.log.levels.ERROR)
    return nil
  end
  // ... rest of function
end
```

All database functions (`get_task`, `get_children`, `get_all_tasks`, `get_tasks_for_file`, `add_task`, `toggle_completed`, `delete_task`, `update_task`) now check if `M.tasks` exists before attempting to use it.

### Bug #4: Nil Parent ID in WHERE Clause

**Error:**
```
sqlite.lua: sql statement parse, stmt: `select * from tasks where `, err: `(incomplete input)`
```

**Cause:** When adding a task without a parent (top-level task), `parent_id` is `nil`. The code was passing this `nil` directly to the `where()` clause on line 43:

```lua
local max_pos = M.tasks:where({ parent_id = parent_id }):map(...)
```

sqlite.lua doesn't handle `nil` values in WHERE clauses - it needs `vim.NIL` instead.

**Fix:** Convert `nil` to `vim.NIL` before using it in any database queries:

```lua
-- Before
function M.add_task(description, parent_id, ...)
  local max_pos = M.tasks:where({ parent_id = parent_id }):map(...)  -- Error if parent_id is nil
  local task = {
    parent_id = parent_id or vim.NIL,  -- Only converted when storing
    ...
  }
end

-- After
function M.add_task(description, parent_id, ...)
  local query_parent_id = parent_id or vim.NIL  -- Convert upfront
  local max_pos = M.tasks:where({ parent_id = query_parent_id }):map(...)  -- Works!
  local task = {
    parent_id = query_parent_id,  -- Use the converted value
    ...
  }
end
```

**Key Learning:** Always convert `nil` to `vim.NIL` BEFORE using it in sqlite.lua queries, not just when storing.

## Testing

All Lua files have been syntax validated and are error-free:

```
✅ lua/task-decomposer/db.lua
✅ lua/task-decomposer/init.lua
✅ lua/task-decomposer/ui.lua
✅ lua/task-decomposer/virtual_text.lua
✅ plugin/task-decomposer.lua
```

## Next Steps

1. Restart Neovim or reload the plugin: `:Lazy reload task-decomposer.nvim`
2. Test the plugin: `<leader>ta` to add a task
3. View tasks: `<leader>tt` to open tree view

The plugin should now initialize and work correctly without any errors!
