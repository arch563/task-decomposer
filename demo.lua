-- Demo file to test task-decomposer.nvim
-- 
-- Try these steps:
-- 1. Position cursor on a line below
-- 2. Press <leader>ta to add a task
-- 3. Press <leader>tt to view the task tree
-- 4. In the tree, press 'a' to add subtasks
-- 5. Press 'x' to mark tasks as done
-- 6. Press 'g' to jump back to code locations

local M = {}

-- Example function 1
function M.calculate_sum(a, b)
  -- Try adding a task here: <leader>ta "Validate input parameters"
  return a + b
end

-- Example function 2
function M.process_data(data)
  -- Try adding a task: <leader>ta "Add error handling"
  local result = {}
  
  for i, item in ipairs(data) do
    -- Try adding: <leader>ta "Optimize this loop"
    table.insert(result, item * 2)
  end
  
  return result
end

-- Example function 3
function M.connect_to_database(config)
  -- Try adding: <leader>ta "Add connection pooling"
  local conn = nil
  
  -- Try adding: <leader>ta "Add retry logic"
  conn = create_connection(config)
  
  return conn
end

-- Example function 4
function M.save_user(user)
  -- Try adding: <leader>ta "Add input validation"
  
  -- Try adding: <leader>ta "Hash password before saving"
  local hashed_password = user.password
  
  -- Try adding: <leader>ta "Add database transaction"
  db.save({
    name = user.name,
    password = hashed_password
  })
end

return M

-- Workflow to try:
-- 1. Add tasks at various lines using <leader>ta
-- 2. Open task tree with <leader>tt
-- 3. See all your tasks in the tree
-- 4. Select a task and press 'a' to add subtasks
-- 5. Press 'x' to mark tasks as done
-- 6. Press 'g' on a task to jump to its location
-- 7. Press 'd' to delete tasks
-- 8. Press 'r' on a task to set it as root (filter view)
-- 9. Press 'R' to clear the root filter
