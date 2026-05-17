-- ~/.config/nvim/lua/plugins/colorscheme.lua
return {
  -- Tema Tokyo Night (fallback se pywal non funziona)
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "storm",
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      -- NON impostare ancora come tema, lo faremo dopo pywal
    end,
  },

  -- Integrazione pywal per generare colorscheme
  {
    "mellow-theme/mellow.nvim",
    dependencies = { "folke/tokyonight.nvim" }, -- Assicura che tokyonight sia caricato
    config = function()
      -- Carica i colori da pywal
      local function load_pywal_colors()
        -- Verifica se pywal è installato e ha generato colori
        local handle = io.popen("command -v wal >/dev/null && cat ~/.cache/wal/colors.json 2>/dev/null")
        if handle then
          local result = handle:read("*a")
          handle:close()

          if result and result ~= "" then
            local success, colors = pcall(vim.json.decode, result)
            if success and colors then
              -- Applica i colori di pywal
              vim.g.colors_name = "pywal"

              -- Imposta colori base
              vim.cmd(string.format("highlight Normal guibg=%s", colors.special.background))
              vim.cmd(string.format("highlight Normal guifg=%s", colors.special.foreground))

              -- Altri gruppi importanti
              vim.cmd(string.format("highlight LineNr guifg=%s", colors.color8 or "#666666"))
              vim.cmd(string.format("highlight Comment guifg=%s", colors.color8 or "#666666"))

              return true
            end
          end
        end
        return false
      end

      -- Applica tema pywal all'avvio
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          local pywal_loaded = load_pywal_colors()

          -- Se pywal non funziona, usa tokyonight
          if not pywal_loaded then
            vim.cmd.colorscheme("tokyonight")
          end
        end,
      })
    end,
  },
}
