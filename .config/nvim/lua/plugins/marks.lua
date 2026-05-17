-- ~/.config/nvim/lua/plugins/marks.lua
-- Marks persistenti per progetto (A-Z). I marks sopravvivono alla chiusura.
return {
  "mohseenrm/marko.nvim",
  opts = {
    debug = false, -- true per logging verboso
  },
  keys = {
    { "mA", desc = "Set mark A" }, -- I comandi nativi funzionano normalmente
    { "'A", desc = "Jump to mark A line" },
    { "`A", desc = "Jump to mark A position" },
  },
  cmd = {
    "MarkoSave",
    "MarkoReload",
    "MarkoDeleteConfig",
    "MarkoDebug",
  },
}
