local signs = {
    { name = "DiagnosticSignError", text = "" },
    { name = "DiagnosticSignWarn", text = "" },
    { name = "DiagnosticSignHint", text = "" },
    { name = "DiagnosticSignInfo", text = "" },
}

for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
end

vim.diagnostic.config {
    underline = true,
    virtual_text = true,
    signs = signs,
    severity_sort = true,
}

local lspconfig = require "lspconfig"
local null_ls = require "null-ls"

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport.properties = (
    vim.tbl_deep_extend("force", capabilities.textDocument.completion.completionItem.resolveSupport.properties or {}, {
        "documentation",
        "detail",
        "additionalTextEdits",
    })
)

local lsp_on_attach = function(client, bufnr)
    local function buf_set_keymap(...)
        vim.api.nvim_buf_set_keymap(bufnr, ...)
    end
    local function buf_set_option(...)
        vim.api.nvim_buf_set_option(bufnr, ...)
    end

    buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

    -- Mappings.
    local opts = { noremap = true, silent = true }
    buf_set_keymap("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    buf_set_keymap("n", "gd", "<Cmd>Telescope lsp_definitions theme=dropdown<CR>", opts)
    buf_set_keymap("n", "gt", "<Cmd>Telescope lsp_type_definitions theme=dropdown<CR>", opts)
    buf_set_keymap("n", "gi", "<cmd>Telescope lsp_implementations theme=dropdown<CR>", opts)
    buf_set_keymap("n", "gr", "<cmd>Telescope lsp_references theme=dropdown<CR>", opts)
    buf_set_keymap("n", "<C-LeftMouse>", "<Cmd>Telescope lsp_definitions theme=dropdown<CR>", opts)
    buf_set_keymap("n", "<leader>D", "<cmd>Telescope lsp_definitions theme=dropdown<CR>", opts)
    buf_set_keymap("n", "<S-LeftMouse>", "<Cmd>Telescope lsp_references theme=dropdown<CR>", opts)
    buf_set_keymap("n", "<M-CR>", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
    buf_set_keymap("n", "<leader>a", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)

    buf_set_keymap("n", "<leader>e", "<cmd>lua user.utils.lsp.show_line_diagnostics()<CR>", opts)
    buf_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
    buf_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)

    buf_set_keymap("n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
    buf_set_keymap("n", "<leader>hh", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
    buf_set_keymap("n", "<leader>hs", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    buf_set_keymap("n", "<C-j>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    buf_set_keymap("i", "<C-j>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    buf_set_keymap("n", "<leader>lwa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
    buf_set_keymap("n", "<leader>lwr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
    buf_set_keymap("n", "<leader>lwl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
    buf_set_keymap("n", "<leader>lq", "<cmd>lua vim.diagnostic.set_loclist()<CR>", opts)

    buf_set_keymap("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
    buf_set_keymap("n", "<leader>r", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)


    local augroup = vim.api.nvim_create_augroup("USER_LSP", { clear = true })
    vim.api.nvim_create_autocmd({"CursorHold"}, { group = augroup, buffer = bufnr, callback = function() user.utils.lsp.show_line_diagnostics() end })

    -- Set some keybinds conditional on server capabilities
    if client.resolved_capabilities.document_formatting then
        buf_set_keymap("n", "<leader>l f", "<cmd>lua vim.lsp.buf.formatting_sync()<CR>", opts)
    end

    if client.resolved_capabilities.document_range_formatting then
        buf_set_keymap("v", "<leader>l f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
    end

    -- Setup highlight references of word under cursor using lsp
    if client.resolved_capabilities.document_highlight then
        vim.api.nvim_create_autocmd({"CursorHold"}, { group = augroup, buffer = bufnr, callback = function() vim.lsp.buf.document_highlight() end })
        vim.api.nvim_create_autocmd({"CursorMoved"}, { group = augroup, buffer = bufnr, callback = function() vim.lsp.buf.clear_references() end })
    end

    if false then
        vim.api.nvim_create_autocmd({"CursorHold"}, { group = augroup, buffer = bufnr, callback = function() vim.lsp.buf.hover() end })
    end

    -- Enable formatting on save
    if client.resolved_capabilities.document_formatting then
        vim.api.nvim_create_autocmd({"BufWritePre"}, { group = augroup, buffer = bufnr, callback = function() vim.lsp.buf.formatting_seq_sync() end })
    end
end

local system_name
if vim.fn.has "mac" == 1 then
    system_name = "macOS"
elseif vim.fn.has "unix" == 1 then
    system_name = "Linux"
elseif vim.fn.has "win32" == 1 then
    system_name = "Windows"
else
    print "Unsupported system for sumneko"
end

local sumneko_root_path = vim.env.USER_DOTFILES_LOCATION .. "/core/vendor/lua-language-server"
local sumneko_binary = sumneko_root_path .. "/bin/" .. system_name .. "/lua-language-server"

local function deno_root_dir(fname)
    -- If the top level directory __DOES__ contain a file named `deno.proj` determine that this is a Deno project.
    if (vim.env.DENO_VERSION ~= nil) or (lspconfig.util.root_pattern "deno.proj"(fname) ~= nil) then
        return lspconfig.util.root_pattern("package.json", "tsconfig.json", ".git")(fname)
    end
    return nil
end

local function nodejs_root_dir(fname)
    -- If the top level directory __DOES NOT__ contain a file named `deno.proj` determine that this is a Nodejs project
    if deno_root_dir(fname) == nil then
        return (
            lspconfig.util.root_pattern "tsconfig.json"(fname)
            or lspconfig.util.root_pattern("package.json", "jsconfig.json", ".git")(fname)
        )
    end
    return nil
end

local lsp_servers = {
    ----- Python: Pyright seems the best performant and modern solution
    -- { name = 'pylsp', config = {} },
    -- { name = 'jedi_language_server', config = {} },
    { name = "pyright", config = {} },

    {
        name = "clangd",
        config = {
            cmd = {
                "clangd",
                "--background-index",
                -- by default, clang-tidy use -checks=clang-diagnostic-*,clang-analyzer-*
                -- to add more checks, create .clang-tidy file in the root directory
                -- and add Checks key, see https://clang.llvm.org/extra/clang-tidy/
                "--clang-tidy",
                "--completion-style=bundled",

                -- Used to fix: https://github.com/neovim/neovim/blob/b65a23a13a29176aa669afc5d1c906d1d51e0a39/runtime/lua/vim/lsp/util.lua#L1767-L1784
                --              If I don't set this I get weird messages about neovim not being able to handle different client encodings,
                --              this is possibly because, by default null-ls and other LSP servers default to utf-16 encoding, but clangd
                --              cannot autodetect that it should use utf-16 encoding
                "--offset-encoding=utf-16",

                -- "--cross-file-rename",
                "--header-insertion=iwyu",
            },
        },
    },
    { name = "rust_analyzer", config = {} },
    { name = "cmake", config = {} },
    {
        name = "bashls",
        config = {
            cmd = { "bash-language-server", "start" },
            cmd_env = { GLOB_PATTERN = "*@(.sh|.inc|.bash|.command)" },
            filetypes = { "sh", "bash" },
        },
    },
    {
        name = "texlab",
        config = {
            settings = {
                texlab = {
                    latexFormatter = "latexindent",
                    latexindent = {
                        modifyLineBreaks = true,
                    },
                },
            },
        },
    },
    { name = "ltex", config = {} }, --- LateX language server: LSP language server for LanguageTool (requires ltex-ls binary in path)
    { name = "jsonls", config = {} },
    { name = "yamlls", config = {} },
    { name = "tsserver", config = { root_dir = nodejs_root_dir } },
    { name = "jdtls", config = {} },
    {
        name = "denols",
        config = {
            -- cmd = { "deno", "lsp"},
            init_options = {
                enable = true,
                lint = true,
                unstable = false,
            },
            root_dir = deno_root_dir,
        },
    },
    { name = "vuels", config = {} },
    { name = "gopls", config = {} },
    { name = "vimls", config = {} },
    { name = "html", config = {} },

    -- NOTE: We use null-ls now, which is more richer in terms of features
    --       and lives inside the neovim process space instead of being a separate
    --       go program
    -- { name = 'efm', config = {
    --     init_options = {documentFormatting = true},
    --     filetypes = { "lua", "sh", "bash", "make"}
    -- }},
    { name = "marksman", config = {} },
    { name = "julials", config = {} },
    {
        name = "sumneko_lua",
        config = function()
            local runtime_path = vim.split(package.path, ";")
            table.insert(runtime_path, "lua/?.lua")
            table.insert(runtime_path, "lua/?/init.lua")

            return {
                cmd = { sumneko_binary, "-E", sumneko_root_path .. "/main.lua" },
                settings = {
                    Lua = {
                        runtime = {
                            -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                            version = "LuaJIT",
                            -- Setup your lua path
                            path = runtime_path,
                        },
                        diagnostics = {
                            -- Get the language server to recognize the `vim` global
                            globals = { "vim" },
                        },
                        workspace = {
                            -- Make the server aware of Neovim runtime files
                            library = vim.api.nvim_get_runtime_file("", true),
                        },
                        -- Do not send telemetry data containing a randomized but unique identifier
                        telemetry = {
                            enable = false,
                        },
                    },
                },
            }
        end,
    },
}

for _, server in ipairs(lsp_servers) do
    local name = server.name
    local config = nil

    if type(server.config) == "table" then
        config = server.config
    elseif type(server.config) == "function" then
        config = server.config()
    else
        config = {}
    end

    config.capabilities = capabilities
    config.on_attach = lsp_on_attach
    config.flags = vim.tbl_deep_extend("force", config.flags or {}, { debounce_text_changes = 500 })
    lspconfig[name].setup(config)

    if name == "rust_analyzer" then
        -- NOTE: Rust tools seems to fuck around too much with our configuration just to get some inline type hints
        -- require('rust-tools').setup({ tools = {hover_with_actions = false}, server = config })
    end
end

null_ls.setup {
    on_attach = lsp_on_attach,
    sources = {
        null_ls.builtins.diagnostics.codespell,
        null_ls.builtins.diagnostics.gitlint,
        null_ls.builtins.diagnostics.write_good,
        null_ls.builtins.diagnostics.proselint,
        null_ls.builtins.code_actions.proselint,
        null_ls.builtins.completion.spell.with {
            filetypes = {
                "text",
                "markdown",
            },
        },

        null_ls.builtins.diagnostics.eslint,
        null_ls.builtins.formatting.prettier.with {
            filetypes = {
                "html",
                "json",
                "yaml",
                "markdown",
                "vue",
                "javascript",
                "typescript",
                "typescriptreact",
                "css",
            },
        },

        null_ls.builtins.formatting.shfmt,
        null_ls.builtins.diagnostics.shellcheck,
        null_ls.builtins.formatting.shellharden,

        null_ls.builtins.formatting.stylua,

        null_ls.builtins.formatting.cmake_format,
        null_ls.builtins.diagnostics.cppcheck,
        null_ls.builtins.formatting.zigfmt,

        -- null_ls.builtins.formatting.autopep8,
        -- null_ls.builtins.diagnostics.pydocstyle,
        -- Uncompromising Python code formatter.
        null_ls.builtins.formatting.black,
        -- python utility / library to sort imports alphabetically and automatically separate them into sections and by type.
        null_ls.builtins.formatting.isort,
        -- Mypy is an optional static type checker for Python that aims to combine the benefits of dynamic (or "duck") typing and static typing.
        -- null_ls.builtins.diagnostics.mypy,
        -- flake8 is a python tool that glues together pycodestyle, pyflakes, mccabe, and third-party plugins to check the style and quality of some python code
        null_ls.builtins.diagnostics.flake8,
        -- Pylint is a Python static code analysis tool which looks for programming errors, helps enforcing a coding standard, sniffs for code smells and offers simple refactoring suggestions.
        -- null_ls.builtins.diagnostics.pylint,
    },
}

require("lsp_extensions").inlay_hints {
    highlight = "Comment",
    prefix = " > ",
    aligned = false,
    only_current_line = false,
    enabled = { "ChainingHint" },
}
