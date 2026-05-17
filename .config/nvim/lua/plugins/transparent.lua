-- ~/.config/nvim/lua/plugins/transparent.lua
return {
  "xiyaowong/transparent.nvim",
  lazy = false, -- Carica all'avvio
  config = function()
    require("transparent").setup({
      -- Gruppi da escludere dalla trasparenza
      exclude_groups = {
        "CursorLine", -- Linea cursore non trasparente
        "CursorLineNr",
        "LineNr", -- Numeri riga non trasparenti
      },
      -- Plugin extra da abilitare
      extra_groups = {
        "NormalFloat", -- Finestre flottanti
        "NeoTreeNormal", -- Neo-tree
        "NeoTreeNormalNC",
        "TelescopeNormal", -- Telescope
        "TelescopeBorder",
        "NvimTreeNormal", -- Nvim-tree
        "NvimTreeNormalNC",
        "BufferLineBackground", -- Barbar
        "BufferLineBufferSelected",
        "BufferLineBufferVisible",
        "StatusLine", -- Statusline
        "StatusLineNC",
      },
    })

    -- Attiva trasparenza all'avvio
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        require("transparent").clear_prefix()
      end,
    })

    -- Comando per toggle trasparenza
    vim.api.nvim_create_user_command("TransparentToggle", function()
      if vim.g.transparent_enabled then
        vim.cmd("TransparentDisable")
        vim.g.transparent_enabled = false
      else
        vim.cmd("TransparentEnable")
        vim.g.transparent_enabled = true
      end
    end, {})

    vim.g.transparent_enabled = true
  end,
  cmd = { "TransparentEnable", "TransparentDisable", "TransparentToggle" },
  keys = {
    { "<leader>uT", "<cmd>TransparentToggle<CR>", desc = "Toggle trasparenza" },
  },
}
