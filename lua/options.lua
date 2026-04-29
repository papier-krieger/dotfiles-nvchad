require "nvchad.options"


-- Usar tree-sitter de cargo en vez de nvm
vim.env.PATH = vim.env.HOME .. "/.cargo/bin:" .. vim.env.PATH

-- 1. Seguridad y Edición
vim.opt.undofile = true
vim.opt.undolevels = 1000

-- 2. Visualización de líneas (Wrap Pro)
local opt = vim.opt

opt.wrap = true
opt.breakindent = true
opt.copyindent = true
opt.preserveindent = true -- Mantiene la estructura de indentación original
opt.linebreak = true      -- Corta por palabras, no letras
opt.showbreak = " ↳ "      -- Símbolo visual para líneas envueltas

-- 3. Guardado automático (Auto-save)
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  callback = function()
    if vim.bo.modified and vim.bo.buftype == "" then
      vim.cmd("silent! write")
    end
  end,
})
