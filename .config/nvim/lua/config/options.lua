-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here-- ~/.config/nvim/lua/options.lua
vim.opt.completeopt = { "menuone", "noselect", "noinsert" } -- Comportamento menu completamento
vim.opt.shortmess:append("c") -- Nasconde messaggi del menu completamento
