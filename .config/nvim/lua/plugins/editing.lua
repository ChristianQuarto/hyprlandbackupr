-- ~/.config/nvim/lua/plugins/editing.lua
-- nvim-autopairs  — chiude automaticamente coppie di delimitatori
-- mini.surround   — aggiunge / modifica / rimuove delimitatori attorno al testo

return {

  -- ---------------------------------------------------------------------------
  -- NVIM-AUTOPAIRS
  -- ---------------------------------------------------------------------------
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      -- Controlla il carattere alla destra del cursore prima di chiudere
      check_ts             = true,    -- usa treesitter per decisioni più smart
      ts_config = {
        -- Non chiude le coppie dentro stringhe/commenti in questi linguaggi
        lua  = { "string" },
        javascript = { "template_string" },
        python = { "string" },
      },
      -- Non aggiunge la coppia se il carattere successivo è già uguale
      ignored_next_char     = [=[[%w%%%'%[%"%.%`%$]]=],
      -- Gestisce gli spazi dentro le coppie: {|} → { | }
      enable_moveright      = true,
      -- Abilita il completamento delle coppie nel completion menu
      enable_afterquote     = true,
      -- Chiude la coppia anche in coppie nidificate
      enable_check_bracket_line = false,
      -- Fast wrap: <M-e> avvolge la parola successiva tra la coppia
      fast_wrap = {
        map            = "<M-e>",
        chars          = { "{", "[", "(", '"', "'" },
        pattern        = [=[[%'%"%>%]%)%}%,]]=],
        end_key        = "$",
        before_key     = "p",
        after_key      = "n",
        cursor_pos_before = true,
        keys           = "qwertyuiopzxcvbnmasdfghjkl",
        manual_position = true,
        highlight      = "Search",
        highlight_grey = "Comment",
      },
    },
    config = function(_, opts)
      local autopairs = require("nvim-autopairs")
      autopairs.setup(opts)

      -- Integrazione con nvim-cmp: aggiunge la coppia anche dopo aver confermato
      -- un completamento (es. digiti "fn<CR>" e ottieni "fn(|)")
      local ok, cmp = pcall(require, "cmp")
      if ok then
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end

      -- Regole extra per HTML/JSX: chiude automaticamente i tag
      local rule  = require("nvim-autopairs.rule")
      local cond  = require("nvim-autopairs.conds")

      -- Spazio dentro le coppie di parentesi: ( | ) → (  |  )
      autopairs.add_rules({
        rule(" ", " ")
          :with_pair(function(opts_)
            local pair = opts_.line:sub(opts_.col - 1, opts_.col)
            return vim.tbl_contains({ "()", "[]", "{}" }, pair)
          end),
        rule("( ", " )")
          :with_pair(cond.none())
          :with_move(function(opts_) return opts_.prev_char:match(".%)") ~= nil end)
          :use_key(")"),
        rule("{ ", " }")
          :with_pair(cond.none())
          :with_move(function(opts_) return opts_.prev_char:match(".%}") ~= nil end)
          :use_key("}"),
        rule("[ ", " ]")
          :with_pair(cond.none())
          :with_move(function(opts_) return opts_.prev_char:match(".%]") ~= nil end)
          :use_key("]"),
      })
    end,
  },

  -- ---------------------------------------------------------------------------
  -- MINI.SURROUND
  -- LazyVim lo include già. Qui personalizziamo i keybind e aggiungiamo alias.
  -- ---------------------------------------------------------------------------
  {
    "nvim-mini/mini.surround",
    opts = {
      -- Keybind (prefisso "gz" per non scontrarsi con i default LazyVim)
      mappings = {
        add            = "gsa",   -- gsa<motion><delimitatore>  aggiunge
        delete         = "gsd",   -- gsd<delimitatore>           rimuove
        find           = "gsf",   -- gsf<delimitatore>           trova il prossimo
        find_left      = "gsF",   -- gsF<delimitatore>           trova il precedente
        highlight      = "gsh",   -- gsh<delimitatore>           evidenzia
        replace        = "gsr",   -- gsr<vecchio><nuovo>         sostituisce
        update_n_lines = "gsn",   -- gsn                         aggiorna n righe
      },
      -- Numero di righe in cui cercare il delimitatore
      n_lines = 20,
      -- Rispetta il caso per i delimitatori testuali (es. "func" vs "FUNC")
      respect_selection_type = true,
      -- Delimitatori personalizzati
      custom_surroundings = {
        -- 'q' = virgolette singole '…'
        q = { input = { "'.-'" }, output = { left = "'", right = "'" } },
        -- 'Q' = virgolette doppie "…"
        Q = { input = { '".-"' },  output = { left = '"', right = '"' } },
        -- 'b' = qualsiasi coppia di parentesi (alias)
        b = { input = { "%b()", "%b[]", "%b{}" } },
        -- 't' = tag HTML <tag>…</tag>
        t = {
          input  = { "<(%w-)%f[^<%w][^<>]->.-</%1>" },
          output = function()
            local tag = vim.fn.input("Tag: ")
            return { left = "<" .. tag .. ">", right = "</" .. tag .. ">" }
          end,
        },
      },
    },
  },
}
