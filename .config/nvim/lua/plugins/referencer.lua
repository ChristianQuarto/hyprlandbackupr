return {
  "romus204/referencer.nvim",
  opts = {
    enable = true,
    format = "  %d ref",
    show_no_reference = true,
    kinds = { 12, 6, 5, 23, 8 },
    hl_group = "Comment",
    color = "#FFA500",
    virt_text_pos = "eol",
    pattern = { "*.go", "*.py" },
    lsp_servers = { "gopls", "pyright" },
  },
}
