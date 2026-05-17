-- ~/.config/nvim/lua/plugins/formatting.lua
-- conform.nvim  — formatter
-- nvim-lint     — linter asincrono

return {

  -- ---------------------------------------------------------------------------
  -- CONFORM.NVIM  — formattazione
  -- ---------------------------------------------------------------------------
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd   = { "ConformInfo" },
    keys  = {
      {
        "<leader>cf",
        function() require("conform").format({ async = true, lsp_fallback = true }) end,
        desc = "Format buffer",
      },
    },
    opts = {
      -- Formatter per filetype
      -- Se ne hai più di uno vengono eseguiti in sequenza
      formatters_by_ft = {
        lua        = { "stylua" },
        python     = { "isort", "black" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd" },
        typescriptreact = { "prettierd" },
        json       = { "prettierd" },
        jsonc      = { "prettierd" },
        yaml       = { "prettierd" },
        html       = { "prettierd" },
        css        = { "prettierd" },
        scss       = { "prettierd" },
        markdown   = { "prettierd" },
        sh         = { "shfmt" },
        bash       = { "shfmt" },
        rust       = { "rustfmt" },
        go         = { "gofmt", "goimports" },
        -- Fallback: se non c'è un formatter specifico, usa l'LSP
        ["_"]      = { "trim_whitespace" },
      },
      -- Formatta automaticamente al salvataggio
      format_on_save = {
        timeout_ms   = 500,
        lsp_fallback = true,   -- usa l'LSP se conform non ha un formatter
      },
      -- Opzioni per i singoli formatter
      formatters = {
        shfmt = {
          prepend_args = { "-i", "2" },   -- indentazione 2 spazi
        },
        black = {
          prepend_args = { "--line-length", "88" },
        },
        stylua = {
          prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
        },
      },
    },
    init = function()
      -- Usa conform per gq (format motion)
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },

  -- ---------------------------------------------------------------------------
  -- NVIM-LINT  — linting asincrono
  -- ---------------------------------------------------------------------------
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    config = function()
      local lint = require("lint")

      -- Linter per filetype
      lint.linters_by_ft = {
        python     = { "flake8" },
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        sh         = { "shellcheck" },
        bash       = { "shellcheck" },
        dockerfile = { "hadolint" },
        yaml       = { "yamllint" },
        markdown   = { "markdownlint" },
      }

      -- Opzioni flake8 (ignora errori compatibili con black)
      lint.linters.flake8.args = {
        "--max-line-length=88",
        "--extend-ignore=E203,W503",
        "-",
      }

      -- Lancia il linter automaticamente
      local lint_group = vim.api.nvim_create_augroup("nvim-lint", { clear = true })
      vim.api.nvim_create_autocmd(
        { "BufWritePost", "BufReadPost", "InsertLeave" },
        {
          group    = lint_group,
          callback = function()
            -- Linta solo se il linter è disponibile nel PATH
            lint.try_lint()
          end,
        }
      )

      -- Keybind per lanciare il linter manualmente
      vim.keymap.set("n", "<leader>cl", function()
        lint.try_lint()
      end, { desc = "Lint file" })
    end,
  },
}
