-- Example lazy.nvim configuration for task-decomposer.nvim

return {
  {
    dir = "~/workspace/task-decomposer.nvim",  -- Adjust this path to where you cloned the plugin
    dependencies = {
      "kkharji/sqlite.lua",
    },
    config = function()
      require("task-decomposer").setup({
        -- Optional configuration
        keymaps = {
          toggle_tree = "<leader>tt",      -- Toggle task tree
          add_task = "<leader>ta",         -- Add task at cursor
        },
        ui = {
          width = 0.4,   -- 40% of screen width
          height = 0.8,  -- 80% of screen height
          border = "rounded",
        },
      })
    end,
    keys = {
      { "<leader>tt", desc = "Toggle task tree" },
      { "<leader>ta", desc = "Add task at cursor" },
    },
  },
}
