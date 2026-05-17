-- ~/.config/nvim/lua/plugins/snippets.lua
-- LuaSnip: motore snippet. Dichiarato UNA SOLA VOLTA qui.
-- cmp.lua lo usa come dipendenza runtime senza ridichiararlo.

return {
  {
    "L3MON4D3/LuaSnip",
    version      = "v2.*",
    build        = "make install_jsregexp",
    dependencies = { "rafamadriz/friendly-snippets" },
    event        = "InsertEnter",
    config = function()
      local ls = require("luasnip")

      ls.setup({
        -- Mantiene l'ultimo nodo attivo finché non esci dal punto di inserimento
        keep_roots            = true,
        link_roots            = true,
        link_children         = true,
        -- Cancella lo snippet quando esci dall'area del placeholder
        exit_roots            = false,
        region_check_events   = "CursorMoved,CursorHold,InsertLeave",
        delete_check_events   = "TextChanged,InsertLeave",
        enable_autosnippets   = true,
        -- Aggiorna snippet dinamici mentre scrivi (utile per snippet con mirror)
        update_events         = "TextChanged,TextChangedI",
      })

      -- Carica snippets in formato VSCode da friendly-snippets
      require("luasnip.loaders.from_vscode").lazy_load()

      -- Carica snippets personalizzati da ~/.config/nvim/snippets/
      -- (crea la cartella e aggiungi file .json o .lua se vuoi snippet custom)
      require("luasnip.loaders.from_vscode").lazy_load({
        paths = { vim.fn.stdpath("config") .. "/snippets" },
      })

      -- Carica snippet in formato Lua da ~/.config/nvim/lua/snippets/
      -- require("luasnip.loaders.from_lua").load({
      --   paths = { vim.fn.stdpath("config") .. "/lua/snippets" },
      -- })

      -- -----------------------------------------------------------------------
      -- Keybind per navigare i placeholder
      -- <C-k> avanza, <C-j> torna indietro
      -- Usati SOLO per navigazione snippet (Tab/S-Tab gestiti da cmp.lua)
      -- -----------------------------------------------------------------------
      vim.keymap.set({ "i", "s" }, "<C-k>", function()
        if ls.jumpable(1) then ls.jump(1) end
      end, { silent = true, desc = "Snippet: prossimo placeholder" })

      vim.keymap.set({ "i", "s" }, "<C-j>", function()
        if ls.jumpable(-1) then ls.jump(-1) end
      end, { silent = true, desc = "Snippet: placeholder precedente" })

      -- <C-l> cambia la scelta nei choice_node (es. true/false, &&/||)
      vim.keymap.set({ "i", "s" }, "<C-l>", function()
        if ls.choice_active() then ls.change_choice(1) end
      end, { silent = true, desc = "Snippet: scelta successiva" })

      -- <C-u> riapre lo snippet se sei uscito accidentalmente
      vim.keymap.set("i", "<C-u>", require("luasnip.extras.select_choice"),
        { silent = true, desc = "Snippet: seleziona scelta" })

      -- -----------------------------------------------------------------------
      -- Snippet custom inline (esempio)
      -- Rimuovi i commenti per attivarli
      -- -----------------------------------------------------------------------
      -- local s  = ls.snippet
      -- local t  = ls.text_node
      -- local i  = ls.insert_node
      -- local f  = ls.function_node
      -- local c  = ls.choice_node
      --
      -- ls.add_snippets("all", {
      --   -- Data odierna: digita "date" + Tab
      --   s("date", { f(function() return os.date("%Y-%m-%d") end) }),
      --   -- TODO comment
      --   s("todo", { t("-- TODO: "), i(1, "descrizione"), t(" (" .. os.date("%Y-%m-%d") .. ")") }),
      -- })
      --
      -- ls.add_snippets("lua", {
      --   -- Funzione Lua con docstring
      --   s("fn", {
      --     t("--- "), i(1, "Descrizione"), t({ "", "" }),
      --     t("local function "), i(2, "nome"), t("("), i(3), t({ ")", "  " }),
      --     i(4, "-- corpo"), t({ "", "end" }),
      --   }),
      -- })
    end,
  },
}
