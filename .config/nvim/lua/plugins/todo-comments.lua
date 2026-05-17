-- ~/.config/nvim/lua/plugins/todo-comments.lua
-- todo-comments.nvim — evidenzia e naviga tra TODO, FIXME, HACK, ecc.
-- LazyVim lo include già. Questo file aggiunge keyword, colori e keybind.

return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = "BufReadPost",
  opts = {
    signs      = true,   -- icona nel gutter
    sign_priority = 8,
    keywords = {
      FIX  = { icon = " ", color = "error",   alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
      TODO = { icon = " ", color = "info" },
      HACK = { icon = " ", color = "warning", alt = { "XXX" } },
      WARN = { icon = " ", color = "warning", alt = { "WARNING", "ATTENTION" } },
      PERF = { icon = " ", color = "hint",    alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
      NOTE = { icon = " ", color = "hint",    alt = { "INFO", "IDEA" } },
      TEST = { icon = "⏲ ", color = "test",   alt = { "TESTING", "PASSED", "FAILED" } },
      -- Keyword personalizzate
      REVIEW = { icon = " ", color = "warning" },
      SAFETY = { icon = " ", color = "error" },
    },
    -- Colori (usa i gruppi highlight o hex diretti)
    colors = {
      error   = { "DiagnosticError",   "ErrorMsg",   "#DC2626" },
      warning = { "DiagnosticWarn",    "WarningMsg", "#FBBF24" },
      info    = { "DiagnosticInfo",               "#2563EB" },
      hint    = { "DiagnosticHint",               "#10B981" },
      test    = { "Identifier",                   "#FF006E" },
    },
    -- Evidenzia solo la keyword, non l'intera riga
    highlight = {
      multiline         = true,   -- gestisce commenti su più righe
      multiline_pattern = "^.",
      multiline_context = 10,
      before            = "",     -- nessun highlight prima della keyword
      keyword           = "wide", -- "fg" | "bg" | "wide" | "wide_bg"
      after             = "fg",   -- colora il testo dopo la keyword
      pattern           = [[.*<(KEYWORDS)\s*:]],
      comments_only     = true,   -- solo nei commenti, non nel codice
      max_line_len      = 400,
      exclude           = { "help" },
    },
    search = {
      command = "rg",
      args    = {
        "--color=never", "--no-heading", "--with-filename",
        "--line-number",  "--column",
      },
      pattern = [[\b(KEYWORDS):]],
    },
  },
  keys = {
    -- Naviga tra i todo nel buffer
    { "]t", function() require("todo-comments").jump_next() end, desc = "Todo successivo" },
    { "[t", function() require("todo-comments").jump_prev() end, desc = "Todo precedente" },
    -- Lista todos con Telescope
    { "<leader>ft", "<cmd>TodoTelescope<cr>",                    desc = "Todo (telescope)" },
    -- Lista todos con Trouble (se installato)
    { "<leader>xt", "<cmd>Trouble todo toggle<cr>",              desc = "Todo (trouble)" },
    -- Solo TODO e FIXME in Trouble
    { "<leader>xT", "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>", desc = "Todo/Fix (trouble)" },
  },
}
