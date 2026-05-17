-- ~/.config/nvim/lua/plugins/dap.lua
-- Debug
return {
  -- Core DAP
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      local dap = require("dap")

      -- Configurazione Python
      dap.adapters.python = {
        type = "executable",
        command = "python",
        args = { "-m", "debugpy.adapter" },
      }

      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          pythonPath = function()
            return vim.fn.input("Path to python: ", vim.fn.getcwd() .. "/venv/bin/python")
          end,
        },
      }

      -- Configurazione JavaScript/TypeScript
      dap.adapters.node2 = {
        type = "executable",
        command = "node",
        args = { vim.fn.stdpath("data") .. "/mason/packages/node-debug2/adapter/debugAdapter.js" },
      }

      dap.configurations.javascript = {
        {
          type = "node2",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          cwd = vim.fn.getcwd(),
        },
      }
      dap.configurations.typescript = dap.configurations.javascript
    end,
  },

  -- DAP UI
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      require("dapui").setup()

      -- Auto apri/chiudi DAP UI
      local dap, dapui = require("dap"), require("dapui")
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },

  -- Virtual text per valori in debug
  {
    "theHamsta/nvim-dap-virtual-text",
    config = true,
  },

  -- Keymaps
  keys = {
    { "<leader>db", "<cmd>DapToggleBreakpoint<CR>", desc = "Toggle breakpoint" },
    { "<leader>dc", "<cmd>DapContinue<CR>", desc = "Continue" },
    { "<leader>do", "<cmd>DapStepOver<CR>", desc = "Step over" },
    { "<leader>di", "<cmd>DapStepInto<CR>", desc = "Step into" },
    { "<leader>du", "<cmd>DapUI Toggle<CR>", desc = "Toggle DAP UI" },
  },
}
