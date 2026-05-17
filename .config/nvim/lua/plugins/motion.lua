-- ~/.config/nvim/lua/plugins/motion.lua
-- nvim-spider  — w/e/b CamelCase-aware
-- portal.nvim  — jumplist con anteprima
-- mini.ai      — text object estesi

return {

  -- ---------------------------------------------------------------------------
  -- NVIM-SPIDER — w e b camelCase-aware
  -- ---------------------------------------------------------------------------
  {
    "chrisgrieser/nvim-spider",
    lazy = true,
    keys = {
      -- Sostituisce w e b nativi con versioni CamelCase-aware.
      -- Premi w su "myVariableName" e si ferma a ogni parola.
      { "w",  "<cmd>lua require('spider').motion('w')<CR>",  mode = { "n", "o", "x" }, desc = "Spider w" },
      { "e",  "<cmd>lua require('spider').motion('e')<CR>",  mode = { "n", "o", "x" }, desc = "Spider e" },
      { "b",  "<cmd>lua require('spider').motion('b')<CR>",  mode = { "n", "o", "x" }, desc = "Spider b" },
      { "ge", "<cmd>lua require('spider').motion('ge')<CR>", mode = { "n", "o", "x" }, desc = "Spider ge" },
    },
    opts = {
      skipInsignificantPunctuation = true,   -- salta punteggiatura isolata
      consistentOperatorPending    = false,
      subwordMovement              = true,   -- attiva il movimento per sub-word
      customPatterns               = {},
    },
  },

  -- ---------------------------------------------------------------------------
  -- PORTAL.NVIM — jumplist e changelist con anteprima floating
  -- ---------------------------------------------------------------------------
  {
    "cbochs/portal.nvim",
    dependencies = { "cbochs/grapple.nvim" },   -- opzionale ma consigliato
    keys = {
      { "<leader>pj", "<cmd>Portal jumplist backward<CR>", desc = "Portal jumplist ←" },
      { "<leader>pk", "<cmd>Portal jumplist forward<CR>",  desc = "Portal jumplist →" },
      { "<leader>pc", "<cmd>Portal changelist backward<CR>", desc = "Portal changelist ←" },
    },
    opts = {
      -- Numero massimo di slot mostrati nella finestra portal
      max_results  = 4,
      -- Filtri applicati alla jumplist
      filter       = nil,
      -- Titolo della finestra floating
      window_options = {
        relative  = "cursor",
        width     = 80,
        height    = 8,
        col       = 2,
        style     = "minimal",
        border    = "rounded",
        title     = "Portal",
        title_pos = "center",
        zindex    = 50,
      },
      -- Label usate per selezionare rapidamente un risultato
      labels = { "j", "k", "h", "l" },
    },
  },

  -- ---------------------------------------------------------------------------
  -- MINI.AI — text object estesi
  -- LazyVim lo include già. Qui lo personalizziamo.
  -- ---------------------------------------------------------------------------
  {
    "nvim-mini/mini.ai",
    event = "VeryLazy",
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,   -- cerca il text object in un range più ampio
        custom_textobjects = {
          -- f = funzione (già incluso, lo estendiamo con treesitter)
          F = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
          -- c = classe
          C = ai.gen_spec.treesitter({ a = "@class.outer",    i = "@class.inner" }),
          -- o = blocco (if, for, while, ecc.)
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          -- t = tag HTML/JSX
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
          -- u = qualsiasi coppia di delimitatori
          u = ai.gen_spec.function_call(),
          -- d = digit (numero)
          d = { "%f[%d]%d+" },
          -- Tutto il buffer
          g = function()
            local from = { line = 1, col = 1 }
            local to   = {
              line = vim.fn.line("$"),
              col  = math.max(vim.fn.getline("$"):len(), 1),
            }
            return { from = from, to = to }
          end,
        },
      }
    end,
  },
}
