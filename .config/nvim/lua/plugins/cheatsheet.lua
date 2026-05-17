-- ~/.config/nvim/lua/plugins/cheatsheet.lua
return {
  "sudormrfbin/cheatsheet.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/popup.nvim",
    "nvim-lua/plenary.nvim",
  },
  keys = {
    { "<leader>?", "<cmd>Cheatsheet<cr>", desc = "Open cheatsheet" },
    { "<leader>w?", "<cmd>Telescope cheatsheet<cr>", desc = "Search cheatsheet with Telescope" },
  },
  opts = {
    -- Categorie da includere
    bundled_cheatsheets = {
      -- Cheatsheet predefinite
      "default", -- Movimenti base
      "builtin", -- Comandi built-in
      "telescope", -- Telescope keymaps
      "nerd-fonts", -- Icone Nerd Font
      "lsp", -- LSP keymaps
      "git", -- Git keymaps
      "markdown", -- Markdown keymaps
    },
    -- Cheatsheet personalizzate
    custom_cheatsheets = {
      {
        type = "keymap",
        name = "Custom",
        keymaps = {
          { desc = "Trova file", lhs = "<leader>ff", rhs = ":Telescope find_files<CR>" },
          { desc = "File explorer", lhs = "<leader>e", rhs = ":Neotree toggle<CR>" },
          { desc = "Buffer pick", lhs = "<A-p>", rhs = ":BufferPick<CR>" },
        },
      },
    },
    -- Mappature extra
    extra_keymaps = {
      { desc = "Toggle terminal", lhs = "<C-\\>", rhs = ":ToggleTerm<CR>" },
    },
  },
}
