local M = {}

M.config = {
	keymaps = {
		toggle_tree = "gtt",
		-- Use 'gt' prefix for task operations (mnemonic: "go task")
		add_task = "gta", -- gt + add
		toggle_task = "gtx", -- gt + toggle/cross-off
		sign_off_tasks = "gts", -- gt + sign-off
		tree_expand = "<CR>",
		tree_toggle_done = "x",
		tree_delete = "d",
		tree_add_subtask = "a",
		tree_set_root = "r",
		tree_clear_root = "u",
		tree_jump = "g",
		tree_close = "q",
	},
	ui = {
		width = 0.25, -- Sidebar width as percentage
		position = "right", -- "left" or "right"
		border = "rounded",
	},
	highlights = {
		task_pending = "TaskPending", -- For incomplete tasks
		task_completed = "TaskCompleted", -- For completed tasks
		task_hint = "TaskHint", -- For task number hints
	},
}

function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})

	-- Setup highlight groups
	M.setup_highlights()

	local db = require("task-decomposer.db")
	local ui = require("task-decomposer.ui")
	local vtext = require("task-decomposer.virtual_text")
	local state = require("task-decomposer.state")

	db.setup()
	vtext.setup()

	local km = M.config.keymaps

	-- Tree keymaps
	vim.keymap.set("n", km.toggle_tree, ui.toggle, { desc = "Toggle task tree" })

	-- Task management keymaps (work outside tree)
	vim.keymap.set("n", km.add_task, vtext.add_task_at_cursor, { desc = "Add task at cursor" })
	vim.keymap.set("n", km.toggle_task, vtext.toggle_task_at_cursor, { desc = "Toggle task at cursor" })
	vim.keymap.set("n", km.sign_off_tasks, vtext.sign_off_completed_tasks, { desc = "Sign off completed tasks" })

	-- Commands
	vim.api.nvim_create_user_command("TaskToggle", ui.toggle, { desc = "Toggle task tree sidebar" })
	vim.api.nvim_create_user_command("TaskAdd", vtext.add_task_at_cursor, { desc = "Add task at cursor" })
	vim.api.nvim_create_user_command(
		"TaskDone",
		vtext.toggle_task_at_cursor,
		{ desc = "Toggle task completion at cursor" }
	)
	vim.api.nvim_create_user_command(
		"TaskSignOff",
		vtext.sign_off_completed_tasks,
		{ desc = "Sign off completed tasks in file" }
	)
	vim.api.nvim_create_user_command("TaskRefresh", vtext.refresh_all, { desc = "Refresh all task displays" })

	-- Root management commands
	vim.api.nvim_create_user_command("TaskSetRoot", function(opts)
		-- Set root by task description search
		local query = opts.args
		if query and query ~= "" then
			local all_tasks = db.get_all_tasks()
			for _, task in ipairs(all_tasks) do
				if task.description:lower():find(query:lower(), 1, true) then
					state.set_root(task.id)
					vim.notify("Root set to: " .. task.description, vim.log.levels.INFO)
					if ui.win and vim.api.nvim_win_is_valid(ui.win) then
						ui.render()
					end
					return
				end
			end
			vim.notify("No task found matching: " .. query, vim.log.levels.WARN)
		end
	end, { nargs = 1, desc = "Set root task by description" })

	vim.api.nvim_create_user_command("TaskClearRoot", function()
		state.clear_root()
		vim.notify("Root cleared, showing all tasks", vim.log.levels.INFO)
		if ui.win and vim.api.nvim_win_is_valid(ui.win) then
			ui.render()
		end
	end, { desc = "Clear root task" })

	vim.api.nvim_create_user_command("TaskShowRoot", function()
		local root_id = state.get_root()
		if root_id then
			local root_task = db.get_task(root_id)
			if root_task then
				vim.notify(string.format("Current root: [%s] %s", root_id, root_task.description), vim.log.levels.INFO)
			else
				vim.notify("Root task not found (may have been deleted)", vim.log.levels.WARN)
				state.clear_root()
			end
		else
			vim.notify("No root set (showing all tasks)", vim.log.levels.INFO)
		end
	end, { desc = "Show current root task" })
end

-- Setup custom highlight groups
function M.setup_highlights()
	local highlights = {
		-- Pending task - translucent blue
		TaskPending = { fg = "#7aa2f7", bg = "NONE", blend = 30 },
		-- Completed task - translucent gray/green
		TaskCompleted = { fg = "#9ece6a", bg = "NONE", blend = 50 },
		-- Task hint number - subtle and dimmed
		TaskHint = { fg = "#565f89", bg = "NONE", italic = true },
	}

	for group, opts in pairs(highlights) do
		vim.api.nvim_set_hl(0, group, opts)
	end
end

return M
