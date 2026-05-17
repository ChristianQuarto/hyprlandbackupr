-- ~/.config/nvim/lua/plugins/ui.lua
return {
  -- Notifiche migliorate
  {
    "rcarriga/nvim-notify",
    opts = {
      background_colour = "#000000",
      timeout = 3000,
      max_width = 60,
      render = "default",
      stages = "fade_in_slide_out",
    },
  },

  -- Noice: UI migliorata per messaggi e cmdline
  {
    "folke/noice.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
    },
  },

  -- Diff avanzato in stile VSCode [citation:10]
  {
    "esmuellert/vscode-diff.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    cmd = "CodeDiff",
    opts = {
      diff = { disable_inlay_hints = true },
      keymaps = {
        view = {
          next_hunk = "]c",
          prev_hunk = "[c",
        },
      },
    },
  },
}
