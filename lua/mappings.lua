require "nvchad.mappings"
pcall(vim.keymap.del, {"n", "t"}, "<A-h>")
pcall(vim.keymap.del, {"n", "t"}, "<A-v>")
pcall(vim.keymap.del, {"n", "t"}, "<A-i>")


-- add yours here

local map = vim.keymap.set

-- Sincronizar raíz estilo VS Code
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local arg = vim.fn.argv(0)
    if arg ~= "" and vim.fn.isdirectory(arg) == 1 then
      vim.cmd("cd " .. vim.fn.fnameescape(vim.fn.fnamemodify(arg, ":p")))
    end
  end,
})


map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("t", "kj", "<C-\\><C-n>", { desc = "Terminal: exit to normal mode" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Iniciar Live Server en segundo plano (Versión Robusta para Linux)
map("n", "<leader>ls", function()
  vim.fn.jobstart("live-server", { detach = true })
  print("🌐 Live Server iniciado (invisible)")
end, { desc = "Start Live Server" })

-- Detener Live Server
map("n", "<leader>lk", function()
  vim.fn.system("pkill -f live-server")
  print("🛑 Live Server detenido")
end, { desc = "Stop Live Server" })

-- Gestión de Ventanas (Splits) con Espacio
map("n", "<leader>vv", "<cmd>vsplit<CR>", { desc = "Split Vertical" })
map("n", "<leader>vs", "<cmd>split<CR>", { desc = "Split Horizontal" })

-- Moverse entre ventanas (Sin usar Ctrl)
map("n", "<leader>h", "<C-w>h", { desc = "Ventana Izquierda" })
map("n", "<leader>l", "<C-w>l", { desc = "Ventana Derecha" })
map("n", "<leader>j", "<C-w>j", { desc = "Ventana Abajo" })
map("n", "<leader>k", "<C-w>k", { desc = "Ventana Arriba" })



-- Cerrar buffer actual con Alt + w
map("n", "<A-w>", function()
  require("nvchad.tabufline").close_buffer()
end, { desc = "Cerrar buffer actual" })

-- Cerrar buffer actual con Espacio + x
map("n", "<leader>x", function()
  require("nvchad.tabufline").close_buffer()
end, { desc = "Cerrar Buffer con leader x" })


-- Abrir/Cerrar barra lateral con Espacio + e (e de Explorer)
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle Explorer" })



-- Copiar buffer a varios archivos. Uso: <leader>cp file1 file2 ... > /dev/null
map("n", "<leader>cp", ":w !tee ", { desc = "Copiar archivo a múltiples destinos" })




-- =============================================================================
-- FILOSOFÍA PURE-VIM: NATIVOS PROTEGIDOS Y CAPAS SEMÁNTICAS (ALT / ALT+SHIFT)
-- =============================================================================

-- 1. CAPA ALT: NAVEGACIÓN DE INTERFAZ Y DIAGNÓSTICOS (Inspección)
-- Horizontal: Movimiento entre Buffers (Pestañas)
map("n", "<A-h>", function() require("nvchad.tabufline").prev() end, { desc = "Buffer: Anterior" })
map("n", "<A-l>", function() require("nvchad.tabufline").next() end, { desc = "Buffer: Siguiente" })

-- Vertical: Salto entre Errores/Advertencias (LSP Diagnostics)
map("n", "<A-k>", vim.diagnostic.goto_prev, { desc = "LSP: Error anterior" })
map("n", "<A-j>", vim.diagnostic.goto_next, { desc = "LSP: Error siguiente" })


-- 2. CAPA ALT + SHIFT: ACCIÓN ESTRUCTURAL (Drag & Move)
-- Vertical: Arrastrar líneas y bloques de código
map("n", "<A-J>", "<cmd>m .+1<cr>==", { desc = "Drag line down" })
map("n", "<A-K>", "<cmd>m .-2<cr>==", { desc = "Drag line up" })
map("v", "<A-J>", ":m '>+1<CR>gv=gv", { desc = "Drag block down" })
map("v", "<A-K>", ":m '<-2<CR>gv=gv", { desc = "Drag block up" })

-- Horizontal: Reordenar posición de pestañas (Buffers)
map("n", "<A-H>", function() require("nvchad.tabufline").move_buf(-1) end, { desc = "Move buffer left" })
map("n", "<A-L>", function() require("nvchad.tabufline").move_buf(1) end, { desc = "Move buffer right" })






--- COMANDO OPENALL (Versión Nueva)
-- Uso: :OpenAll      -> Abre todos los FICHEROS (con o sin extensión) e ignora carpetas.
-- Uso: :OpenAll html -> Abre solo archivos .html

vim.api.nvim_create_user_command("OpenAll", function(opts)

  local cwd = vim.fn.getcwd()
  
  -- 2. LIMPIEZA: Cierra buffers de directorios
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name ~= "" and vim.fn.isdirectory(name) == 1 then
      pcall(vim.cmd, "bd! " .. bufnr)
    end
  end

  local files_to_open = {}
  -- Usamos **/ para buscar en la carpeta actual y en cualquier subcarpeta
  local pattern = (opts.args ~= "") and ("**/*." .. opts.args) or "**/*"
  
  local all_items = vim.fn.globpath(cwd, pattern, false, true)
  
  for _, item in ipairs(all_items) do
    -- Solo archivos, ignorando carpetas pesadas o basura
    if vim.fn.isdirectory(item) == 0 and 
       not item:match("node_modules/") and 
       not item:match("%.git/") then
      table.insert(files_to_open, vim.fn.fnameescape(item))
    end
  end

  if #files_to_open > 0 then
    -- 'args' carga la lista y 'argdo e' abre los buffers
    vim.cmd("args " .. table.concat(files_to_open, " ") .. " | silent argdo e")
    vim.cmd "argument 1" 
    print("🚀 Modo VS Code: " .. #files_to_open .. " archivos cargados desde " .. vim.fn.fnamemodify(cwd, ":t"))
  else
    print("⚠️ No se encontraron archivos en: " .. cwd)
  end
end, { nargs = "?" })


 


-- Atajos para OpenAll
map("n", "<leader>oa", ":OpenAll<CR>", { desc = "Abrir todos los archivos" })
map("n", "<leader>oh", ":OpenAll html<CR>", { desc = "Abrir todos los HTML" })
map("n", "<leader>oc", ":OpenAll css<CR>", { desc = "Abrir todos los CSS" })
map("n", "<leader>oj", ":OpenAll js<CR>", { desc = "Abrir todos los JS" })






-- Ejemplo: Cambiar Alt + i por Leader + t (puedes poner las teclas que quieras)
map({ "n", "t" }, "<leader>tt", function()
  require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
end, { desc = "Terminal Flotante Personalizada" })

-- Para la horizontal (Alt + h alternativo)
map({ "n", "t" }, "<leader>th", function()
  require("nvchad.term").toggle { pos = "sp", id = "horizontalTerm" }
end, { desc = "Terminal Horizontal Personalizada" })

-- Para la vertical (Alt + v alternativo)
map({ "n", "t" }, "<leader>tv", function()
  require("nvchad.term").toggle { pos = "vsp", id = "verticalTerm" }
end, { desc = "Terminal Vertical Personalizada" })




-- Ponlo al final del archivo o con tus otros mapeos de Leader
map("n", "<leader>u", "<cmd>UndotreeToggle<cr>", { desc = "Undo: Ver árbol de historial" })
