local function my_plugins(use)
    ----
    ---- Must have utility plugins that integrates/improve the core experience
    ----
    use { "mbbill/undotree" }
    use {
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
    }

    use {
        "stsewd/fzf-checkout.vim",
        requires = { "junegunn/fzf.vim" },
    }
    -- Utils functions for common Unix like utilities such as mkdir, touch, mv inside of vim
    use { "tpope/vim-eunuch" }
    use { "tpope/vim-dispatch", opt = true, cmd = { "Dispatch", "Make", "Focus", "Start" } }
    use { "nvim-lua/plenary.nvim" }
    use {
        "rcarriga/nvim-notify",
        config = function()
            require("notify").setup {
                stages = "slide",
                background_colour = "#000000",
            }
        end,
    }
    use { "nvim-lua/popup.nvim", requires = { "nvim-lua/plenary.nvim" } }
    use {
        "nvim-telescope/telescope.nvim",
        requires = { "nvim-lua/plenary.nvim" },
        config = function()
            local actions = require "telescope.actions"
            require("telescope").setup {
                defaults = {
                    mappings = {
                        n = {
                            ["q"] = actions.close,
                        },
                        i = {
                            ["<Esc>"] = actions.close,
                            ["<C-c>"] = actions.close,
                            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                        },
                    },
                },
            }
        end,
    }

    --  With the release of Neovim 0.6 we were given the start of extensible core UI hooks
    -- (vim.ui.select and vim.ui.input). They exist to allow plugin authors
    -- to override them with improvements upon the default behavior,
    -- so that's exactly what this plugin does.
    use {
        "https://github.com/stevearc/dressing.nvim",
        requires = { "nvim-telescope/telescope.nvim" },
        config = function()
            require("dressing").setup {}
        end,
    }

    use {
        "folke/trouble.nvim",
        config = function()
            require("trouble").setup {}
        end,
    }
    -- Web dev icons, requires font support. Use NerdFonts in your terminal
    use {
        "kyazdani42/nvim-web-devicons",
        config = function()
            require("nvim-web-devicons").setup {}
        end,
    }
    use {
        "folke/which-key.nvim",
        config = function()
            require("which-key").setup {}
        end,
    }
    -- Better status line
    use {
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
    }

    ----
    ---- Plugins for cursor motion or for text editing
    ----
    use { "junegunn/vim-easy-align" }
    use { "andymass/vim-matchup", event = "VimEnter" }

    -- "Jetpack" like movement within the buffer. Quickly jump where you want to go
    use {
        "ggandor/lightspeed.nvim",
        config = function()
            require("lightspeed").setup {
                ignore_case = false,
            }
        end,
    }

    -- Clipboard manager neovim plugin with telescope integration
    use {
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
    }

    -- Easily move selected lines (visual mode) up, down, left and right
    use {
        "matze/vim-move",
        config = function()
            vim.g.move_map_keys = 0
        end,
    }

    use {
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
    }
    -- Multiple cursors support
    use {
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
    }

    use {
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
    }

    -- Highlight todo in comments
    use {
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
    }

    -- Automatically close braces but only when pressing enter (more conservative approach)
    --      NOTE: It does not work since it collides with our custom <CR> key, and there's
    --            no way to tell the plugin, to not catch the <CR> key by default and let us
    --            handle it
    -- use { 'rstacruz/vim-closer' }

    ----
    ---- Plugins to manage windows
    ----
    use {
        "christoomey/vim-tmux-navigator",
        config = function()
            vim.g.tmux_navigator_no_mappings = 1
        end,
    }
    use {
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
    }
    use {
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
    }

    ----
    ---- Language specific plugins, for syntax highlighting or working with the language
    ----
    use {
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
    }
    use { "dag/vim-fish" }
    use { "mboughaba/i3config.vim" }
    use {
        "plasticboy/vim-markdown",
        config = function()
            vim.g.vim_markdown_folding_disabled = 1
        end,
    }
    use { "vim-crystal/vim-crystal" }
    use { "ziglang/zig.vim" }
    use {
        "rust-lang/rust.vim",
        config = function()
            vim.g.cargo_makeprg_params = "build"
        end,
    }
    use { "simrat39/rust-tools.nvim" }
    use { "iamcco/markdown-preview.nvim", run = "cd app && yarn install", cmd = "MarkdownPreview" }
    -- Plugin that provides nice wrapper commands to build with cmake
    use {
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
    }

    ----
    ---- Git integration
    ----
    use {
        "TimUntersberger/neogit",
        requires = "nvim-lua/plenary.nvim",
        config = function()
            local neogit = require "neogit"

            neogit.setup {}
        end,
    }

    use { "tpope/vim-fugitive" }
    use {
        "kdheepak/lazygit.nvim",
        cmd = { "LazyGit" },
        requires = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").load_extension "lazygit"
        end,
    }

    use {
        "sindrets/diffview.nvim",
        requires = { "nvim-lua/plenary.nvim" },
        config = function()
            require("diffview").setup {}
        end,
    }
    use {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup {
                current_line_blame = false,
            }
        end,
    }

    -- Install LuaSnip and load friendly-snippets (a set of already pre-packaged set of snippets)
    use {
        "L3MON4D3/LuaSnip",
        requires = { "rafamadriz/friendly-snippets" },
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
        end,
    }

    ----
    ---- Packages that take neovim to a whole new level like a full IDE or VSCode experience
    ----
    -- Snippets
    use {
        "hrsh7th/nvim-cmp",
        requires = {
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
        },
        config = function()
            require "dparo.config.cmp"
        end,
    }

    use {
        "neovim/nvim-lspconfig",
        requires = { "hrsh7th/nvim-cmp", "hrsh7th/cmp-nvim-lsp", "nvim-lua/lsp_extensions.nvim" },
        config = function()
            require "dparo.config.lsp"
        end,
    }

    -- This plugin is very uesfull to fill the gap between LSP servers
    -- (which some low-end implementation may not provide all the whistles)
    -- and common command line tools, which are usually quiet complicate but separate
    -- from the LSP server
    -- NOTE: Null-ls can be essentially conceptualized as an LSP server responding to LSP
    --       clients request, but instead of being in a separate process, lives inside neovim.
    --       Null-ls then delegates LSP request to basically external processes, and interprets
    --       their outputs and provides diagnostics/formatting and even completion candidates
    --       (if any are enabled)
    use {
        "jose-elias-alvarez/null-ls.nvim",
        requires = { "nvim-lua/plenary.nvim" },
    }

    ----
    ---- Color schemes
    ----
    -- Theme configurations/generators
    use { "rktjmp/lush.nvim" }
    use { "tjdevries/colorbuddy.nvim" }
    -- Themes
    use { "dracula/vim", as = "dracula" }
    use { "metalelf0/jellybeans-nvim", requires = { "rktjmp/lush.nvim" } }
    use { "tjdevries/gruvbuddy.nvim", requires = { "tjdevries/colorbuddy.nvim" } }
    use { "Th3Whit3Wolf/spacebuddy", requires = { "tjdevries/colorbuddy.nvim" } }
    use {
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
    }
    use { "joshdick/onedark.vim" }
    use {
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
    }

    use { "arcticicestudio/nord-vim" }
    use {
        "sainnhe/everforest",
        config = function()
            vim.g.everforest_background = "hard"
        end,
    }

    use { "sainnhe/sonokai" }
    use {
        "sainnhe/gruvbox-material",
        config = function()
            vim.g.gruvbox_material_background = "hard"
        end,
    }
    use {
        "EdenEast/nightfox.nvim",
        config = function()
            require("nightfox").setup {
                options = {
                    dim_inactive = true,
                },
            }
        end,
    }

    use { "tomasiser/vim-code-dark" }

    use { "tomasr/molokai" }
    use {
        "ellisonleao/gruvbox.nvim",
        config = function()
            vim.g.gruvbox_inverse = 0
            vim.g.gruvbox_contrast_dark = "hard"
            vim.g.gruvbox_contrast_light = "hard"
        end,
    }
    use { "ayu-theme/ayu-vim" }
    use { "mhartington/oceanic-next" }
    use { "folke/tokyonight.nvim" }
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------
----   Setup and install packer, no need to fiddle with this
------------------------------------------------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------

local install_path = vim.fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
local packer_bootstrap = nil

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    packer_bootstrap = vim.fn.system {
        "git",
        "clone",
        "--depth",
        "1",
        "https://github.com/wbthomason/packer.nvim",
        install_path,
    }
end

do
    _G.dparo.plugins = _G.dparo.plugins or {}

    function _G.dparo.plugins.reload(params)
        params = params or {}
        local packer = require "packer"
        if params.sync then
            pcall(packer.sync)
        else
            pcall(packer.compile)
        end
    end

    -- Autocommand that reloads neovim whenever you save the plugins.lua file

    local this_file = vim.fn.fnameescape(vim.fn.expand "<sfile>:p:h" .. "/plugins.lua")
    local config_files = vim.fn.fnameescape(vim.fn.expand "<sfile>:p:h") .. "/config/*"
    vim.cmd([[
        augroup reload_packer_user_config
            autocmd!
            autocmd BufWritePost ]] .. this_file .. [[ source ]] .. this_file .. [[ | lua dparo.plugins.reload({sync=false})
            autocmd BufWritePost ]] .. config_files .. [[ source ]] .. this_file .. [[ | lua dparo.plugins.reload({sync=false})
        augroup END
    ]])
end

-- Use a protected call so we don't error out on first use of this plugin (if it is not yet installed)
local status_ok, packer = pcall(require, "packer")
if not status_ok then
    return
end

local util = require "packer.util"

-- Have packer use a popup window
packer.init {
    auto_clean = true,
    compile_on_sync = true,

    -- NOTE(dparo): 5 Jan 2022
    --     Disabled since it conflicts with `nvim --headless PackerSync` install:
    --     See issue #751 (https://github.com/wbthomason/packer.nvim/issues/751),
    --     it this problem will ever be fixed, you can re-enable this line
    -- max_jobs = 4,
    display = {
        prompt_border = "single",
        open_fn = function()
            return util.float { border = "rounded" }
        end,
    },
    luarocks = {
        python_cmd = "python3",
    },
}

return packer.startup(function(use)
    -- Packer can manage itself
    use "wbthomason/packer.nvim"
    -- Your plugins here
    my_plugins(use)

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
        require("packer").sync()
    end
end)