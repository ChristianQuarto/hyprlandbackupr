-- ~/.config/nvim/lua/plugins/database.lua
-- database da terminale
return {
  -- Core Dadbod [citation:2][citation:4]
  {
    "tpope/vim-dadbod",
    cmd = { "DB", "DBUI" },
  },

  -- UI per Dadbod
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      "tpope/vim-dadbod",
      "kristijanhusak/vim-dadbod-completion",
      "tpope/vim-dotenv",
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIFindBuffer" },
    init = function()
      -- Configura connessioni tramite file .env o variabili ambiente
      vim.g.dbs = {
        development = "postgresql://user:pass@localhost/dev",
        production = "postgresql://user:pass@localhost/prod",
      }
    end,
    keys = {
      { "<leader>db", ":tab DBUI<CR>", desc = "Apri database UI" },
    },
  },
}
