return {
  {
    "stevearc/conform.nvim",
    event = 'BufWritePre',
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

      -- 1. FUENTES GLOBALES
      opts.sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
      }
      opts.preselect = cmp.PreselectMode.None
      opts.completion = {
        autocomplete = false,
        completeopt = "menu,menuone,noselect",
      }

      -- 2. TU CAPA CTRL SEMÁNTICA + TABLA HÍBRIDA + DUPLEX ALT DE NAVEGACIÓN
      opts.mapping = {
        -- El Tab Híbrido Perfecto
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            -- SI ESTÁ ABIERTO: Navega al siguiente elemento de la lista
            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
          else
            local col = vim.fn.col('.') - 1
            local line = vim.fn.getline('.')
            if col == 0 or line:sub(col, col):match('%s') then
              -- SI ESTÁ VACÍO O ESPACIOS: Tabulación física normal
              fallback()
            else
              -- SI HAY TEXTO: Abre y confirma instantáneamente el primer elemento
              cmp.complete()
              vim.defer_fn(function()
                if cmp.visible() then cmp.confirm({ select = true }) else fallback() end
              end, 20)
            end
          end
        end, { "i", "s" }),

        -- Shift+Tab: Navega hacia atrás (prev) en la lista si está abierta
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
          else
            fallback()
          end
        end, { "i", "s" }),

        -- NAVEGACIÓN ALTERNATIVA CON ALT (Duplica la lógica de Tab y Shift+Tab)
        ["<A-j>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
          else
            fallback() -- Si no está abierto, Alt+j actúa normal (o no hace nada)
          end
        end, { "i", "s" }),

        ["<A-k>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
          else
            fallback() -- Si no está abierto, Alt+k actúa normal (o no hace nada)
          end
        end, { "i", "s" }),

        -- Decisiones explícitas de confirmación y cierre
        ["<CR>"] = cmp.mapping(function(fallback)
          if cmp.visible() and cmp.get_selected_entry() then
            cmp.confirm({ select = false })
          else
            fallback() -- Enter normal si el menú está cerrado o nada marcado
          end
        end, { "i", "s" }),

        ["<Esc>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.close()
          end
          fallback()
        end, { "i", "s" }),

        -- TUS DISPARADORES SEMÁNTICOS CON CTRL (100% PORTABLES)
        ["<C-Space>"] = cmp.mapping.complete(), -- Omni-completion unificada (Mezcla total)

        ["<C-g>"] = cmp.mapping(function() -- Genius (LSP Dedicado)
          cmp.complete({ config = { sources = { { name = "nvim_lsp" } } } })
        end),

        ["<C-f>"] = cmp.mapping(function() -- Files y Rutas (Paths)
          cmp.complete({ config = { sources = { { name = "path" } } } })
        end),

        ["<C-b>"] = cmp.mapping(function() -- Buffer (Words / Palabras del archivo)
          cmp.complete({ config = { sources = { { name = "buffer", option = { get_bufnrs = vim.api.nvim_list_bufs } } } } })
        end),

        ["<C-e>"] = cmp.mapping(function() -- Expand (Snippets / Luasnip)
          cmp.complete({ config = { sources = { { name = "luasnip" } } } })
        end),
      }

      -- 3. INTERFAZ VISUAL COHERENTE CON TUS MNEMÓNICAS
      opts.formatting = {
        format = function(entry, vim_item)
          vim_item.menu = ({
            nvim_lsp = "[Genius]",   -- Sincronizado con C-g
            luasnip  = "[Expand]",   -- Sincronizado con C-e
            path     = "[Files]",    -- Sincronizado con C-f
            buffer   = "[Buffer]",   -- Sincronizado con C-b
          })[entry.source.name]
          return vim_item
        end,
      }
      return opts
    end,

    config = function(_, opts)
      local cmp = require "cmp"
      cmp.setup(opts)
      cmp.setup.cmdline("/", { mapping = cmp.mapping.preset.cmdline(), sources = { { name = "buffer" } } })
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
      })
    end,
  },

  {
    "kylechui/nvim-surround",
    version = "*", -- Usa la última versión estable
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
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
      local neoscroll = require('neoscroll')
      neoscroll.setup({
        hide_cursor = true,
        stop_eof = true,
        respect_scrolloff = true,
        easing_function = "quadratic",
      })

      -- Esta es la nueva forma oficial en lugar de set_mappings
      local keymap = {
        ["<C-u>"] = function() neoscroll.ctrl_u({ duration = 250 }) end,
        ["<C-d>"] = function() neoscroll.ctrl_d({ duration = 250 }) end,
        ["<C-b>"] = function() neoscroll.ctrl_b({ duration = 450 }) end,
        ["<C-f>"] = function() neoscroll.ctrl_f({ duration = 450 }) end,
        ["zt"]    = function() neoscroll.zt({ half_win_duration = 250 }) end,
        ["zz"]    = function() neoscroll.zz({ half_win_duration = 250 }) end,
        ["zb"]    = function() neoscroll.zb({ half_win_duration = 250 }) end,
      }

      local modes = { 'n', 'v', 'x' }
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
      require("nvim-autopairs").setup({})
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

  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      opts.defaults = opts.defaults or {}
      opts.defaults.mappings = {
        i = {
          ["<C-j>"] = require("telescope.actions").move_selection_next,
          ["<C-k>"] = require("telescope.actions").move_selection_previous,
        }
      }
    end,
  },

  {
    "L3MON4D3/LuaSnip",
    config = function(_, opts)
      require("luasnip").setup(opts)
      require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvchad/lua/snippets" })
    end,
  },


  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile", "BufWritePost" },
    config = function()
      local lint = require("lint")

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
