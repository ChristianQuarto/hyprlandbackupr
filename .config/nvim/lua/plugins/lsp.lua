-- ~/.config/nvim/lua/plugins/lsp.lua
--
-- cmp-nvim-lsp NON è nelle dependencies qui.
-- Vive in cmp.lua come dependency di nvim-cmp.
-- Le capabilities vengono costruite con pcall in modo da non
-- crashare se per qualsiasi motivo cmp non fosse ancora caricato.

return {

  -- ---------------------------------------------------------------------------
  -- MASON
  -- ---------------------------------------------------------------------------
  {
    "mason-org/mason.nvim",
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "rounded",
        icons  = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local extra_tools = {
        "prettierd", "stylua", "black", "isort", "shfmt",
        "eslint_d", "flake8", "shellcheck", "hadolint", "markdownlint",
      }
      local registry = require("mason-registry")
      registry.refresh(function()
        for _, name in ipairs(extra_tools) do
          local ok, pkg = pcall(registry.get_package, name)
          if ok and not pkg:is_installed() then pkg:install() end
        end
      end)
    end,
  },

  -- ---------------------------------------------------------------------------
  -- MASON-LSPCONFIG
  -- ---------------------------------------------------------------------------
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        "lua_ls", "pyright", "ts_ls", "html",
        "cssls", "jsonls", "bashls", "rust_analyzer", "gopls",
      },
      automatic_installation = true,
    },
  },

  -- ---------------------------------------------------------------------------
  -- NVIM-LSPCONFIG
  -- dependency: solo mason, NON cmp-nvim-lsp
  -- ---------------------------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
    },
    config = function()
      local lspconfig = require("lspconfig")

      -- pcall: se cmp non è ancora in memoria usa capabilities base.
      -- In pratica cmp sarà sempre caricato prima che un server si
      -- attacchi, perché lspconfig si attacca su BufRead che viene
      -- dopo InsertEnter — ma il pcall è una rete di sicurezza.
      local function get_capabilities()
        local base = vim.lsp.protocol.make_client_capabilities()
        local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
        return ok and cmp_lsp.default_capabilities(base) or base
      end

      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              runtime     = { version = "LuaJIT" },
              diagnostics = { globals = { "vim" } },
              workspace   = {
                library         = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
              },
              telemetry  = { enable = false },
              completion = { callSnippet = "Replace" },
            },
          },
        },
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = { checkOnSave = { command = "clippy" } },
          },
        },
        pyright = {}, ts_ls  = {}, html  = {},
        cssls   = {}, jsonls = {}, bashls = {}, gopls = {},
      }

      for name, cfg in pairs(servers) do
        lspconfig[name].setup(
          vim.tbl_deep_extend("force", { capabilities = get_capabilities() }, cfg)
        )
      end

      -- Aspetto diagnostica
      vim.diagnostic.config({
        virtual_text  = { prefix = "●", spacing = 4 },
        signs         = true,
        underline     = true,
        severity_sort = true,
        float         = { border = "rounded", source = "always", header = "", prefix = "" },
      })

      vim.lsp.handlers["textDocument/hover"]         =
        vim.lsp.with(vim.lsp.handlers.hover,          { border = "rounded" })
      vim.lsp.handlers["textDocument/signatureHelp"] =
        vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

      -- Keybind su LspAttach
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
        callback = function(ev)
          local o = function(desc) return { buffer = ev.buf, silent = true, desc = desc } end
          vim.keymap.set("n", "K",          vim.lsp.buf.hover,           o("Hover docs"))
          vim.keymap.set("n", "gd",         vim.lsp.buf.definition,      o("Definition"))
          vim.keymap.set("n", "gD",         vim.lsp.buf.declaration,     o("Declaration"))
          vim.keymap.set("n", "gi",         vim.lsp.buf.implementation,  o("Implementation"))
          vim.keymap.set("n", "gr",         vim.lsp.buf.references,      o("References"))
          vim.keymap.set("n", "gy",         vim.lsp.buf.type_definition, o("Type definition"))
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,          o("Rename"))
          vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, o("Code action"))
          vim.keymap.set("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, o("Format"))
          vim.keymap.set("n", "<leader>lo", "<cmd>LspInfo<cr>",          o("LSP info"))
          vim.keymap.set("n", "<leader>lR", "<cmd>LspRestart<cr>",       o("Restart LSP"))
          vim.keymap.set("n", "[d",         vim.diagnostic.goto_prev,    o("Prev diagnostic"))
          vim.keymap.set("n", "]d",         vim.diagnostic.goto_next,    o("Next diagnostic"))
          vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float,   o("Show diagnostic"))
          vim.keymap.set("n", "<leader>lq", vim.diagnostic.setloclist,   o("Diagnostics quickfix"))
        end,
      })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- NVIM-LIGHTBULB
  -- ---------------------------------------------------------------------------
  {
    "kosayoda/nvim-lightbulb",
    event = "LspAttach",
    opts = {
      autocmd      = { enabled = true },
      sign         = { enabled = true, text = "💡", hl = "DiagnosticInfo" },
      float        = { enabled = false },
      virtual_text = { enabled = false },
    },
  },
}
