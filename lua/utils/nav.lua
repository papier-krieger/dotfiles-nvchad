local M = {}
-- === LÓGICA HTML ===
function M.is_leaf_element(node)
  if node:type() ~= "element" then return false end
  for child in node:iter_children() do
    if child:type() == "element" then return false end
  end
  local line = vim.api.nvim_buf_get_lines(0, node:start(), node:start() + 1, false)[1]
  if line:match("^%s*<[^>]+/>") then return false end
  return true
end

local function move_to_content(nrow, ncol)
  vim.api.nvim_win_set_cursor(0, { nrow + 1, ncol })
  vim.cmd("normal! f>l")  -- move inside tag
  vim.cmd("normal! t<l")  -- land on last content char, then one right
  vim.cmd("startinsert")
end

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

local function html_jump(direction)
  local buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]

  local ok, parser = pcall(vim.treesitter.get_parser, buf)
  if not ok or not parser then return end
  local root = parser:parse()[1]:root()

  local leaves = {}
  local function collect(node)
    if M.is_leaf_element(node) then table.insert(leaves, node)
    else for child in node:iter_children() do collect(child) end end
  end
  collect(root)

  local current = get_current_leaf(leaves, row, col)

  if direction == "next" then
    local found_current = (current == nil)
    for _, node in ipairs(leaves) do
      if found_current then
        local nrow, ncol = node:start()
        move_to_content(nrow, ncol)
        return
      end
      if node == current then found_current = true end
    end
  else
    local prev = nil
    for _, node in ipairs(leaves) do
      if node == current then break end
      prev = node
    end
    if prev then
      local nrow, ncol = prev:start()
      move_to_content(nrow, ncol)
    end
  end
end

-- === LÓGICA CSS ===
local function css_jump(direction)
  if direction == "next" then
    if vim.fn.search("{", "W") > 0 then
      vim.cmd("normal! l")
    end
  else
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.fn.search("{", "bW")
    if vim.fn.search("{", "bW") > 0 then
      vim.cmd("normal! l")
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
    -- treesitter string node names vary by language, cover the common ones
    if t == "string" or t == "quoted_attribute_value" or t == "string_fragment"
      or t == "raw_string" or t == "template_string" then
      local srow, scol, erow, ecol = node:range()
      table.insert(ranges, { srow = srow, scol = scol, erow = erow, ecol = ecol })
    end
    for child in node:iter_children() do collect(child) end
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
      if not s then break end
      table.insert(ranges, {
        srow = lnum - 1, scol = s - 1,
        erow = lnum - 1, ecol = e,
      })
      col = e + 1
    end
  end
  return ranges
end

local function cursor_in_range(row, col, r)
  if row < r.srow or row > r.erow then return false end
  if row == r.srow and col < r.scol then return false end
  if row == r.erow and col >= r.ecol then return false end
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

  if #ranges == 0 then return end

  -- find which range the cursor is currently inside
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
      -- not inside any string: jump to the first one ahead
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
      -- not inside any string: jump to the first one behind
      for i = #ranges, 1, -1 do
        local r = ranges[i]
        if r.erow < row or (r.erow == row and r.ecol <= col) then
          target = r
          break
        end
      end
    end
  end

  if not target then return end

  -- land just before the closing quote: ecol - 1
  vim.api.nvim_win_set_cursor(0, { target.erow + 1, target.ecol - 1 })
  vim.cmd("startinsert")
end






return M
