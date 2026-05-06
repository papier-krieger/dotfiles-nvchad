local function is_leaf_element(node)
  if node:type() ~= "element" then return false end
  for child in node:iter_children() do
    if child:type() == "element" then return false end
  end
  return true
end

local function goto_leaf_tag(direction)
  local buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]
  if vim.fn.mode() == "i" then
    col = 0
  end
  local root = vim.treesitter.get_parser(buf):parse()[1]:root()
  local leaves = {}
  local function collect(node)
    if is_leaf_element(node) then
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

vim.keymap.set("i", "<C-n>", function() goto_leaf_tag("next") end, { silent = true, desc = "Next leaf tag" })
vim.keymap.set("i", "<C-b>", function() goto_leaf_tag("prev") end, { silent = true, desc = "Prev leaf tag" })

return {
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = "nvim-treesitter/nvim-treesitter",
    event = "BufReadPost",
    config = function()
      local select = require("nvim-treesitter-textobjects.select")
      local keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["ab"] = "@block.outer",
        ["ib"] = "@block.inner",
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
      }
      for key, query in pairs(keymaps) do
        vim.keymap.set({ "x", "o" }, key, function()
          select.select_textobject(query, "textobjects")
        end)
      end
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      return opts
    end,
  },
}
