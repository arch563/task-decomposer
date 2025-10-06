-- Shared state across task-decomposer modules
local M = {}

-- Current root task ID for filtering tree view (nil means show all tasks)
M.current_root = nil

-- Active task ID for adding new subtasks (nil means add to root level)
M.active_task = nil

-- Get the current root task ID (for filtering tree view)
function M.get_root()
  return M.current_root
end

-- Set the current root task ID (for filtering tree view)
function M.set_root(task_id)
  M.current_root = task_id
end

-- Clear the root (show all tasks)
function M.clear_root()
  M.current_root = nil
end

-- Get the active task ID (where new tasks will be added as subtasks)
function M.get_active()
  return M.active_task
end

-- Set the active task ID (where new tasks will be added as subtasks)
function M.set_active(task_id)
  M.active_task = task_id
end

-- Clear the active task (new tasks go to root level)
function M.clear_active()
  M.active_task = nil
end

return M
