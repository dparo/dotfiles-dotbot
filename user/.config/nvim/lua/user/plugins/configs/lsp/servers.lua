local system_name = nil
if vim.fn.has "mac" == 1 then
    system_name = "macOS"
elseif vim.fn.has "unix" == 1 then
    system_name = "Linux"
elseif vim.fn.has "win32" == 1 then
    system_name = "Windows"
else
    print "Unsupported system for sumneko"
end

local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local home = os.getenv "HOME"

local jdtls_root_path = home .. "/.local/share/nvim/mason/packages/jdtls"

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
        return (lspconfig.util.root_pattern "tsconfig.json"(fname) or lspconfig.util.root_pattern("package.json", "jsconfig.json", ".git")(fname))
    end
    return nil
end

return {
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
    {
        name = "jdtls",
        config = {
            cmd = {
                "java",
                "-Declipse.application=org.eclipse.jdt.ls.core.id1",
                "-Dosgi.bundles.defaultStartLevel=4",
                "-Declipse.product=org.eclipse.jdt.ls.core.product",
                "-Dlog.protocol=true",
                "-Dlog.level=ALL",
                -- https://projectlombok.org/
                "-javaagent:"
                    .. home
                    .. "/.local/share/nvim/mason/packages/jdtls/lombok.jar",
                "-Xms1g",
                "--add-modules=ALL-SYSTEM",
                "--add-opens",
                "java.base/java.util=ALL-UNNAMED",
                "--add-opens",
                "java.base/java.lang=ALL-UNNAMED",
                "-jar",
                vim.fn.glob(jdtls_root_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"),
                "-configuration",
                jdtls_root_path .. "/config_linux",
                "-data",
                home .. "/.cache/nvim/jdtls/" .. string.gsub(vim.fn.getcwd(), "/", "%%"),
            },

            root_dir = require("jdtls.setup").find_root {
                ".git",
                "mvnw",
                "gradlew",
                "build.xml",
                "pom.xml",
                "settings.gradle",
                "settings.gradle.kts",
                "build.gradle",
                "build.gradle.kts",
            },

            -- Here you can configure eclipse.jdt.ls specific settings
            -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
            -- for a list of options
            settings = {
                java = {},
            },

            -- Language server `initializationOptions`
            -- You need to extend the `bundles` with paths to jar files
            -- if you want to use additional eclipse.jdt.ls plugins.
            --
            -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
            --
            -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
            init_options = {
                resolveAdditionalTextEditsSupport = true,
                bundles = {
                    -- vim.fn.glob("path/to/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar")
                },
            },
        },
    },
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
