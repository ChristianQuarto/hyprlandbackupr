-- ~/.config/nvim/lua/plugins/pywal.lua
return {
  "RedsXDD/neopywal.nvim",
  name = "neopywal",
  lazy = false, -- Carica all'avvio
  priority = 1000, -- Priorità alta per il colorscheme
  opts = {
    -- Opzioni di configurazione
    transparent_background = trye, -- Metti true se vuoi sfondo trasparente
    dim_inactive = true, -- Scurisce le finestre inattive
    terminal_colors = true, -- Applica i colori al terminale integrato
    styles = {
      comments = { "italic" },
      conditionals = { "italic" },
      functions = {},
      keywords = {},
      strings = {},
      variables = {},
    },
    -- Se vuoi usare una palette predefinita invece di pywal
    -- use_palette = "catppuccin-mocha",  -- Scommenta per usare palette fissa
  },
  config = function(_, opts)
    local neopywal = require("neopywal")
    neopywal.setup(opts)
    vim.cmd.colorscheme("neopywal")
  end,
}
