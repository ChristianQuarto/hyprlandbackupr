-- ~/.config/nvim/lua/plugins/git-extras.lua
-- diffview.nvim — diff visuale e cronologia git
-- neogit        — interfaccia git tipo Magit
-- octo.nvim     — GitHub PR e issue da Neovim

return {

  -- ---------------------------------------------------------------------------
  -- DIFFVIEW.NVIM — diff side-by-side e file history
  -- ---------------------------------------------------------------------------
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd  = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFileHistory" },
    keys = {
      { "<leader>gD",  "<cmd>DiffviewOpen<CR>",                desc = "Diffview open" },
      { "<leader>gH",  "<cmd>DiffviewFileHistory %<CR>",       desc = "File history" },
      { "<leader>gA",  "<cmd>DiffviewFileHistory<CR>",         desc = "Repo history" },
      { "<leader>gX",  "<cmd>DiffviewClose<CR>",               desc = "Diffview close" },
    },
    opts = {
      enhanced_diff_hl    = true,
      show_help_hints     = false,
      watch_index         = true,
      icons = {
        folder_closed = "",
        folder_open   = "",
      },
      signs = {
        fold_closed = "",
        fold_open   = "",
        done        = "✓",
      },
      view = {
        default = {
          layout            = "diff2_horizontal",
          disable_diagnostics = true,
          winbar_info       = false,
        },
        merge_tool = {
          layout            = "diff3_horizontal",
          disable_diagnostics = true,
          winbar_info       = true,
        },
        file_history = {
          layout            = "diff2_horizontal",
          disable_diagnostics = true,
          winbar_info       = false,
        },
      },
      file_panel = {
        listing_style     = "tree",
        tree_options = {
          flatten_dirs    = true,
          folder_statuses = "only_folded",
        },
        win_config = {
          position = "left",
          width    = 35,
        },
      },
      file_history_panel = {
        log_options = {
          git = {
            single_file = { diff_merges = "combined" },
            multi_file  = { diff_merges = "first-parent" },
          },
        },
        win_config = {
          position = "bottom",
          height   = 16,
        },
      },
      hooks = {
        -- Chiude automaticamente Neotree quando apri diffview
        view_opened = function()
          require("neo-tree.command").execute({ action = "close" })
        end,
      },
      keymaps = {
        view = {
          { "n", "q",          "<cmd>DiffviewClose<CR>",     { desc = "Chiudi diffview" } },
          { "n", "<leader>gX", "<cmd>DiffviewClose<CR>",     { desc = "Chiudi diffview" } },
        },
      },
    },
  },

  -- ---------------------------------------------------------------------------
  -- NEOGIT — interfaccia git ispirata a Magit di Emacs
  -- ---------------------------------------------------------------------------
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",   -- integrazione diretta con diffview
      "nvim-telescope/telescope.nvim",
    },
    cmd  = "Neogit",
    keys = {
      { "<leader>gg", "<cmd>Neogit<CR>",                         desc = "Neogit" },
      { "<leader>gC", "<cmd>Neogit commit<CR>",                  desc = "Neogit commit" },
      { "<leader>gP", "<cmd>Neogit push<CR>",                    desc = "Neogit push" },
      { "<leader>gL", "<cmd>Neogit log<CR>",                     desc = "Neogit log" },
    },
    opts = {
      -- Usa diffview per i diff invece della finestra integrata
      integrations = {
        diffview  = true,
        telescope = true,
      },
      -- Dimensione della finestra
      kind = "split",   -- "split" | "vsplit" | "floating" | "tab"
      -- Conferma automatica del rebase
      disable_commit_confirmation = false,
      -- Mostra i rami del repository
      graph_style = "unicode",
      telescope_sorter = function()
        return require("telescope").extensions.fzf.native_fzf_sorter()
      end,
      sections = {
        -- Mostra sempre le sezioni espanse
        untracked   = { folded = false, hidden = false },
        unstaged    = { folded = false, hidden = false },
        staged      = { folded = false, hidden = false },
        stashes     = { folded = true  },
        unpulled_upstream  = { folded = true  },
        unmerged_upstream  = { folded = false },
        unpulled_pushRemote = { folded = true  },
        unmerged_pushRemote = { folded = false },
        recent      = { folded = true  },
        rebase      = { folded = true, hidden = false },
      },
    },
  },

  -- ---------------------------------------------------------------------------
  -- OCTO.NVIM — GitHub PR, issue e review da Neovim
  -- Richiede: gh CLI installato e autenticato (gh auth login)
  -- ---------------------------------------------------------------------------
  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    cmd  = "Octo",
    keys = {
      { "<leader>go",  "<cmd>Octo pr list<CR>",       desc = "PR list" },
      { "<leader>gi",  "<cmd>Octo issue list<CR>",    desc = "Issue list" },
      { "<leader>gpr", "<cmd>Octo pr create<CR>",     desc = "Crea PR" },
      { "<leader>grc", "<cmd>Octo review start<CR>",  desc = "Inizia review" },
    },
    opts = {
      use_local_fs          = false,
      enable_builtin        = true,
      default_remote        = { "upstream", "origin" },
      default_merge_method  = "commit",
      ssh_aliases           = {},
      picker               = "telescope",
      picker_config = {
        use_emojis = true,
        mappings = {
          open_in_browser = { lhs = "<C-b>", desc = "Apri nel browser" },
          copy_url        = { lhs = "<C-y>", desc = "Copia URL" },
          checkout_pr     = { lhs = "<C-o>", desc = "Checkout PR" },
          merge_pr        = { lhs = "<C-m>", desc = "Merge PR" },
        },
      },
      comment_icon         = "▎",
      outdated_icon        = "󰅒 ",
      resolved_icon        = " ",
      timeline_marker      = "",
      timeline_indent      = "2",
      right_bubble_delimiter = "",
      left_bubble_delimiter  = "",
      ui = { use_signcolumn = true },
      issues = {
        order_by = { field = "CREATED_AT", direction = "DESC" },
      },
      pull_requests = {
        order_by    = { field = "CREATED_AT", direction = "DESC" },
        always_select_remote_on_create = false,
      },
      file_panel = { size = 10, use_icons = true },
      mappings = {
        issue = {
          close_issue         = { lhs = "<leader>ic", desc = "Chiudi issue" },
          reopen_issue        = { lhs = "<leader>io", desc = "Riapri issue" },
          list_issues         = { lhs = "<leader>il", desc = "Lista issue" },
          reload              = { lhs = "<C-r>",      desc = "Ricarica" },
          open_in_browser     = { lhs = "<C-b>",      desc = "Apri nel browser" },
          copy_url            = { lhs = "<C-y>",      desc = "Copia URL" },
          add_assignee        = { lhs = "<leader>aa", desc = "Aggiungi assignee" },
          remove_assignee     = { lhs = "<leader>ad", desc = "Rimuovi assignee" },
          add_label           = { lhs = "<leader>la", desc = "Aggiungi label" },
          remove_label        = { lhs = "<leader>ld", desc = "Rimuovi label" },
          add_comment         = { lhs = "<leader>ca", desc = "Aggiungi commento" },
          delete_comment      = { lhs = "<leader>cd", desc = "Elimina commento" },
          react_hooray        = { lhs = "<leader>rh", desc = "🎉" },
          react_heart         = { lhs = "<leader>rh", desc = "❤️" },
          react_eyes          = { lhs = "<leader>re", desc = "👀" },
          react_thumbs_up     = { lhs = "<leader>r+", desc = "👍" },
          react_thumbs_down   = { lhs = "<leader>r-", desc = "👎" },
          react_rocket        = { lhs = "<leader>rr", desc = "🚀" },
          react_laugh         = { lhs = "<leader>rl", desc = "😄" },
          react_confused      = { lhs = "<leader>rc", desc = "😕" },
        },
        pull_request = {
          checkout_pr         = { lhs = "<leader>po", desc = "Checkout PR" },
          merge_pr            = { lhs = "<leader>pm", desc = "Merge PR" },
          squash_and_merge_pr = { lhs = "<leader>psm", desc = "Squash merge" },
          list_commits        = { lhs = "<leader>pc", desc = "Lista commit" },
          list_changed_files  = { lhs = "<leader>pf", desc = "File modificati" },
          show_pr_diff        = { lhs = "<leader>pd", desc = "Diff PR" },
          add_reviewer        = { lhs = "<leader>va", desc = "Aggiungi reviewer" },
          remove_reviewer     = { lhs = "<leader>vd", desc = "Rimuovi reviewer" },
          close_pr            = { lhs = "<leader>ic", desc = "Chiudi PR" },
          reopen_pr           = { lhs = "<leader>io", desc = "Riapri PR" },
          reload              = { lhs = "<C-r>",      desc = "Ricarica" },
          open_in_browser     = { lhs = "<C-b>",      desc = "Apri nel browser" },
          copy_url            = { lhs = "<C-y>",      desc = "Copia URL" },
        },
      },
    },
  },
}
