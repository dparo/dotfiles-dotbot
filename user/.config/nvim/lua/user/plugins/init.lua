local generic = {
    ----
    ---- Must have utility plugins that integrates/improve the core experience
    ----

    -- A high-performance #RRGGBB format color highlighter for Neovim which has no external dependencies! Written in performant Luajit
    {
        "NvChad/nvim-colorizer.lua",
        config = function()
            require("colorizer").setup()
        end,
    },

    { "nathom/filetype.nvim" },

    --- Trim trailing whitespaces
    {
        "cappyzawa/trim.nvim",
        config = function()
            require("trim").setup {
                disable = {},
                patterns = {
                    [[%s/\s\+$//e]], -- remove unwanted spaces
                    [[%s/\($\n\s*\)\+\%$//]], -- trim last line
                    [[%s/\%^\n\+//]], -- trim first line
                    [[%s/\(\n\n\n\)\n\+/\1/]], -- replace more than 3 blank lines with 3 blank lines
                },
            }
        end,
    },

    -- Many people really want to do tnoremap <Esc> <C-\><C-n>. However, there is a few command line utilties
    -- they rely on also use <Esc>.
    -- This is a plugin that let you map <Esc> to <C-\><C-n> except when these command line utilties are running in the termial
    {
        "sychen52/smart-term-esc.nvim",
        config = function()
            require("smart-term-esc").setup {
                key = "<Esc>",
                except = { "nvim", "fzf", "lazygit" },
            }
        end,
    },

    { "mbbill/undotree" },
    {
        "junegunn/fzf.vim",
        requires = {
            {
                "$USER_DOTFILES_LOCATION/core/vendor/fzf",
                run = 'cd "$USER_DOTFILES_LOCATIONcore/vendor/fzf" && ./install --xdg --key-bindings --completion --update-rc --no-zsh --no-bash',
            },
        },
        config = function()
            vim.g.fzf_buffers_jump = 1
            vim.g.fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'
            vim.g.fzf_tags_command = "ctags -R"
            vim.g.fzf_commands_expect = "alt-enter,ctrl-x"
            --vim.g.fzf_layout = { window = { width = 0.8, height = 0.8 } }
            vim.g.fzf_layout = { down = "~80%" }
            vim.g.fzf_action = {
                ["ctrl-h"] = "split",
                ["ctrl-q"] = vim.NIL,
                ["ctrl-t"] = "tab split",
                ["ctrl-v"] = "vsplit",
            }

            -- Changes default command line options for Ripgre and Ag
            vim.cmd [[
                function! RipgrepFzf(query, fullscreen)
                    let command_fmt = 'rg --follow --hidden --glob=!.git/ --column --line-number --no-heading --color=always --smart-case -- %s || true'
                    let initial_command = printf(command_fmt, shellescape(a:query))
                    let reload_command = printf(command_fmt, '{q}')
                    let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
                    call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
                endfunction

                function! AgFzf(query, fullscreen)
                    let command_fmt = 'ag --nobreak --nogroup --follow --no-heading --hidden --ignore .git/ --column --line-number --color --smart-case %s || true'
                    let initial_command = printf(command_fmt, shellescape(a:query))
                    let reload_command = printf(command_fmt, '{q}')
                    let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
                    call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
                endfunction

                command! -nargs=* -bang Rg call RipgrepFzf(<q-args>, <bang>0)
                command! -nargs=* -bang Ag call AgFzf(<q-args>, <bang>0)
            ]]
        end,
    },

    {
        "stsewd/fzf-checkout.vim",
        requires = { "junegunn/fzf.vim" },
    },

    -- Utils functions for common Unix like utilities such as mkdir, touch, mv inside of vim
    { "tpope/vim-eunuch" },
    { "tpope/vim-dispatch", opt = true, cmd = { "Dispatch", "Make", "Focus", "Start" } },
    { "nvim-lua/plenary.nvim" },
    {
        "rcarriga/nvim-notify",
        config = function()
            require("notify").setup {
                stages = "slide",
                background_colour = "#000000",
            }
        end,
    },
    { "nvim-lua/popup.nvim", requires = { "nvim-lua/plenary.nvim" } },
    {
        "nvim-telescope/telescope.nvim",
        requires = { "nvim-lua/plenary.nvim" },
        config = function()
            require "user.plugins.configs.telescope"
        end,
    },

    --  With the release of Neovim 0.6 we were given the start of extensible core UI hooks
    -- (vim.ui.select and vim.ui.input). They exist to allow plugin authors
    -- to override them with improvements upon the default behavior,
    -- so that's exactly what this plugin does.
    {
        "https://github.com/stevearc/dressing.nvim",
        requires = { "nvim-telescope/telescope.nvim" },
        config = function()
            require("dressing").setup {}
        end,
    },

    {
        "folke/trouble.nvim",
        config = function()
            require("trouble").setup {}
        end,
    },
    -- Web dev icons, requires font support. Use NerdFonts in your terminal
    {
        "kyazdani42/nvim-web-devicons",
        config = function()
            require("nvim-web-devicons").setup {}
        end,
    },
    {
        "folke/which-key.nvim",
        config = function()
            require("which-key").setup {
                icons = {
                    breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
                    separator = "  ", -- symbol used between a key and it's label
                    group = "+", -- symbol prepended to a group
                },
                spelling = {
                    enabled = true,
                },
                popup_mappings = {
                    scroll_down = "<c-d>", -- binding to scroll down inside the popup
                    scroll_up = "<c-u>", -- binding to scroll up inside the popup
                },

                window = {
                    border = "none", -- none/single/double/shadow
                },

                layout = {
                    spacing = 3, -- spacing between columns
                },
            }
        end,
    },
    -- Better status line
    {
        "hoob3rt/lualine.nvim",
        requires = { "kyazdani42/nvim-web-devicons" },
        config = function()
            require("lualine").setup {
                options = {
                    globalstatus = true,
                    icons_enabled = true,
                    theme = "nightfox",
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                },
                sections = {
                    -- path=1 means print the relative filepath in the status bar instead of just the filename
                    lualine_c = { { "filename", file_status = true, path = 1 } },
                },
            }
        end,
    },

    ----
    ---- Plugins for cursor motion or for text editing
    ----
    { "junegunn/vim-easy-align" },
    { "andymass/vim-matchup", event = "VimEnter" },

    -- "Jetpack" like movement within the buffer. Quickly jump where you want to go
    {
        "ggandor/lightspeed.nvim",
        config = function()
            require("lightspeed").setup {
                ignore_case = false,
            }
        end,
    },

    -- Clipboard manager neovim plugin with telescope integration
    {
        "AckslD/nvim-neoclip.lua",
        requires = {
            "nvim-telesope/telescope.nvim",
        },
        config = function()
            require("neoclip").setup {
                default_register = "+",
                keys = {
                    telescope = {
                        i = {
                            select = "<tab>",
                            paste = "<c-p>",
                            paste_behind = "<cr>",
                            replay = "<c-q>",
                            custom = {},
                        },
                        n = {
                            select = "<Tab>",
                            paste = "p",
                            paste_behind = "<cr>",
                            replay = "q",
                            custom = {},
                        },
                    },
                },
            }
        end,
    },

    -- Easily move selected lines (visual mode) up, down, left and right
    {
        "matze/vim-move",
        config = function()
            vim.g.move_map_keys = 0
        end,
    },

    {
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup {
                toggler = {
                    line = "gcc",
                    block = "gbc",
                },
                mappings = {
                    basic = true,
                    extra = true,
                    extended = false,
                },
            }
        end,
    },
    -- Multiple cursors support
    {
        "mg979/vim-visual-multi",
        branch = "master",
        config = function()
            vim.g.VM_theme = "codedark"
            vim.g.VM_maps = {
                ["Add Cursor Down"] = "<C-j>",
                ["Add Cursor Up"] = "<C-k>",
                ["Find Subword Under"] = "<C-d>",
                ["Find Under"] = "<C-d>",
                Undo = "<C-u>",
            }
        end,
    },

    {
        "windwp/nvim-autopairs",
        config = function()
            require("nvim-autopairs").setup {
                disable_filetype = { "TelescopePrompt", "lua" },
                check_ts = true,
                fast_wrap = {
                    map = "<M-e>",
                    chars = { "{", "[", "(", '"', "'" },
                    pattern = [=[[%'%"%)%>%]%)%}%,]]=],
                    end_key = "$",
                    keys = "qwertyuiopzxcvbnmasdfghjkl",
                    check_comma = true,
                    highlight = "Search",
                    highlight_grey = "Comment",
                },
            }
        end,
    },

    -- Highlight todo in comments
    {
        "folke/todo-comments.nvim",
        requires = { "nvim-lua/plenary.nvim", "folke/trouble.nvim", "nvim-telescope/telescope.nvim" },
        config = function()
            require("todo-comments").setup {
                highlight = {
                    before = "",
                    keyword = "fg",
                    after = "",
                    pattern = [[.*<(KEYWORDS)>(\(.*\))?\s*:?]],
                },
                search = {
                    pattern = [[\b(KEYWORDS)\b(\(.*\))?\s*:?]],
                },
            }
        end,
    },

    -- Automatically close braces but only when pressing enter (more conservative approach)
    --      NOTE: It does not work since it collides with our custom <CR> key, and there's
    --            no way to tell the plugin, to not catch the <CR> key by default and let us
    --            handle it
    -- { 'rstacruz/vim-closer' }

    ----
    ---- Plugins to manage windows
    ----
    {
        "christoomey/vim-tmux-navigator",
        config = function()
            vim.g.tmux_navigator_no_mappings = 1
        end,
    },
    {
        "akinsho/toggleterm.nvim",
        config = function()
            require("toggleterm").setup {
                -- size can be a number or function which is passed the current terminal
                size = function(term)
                    if term.direction == "horizontal" then
                        return 15
                    elseif term.direction == "vertical" then
                        return vim.o.columns * 0.4
                    end
                end,
                open_mapping = [[<F4>]],
                start_in_insert = true,
                insert_mappings = true, -- whether or not the open mapping applies in insert mode
                persist_size = true,
                direction = "horizontal",
                close_on_exit = true, -- close the terminal window when the process exits
                shell = vim.o.shell, -- change the default shell
                -- This field is only relevant if direction is set to 'float'
                float_opts = {
                    winblend = 3,
                    highlights = {
                        border = "Normal",
                        background = "Normal",
                    },
                },
            }
        end,
    },
    {
        "kyazdani42/nvim-tree.lua",
        requires = { "kyazdani42/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup {
                hijack_netrw = false,
                disable_netrw = false,
                open_on_setup = false,
                hijack_directories = {
                    enable = false,
                    auto_open = false,
                },
            }
        end,
    },

    ----
    ---- Language specific plugins, for syntax highlighting or working with the language
    ----
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        run = ":TSUpdateSync all",
        requires = { "nvim-treesitter/playground", "p00f/nvim-ts-rainbow" },
        config = function()
            require("nvim-treesitter.configs").setup {
                ensure_installed = "all", -- "all" or a list of languages
                highlight = {
                    enable = true, -- false will disable the whole extension
                    additional_vim_regex_highlighting = true,
                    -- disable = { "c", "rust" },  -- list of language that will be disabled
                },
                indent = {
                    enable = false,
                },
                rainbow = {
                    -- Default colors seems to suck, and the major colorschemes that I use do not
                    -- seem to support it yet, disable the rainbow for now
                    enable = false,
                    -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
                    extended_mode = false, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
                    max_file_lines = nil, -- Do not enable for files with more than n lines, int
                    -- Setting colors
                    -- colors = {
                    -- }
                },
                playground = {
                    enable = true,
                },
            }
        end,
    },
    { "dag/vim-fish" },
    { "mboughaba/i3config.vim" },
    {
        "plasticboy/vim-markdown",
        config = function()
            vim.g.vim_markdown_folding_disabled = 1
        end,
    },
    { "vim-crystal/vim-crystal" },
    { "ziglang/zig.vim" },
    {
        "rust-lang/rust.vim",
        config = function()
            vim.g.cargo_makeprg_params = "build"
        end,
    },
    { "simrat39/rust-tools.nvim" },
    { "iamcco/markdown-preview.nvim", run = "cd app && yarn install", cmd = "MarkdownPreview" },
    -- Plugin that provides nice wrapper commands to build with cmake
    {
        "cdelledonne/vim-cmake",
        config = function()
            vim.g.cmake_command = "cmake"
            vim.g.cmake_default_config = "Debug"
            vim.g.cmake_build_dir_location = "./build"
            vim.g.cmake_link_compile_commands = 1
            vim.g.cmake_jump = 0
            vim.g.cmake_jump_on_completion = 0
            vim.g.cmake_jump_on_error = 0

            vim.cmd [[
                augroup vim-cmake-group
                    autocmd!
                    autocmd User CMakeBuildFailed :cfirst
                    autocmd! User CMakeBuildSucceeded CMakeClose
                augroup END
            ]]
        end,
    },

    ----
    ---- Git integration
    ----
    {
        "TimUntersberger/neogit",
        requires = "nvim-lua/plenary.nvim",
        config = function()
            local neogit = require "neogit"

            neogit.setup {}
        end,
    },

    { "tpope/vim-fugitive" },
    {
        "kdheepak/lazygit.nvim",
        cmd = { "LazyGit" },
        requires = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").load_extension "lazygit"
        end,
    },

    {
        "sindrets/diffview.nvim",
        requires = { "nvim-lua/plenary.nvim" },
        config = function()
            require("diffview").setup {}
        end,
    },
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup {
                current_line_blame = false,
            }
        end,
    },

    -- Install LuaSnip and load friendly-snippets (a set of already pre-packaged set of snippets)
    {
        "L3MON4D3/LuaSnip",
        requires = { "rafamadriz/friendly-snippets" },
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
        end,
    },

    ----
    ---- Packages that take neovim to a whole new level like a full IDE or VSCode experience
    ----
    -- Snippets
    {
        "hrsh7th/nvim-cmp",
        requires = {
            "nvim-lua/plenary.nvim",
            "windwp/nvim-autopairs",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-nvim-lua",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "kyazdani42/nvim-web-devicons",
            "jose-elias-alvarez/null-ls.nvim",
            "hrsh7th/cmp-nvim-lsp-signature-help",
            "petertriho/cmp-git",
        },
        config = function()
            require "user.plugins.configs.cmp"
        end,
    },

    {
        "neovim/nvim-lspconfig",
        requires = {
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-nvim-lsp",
            "nvim-lua/lsp_extensions.nvim",
            "jose-elias-alvarez/null-ls.nvim",
            "nvim-lua/plenary.nvim",
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            require "user.plugins.configs.lsp"
        end,
    },
}

local themes = {
    -- Theme configurations/generators
    { "rktjmp/lush.nvim" },
    { "tjdevries/colorbuddy.nvim" },

    { "dracula/vim", as = "dracula" },
    { "metalelf0/jellybeans-nvim", requires = { "rktjmp/lush.nvim" } },
    { "tjdevries/gruvbuddy.nvim", requires = { "tjdevries/colorbuddy.nvim" } },
    { "Th3Whit3Wolf/spacebuddy", requires = { "tjdevries/colorbuddy.nvim" } },
    {
        "marko-cerovac/material.nvim",
        config = function()
            vim.g.material_style = "darker"
            require("material").setup {
                custom_highlights = {
                    Special = "#FFFFFF",
                    SpecialChar = "#FFFFFF",
                    cSpecialCharacter = "#FFFFFF",
                    TSStringEscape = "#FFFFFF",
                    TSStringSpecial = "#FFFFFF",
                },
            }
        end,
    },
    { "joshdick/onedark.vim" },
    {
        "olimorris/onedarkpro.nvim",
        config = function()
            require("onedarkpro").setup {
                styles = {
                    comments = "italic",
                    functions = "NONE",
                    keywords = "bold",
                    strings = "NONE",
                    variables = "NONE",
                },
                options = {
                    italic = false,
                },
            }
        end,
    },

    { "arcticicestudio/nord-vim" },
    {
        "sainnhe/everforest",
        config = function()
            vim.g.everforest_background = "hard"
        end,
    },

    { "sainnhe/sonokai" },
    {
        "sainnhe/gruvbox-material",
        config = function()
            vim.g.gruvbox_material_background = "hard"
        end,
    },
    {
        "EdenEast/nightfox.nvim",
        config = function()
            require("nightfox").setup {
                options = {
                    dim_inactive = true,
                },
            }
        end,
    },

    { "tomasiser/vim-code-dark" },

    { "tomasr/molokai" },
    {
        "ellisonleao/gruvbox.nvim",
        config = function()
            vim.g.gruvbox_inverse = 0
            vim.g.gruvbox_contrast_dark = "hard"
            vim.g.gruvbox_contrast_light = "hard"
        end,
    },
    {
        "ayu-theme/ayu-vim",
        config = function()
            vim.g.ayucolor = "dark"
        end,
    },
    { "mhartington/oceanic-next" },
    {
        "folke/tokyonight.nvim",
        config = function()
            vim.g.tokyonight_style = "storm"
        end,
    },

    { "Everblush/everblush.nvim" },
}

local unused = {
    {
        "lukas-reineke/indent-blankline.nvim",
        config = function()
            require("indent_blankline").setup {
                -- for example, context is off by default, use this to turn it on
                show_current_context = true,
                show_current_context_start = true,
            }
        end,
    },

    -- Dashboard startup page
    {
        "goolord/alpha-nvim",
        config = function()
            require("alpha").setup(require("alpha.themes.dashboard").config)
        end,
    },

    -- Speed up loading Lua modules in Neovim to improve startup time
    {
        "lewis6991/impatient.nvim",
    },
}

local M = {}
table.insert(M, generic)
table.insert(M, themes)
return M
