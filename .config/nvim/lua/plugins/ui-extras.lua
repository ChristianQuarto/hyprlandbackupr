-- ~/.config/nvim/lua/plugins/ui-extras.lua
-- noice.nvim          — cmdline e notifiche moderne
-- rainbow-delimiters  — parentesi colorate per livello
-- modes.nvim          — colora la cursorline per modalità
-- nvim-scrollbar      — scrollbar con diagnostics
-- statuscol.nvim      — colonna numeri personalizzata

return {

  -- ---------------------------------------------------------------------------
  -- NOICE.NVIM — ridisegna cmdline, messaggi e notifiche
  -- LazyVim lo include già — qui lo personalizziamo
  -- ---------------------------------------------------------------------------
  {
    "folke/noice.nvim",
    opts = {
      lsp = {
        -- Hover e signature usano già i nostri handler custom in lsp.lua
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"]                = true,
          ["cmp.entry.get_documentation"]                  = true,
        },
        signature = { enabled = false }, -- gestiamo noi con lsp_signature.nvim
        hover     = { enabled = true  },
        progress  = {
          enabled = false, -- gestiamo noi con fidget.nvim
          throttle = 1000 / 30,
        },
      },
      routes = {
        -- Nascondi messaggi poco utili
        { filter = { event = "msg_show", any = {
          { find = "%d+L, %d+B" },
          { find = "; after #%d+" },
          { find = "; before #%d+" },
          { find = "%d fewer lines" },
          { find = "%d more lines" },
          { find = "written" },
        }}, opts = { skip = true } },
      },
      presets = {
        bottom_search         = true,   -- barra di ricerca in basso
        command_palette       = true,   -- cmdline al centro
        long_message_to_split = true,   -- messaggi lunghi in split
        inc_rename            = true,   -- usa noice per inc-rename
        lsp_doc_border        = true,   -- bordi sui popup LSP
      },
      cmdline = {
        enabled  = true,
        view     = "cmdline_popup",
        format = {
          cmdline     = { icon = ">" },
          search_down = { icon = "🔍⌄" },
          search_up   = { icon = "🔍⌃" },
          filter      = { icon = "$" },
          lua         = { icon = "☾" },
          help        = { icon = "?" },
        },
      },
    },
  },

  -- ---------------------------------------------------------------------------
  -- RAINBOW-DELIMITERS — parentesi colorate per livello di annidamento
  -- ---------------------------------------------------------------------------
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "BufReadPost",
    config = function()
      local rainbow = require("rainbow-delimiters")
      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow.strategy["global"],
          vim  = rainbow.strategy["local"],
        },
        query = {
          [""]     = "rainbow-delimiters",
          lua      = "rainbow-blocks",
          tsx      = "rainbow-parens",
          verilog  = "rainbow-blocks",
        },
        priority = {
          [""] = 110,
          lua  = 210,
        },
        -- Colori ciclici per ogni livello di annidamento
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      }
    end,
  },

  -- ---------------------------------------------------------------------------
  -- MODES.NVIM — colora cursorline e altri elementi in base alla modalità
  -- ---------------------------------------------------------------------------
  {
    "mvllow/modes.nvim",
    event = "VeryLazy",
    opts = {
      colors = {
        copy    = "#FFEE55",  -- giallo in yank
        delete  = "#F55385",  -- rosso in delete
        insert  = "#5FB0FC",  -- blu in insert
        visual  = "#D787FF",  -- viola in visual
      },
      -- Larghezza del cursore per ogni modalità
      line_opacity = 0.15,
      set_cursor   = true,
      set_cursorline = true,
      set_number   = true,
      ignore_filetypes = {
        "NvimTree", "TelescopePrompt", "neo-tree",
        "alpha", "dashboard", "lazy", "mason",
      },
    },
  },

  -- ---------------------------------------------------------------------------
  -- NVIM-SCROLLBAR — scrollbar laterale con markers diagnostics e git
  -- ---------------------------------------------------------------------------
  {
    "petertriho/nvim-scrollbar",
    event = "BufReadPost",
    dependencies = {
      "lewis6991/gitsigns.nvim",  -- mostra i chunk git nella scrollbar
    },
    config = function()
      require("scrollbar").setup({
        show             = true,
        show_in_active_only = false,
        set_highlights   = true,
        folds            = 1000,
        max_lines        = false,
        hide_if_all_visible = false,
        throttle_ms      = 100,
        handle = {
          text       = " ",
          blend      = 30,
          color      = nil,
          color_nr   = nil,
          highlight  = "CursorColumn",
          hide_if_all_visible = true,
        },
        marks = {
          Cursor = {
            text      = "•",
            priority  = 0,
            gui       = nil,
            color     = nil,
            cterm     = nil,
            color_nr  = nil,
            highlight = "Normal",
          },
          Search   = { highlight = "Search" },
          Error    = { highlight = "DiagnosticVirtualTextError" },
          Warn     = { highlight = "DiagnosticVirtualTextWarn" },
          Info     = { highlight = "DiagnosticVirtualTextInfo" },
          Hint     = { highlight = "DiagnosticVirtualTextHint" },
          Misc     = { highlight = "DiagnosticVirtualTextHint" },
          GitAdd   = { text = "│", highlight = "GitSignsAdd" },
          GitChange = { text = "│", highlight = "GitSignsChange" },
          GitDelete = { text = "▸", highlight = "GitSignsDelete" },
        },
        excluded_buftypes = { "terminal" },
        excluded_filetypes = {
          "cmp_docs", "cmp_menu", "noice", "prompt", "TelescopePrompt",
          "alpha", "dashboard", "neo-tree", "lazy", "mason",
        },
        autocmd = {
          render = { "BufWinEnter", "TabEnter", "TermEnter", "WinEnter",
                     "CmdwinLeave", "TextChanged", "VimResized", "WinScrolled" },
          clear  = { "BufWinLeave", "TabLeave", "TermLeave", "WinLeave" },
        },
        handlers = {
          cursor   = true,
          diagnostic = true,
          gitsigns = true,   -- mostra chunk git nella scrollbar
          handle   = true,
          search   = false,  -- richiede hlslens, disabilitato per default
          ale      = false,
        },
      })

      -- Integrazione gitsigns
      require("scrollbar.handlers.gitsigns").setup()
    end,
  },

  -- ---------------------------------------------------------------------------
  -- STATUSCOL.NVIM — colonna sinistra (numeri, segni) personalizzata
  -- ---------------------------------------------------------------------------
  {
    "luukvbaal/statuscol.nvim",
    event = "BufReadPost",
    config = function()
      local builtin = require("statuscol.builtin")
      require("statuscol").setup({
        relculright = true,   -- numeri relativi allineati a destra
        segments = {
          -- Segni (gitsigns, diagnostics, breakpoint)
          { text = { "%s" }, click = "v:lua.ScSa" },
          -- Numero di riga
          { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
          -- Segno fold
          { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
        },
      })
    end,
  },
}
