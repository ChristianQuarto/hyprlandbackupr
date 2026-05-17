-- ~/.config/nvim/lua/plugins/telescope.lua
-- Le keybind NON sono qui — vivono tutte in keymaps.lua per evitare duplicati.

return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.8",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      -- "make" è sufficiente su Linux/macOS; cmake è necessario solo su Windows
      build = "make",
      cond  = function() return vim.fn.executable("make") == 1 end,
    },
    "nvim-telescope/telescope-ui-select.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local actions   = require("telescope.actions")

    telescope.setup({
      defaults = {
        prompt_prefix    = "   ",
        selection_caret  = "  ",
        path_display     = { "truncate" },
        sorting_strategy = "ascending",
        layout_config = {
          horizontal = { prompt_position = "top", preview_width = 0.55 },
          width  = 0.87,
          height = 0.80,
        },
        file_ignore_patterns = {
          "node_modules", "%.git/", "dist/", "build/", "__pycache__", "%.lock",
        },
        mappings = {
          i = {
            ["<C-j>"]   = actions.move_selection_next,
            ["<C-k>"]   = actions.move_selection_previous,
            ["<C-q>"]   = actions.send_selected_to_qflist + actions.open_qflist,
            ["<C-s>"]   = actions.select_horizontal,
            ["<Esc>"]   = actions.close,
          },
          n = { ["q"] = actions.close },
        },
      },
      pickers = {
        find_files  = { hidden = true },
        live_grep   = { additional_args = { "--hidden" } },
        buffers     = { sort_lastused = true, ignore_current_buffer = true },
      },
      extensions = {
        fzf = {
          fuzzy                   = true,
          override_generic_sorter = true,
          override_file_sorter    = true,
          case_mode               = "smart_case",
        },
        ["ui-select"] = {
          require("telescope.themes").get_dropdown(),
        },
      },
    })

    -- pcall evita errori se fzf-native non è ancora compilato
    pcall(telescope.load_extension, "fzf")
    pcall(telescope.load_extension, "ui-select")
  end,
}
