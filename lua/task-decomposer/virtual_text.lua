local M = {}

local db = require("task-decomposer.db")
local state = require("task-decomposer.state")
local api = vim.api

M.ns_id = api.nvim_create_namespace("task_decomposer")
M.active_buffers = {}

function M.setup()
  local group = api.nvim_create_augroup("TaskDecomposer", { clear = true })
  
  api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
    group = group,
    callback = function(args)
      M.update_buffer(args.buf)
    end,
  })
  
  api.nvim_create_autocmd("BufUnload", {
    group = group,
    callback = function(args)
      M.clear_buffer(args.buf)
    end,
  })
end

function M.update_buffer(bufnr)
  bufnr = bufnr or api.nvim_get_current_buf()
  
  if not api.nvim_buf_is_valid(bufnr) then
    return
  end
  
  local file_path = api.nvim_buf_get_name(bufnr)
  if file_path == "" or file_path == "Task Decomposer" then
    return
  end
  
  M.clear_buffer(bufnr)
  
  -- Get ALL tasks for file (including completed, but not hidden)
  local all_tasks = db.get_all_tasks()
  local tasks = {}
  for _, task in ipairs(all_tasks) do
    if task.file_path == file_path and task.hidden == 0 then
      table.insert(tasks, task)
    end
  end
  
  for _, task in ipairs(tasks) do
    if task.line_number and task.line_number ~= vim.NIL then
      local line_idx = task.line_number - 1
      local line_count = api.nvim_buf_line_count(bufnr)
      
      if line_idx >= 0 and line_idx < line_count then
        -- Get task index from UI - build indices if needed
        local ui = require("task-decomposer.ui")
        ui.build_task_indices() -- Ensure indices are built
        local task_index = ui.get_task_index(task.id) or "?"
        
        -- Create virtual text with status icon and description
        local status_icon = task.completed == 1 and "✓" or "○"
        local virt_text = string.format("%s %s", status_icon, task.description)
        local hl_group = task.completed == 1 and "TaskCompleted" or "TaskPending"
        
        -- Create diagnostic-style hint with task number
        local hint_text = string.format("[%s]", task_index)
        
        api.nvim_buf_set_extmark(bufnr, M.ns_id, line_idx, 0, {
          virt_text = {
            { virt_text, hl_group },
            { " ", "Normal" },
            { hint_text, "TaskHint" }
          },
          virt_text_pos = "eol",
          hl_mode = "combine",
          id = task.id, -- Use task ID as extmark ID for easy lookup
        })
      end
    end
  end
  
  M.active_buffers[bufnr] = true
end

function M.clear_buffer(bufnr)
  if api.nvim_buf_is_valid(bufnr) then
    api.nvim_buf_clear_namespace(bufnr, M.ns_id, 0, -1)
  end
  M.active_buffers[bufnr] = nil
end

function M.refresh_all()
  for bufnr, _ in pairs(M.active_buffers) do
    M.update_buffer(bufnr)
  end
  
  for _, bufnr in ipairs(api.nvim_list_bufs()) do
    if api.nvim_buf_is_loaded(bufnr) then
      M.update_buffer(bufnr)
    end
  end
end

function M.add_task_at_cursor()
  local bufnr = api.nvim_get_current_buf()
  local file_path = api.nvim_buf_get_name(bufnr)
  
  if file_path == "" then
    vim.notify("Cannot add task to unnamed buffer", vim.log.levels.WARN)
    return
  end
  
  local cursor = api.nvim_win_get_cursor(0)
  local line_number = cursor[1]
  local column_number = cursor[2]
  
  -- Get the active task from shared state (where new tasks will be added as subtasks)
  local parent_id = state.get_active()
  
  -- Build prompt message
  local prompt = "Task description: "
  if parent_id then
    local active_task = db.get_task(parent_id)
    if active_task then
      prompt = string.format("Task (under '%s'): ", active_task.description)
    end
  end
  
  -- Use Snacks.input directly if available, otherwise fall back to vim.ui.input
  local has_snacks, snacks = pcall(require, "snacks")
  if has_snacks and snacks.input then
    snacks.input({
      prompt = prompt,
      win = {
        relative = "cursor",
        row = -3,
        col = 0,
      }
    }, function(description)
      if description and description ~= "" then
        db.add_task(description, parent_id, file_path, line_number, column_number)
        M.update_buffer(bufnr)
        
        -- Update UI if open
        local ui = require("task-decomposer.ui")
        if ui.win and api.nvim_win_is_valid(ui.win) then
          ui.render()
        end
        
        vim.notify("Task added", vim.log.levels.INFO)
      end
    end)
  else
    vim.ui.input({ prompt = prompt }, function(description)
      if description and description ~= "" then
        db.add_task(description, parent_id, file_path, line_number, column_number)
        M.update_buffer(bufnr)
        
        -- Update UI if open
        local ui = require("task-decomposer.ui")
        if ui.win and api.nvim_win_is_valid(ui.win) then
          ui.render()
        end
        
        vim.notify("Task added", vim.log.levels.INFO)
      end
    end)
  end
end

-- Toggle task completion at cursor line
function M.toggle_task_at_cursor()
  local bufnr = api.nvim_get_current_buf()
  local file_path = api.nvim_buf_get_name(bufnr)
  
  if file_path == "" then
    vim.notify("No file path for buffer", vim.log.levels.WARN)
    return
  end
  
  local cursor = api.nvim_win_get_cursor(0)
  local line_number = cursor[1]
  
  -- Get ALL tasks for current file (including completed ones)
  local all_tasks = db.get_all_tasks()
  local tasks = {}
  for _, task in ipairs(all_tasks) do
    if task.file_path == file_path and task.hidden == 0 then
      table.insert(tasks, task)
    end
  end
  
  -- Find task at current line
  local task_at_line = nil
  for _, task in ipairs(tasks) do
    if task.line_number == line_number then
      task_at_line = task
      break
    end
  end
  
  if task_at_line then
    db.toggle_completed(task_at_line.id)
    M.update_buffer(bufnr)
    
    -- Update UI if open
    local ui = require("task-decomposer.ui")
    if ui.win and api.nvim_win_is_valid(ui.win) then
      ui.render()
    end
    
    local status = task_at_line.completed == 1 and "undone" or "done"
    vim.notify(string.format("Task marked as %s", status), vim.log.levels.INFO)
  else
    vim.notify("No task found at cursor line", vim.log.levels.WARN)
  end
end

-- Sign off (complete) all pending tasks in current file
-- Changed: No longer deletes tasks, just marks as completed
function M.sign_off_completed_tasks()
  local bufnr = api.nvim_get_current_buf()
  local file_path = api.nvim_buf_get_name(bufnr)
  
  if file_path == "" then
    vim.notify("No file path for buffer", vim.log.levels.WARN)
    return
  end
  
  -- Get all tasks (not just pending)
  local all_tasks = db.get_all_tasks()
  local file_tasks = {}
  for _, task in ipairs(all_tasks) do
    if task.file_path == file_path and task.completed == 0 then
      table.insert(file_tasks, task)
    end
  end
  
  if #file_tasks > 0 then
    for _, task in ipairs(file_tasks) do
      db.toggle_completed(task.id) -- Mark as completed
    end
    
    M.update_buffer(bufnr)
    
    -- Update UI if open
    local ui = require("task-decomposer.ui")
    if ui.win and api.nvim_win_is_valid(ui.win) then
      ui.render()
    end
    
    vim.notify(string.format("Signed off %d task(s) - now showing as completed", #file_tasks), vim.log.levels.INFO)
  else
    vim.notify("No pending tasks to sign off", vim.log.levels.INFO)
  end
end

return M
