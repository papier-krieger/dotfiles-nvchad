require "nvchad.mappings"

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
map("n", "<A-J>", "<cmd>m .+1<cr>==", { desc = "Mover línea abajo" })
map("n", "<A-K>", "<cmd>m .-2<cr>==", { desc = "Mover línea arriba" })
map("v", "<A-J>", ":m '>+1<CR>gv=gv", { desc = "Mover bloque abajo" })
map("v", "<A-K>", ":m '<-2<CR>gv=gv", { desc = "Mover bloque arriba" })


-- --- NAVEGACIÓN DE BUFFERS (Pestañas de NvChad) ---
-- Usamos H y L directamente porque son las más rápidas
map("n", "H", function()
  require("nvchad.tabufline").prev()
end, { desc = "Anterior buffer" })

map("n", "L", function()
  require("nvchad.tabufline").next()
end, { desc = "Siguiente buffer" })



-- --- NAVEGACIÓN DE PANTALLA (Estilo Vim original en Alt) ---
-- Alt + k (Arriba) -> Tope de pantalla (H)
map("n", "<A-k>", "H", { desc = "Saltar al tope de la pantalla" })

-- Alt + m (Mitad) -> Centro de la pantalla (M)
map("n", "<A-m>", "M", { desc = "Saltar al centro de la pantalla" })

-- Alt + j (Abajo) -> Fondo de pantalla (L)
map("n", "<A-j>", "L", { desc = "Saltar al fondo de la pantalla" })


-- -- Alternativa: Navegación de diagnósticos (Errores/Warnings)
-- map("n", "<A-j>", function()
--   vim.diagnostic.goto_next({ float = { border = "rounded" } })
--   vim.cmd("norm zz") -- Centra la pantalla en el error
-- end, { desc = "Ir al siguiente error" })
--
-- map("n", "<A-k>", function()
--   vim.diagnostic.goto_prev({ float = { border = "rounded" } })
--   vim.cmd("norm zz") -- Centra la pantalla en el error
-- end, { desc = "Ir al error anterior" })


-- --- REORDENAR PESTAÑAS ---
-- Para mover la posición de la pestaña actual en la barra
map("n", "<A-H>", function()
  require("nvchad.tabufline").move_buf(-1)
end, { desc = "Desplazar pestaña a la izquierda" })


map("n", "<A-L>", function()
  require("nvchad.tabufline").move_buf(1)
end, { desc = "Desplazar pestaña a la derecha" })


-- Copiar buffer a varios archivos. Uso: <leader>cp file1 file2 ... > /dev/null
map("n", "<leader>cp", ":w !tee ", { desc = "Copiar archivo a múltiples destinos" })



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
