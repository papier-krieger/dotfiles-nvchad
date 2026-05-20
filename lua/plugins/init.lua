return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvchad/nvim-colorizer.lua",
    opts = {
      user_default_options = {
        names = false,
        RRGGBBAA = true,
        rgb_fn = true,
        hsl_fn = true,
        css = true,
        sass = { enable = true, parsers = { "css" } },
      },
    },
  },

  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require "cmp"
      local types = require "cmp.types"
      local kind = types.lsp.CompletionItemKind

      -- nil = Todo | "nvim_lsp" | "friendly" | "diy" | "path" | "buffer"
      -- "LSP_Functions" | "LSP_Variables" | "LSP_Values"
      local current_filter = nil
      local SELECT_MODE = true
      -- local SELECT_MODE = false

      -- 1. FUENTES
      opts.sources = cmp.config.sources {
        {
          name = "nvim_lsp",
          entry_filter = function(entry)
            -- excluir snippets del LSP siempre, excepto emmet_ls
            if entry:get_kind() == kind.Snippet then
              local client_name = entry.source.source.client.name
              if client_name ~= "emmet_ls" then
                return false
              end
            end

            if current_filter == nil or current_filter == "nvim_lsp" then
              return true
            end
            if current_filter == "LSP_Functions" then
              local k = entry:get_kind()
              return k == kind.Method or k == kind.Function or k == kind.Constructor
            end
            if current_filter == "LSP_Variables" then
              local k = entry:get_kind()
              return k == kind.Variable or k == kind.Constant or k == kind.Field or k == kind.Property
            end
            if current_filter == "LSP_Values" then
              local k = entry:get_kind()
              return k == kind.Value or k == kind.Enum or k == kind.EnumMember
            end
            return false
          end,
        },
        {
          name = "luasnip",
          entry_filter = function(entry)
            -- bloquear si no corresponde al filtro activo
            if
              current_filter == "nvim_lsp"
              or current_filter == "path"
              or current_filter == "buffer"
              or current_filter == "LSP_Functions"
              or current_filter == "LSP_Variables"
              or current_filter == "LSP_Values"
            then
              return false
            end

            local item = entry:get_completion_item()
            local is_diy = item.label and item.label:find "^diy%." ~= nil

            -- filtro DIY: solo diy.
            if current_filter == "diy" then
              return is_diy
            end

            -- filtro friendly: todo menos diy.
            if current_filter == "friendly" then
              return not is_diy
            end

            -- filtro nil (A-a): todo
            return true
          end,
        },
        {
          name = "path",
          entry_filter = function()
            return current_filter == nil or current_filter == "path"
          end,
        },
        {
          name = "buffer",
          entry_filter = function()
            return current_filter == nil or current_filter == "buffer"
          end,
        },
      }

      opts.preselect = cmp.PreselectMode.None
      opts.completion = {
        autocomplete = false,
        completeopt = SELECT_MODE and "menu,menuone,select" or "menu,menuone,noselect",
      }

      -- 2. MAPPINGS
      opts.mapping = {
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item { behavior = cmp.SelectBehavior.Select }
          else
            local col = vim.fn.col "." - 1
            local line = vim.fn.getline "."
            if col == 0 or line:sub(col, col):match "%s" then
              fallback()
            else
              cmp.complete()
              vim.defer_fn(function()
                if cmp.visible() then
                  cmp.confirm { select = true }
                else
                  fallback()
                end
              end, 20)
            end
          end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item { behavior = cmp.SelectBehavior.Select }
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<A-j>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item { behavior = cmp.SelectBehavior.Select }
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<A-k>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item { behavior = cmp.SelectBehavior.Select }
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<CR>"] = cmp.mapping(function(fallback)
          if cmp.visible() and cmp.get_selected_entry() then
            cmp.confirm { select = false }
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<Esc>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.close()
          end
          fallback()
        end, { "i", "s" }),

        -- LSP puro — como C-Space en VSCode
        ["<C-Space>"] = cmp.mapping(function()
          if cmp.visible() then
            cmp.close()
          end
          current_filter = "nvim_lsp"
          cmp.complete()
        end, { "i", "s" }),
      }

      -- 3. FILTROS ALT
      local function create_filter(filter_target)
        return function()
          if filter_target == "path" then
            require "cmp_path"
          end
          if cmp.visible() then
            cmp.close()
          end
          current_filter = filter_target
          cmp.complete()
          if SELECT_MODE and filter_target == "diy" then
            vim.defer_fn(function()
              if cmp.visible() then
                cmp.select_next_item { behavior = cmp.SelectBehavior.Select }
              end
            end, 35)
          end
        end
      end

      -- LSP puro (igual que C-Space pero con Alt)
      vim.keymap.set("i", "<A-Space>", function()
        if cmp.visible() then
          cmp.close()
        end
        current_filter = "nvim_lsp"
        cmp.complete()
      end, { desc = "CMP: LSP puro" })

      -- Todo
      vim.keymap.set("i", "<A-a>", function()
        if cmp.visible() then
          cmp.close()
        end
        current_filter = nil
        cmp.complete()
      end, { desc = "CMP: All" })

      vim.keymap.set("i", "<A-s>", create_filter "friendly", { desc = "CMP: Snippets (friendly)" })
      vim.keymap.set("i", "<A-d>", create_filter "diy", { desc = "CMP: Snippets DIY" })
      vim.keymap.set("i", "<A-f>", create_filter "LSP_Functions", { desc = "CMP: LSP Functions" })
      vim.keymap.set("i", "<A-x>", create_filter "LSP_Variables", { desc = "CMP: LSP Variables" })
      vim.keymap.set("i", "<A-v>", create_filter "LSP_Values", { desc = "CMP: LSP Values" })
      vim.keymap.set("i", "<A-w>", create_filter "buffer", { desc = "CMP: Words (buffer)" })
      vim.keymap.set("i", "<A-r>", create_filter "path", { desc = "CMP: Paths (rutas)" })

      -- 4. FORMATTING
      opts.formatting = {
        format = function(entry, vim_item)
          local lsp_label = "[Genius]"
          if current_filter == "LSP_Functions" then
            lsp_label = "[Functions]"
          elseif current_filter == "LSP_Variables" then
            lsp_label = "[Variables]"
          elseif current_filter == "LSP_Values" then
            lsp_label = "[Values]"
          end
          vim_item.menu = ({
            nvim_lsp = lsp_label,
            luasnip = current_filter == "diy" and "[DIY]" or "[Snips]",
            path = "[Files]",
            buffer = "[Words]",
          })[entry.source.name]
          return vim_item
        end,
      }

      return opts
    end,

    config = function(_, opts)
      local cmp = require "cmp"
      cmp.setup(opts)
      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
      })
    end,
  },

  { "hrsh7th/cmp-path" },

  {
    "kylechui/nvim-surround",
    version = "*", -- Usa la última versión estable
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup {}
    end,
  },

  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "javascript", "typescript", "javascriptreact", "typescriptreact", "svelte", "vue" },
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      update_focused_file = {
        enable = true,
        update_root = true,
      },

      hijack_cursor = true,
      hijack_directories = {
        enable = true,
        auto_open = true,
      },
    },
  },

  {
    "tpope/vim-unimpaired",
    event = "VeryLazy",
  },

  {
    "karb94/neoscroll.nvim",
    keys = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "zt", "zz", "zb" },

    config = function()
      local neoscroll = require "neoscroll"
      neoscroll.setup {
        hide_cursor = true,
        stop_eof = true,
        respect_scrolloff = true,
        easing_function = "quadratic",
      }

      -- Esta es la nueva forma oficial en lugar de set_mappings
      local keymap = {
        ["<C-u>"] = function()
          neoscroll.ctrl_u { duration = 250 }
        end,
        ["<C-d>"] = function()
          neoscroll.ctrl_d { duration = 250 }
        end,
        ["<C-b>"] = function()
          neoscroll.ctrl_b { duration = 450 }
        end,
        ["<C-f>"] = function()
          neoscroll.ctrl_f { duration = 450 }
        end,
        ["zt"] = function()
          neoscroll.zt { half_win_duration = 250 }
        end,
        ["zz"] = function()
          neoscroll.zz { half_win_duration = 250 }
        end,
        ["zb"] = function()
          neoscroll.zb { half_win_duration = 250 }
        end,
      }

      local modes = { "n", "v", "x" }
      for key, func in pairs(keymap) do
        vim.keymap.set(modes, key, func)
      end
    end,
  },

  {
    "mbbill/undotree",
    lazy = false,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup {}
    end,
  },

  {
    "andymass/vim-matchup",
    lazy = false, -- Importante para que % funcione desde el inicio
    config = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = "nvim-treesitter/nvim-treesitter",
    event = "BufReadPost",
    config = function()
      local select = require "nvim-treesitter-textobjects.select"
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

  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      opts.defaults = opts.defaults or {}
      opts.defaults.mappings = {
        i = {
          ["<C-j>"] = require("telescope.actions").move_selection_next,
          ["<C-k>"] = require("telescope.actions").move_selection_previous,
        },
      }
    end,
  },

  {
    "L3MON4D3/LuaSnip",
    config = function(_, opts)
      require("luasnip").setup(opts)
      require("luasnip.loaders.from_vscode").load()
      require("luasnip.loaders.from_lua").load { paths = "~/.config/nvchad/lua/snippets" }
    end,
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile", "BufWritePost" },
    config = function()
      local lint = require "lint"

      -- Conectamos los archivos HTML con el htmlhint que instalaste en Mason
      lint.linters_by_ft = {
        html = { "htmlhint" },
      }

      -- Automatización: Analiza el archivo al abrir, guardar o salir del modo inserto
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
