local M = {}

function M.is_leaf_element(node)
  if node:type() ~= "element" then return false end
  for child in node:iter_children() do
    if child:type() == "element" then return false end
  end
  return true
end

function M.goto_leaf_tag(direction)
  local buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]
  
  if vim.fn.mode() == "i" then
    col = 0
  end

  -- Asegurar que el parser existe para evitar crashes
  local ok, parser = pcall(vim.treesitter.get_parser, buf)
  if not ok or not parser then return end

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

return M 
