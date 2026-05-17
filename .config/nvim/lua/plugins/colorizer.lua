return {
  "brenoprata10/nvim-highlight-colors",
  config = function()
    require("nvim-highlight-colors").setup({
      -- Stili di rendering
      render = "background", -- o "foreground" o "virtual"

      -- Abilita per tutti i file
      enable_named_colors = true, -- Nomi colori (red, blue)
      enable_tailwind = true, -- Colori Tailwind
      enable_css_variables = true, -- Variabili CSS

      -- Customizzazione
      exclude_filetypes = { "toggleterm", "NvimTree" },

      -- Simboli virtual text (se render = "virtual")
      virtual_symbol = "■",
    })
  end,
}
