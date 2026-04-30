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

-- Navegar por pestañas (buffers) con Shift + h / l
map("n", "L", "<cmd>bnext<CR>", { desc = "Siguiente pestaña" })
map("n", "H", "<cmd>bprevious<CR>", { desc = "Pestaña anterior" })

-- Mover buffers a los lados con Alt
map("n", "<A-l>", function()
  require("nvchad.tabufline").move_buf(1)
end, { desc = "Mover buffer a la derecha" })

map("n", "<A-h>", function()
  require("nvchad.tabufline").move_buf(-1)
end, { desc = "Mover buffer a la izquierda" })

-- Mover líneas y bloques de código (Alt + j/k)
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Mover línea abajo" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Mover línea arriba" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Mover bloque abajo" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Mover bloque arriba" })
