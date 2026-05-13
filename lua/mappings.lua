require "nvchad.mappings"
pcall(vim.keymap.del, {"n", "t"}, "<A-h>")
pcall(vim.keymap.del, {"n", "t"}, "<A-v>")
pcall(vim.keymap.del, {"n", "t"}, "<A-i>")

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

-- === HOW TO GET OUT OF INSERT-MODE ===
map("i", "jk", "<cmd>stopinsert<cr>", { desc = "Insert → Normal mode" })

-- === HOW TO GET OUT OF TERMINAL-MODE ===
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Terminal: exit to normal mode" })
map("t", "jk", "<C-\\><C-n>", { desc = "Terminal: exit to normal mode" })

-- === ESTRUCTURAS SIMPLES ===
map("i", "ää", "{}<Left>", { desc = "Insertar {}" })
map("i", "üü", "[]<Left>", { desc = "Insertar []" })
map("i", "öö", "()<Left>", { desc = "Insertar ()" })

-- === ESTRUCTURAS DOBLES ===
map("i", "éé", "((  ))<Left><Left><Left>", { desc = "Doble parenthesis" })
map("i", "èè", "[[  ]]<Left><Left><Left>", { desc = "Doble parenthesis" })
map("i", "àà", "{{  }}<Left><Left><Left>", { desc = "Doble parenthesis" })

-- Live Server
map("n", "<leader>ls", function()
  vim.fn.jobstart("live-server", { detach = true })
  print("🌐 Live Server iniciado (invisible)")
end, { desc = "Start Live Server" })

map("n", "<leader>lk", function()
  vim.fn.system("pkill -f live-server")
  print("🛑 Live Server detenido")
end, { desc = "Stop Live Server" })

-- Moverse entre ventanas
map("n", "<leader>h", "<C-w>h", { desc = "Ventana Izquierda" })
map("n", "<leader>l", "<C-w>l", { desc = "Ventana Derecha" })
map("n", "<leader>j", "<C-w>j", { desc = "Ventana Abajo" })
map("n", "<leader>k", "<C-w>k", { desc = "Ventana Arriba" })

-- Cerrar buffers
map("n", "<A-w>", function()
  require("nvchad.tabufline").close_buffer()
end, { desc = "Cerrar buffer actual" })

map("n", "<leader>x", function()
  require("nvchad.tabufline").close_buffer()
end, { desc = "Cerrar Buffer con leader x" })

-- Explorer
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle Explorer" })

-- Copiar buffer
map("n", "<leader>cp", ":w !tee ", { desc = "Copiar archivo a múltiples destinos" })


-- =============================================================================
-- FILOSOFÍA PURE-VIM: NATIVOS PROTEGIDOS Y CAPAS SEMÁNTICAS (ALT / ALT+SHIFT)
-- =============================================================================

-- 1. CAPA ALT: NAVEGACIÓN DE INTERFAZ Y DIAGNÓSTICOS
map("n", "<A-h>", function() require("nvchad.tabufline").prev() end, { desc = "Buffer: Anterior" })
map("n", "<A-l>", function() require("nvchad.tabufline").next() end, { desc = "Buffer: Siguiente" })

map("n", "<A-j>", "<Down>", { desc = "Interfaz: Bajar" })
map("n", "<A-k>", "<Up>", { desc = "Interfaz: Subir" })

map("n", "<A-n>", function()
  vim.diagnostic.jump({ count = 1, severity = { min = vim.diagnostic.severity.HINT } })
end, { desc = "LSP/Lint: Siguiente error o advertencia" })

map("n", "<A-p>", function()
  vim.diagnostic.jump({ count = -1, severity = { min = vim.diagnostic.severity.HINT } })
end, { desc = "LSP/Lint: Error o advertencia anterior" })

map("n", "<A-d>", function() vim.diagnostic.open_float() end, { desc = "LSP/Lint: Ver detalle del error" })

map("n", "<leader>d", "<cmd>ConformInfo<cr>", { desc = "Formatter: Ver reporte de fallos (Conform)" })

-- Navegación Inteligente (insert mode)
map("i", "<A-n>", function() require("utils.nav").smart_jump("next") end, { silent = true, desc = "Nav: Siguiente estructura" })
map("i", "<A-p>", function() require("utils.nav").smart_jump("prev") end, { silent = true, desc = "Nav: Estructura anterior" })

-- Quote jump (insert mode) — new mappings for nav.quote_jump
-- map("i", "<A-l>", function() require("utils.nav").quote_jump("next") end, { silent = true, desc = "Nav: Siguiente comilla" })
-- map("i", "<A-h>", function() require("utils.nav").quote_jump("prev") end, { silent = true, desc = "Nav: Comilla anterior" })


-- 2. CAPA ALT + SHIFT: ACCIÓN ESTRUCTURAL (Drag & Move)
map("n", "<A-J>", "<cmd>m .+1<cr>==", { desc = "Drag line down" })
map("n", "<A-K>", "<cmd>m .-2<cr>==", { desc = "Drag line up" })
map("v", "<A-J>", ":m '>+1<CR>gv=gv", { desc = "Drag block down" })
map("v", "<A-K>", ":m '<-2<CR>gv=gv", { desc = "Drag block up" })

map("n", "<A-H>", function() require("nvchad.tabufline").move_buf(-1) end, { desc = "Move buffer left" })
map("n", "<A-L>", function() require("nvchad.tabufline").move_buf(1) end, { desc = "Move buffer right" })


-- 3. CAPA CTRL: MOVIMIENTO EN INSERT MODE
-- map("i", "<C-n>", '<C-o>/""<CR><Right>', { desc = 'Insert: siguiente ""' })
-- map("i", "<C-p>", '<C-o>h<C-o>?""<CR><Right>', { desc = 'Insert: anterior ""' })
map("i", "<C-n>", function() require("utils.nav").quote_jump("next") end, { silent = true, desc = 'Insert: siguiente ""' })
map("i", "<C-p>", function() require("utils.nav").quote_jump("prev") end, { silent = true, desc = 'Insert: anterior ""' })


-- === COMANDO OPENALL ===
vim.api.nvim_create_user_command("OpenAll", function(opts)
  local cwd = vim.fn.getcwd()

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name ~= "" and vim.fn.isdirectory(name) == 1 then
      pcall(vim.cmd, "bd! " .. bufnr)
    end
  end

  local files_to_open = {}
  local pattern = (opts.args ~= "") and ("**/*." .. opts.args) or "**/*"
  local all_items = vim.fn.globpath(cwd, pattern, false, true)

  for _, item in ipairs(all_items) do
    if vim.fn.isdirectory(item) == 0 and
       not item:match("node_modules/") and
       not item:match("%.git/") then
      table.insert(files_to_open, vim.fn.fnameescape(item))
    end
  end

  if #files_to_open > 0 then
    vim.cmd("args " .. table.concat(files_to_open, " ") .. " | silent argdo e")
    vim.cmd "argument 1"
    print("🚀 Modo VS Code: " .. #files_to_open .. " archivos cargados desde " .. vim.fn.fnamemodify(cwd, ":t"))
  else
    print("⚠️ No se encontraron archivos en: " .. cwd)
  end
end, { nargs = "?" })

map("n", "<leader>oa", ":OpenAll<CR>", { desc = "Abrir todos los archivos" })
map("n", "<leader>oh", ":OpenAll html<CR>", { desc = "Abrir todos los HTML" })
map("n", "<leader>oc", ":OpenAll css<CR>", { desc = "Abrir todos los CSS" })
map("n", "<leader>oj", ":OpenAll js<CR>", { desc = "Abrir todos los JS" })


-- === TERMINALES ===
map({ "n", "t" }, "<leader>tt", function()
  require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
end, { desc = "Terminal Flotante Personalizada" })

map({ "n", "t" }, "<leader>th", function()
  require("nvchad.term").toggle { pos = "sp", id = "horizontalTerm" }
end, { desc = "Terminal Horizontal Personalizada" })

map({ "n", "t" }, "<leader>tv", function()
  require("nvchad.term").toggle { pos = "vsp", id = "verticalTerm" }
end, { desc = "Terminal Vertical Personalizada" })


-- Undotree
map("n", "<leader>u", "<cmd>UndotreeToggle<cr>", { desc = "Undo: Ver árbol de historial" })

-- Toggle autopairs
map("n", "yoa", function()
  local ap = require("nvim-autopairs")
  if ap.state.disabled then
    ap.enable()
    print("autopairs ON")
  else
    ap.disable()
    print("autopairs OFF")
  end
end, { desc = "Toggle autopairs" })

map("n", "]oa", function()
  require("nvim-autopairs").enable()
  print("autopairs ON")
end, { desc = "autopairs ON" })

map("n", "[oa", function()
  require("nvim-autopairs").disable()
  print("autopairs OFF")
end, { desc = "autopairs OFF" })


-- === COMANDO :H - PANEL DE CONTROL DE TERMINAL ===
vim.api.nvim_create_user_command('H', function()
  vim.opt.shortmess:append "A"
  vim.cmd('edit ~/.bash_history')
  vim.cmd('setlocal noswapfile')
  vim.cmd('setlocal autoread')
  vim.cmd('enew')
  vim.cmd('term')
  vim.cmd('bprevious')
  vim.opt.shortmess:remove "A"
  print("Modo Historial: Usa Tab para cambiar a la Terminal")
end, {})
