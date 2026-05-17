local M = {}

-- === LÓGICA HTML ===

local void_elements = {
  meta = true,
  link = true,
  br = true,
  hr = true,
  input = true,
  img = true,
  area = true,
  base = true,
  col = true,
  embed = true,
  param = true,
  source = true,
  track = true,
  wbr = true,
}

-- Determina si un nodo de Tree-sitter es un elemento hoja (sin sub-etiquetas HTML)
function M.is_leaf_element(node)
  if node:type() ~= "element" then
    return false
  end
  for child in node:iter_children() do
    if child:type() == "element" then
      return false
    end
  end
  -- Check for self-closing syntax />
  local line = vim.api.nvim_buf_get_lines(0, node:start(), node:start() + 1, false)[1]
  if line and line:match "^%s*<[^>]+/>" then
    return false
  end
  -- Check for void elements (HTML5 tags that never have content)
  local tag_name = nil
  for child in node:iter_children() do
    if child:type() == "start_tag" then
      for subchild in child:iter_children() do
        if subchild:type() == "tag_name" then
          tag_name = vim.treesitter.get_node_text(subchild, 0)
          break
        end
      end
      break
    end
  end
  if tag_name and void_elements[tag_name:lower()] then
    return false
  end
  return true
end

-- Mueve el cursor e ingresa al modo de inserción usando rangos puros de Tree-sitter
local function move_to_content(node)
  local start_tag = nil
  for child in node:iter_children() do
    if child:type() == "start_tag" then
      start_tag = child
      break
    end
  end

  if not start_tag then
    local ts_row, ts_col = node:start()
    vim.api.nvim_win_set_cursor(0, { ts_row + 1, ts_col })
    vim.cmd "normal! f>"
    vim.cmd "startinsert"
    return
  end

  local _, _, start_erow, start_ecol = start_tag:range()

  local _, _, end_srow, end_scol = node:range()
  local end_tag = nil
  for child in node:iter_children() do
    if child:type() == "end_tag" then
      end_tag = child
      break
    end
  end

  if end_tag then
    end_srow, end_scol = end_tag:start()
  end

  if start_erow == end_srow and start_ecol == end_scol then
    vim.api.nvim_win_set_cursor(0, { start_erow + 1, start_ecol })
    vim.cmd "startinsert"
  else
    vim.api.nvim_win_set_cursor(0, { end_srow + 1, end_scol })
    vim.cmd "startinsert"
  end
end

-- Comprueba si el cursor está dentro del contenido del elemento
-- (después del '>' de apertura y antes del '</' de cierre)
local function cursor_is_in_content(node, row, col)
  local start_tag = nil
  for child in node:iter_children() do
    if child:type() == "start_tag" then
      start_tag = child
      break
    end
  end
  if not start_tag then
    return false
  end
  local _, _, st_erow, st_ecol = start_tag:range()
  return row > st_erow or (row == st_erow and col >= st_ecol)
end

-- Comprueba si el cursor está dentro de la etiqueta de cierre '</tag>'
local function cursor_is_in_end_tag(node, row, col)
  for child in node:iter_children() do
    if child:type() == "end_tag" then
      local et_srow, et_scol, et_erow, et_ecol = child:range()
      if
        (row > et_srow or (row == et_srow and col >= et_scol + 1))
        and (row < et_erow or (row == et_erow and col <= et_ecol))
      then
        return true
      end
    end
  end
  return false
end

-- Busca cuál es el nodo hoja actual en el que se encuentra el cursor
local function get_current_leaf(leaves, row, col)
  for _, node in ipairs(leaves) do
    local srow = node:start()
    local erow, ecol = node:end_()
    if srow <= row and (erow > row or (erow == row and ecol >= col)) then
      return node
    end
  end
  return nil
end

-- Administra la recolección de nodos y los saltos hacia adelante o atrás en HTML
local function html_jump(direction)
  local buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]

  local ok, parser = pcall(vim.treesitter.get_parser, buf)
  if not ok or not parser then
    return
  end
  local root = parser:parse()[1]:root()

  local leaves = {}
  local function collect(node)
    if M.is_leaf_element(node) then
      table.insert(leaves, node)
    else
      for child in node:iter_children() do
        collect(child)
      end
    end
  end
  collect(root)

  local current = get_current_leaf(leaves, row, col)

  if direction == "next" then
    if current then
      if not cursor_is_in_content(current, row, col) then
        -- opening tag → jump to current element's content
        move_to_content(current)
        return
      end
      -- in content → jump to next leaf
      local found = false
      for _, node in ipairs(leaves) do
        if found then
          move_to_content(node)
          return
        end
        if node == current then
          found = true
        end
      end
    else
      -- not in any leaf → find first leaf after cursor
      for _, node in ipairs(leaves) do
        local srow, scol = node:start()
        if srow > row or (srow == row and scol >= col) then
          move_to_content(node)
          return
        end
      end
    end
  else -- direction == "prev"
    if current then
      if cursor_is_in_end_tag(current, row, col) then
        -- in closing tag → jump to current element's content
        move_to_content(current)
        return
      end
      -- in opening tag or content → jump to previous leaf
      local prev = nil
      for _, node in ipairs(leaves) do
        if node == current then
          break
        end
        prev = node
      end
      if prev then
        move_to_content(prev)
      end
    else
      -- not in any leaf → find last leaf before cursor
      local prev = nil
      for _, node in ipairs(leaves) do
        local erow, ecol = node:end_()
        if erow < row or (erow == row and ecol <= col) then
          prev = node
        end
      end
      if prev then
        move_to_content(prev)
      end
    end
  end
end

-- === LÓGICA CSS ===

local function css_jump(direction)
  if direction == "next" then
    if vim.fn.search("{", "W") > 0 then
      vim.cmd "normal! l"
    end
  else
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.fn.search("{", "bW")
    if vim.fn.search("{", "bW") > 0 then
      vim.cmd "normal! l"
    else
      vim.api.nvim_win_set_cursor(0, pos)
    end
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
    vim.cmd("normal! " .. (direction == "next" and "5j" or "5k"))
  end
end

-- === LÓGICA DE SALTO ENTRE COMILLAS ===

local function get_string_ranges(buf, root)
  local ranges = {}
  local function collect(node)
    local t = node:type()
    if
      t == "string"
      or t == "quoted_attribute_value"
      or t == "string_fragment"
      or t == "raw_string"
      or t == "template_string"
    then
      local srow, scol, erow, ecol = node:range()
      table.insert(ranges, { srow = srow, scol = scol, erow = erow, ecol = ecol })
    end
    for child in node:iter_children() do
      collect(child)
    end
  end
  collect(root)
  return ranges
end

local function get_string_ranges_fallback(buf)
  local ranges = {}
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  for lnum, line in ipairs(lines) do
    local col = 1
    while true do
      local s, e = line:find('"[^"]*"', col)
      if not s then
        break
      end
      table.insert(ranges, {
        srow = lnum - 1,
        scol = s - 1,
        erow = lnum - 1,
        ecol = e,
      })
      col = e + 1
    end
  end
  return ranges
end

local function cursor_in_range(row, col, r)
  if row < r.srow or row > r.erow then
    return false
  end
  if row == r.srow and col < r.scol then
    return false
  end
  if row == r.erow and col >= r.ecol then
    return false
  end
  return true
end

function M.quote_jump(direction)
  local buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]

  local ranges
  local ok, parser = pcall(vim.treesitter.get_parser, buf)
  if ok and parser then
    local root = parser:parse()[1]:root()
    ranges = get_string_ranges(buf, root)
  else
    ranges = get_string_ranges_fallback(buf)
  end

  if #ranges == 0 then
    return
  end

  local current_idx = nil
  for i, r in ipairs(ranges) do
    if cursor_in_range(row, col, r) then
      current_idx = i
      break
    end
  end

  local target = nil
  if direction == "next" then
    if current_idx then
      target = ranges[current_idx + 1]
    else
      for _, r in ipairs(ranges) do
        if r.srow > row or (r.srow == row and r.scol > col) then
          target = r
          break
        end
      end
    end
  else
    if current_idx and current_idx > 1 then
      target = ranges[current_idx - 1]
    else
      for i = #ranges, 1, -1 do
        local r = ranges[i]
        if r.erow < row or (r.erow == row and r.ecol <= col) then
          target = r
          break
        end
      end
    end
  end

  if not target then
    return
  end

  vim.api.nvim_win_set_cursor(0, { target.erow + 1, target.ecol - 1 })
  vim.cmd "startinsert"
end

return M
