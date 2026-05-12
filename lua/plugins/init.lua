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

      -- Definir fuentes por defecto
      opts.sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
      }

      -- Configuracion de comportamiento (SIN autoseleccion)
      opts.preselect = cmp.PreselectMode.None
      opts.completion = {
        autocomplete = false,
        completeopt = "menu,menuone,noselect", -- 'noselect' evita que se elija uno solo
      }


      opts.mapping = {
  
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            -- Si el menú ya está abierto, el Tab confirma la selección
            cmp.confirm({ select = true })
          else
            -- VALIDACIÓN DE SEGURIDAD:
            -- Miramos si hay un espacio o si la línea está vacía antes del cursor
            local col = vim.fn.col('.') - 1
            local line = vim.fn.getline('.')
            local char_before = line:sub(col, col)

            if col == 0 or char_before:match('%s') then
              -- Si es el inicio o hay un espacio, ponemos sangría normal
              fallback()
            else
              -- SOLO si hay texto pegado al cursor, intentamos la "magia" de Emmet/LSP
              cmp.complete()
              vim.defer_fn(function()
                if cmp.visible() then
                  cmp.confirm({ select = true })
                else
                  fallback()
                end
              end, 20)
            end
          end
        end, { "i", "s" }),

        -- 1. DISPARADORES ESPECIALIZADOS
        -- Ctrl + l para LSP (Inteligencia)
        ["<C-l>"] = cmp.mapping(function()
          cmp.complete({ config = { sources = { { name = "nvim_lsp" }, { name = "nvim_lua" }, } } })
        end),

        -- Ctrl + o para Outlines / Objects (Snippets) 
        ["<C-o>"] = cmp.mapping(function()
          cmp.complete({ config = { sources = { { name = "luasnip" } } } })
        end),

        -- Ctrl + u para Url's / Paths (Rutas de archivos)
        ["<C-u>"] = cmp.mapping(function()
          cmp.complete({ config = { sources = { { name = "path" } } } })
        end),

        -- Ctrl + b para Buffer (Texto escrito)
        
        -- OPCIÓN A: Sugerencias SOLO del archivo actual
        -- ["<C-b>"] = cmp.mapping(function()
        --   cmp.complete({ config = { sources = { { name = "buffer" } } } })
        -- end),

        -- OPCIÓN B: Sugerencias de TODOS los archivos abiertos (Buffers)
        ["<C-b>"] = cmp.mapping(function()
          cmp.complete({
            config = {
              sources = {
                {
                  name = "buffer",
                  option = {
                    get_bufnrs = function()
                      return vim.api.nvim_list_bufs()
                    end
                  }
                }
              }
            }
          })
        end),

        -- 2. NAVEGACIÓN (Cuando el menú ya está abierto)

        ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        ["<A-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        ["<A-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),

        -- 3. CONFIRMACIÓN
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        
        -- 4. ABRIR AL        
        -- -- 4. ABRIR ALL
        ["<C-Space>"] = cmp.mapping.complete(),
      }

      opts.formatting = {
        format = function(entry, vim_item)
          -- Esto añade iconos bonitos y te dice de dónde viene cada sugerencia
          vim_item.menu = ({
            nvim_lsp = "[LSP]",     -- Para <C-l>
            luasnip  = "[Own]", -- Para <C-o>
            path     = "[URL]",     -- Para <C-u>
            buffer   = "[Buffer]",  -- Para <C-Space>
          })[entry.source.name]
          return vim_item
        end,
      }



      return opts
    end,

      config = function(_,opts)
    -- 1. Ejecuta la configuaracion base que definimos en 'opts' 
        local cmp = require "cmp"
        cmp.setup(opts)

    -- 2. Configuración para búsqueda con '/' (hace que C-j/k funcionen para buscar palabras en el archivo)
    cmp.setup.cmdline("/", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" },
      },
    })

    -- 3. Configuración para la barra de comandos ':' (sugiere comandos y rutas)
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = "path" },
      }, {
        { name = "cmdline" },
      }),
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


}
