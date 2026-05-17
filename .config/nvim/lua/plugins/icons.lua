-- ~/.config/nvim/lua/plugins/icons.lua
return {
  "nvim-tree/nvim-web-devicons",
  lazy = true,
  opts = {
    default = true,
  },
}

-- nvim-image per preview immagini (richiede dipendenze) [citation:9]
-- {
--     "samodostal/image.nvim",
--     build = "bash install.sh",
--     cond = vim.fn.executable("magick") == 1,
--     opts = {
--         integrations = {
--             markdown = { enabled = true, clear_in_insert_mode = true },
--             neorg = { enabled = true },
--         },
--         max_width = 100,
--         max_height = 12,
--     },
-- }
