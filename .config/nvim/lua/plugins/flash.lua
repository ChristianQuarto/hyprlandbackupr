-- ~/.config/nvim/lua/plugins/flash.lua
-- flash.nvim — navigazione a salti nel buffer e tra finestre
-- LazyVim lo include già, questo file personalizza keybind e comportamento.

return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {
    -- Modalità di ricerca
    search = {
      -- Cerca in tutte le finestre visibili
      multi_window = true,
      -- Inizia a cercare avanti per default
      forward      = true,
      -- Wrap attorno al documento
      wrap         = true,
      -- Caso: "smart" = case-insensitive finché non metti una maiuscola
      mode         = "fuzzy",
    },
    jump = {
      -- Aggiunge il salto alla jumplist (<C-o> per tornare indietro)
      jumplist  = true,
      -- Posiziona il cursore prima del match
      pos       = "start",
      -- Aggiunge salti anche ai label quando si usa treesitter
      autojump  = false,
    },
    label = {
      -- Uppercase rende le label più visibili
      uppercase     = false,
      -- Colora anche il testo dopo il label
      after         = true,
      before        = false,
      -- Stile del label
      style         = "overlay",
      -- Riduci il numero di label necessari
      reuse         = "lowercase",
      distance      = true,
      min_jump_dist = 2,
    },
    highlight = {
      -- Sfondo semi-trasparente sul testo non-match
      backdrop = true,
      -- Gruppi highlight usati da flash
      groups   = {
        match        = "FlashMatch",
        current      = "FlashCurrent",
        backdrop     = "FlashBackdrop",
        label        = "FlashLabel",
      },
    },
    -- Modalità disponibili
    modes = {
      -- Modalità 's': salto a una parola (default)
      search = {
        enabled = true,
        highlight = { backdrop = false },
        jump     = { history = true, register = true, nohlsearch = true },
        search   = {},
      },
      -- Modalità 'char': rimpiazza f/F/t/T con label visivi
      char = {
        enabled  = true,
        config   = function(opts)
          opts.autojump = #require("flash").labeler.si > 0
        end,
        -- Caratteri usati come trigger (rimpiazza le motion native)
        keys     = { "f", "F", "t", "T", ";", "," },
        jump     = { register = false },
        highlight = { backdrop = true },
        jump_labels = false,
      },
      -- Modalità treesitter: salta a nodi AST
      treesitter = {
        labels         = "abcdefghijklmnopqrstuvwxyz",
        jump           = { pos = "range", autojump = true },
        search         = { incremental = false },
        label          = { before = true, after = true, style = "inline" },
        highlight      = { backdrop = false, matches = false },
      },
      treesitter_search = {
        jump    = { pos = "range" },
        search  = { multi_window = true, wrap = true, incremental = false },
        remote_op = { restore = true },
        label   = { before = true, after = true, style = "inline" },
      },
      -- Modalità remote: esegue operazioni su testo lontano
      remote = {
        remote_op = { restore = true, motion = true },
      },
    },
  },
  keys = {
    -- s  = salta avanti/indietro nel buffer (normale, visual, operator)
    { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash jump" },
    -- S  = salta a nodo treesitter
    { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash treesitter" },
    -- r  = remote flash (operator pending): es. yr<label> per yank a distanza
    { "r",     mode = "o",               function() require("flash").remote() end,             desc = "Remote flash" },
    -- R  = treesitter search in operator pending / visual
    { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter search" },
    -- <C-s> = attiva/disattiva flash mentre sei nella ricerca di telescope
    { "<C-s>", mode = "c",               function() require("flash").toggle() end,             desc = "Toggle flash (search)" },
  },
}
