-- ~/.config/nvim/lua/plugins/lsp-extras.lua
-- Miglioramenti visivi LSP:
-- fidget, inc-rename, outline, tiny-inline-diagnostic, lsp_signature

return {

  -- ---------------------------------------------------------------------------
  -- FIDGET.NVIM — progresso LSP in basso a destra
  -- ---------------------------------------------------------------------------
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      progress = {
        suppress_on_insert   = true,   -- nasconde mentre scrivi
        ignore_done_already  = true,
        poll_rate            = 0,      -- aggiornamento su evento, non a polling
        display = {
          render_limit    = 5,
          done_ttl        = 2,         -- scompare dopo 2s quando finisce
          done_icon       = "✓",
          progress_icon   = { pattern = "dots", period = 1 },
        },
      },
      notification = {
        window = {
          normal_hl    = "Comment",
          winblend     = 0,
          border       = "none",
          align        = "bottom",     -- posizione: angolo in basso a destra
          relative     = "editor",
          x_padding    = 1,
          y_padding    = 0,
          zindex       = 45,
          max_width    = 0,
          max_height   = 0,
        },
      },
    },
  },

  -- ---------------------------------------------------------------------------
  -- INC-RENAME.NVIM — rename con anteprima live mentre scrivi
  -- ---------------------------------------------------------------------------
  {
    "smjonas/inc-rename.nvim",
    event = "LspAttach",
    config = function()
      require("inc_rename").setup({
        input_buffer_type = "dressing",   -- usa dressing.nvim se disponibile
      })

      -- Sovrascrive <leader>rn per usare inc-rename invece del rename base
      vim.keymap.set("n", "<leader>rn", function()
        return ":IncRename " .. vim.fn.expand("<cword>")
      end, { expr = true, desc = "Rename (live preview)" })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- OUTLINE.NVIM — pannello laterale con simboli del file
  -- ---------------------------------------------------------------------------
  {
    "hedyhli/outline.nvim",
    cmd  = { "Outline", "OutlineOpen" },
    keys = {
      { "<leader>lo", "<cmd>Outline<CR>", desc = "Toggle outline" },
    },
    opts = {
      outline_window = {
        position         = "right",
        width            = 30,
        relative_width   = false,
        auto_close       = false,
        auto_jump        = false,
        jump_highlight_duration = 300,
        center_on_jump   = true,
        show_numbers     = false,
        show_relative_numbers = false,
        wrap             = false,
      },
      outline_items = {
        show_symbol_details  = true,
        show_symbol_lineno   = false,
        highlight_hovered_item = true,
        auto_set_cursor      = true,
      },
      guides = {
        enabled = true,
        markers = { bottom = "└", middle = "├", vertical = "│" },
      },
      symbol_folding = {
        autofold_depth      = 1,   -- piega tutto tranne il primo livello
        auto_unfold_hover   = true,
        markers             = { "▶", "▼" },
      },
      preview_window = {
        auto_preview   = false,
        open_hover_on_preview = false,
        winhl          = "NormalFloat:",
        winblend       = 0,
        border         = "rounded",
      },
      -- Simboli da mostrare (tutti per default)
      symbols = {
        icon_fetcher = nil,
        icon_source  = nil,
        icons        = {
          File          = { icon = "󰈙", hl = "Identifier" },
          Module        = { icon = "󰆧", hl = "Include" },
          Namespace     = { icon = "󰅪", hl = "Include" },
          Package       = { icon = "󰏗", hl = "Include" },
          Class         = { icon = "󰠱", hl = "Type" },
          Method        = { icon = "󰊕", hl = "Function" },
          Property      = { icon = "", hl = "@property" },
          Field         = { icon = "󰜢", hl = "@field" },
          Constructor   = { icon = "", hl = "@constructor" },
          Enum          = { icon = "", hl = "@number" },
          Interface     = { icon = "", hl = "Type" },
          Function      = { icon = "󰊕", hl = "Function" },
          Variable      = { icon = "󰀫", hl = "@variable" },
          Constant      = { icon = "󰏿", hl = "Constant" },
          String        = { icon = "", hl = "String" },
          Number        = { icon = "󰎠", hl = "Number" },
          Boolean       = { icon = "", hl = "Boolean" },
          Array         = { icon = "󰅪", hl = "Type" },
          Object        = { icon = "󰅩", hl = "Type" },
          Key           = { icon = "󰌋", hl = "" },
          Null          = { icon = "󰟢", hl = "Type" },
          EnumMember    = { icon = "", hl = "@field" },
          Struct        = { icon = "󰙅", hl = "Type" },
          Event         = { icon = "", hl = "@variable" },
          Operator      = { icon = "󰆕", hl = "Operator" },
          TypeParameter = { icon = "󰊄", hl = "Type" },
          Component     = { icon = "󰅴", hl = "Function" },
          Fragment      = { icon = "󰅴", hl = "Constant" },
        },
      },
    },
  },

  -- ---------------------------------------------------------------------------
  -- TINY-INLINE-DIAGNOSTIC — diagnostica inline più leggibile
  -- ---------------------------------------------------------------------------
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event    = "LspAttach",
    priority = 1000,   -- carica prima degli altri plugin di diagnostica
    config = function()
      require("tiny-inline-diagnostic").setup({
        signs = {
          left   = "",
          right  = "",
          diag   = "●",
          arrow  = "    ",
          up_arrow = "    ",
          vertical       = " │",
          vertical_end   = " └",
        },
        hi = {
          error        = "DiagnosticError",
          warn         = "DiagnosticWarn",
          info         = "DiagnosticInfo",
          hint         = "DiagnosticHint",
          arrow        = "NonText",
          background   = "CursorLine",
          mixing_color = "None",
        },
        blend = {
          factor = 0.27,
        },
        options = {
          show_source          = false,
          throttle             = 20,
          softwrap             = 15,
          multiple_diag_under_cursor = true,
          multilines           = false,
          show_all_diags_on_cursorline = false,
          enable_on_insert     = false,
          overflow = {
            mode = "wrap",
          },
          break_line = {
            enabled    = false,
            after      = 30,
          },
          virt_texts = {
            priority = 2048,
          },
          severity = {
            vim.diagnostic.severity.ERROR,
            vim.diagnostic.severity.WARN,
            vim.diagnostic.severity.INFO,
            vim.diagnostic.severity.HINT,
          },
        },
      })

      -- Disabilita la virtual_text standard di Neovim per evitare duplicati
      vim.diagnostic.config({ virtual_text = false })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- LSP_SIGNATURE.NVIM — firma della funzione mentre scrivi gli argomenti
  -- ---------------------------------------------------------------------------
  {
    "ray-x/lsp_signature.nvim",
    event = "LspAttach",
    opts = {
      bind             = true,
      handler_opts     = { border = "rounded" },
      hint_enable      = true,
      hint_prefix      = "󰏫 ",
      hint_scheme      = "String",
      hint_inline      = function() return false end,
      hi_parameter     = "LspSignatureActiveParameter",
      max_height       = 12,
      max_width        = 80,
      wrap             = true,
      floating_window  = true,
      floating_window_above_cur_line = true,
      close_timeout    = 4000,
      fix_pos          = false,
      auto_close_after = nil,
      extra_trigger_chars = {},
      zindex           = 200,
      padding          = " ",
      transparency     = nil,
      shadow_blend     = 36,
      shadow_guibg     = "Black",
      timer_interval   = 200,
      toggle_key       = "<C-k>",      -- toggle manuale della firma
      toggle_key_flip_floatwin_setting = false,
      select_signature_key = "<M-n>", -- cicla tra firme overload
      move_cursor_key  = nil,
    },
  },
}
