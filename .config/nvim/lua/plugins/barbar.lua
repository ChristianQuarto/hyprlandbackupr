-- ~/.config/nvim/lua/plugins/barbar.lua
-- Barra dei buffer con icone, riordinabili e indicatori git
return {
  "romgrk/barbar.nvim",
  dependencies = {
    "lewis6991/gitsigns.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  version = "^1.0.0",
  opts = {
    animation = true,
    auto_hide = false,
    tabpages = true,
    icons = {
      button = "",
      modified = { button = "●" },
      pinned = { button = "車" },
      separator = { left = "▎" },
      filetype = { enabled = true },
    },
    sidebar_filetypes = {
      ["neo-tree"] = { event = "BufWipeout" },
    },
  },
  keys = {
    -- Navigazione
    { "<A-1>", "<Cmd>BufferGoto 1<CR>" },
    { "<A-2>", "<Cmd>BufferGoto 2<CR>" },
    { "<A-3>", "<Cmd>BufferGoto 3<CR>" },
    { "<A-4>", "<Cmd>BufferGoto 4<CR>" },
    { "<A-5>", "<Cmd>BufferGoto 5<CR>" },
    { "<A-6>", "<Cmd>BufferGoto 6<CR>" },
    { "<A-7>", "<Cmd>BufferGoto 7<CR>" },
    { "<A-8>", "<Cmd>BufferGoto 8<CR>" },
    { "<A-9>", "<Cmd>BufferGoto 9<CR>" },
    { "<A-0>", "<Cmd>BufferLast<CR>" },

    -- Spostamento buffer
    { "<A-l>", "<Cmd>BufferMoveNext<CR>" },
    { "<A-h>", "<Cmd>BufferMovePrevious<CR>" },

    -- Chiusura
    { "<A-c>", "<Cmd>BufferClose<CR>" },

    -- BufferPick mode
    { "<A-p>", "<Cmd>BufferPick<CR>" },
  },
}
