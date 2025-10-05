local M = {}

local sqlite = require("sqlite.db")
local tbl = require("sqlite.tbl")

M.db = nil
M.tasks = nil

function M.setup()
  local db_path = vim.fn.stdpath("data") .. "/task-decomposer.db"
  
  M.db = sqlite({
    uri = db_path,
    opts = {
      keep_open = true,  -- Keep connection open to avoid connection management issues
    },
  })

  M.tasks = tbl("tasks", {
    id = { "integer", primary = true, auto_increment = true },
    parent_id = "integer",
    description = { "text", required = true },
    file_path = "text",
    line_number = "integer",
    column_number = "integer",
    completed = { "integer", default = 0 },
    hidden = { "integer", default = 0 }, -- 0 = visible, 1 = hidden
    created_at = "text",
    position = { "integer", default = 0 },
  })

  -- Bind the table to the database
  M.tasks:set_db(M.db)

  if not M.tasks:exists() then
    M.tasks:create()
  end
end

function M.add_task(description, parent_id, file_path, line_number, column_number)
  if not M.tasks then
    vim.notify("Task database not initialized", vim.log.levels.ERROR)
    return nil
  end
  
  -- Query for siblings based on parent_id to calculate position
  local max_pos
  if parent_id == nil then
    -- For top-level tasks, use custom WHERE clause for NULL comparison
    -- Wrap in double table for numeric key to work with raw SQL
    max_pos = M.tasks:map(function(task)
      return task.position or 0
    end, { where = { { "parent_id IS NULL" } } })
  else
    -- For subtasks, query with specific parent_id
    max_pos = M.tasks:map(function(task)
      return task.position or 0
    end, { where = { parent_id = parent_id } })
  end
  
  local position = 0
  if #max_pos > 0 then
    position = math.max(unpack(max_pos)) + 1
  end

  local task = {
    description = description,
    completed = 0,
    created_at = os.date("%Y-%m-%d %H:%M:%S"),
    position = position,
  }
  
  -- Only include optional fields if they have values
  if parent_id then
    task.parent_id = parent_id
  end
  if file_path then
    task.file_path = file_path
  end
  if line_number then
    task.line_number = line_number
  end
  if column_number then
    task.column_number = column_number
  end
  
  M.tasks:insert(task)
  -- Get the most recently inserted task with this description
  local result = M.tasks:get({ where = { description = description }, order_by = { desc = "id" }, limit = 1 })
  return result[1]
end

function M.get_task(id)
  if not M.tasks then
    return nil
  end
  return M.tasks:where({ id = id })
end

function M.get_children(parent_id)
  if not M.tasks then
    return {}
  end
  if parent_id == nil then
    -- Use custom WHERE clause for NULL comparison
    -- Wrap in double table for numeric key to work with raw SQL
    return M.tasks:get({ where = { { "parent_id IS NULL" } }, order_by = { asc = "position" } })
  else
    return M.tasks:get({ where = { parent_id = parent_id }, order_by = { asc = "position" } })
  end
end

function M.get_all_tasks()
  if not M.tasks then
    return {}
  end
  return M.tasks:get()
end

function M.toggle_completed(id)
  if not M.tasks then
    return nil
  end
  local task = M.get_task(id)
  if task then
    local new_status = task.completed == 1 and 0 or 1
    M.tasks:update({
      where = { id = id },
      set = { completed = new_status },
    })
    return new_status
  end
end

function M.delete_task(id)
  if not M.tasks then
    return
  end
  local children = M.get_children(id)
  for _, child in ipairs(children) do
    M.delete_task(child.id)
  end
  M.tasks:remove({ id = id })
end

function M.update_task(id, updates)
  if not M.tasks then
    return
  end
  M.tasks:update({
    where = { id = id },
    set = updates,
  })
end

function M.get_tasks_for_file(file_path)
  if not M.tasks then
    return {}
  end
  return M.tasks:get({
    where = {
      file_path = file_path,
      completed = 0,
      hidden = 0, -- Only show non-hidden tasks
    }
  })
end

function M.toggle_hidden(id)
  if not M.tasks then
    return nil
  end
  local task = M.get_task(id)
  if task then
    local new_status = task.hidden == 1 and 0 or 1
    M.tasks:update({
      where = { id = id },
      set = { hidden = new_status },
    })
    return new_status
  end
end

return M
