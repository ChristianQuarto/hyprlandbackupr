-- ~/.config/nvim/lua/plugins/lualine.lua
-- ~/.config/nvim/lua/plugins/lualine.lua
return {
  "nvim-lualine/lualine.nvim",
  lazy = false,
  requires = { "nvim-tree/nvim-web-devicons", opt = true },
  opts = {
    options = {
      theme = bubbles_theme,
      component_separators = "|",
      section_separators = { left = "", right = "" },
    },
    sections = {
      lualine_a = {
        { "mode", separator = { left = "" }, right_padding = 2 },
      },
      lualine_b = {
        "filename",
        "branch",
        "diff",
      },
      --lualine_c = { "fileformat" },
      lualine_x = {},
      lualine_y = { "filetype", "progress" },
      lualine_z = {
        { "location", separator = { right = "" }, left_padding = 2 },
      },
    },
    inactive_sections = {
      lualine_a = { "filename" },
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = { "location" },
    },
    tabline = {},
    extensions = { "neo-tree", "fugitive", "quickfix" },
  },
}
