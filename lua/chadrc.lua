-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "onedark",

	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },
}

-- M.nvdash = { load_on_startup = true }
-- M.ui = {
--       tabufline = {
--          lazyload = false
--      }
-- }


M.plugins = {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      -- Esto desactiva que el menú aparezca solo
      opts.completion = { autocomplete = false }
    end,
  },
}


M.term = {
  float = {
    relative = "editor",
    row = 0.1,
    col = 0.1,
    width = 0.8,
    height = 0.6,
    border = "single",
    border = "rounded",
    -- border = {"╔", "═" ,"╗", "║", "╝", "═", "╚", "║"}
  },
}


return M
