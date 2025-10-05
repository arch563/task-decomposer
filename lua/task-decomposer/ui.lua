local M = {}

local db = require("task-decomposer.db")
local state = require("task-decomposer.state")
local api = vim.api

M.buf = nil
M.win = nil
M.ns_id = nil
M.expanded = {}
M.task_indices = {} -- Store task indices for display

local function create_buffer()
  M.buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(M.buf, "buftype", "nofile")
  api.nvim_buf_set_option(M.buf, "bufhidden", "wipe")
  api.nvim_buf_set_option(M.buf, "swapfile", false)
  api.nvim_buf_set_option(M.buf, "filetype", "task-decomposer")
  api.nvim_buf_set_name(M.buf, "Task Decomposer")
  return M.buf
end

local function get_icon(task, has_children)
  if has_children then
    if M.expanded[task.id] then
      return "▼"
    else
      return "▶"
    end
  end
  if task.completed == 1 then
    return "✓"
  else
    return "○"
  end
end

-- Calculate completion stats for a task's direct children only
local function get_completion_stats(task_id)
  local children = db.get_children(task_id)
  if #children == 0 then
    return { total = 0, completed = 0, percentage = 0 }
  end
  
  local total = #children
  local completed = 0
  
  for _, child in ipairs(children) do
    if child.completed == 1 then
      completed = completed + 1
    end
  end
  
  local percentage = total > 0 and (completed / total * 100) or 0
  return { total = total, completed = completed, percentage = percentage }
end

-- Get progress indicator blocks - one block per subtask
local function get_progress_blocks(stats)
  if stats.total == 0 then
    return "", {}
  end
  
  local blocks = {}
  local block_hls = {}
  
  for i = 1, stats.total do
    if i <= stats.completed then
      -- Completed subtask - checked box
      table.insert(blocks, "✓")
      table.insert(block_hls, "TaskProgressComplete")
    else
      -- Incomplete subtask - empty box
      table.insert(blocks, "○")
      table.insert(block_hls, "TaskProgressIncomplete")
    end
  end
  
  return table.concat(blocks, ""), block_hls
end

-- Build hierarchical index (e.g., 1.2.3)
local function build_task_index(parent_index, child_position)
  if parent_index == "" then
    return tostring(child_position)
  else
    return parent_index .. "." .. tostring(child_position)
  end
end

local function render_tree(lines, task_map, indent, parent_id, parent_index, highlights)
  local children = db.get_children(parent_id)
  
  for i, task in ipairs(children) do
    local has_children = #db.get_children(task.id) > 0
    local icon = get_icon(task, has_children)
    
    -- Build hierarchical index
    local task_index = build_task_index(parent_index, i)
    M.task_indices[task.id] = task_index
    
    -- Build pipe characters for tree visualization
    local pipe_chars = ""
    if indent > 0 then
      pipe_chars = string.rep("│ ", indent - 1)
      if i == #children then
        pipe_chars = pipe_chars .. "└─"
      else
        pipe_chars = pipe_chars .. "├─"
      end
    end
    
    local hidden_indicator = task.hidden == 1 and "👁️ " or "" -- Eye icon for hidden
    
    -- Add progress blocks for tasks with children
    local progress_blocks = ""
    local block_hls = {}
    local stats = nil
    if has_children then
      stats = get_completion_stats(task.id)
      progress_blocks, block_hls = get_progress_blocks(stats)
      if progress_blocks ~= "" then
        progress_blocks = progress_blocks .. " "
      end
    end
    
    local location = ""
    if task.file_path and task.file_path ~= vim.NIL then
      local filename = vim.fn.fnamemodify(task.file_path, ":t")
      location = string.format(" @%s:%d", filename, task.line_number or 0)
    end
    
    -- Format: [index] progress_blocks pipe_chars icon description location
    local index_display = string.format("[%s] ", task_index)
    local line = string.format("%s%s%s%s %s%s", 
      index_display, progress_blocks, pipe_chars, icon, hidden_indicator, task.description .. location)
    
    table.insert(lines, line)
    task_map[#lines] = task
    
    -- Store highlight info for each progress block
    if progress_blocks ~= "" and #block_hls > 0 and stats then
      -- Calculate byte offsets for each checkbox character
      local byte_offset = #index_display
      
      for j, hl_group in ipairs(block_hls) do
        -- Each checkbox character (✓ or ○) is 3 bytes in UTF-8
        local char = j <= stats.completed and "✓" or "○"
        local char_byte_len = #char
        
        local byte_start = byte_offset
        local byte_end = byte_offset + char_byte_len
        
        table.insert(highlights, {
          line = #lines - 1, -- 0-indexed
          col_start = byte_start,
          col_end = byte_end,
          hl_group = hl_group
        })
        
        byte_offset = byte_offset + char_byte_len
      end
    end
    
    -- Highlight the main task status icon (○ or ✓)
    -- Find the position of the icon in the line
    local icon_offset = #index_display + #progress_blocks + #pipe_chars
    local icon_byte_len = #icon
    local icon_hl = task.completed == 1 and "TaskProgressComplete" or "TaskProgressIncomplete"
    
    table.insert(highlights, {
      line = #lines - 1, -- 0-indexed
      col_start = icon_offset,
      col_end = icon_offset + icon_byte_len,
      hl_group = icon_hl
    })
    
    if has_children and M.expanded[task.id] then
      render_tree(lines, task_map, indent + 1, task.id, task_index, highlights)
    end
  end
end

-- Build task indices without rendering (for virtual text)
function M.build_task_indices()
  M.task_indices = {}
  
  local function build_indices(parent_id, parent_index)
    local children = db.get_children(parent_id)
    for i, task in ipairs(children) do
      local task_index = build_task_index(parent_index, i)
      M.task_indices[task.id] = task_index
      local has_children = #db.get_children(task.id) > 0
      if has_children then
        build_indices(task.id, task_index)
      end
    end
  end
  
  build_indices(nil, "")
end

function M.render()
  if not M.buf or not api.nvim_buf_is_valid(M.buf) then
    return
  end

  api.nvim_buf_set_option(M.buf, "modifiable", true)
  
  local lines = {}
  local task_map = {}
  local highlights = {} -- Track highlights to apply
  M.task_indices = {}
  
  local current_root = state.get_root()
  
  if current_root then
    local root_task = db.get_task(current_root)
    if root_task then
      lines[1] = "╔═══ Root: " .. root_task.description .. " ═══╗"
      lines[2] = ""
      task_map[1] = root_task
      render_tree(lines, task_map, 0, current_root, "", highlights)
    end
  else
    lines[1] = "╔═══ All Tasks ═══╗"
    lines[2] = ""
    render_tree(lines, task_map, 0, nil, "", highlights)
  end
  
  -- Add help text at bottom
  table.insert(lines, "")
  table.insert(lines, "─────────────────────────────────")
  table.insert(lines, "Press ? for help")
  
  api.nvim_buf_set_lines(M.buf, 0, -1, false, lines)
  api.nvim_buf_set_option(M.buf, "modifiable", false)
  
  -- Apply highlights for progress indicators
  if not M.ns_id then
    M.ns_id = api.nvim_create_namespace("task_decomposer_ui")
  end
  api.nvim_buf_clear_namespace(M.buf, M.ns_id, 0, -1)
  
  for _, hl in ipairs(highlights) do
    api.nvim_buf_add_highlight(M.buf, M.ns_id, hl.hl_group, hl.line, hl.col_start, hl.col_end)
  end
  
  M.task_map = task_map
end

function M.open()
  if M.win and api.nvim_win_is_valid(M.win) then
    api.nvim_set_current_win(M.win)
    return
  end

  if not M.buf or not api.nvim_buf_is_valid(M.buf) then
    create_buffer()
  end

  -- Create a proper vertical split instead of floating window
  local width = math.floor(vim.o.columns * 0.25) -- 25% of screen width
  
  -- Create split on the right
  vim.cmd("botright vsplit")
  M.win = api.nvim_get_current_win()
  
  -- Set the buffer in the window
  api.nvim_win_set_buf(M.win, M.buf)
  
  -- Set the width
  api.nvim_win_set_width(M.win, width)
  
  -- Set window options
  api.nvim_win_set_option(M.win, "wrap", false)
  api.nvim_win_set_option(M.win, "cursorline", true)
  api.nvim_win_set_option(M.win, "number", false)
  api.nvim_win_set_option(M.win, "relativenumber", false)
  api.nvim_win_set_option(M.win, "winfixwidth", true) -- Keep width fixed

  M.setup_keymaps()
  M.render()
end

function M.close()
  if M.win and api.nvim_win_is_valid(M.win) then
    api.nvim_win_close(M.win, true)
    M.win = nil
  end
end

function M.toggle()
  if M.win and api.nvim_win_is_valid(M.win) then
    M.close()
  else
    M.open()
  end
end

function M.get_current_task()
  local line = api.nvim_win_get_cursor(M.win)[1]
  return M.task_map and M.task_map[line]
end

function M.toggle_expand()
  local task = M.get_current_task()
  if not task then return end
  
  local has_children = #db.get_children(task.id) > 0
  if has_children then
    M.expanded[task.id] = not M.expanded[task.id]
    M.render()
  end
end

function M.toggle_done()
  local task = M.get_current_task()
  if not task then return end
  
  db.toggle_completed(task.id)
  M.render()
  require("task-decomposer.virtual_text").refresh_all()
end

function M.toggle_hidden()
  local task = M.get_current_task()
  if not task then return end
  
  local new_status = db.toggle_hidden(task.id)
  M.render()
  require("task-decomposer.virtual_text").refresh_all()
  
  local status_text = new_status == 1 and "hidden" or "visible"
  vim.notify(string.format("Task marked as %s", status_text), vim.log.levels.INFO)
end

function M.delete_current()
  local task = M.get_current_task()
  if not task then return end
  
  local confirm = vim.fn.confirm(
    string.format("Delete '%s' and all subtasks?", task.description),
    "&Yes\n&No",
    2
  )
  
  if confirm == 1 then
    db.delete_task(task.id)
    M.render()
    require("task-decomposer.virtual_text").refresh_all()
  end
end

function M.add_task_ui()
  local task = M.get_current_task()
  local parent_id = task and task.id or state.get_root()
  
  -- Use Snacks.input directly if available, otherwise fall back to vim.ui.input
  local has_snacks, snacks = pcall(require, "snacks")
  if has_snacks and snacks.input then
    snacks.input({
      prompt = "Task description: ",
      win = {
        relative = "cursor",
        row = -3,
        col = 0,
      }
    }, function(description)
      if description and description ~= "" then
        db.add_task(description, parent_id)
        M.render()
      end
    end)
  else
    vim.ui.input({ prompt = "Task description: " }, function(description)
      if description and description ~= "" then
        db.add_task(description, parent_id)
        M.render()
      end
    end)
  end
end

function M.set_root()
  local task = M.get_current_task()
  if task then
    state.set_root(task.id)
    M.expanded = {}
    M.render()
    vim.notify("Root set to: " .. task.description, vim.log.levels.INFO)
  end
end

function M.clear_root()
  state.clear_root()
  M.expanded = {}
  M.render()
  vim.notify("Root cleared, showing all tasks", vim.log.levels.INFO)
end

function M.jump_to_task()
  local task = M.get_current_task()
  if not task or not task.file_path or task.file_path == vim.NIL then
    vim.notify("Task has no file location", vim.log.levels.WARN)
    return
  end
  
  M.close()
  
  vim.cmd("edit " .. vim.fn.fnameescape(task.file_path))
  
  if task.line_number and task.line_number ~= vim.NIL then
    api.nvim_win_set_cursor(0, { task.line_number, task.column_number or 0 })
  end
end

function M.show_help()
  local help_lines = {
    "╔═══ Task Decomposer Help ═══╗",
    "",
    "Navigation:",
    "  <CR>/o    - Expand/collapse task",
    "  j/k       - Move up/down",
    "  <C-w>hjkl - Navigate windows (tree is a window)",
    "",
    "Actions:",
    "  a         - Add subtask to current task",
    "  x         - Toggle task done/undone",
    "  h         - Toggle hide/show task",
    "  d         - Delete task and subtasks",
    "  g         - Jump to task location",
    "",
    "View:",
    "  r         - Set current task as root",
    "  u         - Clear root (show all)",
    "  q/<ESC>   - Close sidebar",
    "  ?         - Show this help",
    "",
    "Task Format:",
    "  [1.2.3] - Hierarchical index",
    "  ├─ └─   - Tree structure",
    "  [✓]/[ ] - Completion status",
    "  👁️      - Hidden task indicator",
    "  @file:line - File location",
    "",
    "Press any key to close...",
  }
  
  local help_buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(help_buf, 0, -1, false, help_lines)
  api.nvim_buf_set_option(help_buf, "modifiable", false)
  
  local help_win = api.nvim_open_win(help_buf, true, {
    relative = "editor",
    width = 50,
    height = #help_lines,
    row = math.floor((vim.o.lines - #help_lines) / 2),
    col = math.floor((vim.o.columns - 50) / 2),
    style = "minimal",
    border = "rounded",
  })
  
  vim.keymap.set("n", "<CR>", function()
    api.nvim_win_close(help_win, true)
  end, { buffer = help_buf, noremap = true, silent = true })
  
  vim.keymap.set("n", "q", function()
    api.nvim_win_close(help_win, true)
  end, { buffer = help_buf, noremap = true, silent = true })
end

function M.setup_keymaps()
  local opts = { noremap = true, silent = true, buffer = M.buf }
  
  vim.keymap.set("n", "q", M.close, opts)
  vim.keymap.set("n", "<ESC>", M.close, opts)
  vim.keymap.set("n", "<CR>", M.toggle_expand, opts)
  vim.keymap.set("n", "o", M.toggle_expand, opts)
  vim.keymap.set("n", "x", M.toggle_done, opts)
  vim.keymap.set("n", "h", M.toggle_hidden, opts) -- Toggle hide/show
  vim.keymap.set("n", "d", M.delete_current, opts)
  vim.keymap.set("n", "a", M.add_task_ui, opts)
  vim.keymap.set("n", "r", M.set_root, opts)
  vim.keymap.set("n", "u", M.clear_root, opts) -- 'u' for clear root (disables undo)
  vim.keymap.set("n", "g", M.jump_to_task, opts)
  vim.keymap.set("n", "<C-g>", M.jump_to_task, opts)
  vim.keymap.set("n", "?", M.show_help, opts)
end

-- Get task index for a task ID
function M.get_task_index(task_id)
  return M.task_indices[task_id]
end

return M
