-- ~/.config/nvim/lua/plugins/markdown.lua
-- preview markdown
return {
  {
    "toppair/peek.nvim",
    build = "deno task --quiet build:fast",
    ft = "markdown",
    config = function()
      -- Verifica che deno sia installato
      local deno_check = vim.fn.executable("deno")
      if deno_check == 0 then
        vim.notify("Deno non trovato! Installa deno per usare peek.nvim", vim.log.levels.WARN)
        return
      end

      require("peek").setup({
        theme = "dark",
        app = "browser",
      })
      vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
      vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
    end,
    keys = {
      { "<leader>md", "<cmd>PeekOpen<CR>", desc = "Open markdown preview" },
    },
  },
}
