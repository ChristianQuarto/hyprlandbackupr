-- ~/.config/nvim/lua/keymaps.lua
-- Tutte le keybind in un unico posto.
-- Questo file viene caricato da init.lua con: require("keymaps")
--
-- NOTA SUL LEADER:
-- LazyVim usa <Space> come leader di default.
-- Se vuoi la virgola, assicurati che in lazy.lua NON ci sia
-- vim.g.mapleader impostato altrove prima di questo require.
-- La virgola è più comoda su tastiera italiana ma attenzione:
-- in normal mode "," è la motion inversa di "f/t" — perdi quella funzione.

vim.g.mapleader      = ","
vim.g.maplocalleader = ","

local map  = vim.keymap.set
local opts = { noremap = true, silent = true }
local function o(desc) return { noremap = true, silent = true, desc = desc } end

-- =============================================================================
-- NAVIGAZIONE SPLIT  (Ctrl + hjkl)
-- =============================================================================
map("n", "<C-h>", "<C-w>h", o("Finestra sinistra"))
map("n", "<C-j>", "<C-w>j", o("Finestra sotto"))
map("n", "<C-k>", "<C-w>k", o("Finestra sopra"))
map("n", "<C-l>", "<C-w>l", o("Finestra destra"))

-- Ridimensiona split (Alt + frecce)
map("n", "<M-Left>",  "<C-w><", o("Riduci larghezza"))
map("n", "<M-Right>", "<C-w>>", o("Aumenta larghezza"))
map("n", "<M-Up>",    "<C-w>+", o("Aumenta altezza"))
map("n", "<M-Down>",  "<C-w>-", o("Riduci altezza"))

-- =============================================================================
-- TELESCOPE  (gruppo ,f)
-- =============================================================================
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>",                    o("Trova file"))
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>",                     o("Live grep"))
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>",                       o("Buffer list"))
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>",                     o("Help tags"))
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>",                      o("File recenti"))
map("n", "<leader>fw", "<cmd>Telescope grep_string<CR>",                   o("Cerca parola corrente"))
map("n", "<leader>fs", "<cmd>Telescope current_buffer_fuzzy_find<CR>",     o("Cerca nel buffer"))
map("n", "<leader>fm", "<cmd>Telescope marks<CR>",                         o("Marks"))
map("n", "<leader>fk", "<cmd>Telescope keymaps<CR>",                       o("Keymaps"))
map("n", "<leader>fc", "<cmd>Telescope commands<CR>",                      o("Comandi"))
map("n", "<leader>fd", "<cmd>Telescope diagnostics<CR>",                   o("Diagnostics"))
map("n", "<leader>fG", "<cmd>Telescope git_status<CR>",                    o("Git status"))

-- =============================================================================
-- FILE EXPLORER  (gruppo ,e)
-- =============================================================================
map("n", "<leader>e", "<cmd>Neotree toggle<CR>", o("Toggle explorer"))
map("n", "<leader>E", "<cmd>Neotree focus<CR>",  o("Focus explorer"))

-- =============================================================================
-- GIT  (gruppo ,g)
-- =============================================================================
map("n", "<leader>gg", "<cmd>Neogit<CR>",                        o("Neogit"))
map("n", "<leader>gb", "<cmd>Gitsigns blame_line<CR>",           o("Blame line"))
map("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>",         o("Preview hunk"))
map("n", "<leader>gd", "<cmd>Gitsigns diffthis<CR>",             o("Diff this"))
map("n", "<leader>gs", "<cmd>Gitsigns stage_hunk<CR>",           o("Stage hunk"))
map("n", "<leader>gr", "<cmd>Gitsigns reset_hunk<CR>",           o("Reset hunk"))
map("n", "<leader>gS", "<cmd>Gitsigns stage_buffer<CR>",         o("Stage buffer"))
map("n", "<leader>gu", "<cmd>Gitsigns undo_stage_hunk<CR>",      o("Undo stage hunk"))
map("n", "]h",         "<cmd>Gitsigns next_hunk<CR>",            o("Hunk successivo"))
map("n", "[h",         "<cmd>Gitsigns prev_hunk<CR>",            o("Hunk precedente"))

-- =============================================================================
-- LSP  (gruppo ,l)
-- Le keybind gd/gr/K sono anche in lsp.lua su LspAttach.
-- Qui le ridefinizioni globali servono come fallback visibile in which-key.
-- =============================================================================
map("n", "K",           vim.lsp.buf.hover,                               o("Hover docs"))
map("n", "gd",          vim.lsp.buf.definition,                          o("Definition"))
map("n", "gD",          vim.lsp.buf.declaration,                         o("Declaration"))
map("n", "gi",          vim.lsp.buf.implementation,                      o("Implementation"))
map("n", "gr",          vim.lsp.buf.references,                          o("References"))
map("n", "gy",          vim.lsp.buf.type_definition,                     o("Type definition"))
map("n", "<leader>rn",  vim.lsp.buf.rename,                              o("Rename"))
map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action,                 o("Code action"))
map("n", "<leader>lf",  function() vim.lsp.buf.format({ async = true }) end, o("Format"))
map("n", "<leader>lo",  "<cmd>LspInfo<CR>",                              o("LSP info"))
map("n", "<leader>lR",  "<cmd>LspRestart<CR>",                           o("Restart LSP"))
map("n", "[d",          vim.diagnostic.goto_prev,                        o("Diagnostic precedente"))
map("n", "]d",          vim.diagnostic.goto_next,                        o("Diagnostic successiva"))
map("n", "<leader>ld",  vim.diagnostic.open_float,                       o("Mostra diagnostic"))
map("n", "<leader>lq",  vim.diagnostic.setloclist,                       o("Diagnostics → quickfix"))

-- =============================================================================
-- BUFFER  (gruppo ,b)
-- Usa i comandi di barbar.nvim (che hai già configurato)
-- =============================================================================
map("n", "<leader>bd", "<cmd>BufferClose<CR>",    o("Chiudi buffer"))
map("n", "<leader>bn", "<cmd>BufferNext<CR>",     o("Buffer successivo"))
map("n", "<leader>bp", "<cmd>BufferPrevious<CR>", o("Buffer precedente"))
-- FIX: prima era mappato due volte a <leader>bp — ora usa <leader>bP
map("n", "<leader>bP", "<cmd>BufferPick<CR>",     o("Buffer pick"))
map("n", "<leader>bD", "<cmd>BufferCloseAllButCurrent<CR>", o("Chiudi tutti tranne corrente"))
-- Navigazione rapida con Tab / S-Tab
map("n", "<S-l>", "<cmd>BufferNext<CR>",     o("Buffer successivo"))
map("n", "<S-h>", "<cmd>BufferPrevious<CR>", o("Buffer precedente"))

-- =============================================================================
-- WINDOW  (gruppo ,w)
-- =============================================================================
map("n", "<leader>wv", "<C-w>v", o("Split verticale"))
map("n", "<leader>ws", "<C-w>s", o("Split orizzontale"))
map("n", "<leader>wc", "<C-w>c", o("Chiudi finestra"))
map("n", "<leader>wo", "<C-w>o", o("Chiudi altre finestre"))
map("n", "<leader>we", "<C-w>=", o("Equalizza finestre"))

-- =============================================================================
-- TERMINAL  (gruppo ,t)
-- =============================================================================
map("n", "<leader>tt", "<cmd>ToggleTerm<CR>",   o("Toggle terminal"))
map("t", "<Esc>",      "<C-\\><C-n>",           o("Esci da terminal mode"))
map("t", "<C-h>",      "<C-\\><C-n><C-w>h",     o("Terminal → finestra sinistra"))
map("t", "<C-j>",      "<C-\\><C-n><C-w>j",     o("Terminal → finestra sotto"))
map("t", "<C-k>",      "<C-\\><C-n><C-w>k",     o("Terminal → finestra sopra"))
map("t", "<C-l>",      "<C-\\><C-n><C-w>l",     o("Terminal → finestra destra"))

-- =============================================================================
-- DEBUG  (gruppo ,d)
-- =============================================================================
map("n", "<leader>db", "<cmd>DapToggleBreakpoint<CR>",  o("Toggle breakpoint"))
map("n", "<leader>dc", "<cmd>DapContinue<CR>",          o("Continue"))
map("n", "<leader>do", "<cmd>DapStepOver<CR>",          o("Step over"))
map("n", "<leader>di", "<cmd>DapStepInto<CR>",          o("Step into"))
map("n", "<leader>dO", "<cmd>DapStepOut<CR>",           o("Step out"))
map("n", "<leader>du", function() require("dapui").toggle() end, o("Toggle DAP UI"))
map("n", "<leader>dr", "<cmd>DapToggleRepl<CR>",        o("Toggle REPL"))
map("n", "<leader>dl", "<cmd>DapRunLast<CR>",           o("Run last"))

-- =============================================================================
-- UI  (gruppo ,u)
-- =============================================================================
map("n", "<leader>un", "<cmd>Noice dismiss<CR>",     o("Dismiss notifiche"))
map("n", "<leader>uT", "<cmd>TransparentToggle<CR>", o("Toggle trasparenza"))
map("n", "<leader>u?", "<cmd>WhichKey<CR>",          o("Which-key"))
map("n", "<leader>ul", "<cmd>Lazy<CR>",              o("Lazy plugin manager"))
map("n", "<leader>um", "<cmd>Mason<CR>",             o("Mason"))

-- =============================================================================
-- MARKDOWN  (gruppo ,m)
-- =============================================================================
map("n", "<leader>mp", "<cmd>PeekOpen<CR>",  o("Markdown preview"))
map("n", "<leader>mc", "<cmd>PeekClose<CR>", o("Chiudi preview"))

-- =============================================================================
-- NOTES  (gruppo ,n)
-- =============================================================================
map("n", "<leader>no", function()
  local ok, obsidian = pcall(require, "obsidian")
  if ok then obsidian.util.toggle_checkbox() end
end, o("Obsidian: toggle checkbox"))
map("n", "<leader>nw", "<cmd>VimwikiIndex<CR>", o("Vimwiki index"))

-- =============================================================================
-- QUALITÀ DELLA VITA
-- =============================================================================
-- Centrage schermo dopo navigazione
map("n", "n",  "nzz",  opts)
map("n", "N",  "Nzz",  opts)
map("n", "*",  "*zz",  opts)
map("n", "#",  "#zz",  opts)
map("n", "g*", "g*zz", opts)
map("n", "<C-d>", "<C-d>zz", opts)  -- centra anche dopo mezz-pagina
map("n", "<C-u>", "<C-u>zz", opts)

-- Mantieni selezione dopo indent
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- Sposta righe (Alt + jk)
map("n", "<A-j>", ":m .+1<CR>==",        opts)
map("n", "<A-k>", ":m .-2<CR>==",        opts)
map("v", "<A-j>", ":m '>+1<CR>gv=gv",   opts)
map("v", "<A-k>", ":m '<-2<CR>gv=gv",   opts)

-- Clipboard di sistema
map({ "n", "v" }, "<leader>y", '"+y', o("Copia in clipboard"))
map("n",           "<leader>Y", '"+Y', o("Copia riga in clipboard"))
map({ "n", "v" }, "<leader>P", '"+p', o("Incolla da clipboard"))

-- Salva con Ctrl+S
map({ "i", "n", "v" }, "<C-s>", "<cmd>write<CR>", o("Salva"))

-- Togli evidenziazione ricerca
map("n", "<Esc>", "<cmd>nohlsearch<CR>", opts)

-- Incolla senza sovrascrivere il registro (utile in visual mode)
map("v", "p", '"_dP', opts)

-- FIX: "q" era mappato a BufferClose — rotto per macro e quickfix.
-- Non mappa mai "q" in normal mode a qualcosa di diverso da :q o macro.
-- Usa <leader>bd per chiudere il buffer.
