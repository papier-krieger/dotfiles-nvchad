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

-- Cerrar la ventana actual (Buffer)
map("n", "<leader>x", "<cmd>bd<CR>", { desc = "Cerrar Buffer/Ventana" })


-- Abrir/Cerrar barra lateral con Espacio + e (e de Explorer)
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle Explorer" })



-- Navegar por pestañas (buffers) con Shift + h / l
map("n", "L", "<cmd>bnext<CR>", { desc = "Siguiente pestaña" })
map("n", "H", "<cmd>bprevious<CR>", { desc = "Pestaña anterior" })


