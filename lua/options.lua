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
-- opt.foldmethod = "indent"  -- Usa la indentación (que prettier ya arregló)
opt.foldmethod = "manual"
opt.foldlevel = 99        -- Todo abierto al empezar
opt.foldenable = true     -- Habilitar plegado

-- Asegura que Neovim use los mismos 2 espacios que Prettier
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true


-- Para que no se borren los pliegues manuales al salir
vim.api.nvim_create_autocmd({ "BufWinLeave" }, {
  pattern = { "*.*" },
  command = "mkview",
})

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  pattern = { "*.*" },
  command = "silent! loadview",
})


-- 3. Guardado automático (Optimizado para Live Server)
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  -- Solo se activa en archivos web para que el Live Server sea reactivo
  pattern = { "*.html", "*.css", "*.js", "*.jsx", "*.ts", "*.tsx" }, 
  callback = function()
    if vim.bo.modified and vim.bo.buftype == "" then
      vim.cmd("silent! write")
    end
  end,
})


-- 4. Clipboard
vim.opt.clipboard = "unnamedplus"
