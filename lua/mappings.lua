require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

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


-- Mover líneas y bloques de código (Alt + j/k)
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Mover línea abajo" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Mover línea arriba" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Mover bloque abajo" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Mover bloque arriba" })


-- Navegar por pestañas (buffers) siguiendo el orden visual de NvChad
map("n", "L", function()
  require("nvchad.tabufline").next()
end, { desc = "Siguiente buffer (visual)" })

map("n", "H", function()
  require("nvchad.tabufline").prev()
end, { desc = "Anterior buffer (visual)" })


-- Mover la posición del buffer (Reordenar las pestañas)
map("n", "<A-l>", function()
  require("nvchad.tabufline").move_buf(1)
end, { desc = "Desplazar pestaña a la derecha" })

map("n", "<A-h>", function()
  require("nvchad.tabufline").move_buf(-1)
end, { desc = "Desplazar pestaña a la izquierda" })


-- Copiar buffer a varios archivos. Uso: <leader>cp file1 file2 ... > /dev/null
map("n", "<leader>cp", ":w !tee ", { desc = "Copiar archivo a múltiples destinos" })



-- 1. Comando Maestro Inteligente (Acepta extensión opcional)
-- Uso: :OpenAll         -> Abre todos los archivos con extensión (*.*)
-- Uso: :OpenAll html    -> Abre solo archivos .html
-- Nota: Limpia buffers de carpetas y evita abrir patrones vacíos.
vim.api.nvim_create_user_command("OpenAll", function(opts)
  -- Fuerza a Neovim a entrar en la carpeta del archivo actual (Sincroniza el Root)
  vim.cmd "cd %:p:h"

  -- LIMPIEZA: Recorre buffers y cierra directorios (netrw/nvim-tree) para limpiar la barra superior
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name ~= "" and vim.fn.isdirectory(name) == 1 then
      pcall(vim.cmd, "bd! " .. bufnr) -- Usa pcall y bd! para forzar cierre sin errores
    end
  end

  -- DEFINICIÓN: Si no se pasa argumento usa *.* (archivos), si se pasa usa *.ext
  local pattern = (opts.args ~= "") and ("*." .. opts.args) or "*.*"
  
  -- SEGURIDAD: Comprueba si existen archivos antes de intentar abrirlos (evita buffers fantasma)
  local has_files = #vim.fn.glob(pattern, false, true) > 0

  if has_files then
    -- Carga los archivos en la lista de argumentos y los abre todos silenciosamente
    vim.cmd("args " .. pattern .. " | silent argdo e")
    print("📂 Archivos [" .. pattern .. "] cargados en: " .. vim.fn.getcwd())
  else
    -- Aviso amigable si la carpeta no contiene archivos de ese tipo
    print("⚠️ No se encontraron archivos con el patrón: " .. pattern)
  end
end, { nargs = "?" })

-- 2. Atajos Rápidos (Presionar rápido para evitar modo Insertar con 'o')
map("n", "<leader>oa", ":OpenAll<CR>", { desc = "Abrir todos los archivos (*.*)" })
map("n", "<leader>oh", ":OpenAll html<CR>", { desc = "Abrir todos los HTML" })
map("n", "<leader>oc", ":OpenAll css<CR>", { desc = "Abrir todos los CSS" })
map("n", "<leader>oj", ":OpenAll js<CR>", { desc = "Abrir todos los JS" })


