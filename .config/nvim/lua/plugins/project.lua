-- ~/.config/nvim/lua/plugins/project.lua

-- Rileva progetti (git, package.json) e cambia directory.
return {
  "ahmedkhalf/project.nvim",
  config = function()
    require("project_nvim").setup({
      detection_methods = { "pattern", "lsp" },
      patterns = { ".git", "Makefile", "package.json", "Cargo.toml", "pyproject.toml" },
      silent_chdir = false,
    })

    -- Cambia directory automaticamente quando apri un progetto
    vim.api.nvim_create_autocmd("BufEnter", {
      callback = function()
        if vim.fn.getcwd() ~= vim.loop.cwd() then
          require("telescope").extensions.projects.projects()
        end
      end,
    })
  end,
}
