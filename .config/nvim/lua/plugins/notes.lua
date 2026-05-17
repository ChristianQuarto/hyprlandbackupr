-- ~/.config/nvim/lua/plugins/notes.lua
return {
  -- Obsidian.nvim per vault Obsidian
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown", -- Carica solo per file markdown
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp", -- Per completamento
    },
    -- Usa opts per la configurazione (lazy.nvim gestisce il require)
    opts = {
      workspaces = {
        {
          name = "personal",
          path = "~/Documents/Obsidian/Personal",
        },
        {
          name = "work",
          path = "~/Documents/Obsidian/Work",
        },
      },
      daily_notes = {
        folder = "Daily",
        date_format = "%Y-%m-%d",
        template = nil,
      },
      completion = {
        nvim_cmp = true,
        min_chars = 2,
      },
      -- I mappings vanno definiti qui dentro, non richiedono obsidian direttamente
      mappings = {},
      ui = {
        enable = true,
        update_debounce = 200,
      },
      -- Aggiungi questo per evitare errori
      picker = {
        name = "telescope.nvim", -- o "fzf-lua" se preferisci
      },
    },
    -- Configurazione aggiuntiva dopo il caricamento
    config = function(_, opts)
      local obsidian = require("obsidian")
      obsidian.setup(opts)

      -- Keymaps personalizzati (sicuri perché il plugin è caricato)
      vim.keymap.set("n", "<leader>oc", function()
        local note = obsidian.util.gf()
        if note then
          vim.cmd("edit " .. note)
        end
      end, { desc = "Apri nota sotto cursore", buffer = 0 })

      vim.keymap.set("n", "<leader>oo", function()
        obsidian.util.toggle_checkbox()
      end, { desc = "Toggle checkbox", buffer = 0 })
    end,
  },

  -- Alternativa: vimwiki (se Obsidian non funziona)
  {
    "vimwiki/vimwiki",
    lazy = true,
    ft = "markdown",
    init = function()
      vim.g.vimwiki_list = {
        { path = "~/Documents/vimwiki/", syntax = "markdown", ext = ".md" },
      }
    end,
    keys = {
      { "<leader>ww", "<Plug>VimwikiIndex", desc = "Vimwiki index" },
      { "<leader>wd", "<Plug>VimwikiDiaryIndex", desc = "Vimwiki diary" },
    },
  },
}
