require "nvchad.options"

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!


-- 1. Seguridad: Historial de 'Undo' persistente
-- Permite usar 'u' incluso tras cerrar Neovim o guardar.
vim.opt.undofile = true
vim.opt.undolevels = 1000

-- 2. Guardado automático (Auto-save) mejorado
-- Guarda al salir de modo insertar o cambiar texto.
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  callback = function()
    if vim.bo.modified and vim.bo.buftype == "" then
      vim.cmd("silent! write")
    end
  end,
})
