-- Shared state across task-decomposer modules
local M = {}

-- Current root task ID (nil means show all tasks)
M.current_root = nil

-- Get the current root task ID
function M.get_root()
  return M.current_root
end

-- Set the current root task ID
function M.set_root(task_id)
  M.current_root = task_id
end

-- Clear the root (show all tasks)
function M.clear_root()
  M.current_root = nil
end

return M
