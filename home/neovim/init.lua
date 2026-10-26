vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local o = vim.opt
o.number = true
o.relativenumber = true
o.mouse = "a"
o.clipboard = "unnamedplus"
o.ignorecase = true
o.smartcase = true
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.smartindent = true
o.signcolumn = "yes"
o.cursorline = true
o.scrolloff = 8
o.splitright = true
o.splitbelow = true
o.undofile = true
o.updatetime = 250
o.timeoutlen = 400
o.termguicolors = true
o.winborder = "rounded"
o.confirm = true

require("rose-pine").setup({ styles = { transparency = true } })
vim.cmd.colorscheme("rose-pine")

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.hl.on_yank()
  end,
})

require("lualine").setup({ options = { theme = "auto", globalstatus = true } })
require("gitsigns").setup()
require("nvim-autopairs").setup()
require("nvim-tree").setup({
  view = { width = 35 },
  renderer = { group_empty = true },
  update_focused_file = { enable = true },
})

local telescope = require("telescope")
telescope.setup()
pcall(telescope.load_extension, "fzf")

require("blink.cmp").setup({
  keymap = { preset = "enter" },
  completion = { documentation = { auto_show = true } },
  signature = { enabled = true },
})

vim.diagnostic.config({
  virtual_text = true,
  severity_sort = true,
  float = { source = true },
})

vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })
vim.lsp.enable({ "jdtls", "lua_ls", "nixd", "basedpyright", "ruff", "ts_ls" })

local map = vim.keymap.set
local tb = require("telescope.builtin")

map("n", "<Esc>", "<cmd>nohlsearch<cr>")
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Speichern" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Fenster schließen" })
map("n", "<C-h>", "<C-w>h", { desc = "Fenster links" })
map("n", "<C-j>", "<C-w>j", { desc = "Fenster unten" })
map("n", "<C-k>", "<C-w>k", { desc = "Fenster oben" })
map("n", "<C-l>", "<C-w>l", { desc = "Fenster rechts" })
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Vorheriger Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Nächster Buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Buffer schließen" })
map("v", "<", "<gv")
map("v", ">", ">gv")

map("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Dateibaum" })
map("n", "<leader><leader>", tb.find_files, { desc = "Datei suchen" })
map("n", "<leader>ff", tb.find_files, { desc = "Datei suchen" })
map("n", "<leader>fg", tb.live_grep, { desc = "Text im Projekt suchen" })
map("n", "<leader>fw", tb.grep_string, { desc = "Wort unter Cursor suchen" })
map("n", "<leader>fb", tb.buffers, { desc = "Offene Buffer" })
map("n", "<leader>fr", tb.oldfiles, { desc = "Zuletzt geöffnet" })
map("n", "<leader>fh", tb.help_tags, { desc = "Hilfe" })
map("n", "<leader>fk", tb.keymaps, { desc = "Keybinds" })
map("n", "<leader>fd", tb.diagnostics, { desc = "Alle Fehler/Warnungen" })
map("n", "<leader>fs", tb.lsp_document_symbols, { desc = "Symbole in Datei" })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local function lmap(keys, fn, desc)
      map("n", keys, fn, { buffer = args.buf, desc = desc })
    end
    lmap("gd", tb.lsp_definitions, "Zur Definition")
    lmap("gD", vim.lsp.buf.declaration, "Zur Deklaration")
    lmap("<leader>cr", vim.lsp.buf.rename, "Umbenennen")
    lmap("<leader>ca", vim.lsp.buf.code_action, "Code Action / Quick Fix")
    lmap("<leader>cf", vim.lsp.buf.format, "Formatieren")
    lmap("<leader>cd", vim.diagnostic.open_float, "Fehler der Zeile")
    lmap("<leader>cu", tb.lsp_references, "Verwendungen")
    lmap("<leader>ci", tb.lsp_implementations, "Implementierungen")
    lmap("<leader>co", function()
      vim.lsp.buf.code_action({
        context = { only = { "source.organizeImports" }, diagnostics = {} },
        apply = true,
      })
    end, "Imports aufräumen")
  end,
})

local wk = require("which-key")
wk.setup({ preset = "modern" })
wk.add({
  { "<leader>f", group = "Finden" },
  { "<leader>c", group = "Code" },
  { "<leader>b", group = "Buffer" },
})
