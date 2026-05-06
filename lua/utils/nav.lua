local M = {}

-- === LÓGICA HTML  ===
function M.is_leaf_element(node)
  if node:type() ~= "element" then return false end
  for child in node:iter_children() do
    if child:type() == "element" then return false end
  end
  return true
end

local function html_jump(direction)
  local buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]
  if vim.fn.mode() == "i" then col = 0 end

  local ok, parser = pcall(vim.treesitter.get_parser, buf)
  if not ok or not parser then return end

  local root = parser:parse()[1]:root() -- Si falla en el futuro, usar: parser:parse():root()
  local leaves = {}

  local function collect(node)
    if M.is_leaf_element(node) then table.insert(leaves, node)
    else for child in node:iter_children() do collect(child) end end
  end
  collect(root)

  if direction == "next" then
    for _, node in ipairs(leaves) do
      local nrow, ncol = node:start()
      if nrow > row then
        vim.api.nvim_win_set_cursor(0, { nrow + 1, ncol })
        vim.cmd("normal! f>l")
        vim.cmd("startinsert")
        return
      end
    end
  else
    for i = #leaves, 1, -1 do
      local node = leaves[i]
      local nrow, ncol = node:start()
      if nrow < row or (nrow == row and ncol < col) then
        vim.api.nvim_win_set_cursor(0, { nrow + 1, ncol })
        vim.cmd("normal! f>l")
        vim.cmd("startinsert")
        return
      end
    end
  end
end


-- === LÓGICA CSS ===
local function css_jump(direction)
  if direction == "next" then
    -- Salto adelante: busca la siguiente llave y entra
    vim.fn.search("{", "W")
    vim.cmd("normal! l")
  else
    -- Salto atrás: 
    -- 1. Buscamos la llave '{' actual para asegurarnos de estar "detrás" de ella
    vim.fn.search("{", "bW")
    -- 2. Ahora que estamos en la '{' actual, buscamos la '{' del bloque anterior
    -- Usamos 'bW' otra vez para saltar a la de arriba
    vim.fn.search("{", "bW")
    -- 3. Entramos después de la llave encontrada
    vim.cmd("normal! l")
  end
end



-- === LÓGICA DE SALTO INTELIGENTE (EL SELECTOR) ===
function M.smart_jump(direction)
  local ft = vim.bo.filetype

  if ft == "html" or ft == "xml" then
    html_jump(direction)
  elseif ft == "css" or ft == "scss" then
    css_jump(direction)
  else
    -- Salto genérico para otros archivos
    vim.cmd("normal! " .. (direction == "next" and "5j" or "5k"))
  end
  
  -- Asegurar que terminamos en modo insertar si venimos de ahí
  if vim.fn.mode() == "i" or vim.api.nvim_get_mode().mode == "i" then
    vim.cmd("startinsert")
  end
end

return M
