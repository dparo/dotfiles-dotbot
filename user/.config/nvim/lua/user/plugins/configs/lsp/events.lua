local M = {}

function M.on_attach(client, bufnr)
    local buf_set_keymap = vim.api.nvim_buf_set_keymap
    local buf_set_option = vim.api.nvim_buf_set_option

    buf_set_option(bufnr, "formatexpr", "v:lua.vim.lsp.formatexpr()")
    buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
    buf_set_option(bufnr, "tagfunc", "v:lua.vim.lsp.tagfunc")

    -- print("Client name: " .. client.name)

    -- Mappings.
    local opts = { noremap = true, silent = true }
    buf_set_keymap(bufnr, "n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    buf_set_keymap(bufnr, "n", "gd", "<Cmd>Telescope lsp_definitions theme=dropdown<CR>", opts)
    buf_set_keymap(bufnr, "n", "gt", "<Cmd>Telescope lsp_type_definitions theme=dropdown<CR>", opts)
    buf_set_keymap(bufnr, "n", "gi", "<cmd>Telescope lsp_implementations theme=dropdown<CR>", opts)
    buf_set_keymap(bufnr, "n", "gr", "<cmd>Telescope lsp_references theme=dropdown<CR>", opts)
    buf_set_keymap(bufnr, "n", "<C-LeftMouse>", "<Cmd>Telescope lsp_definitions theme=dropdown<CR>", opts)
    buf_set_keymap(bufnr, "n", "<leader>D", "<cmd>Telescope lsp_definitions theme=dropdown<CR>", opts)
    buf_set_keymap(bufnr, "n", "<S-LeftMouse>", "<Cmd>Telescope lsp_references theme=dropdown<CR>", opts)
    buf_set_keymap(bufnr, "n", "<M-CR>", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
    buf_set_keymap(bufnr, "n", "<leader>a", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)

    buf_set_keymap(bufnr, "n", "<leader>e", "<cmd>lua user.utils.lsp.show_line_diagnostics()<CR>", opts)
    buf_set_keymap(bufnr, "n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
    buf_set_keymap(bufnr, "n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)

    buf_set_keymap(bufnr, "n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
    buf_set_keymap(bufnr, "n", "<leader>hh", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
    buf_set_keymap(bufnr, "n", "<leader>hs", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    buf_set_keymap(bufnr, "n", "<C-j>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    buf_set_keymap(bufnr, "i", "<C-j>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    buf_set_keymap(bufnr, "n", "<leader>lwa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
    buf_set_keymap(bufnr, "n", "<leader>lwr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
    buf_set_keymap(bufnr, "n", "<leader>lwl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
    buf_set_keymap(bufnr, "n", "<leader>lq", "<cmd>lua vim.diagnostic.set_loclist()<CR>", opts)

    -- JDTLS specific binds
    if client.name == "jdt.ls" then
        buf_set_keymap(bufnr, "n", "<leader>lev", "<Cmd>lua require('jdtls').extract_variable()<CR>", opts)
        buf_set_keymap(bufnr, "v", "<leader>lev", "<Cmd>lua require('jdtls').extract_variable(true)<CR>", opts)

        buf_set_keymap(bufnr, "n", "<leader>lec", "<Cmd>lua require('jdtls').extract_constant()<CR>", opts)
        buf_set_keymap(bufnr, "v", "<leader>lec", "<Cmd>lua require('jdtls').extract_constant(true)<CR>", opts)

        buf_set_keymap(bufnr, "v", "<leader>lem", "<Cmd>lua require('jdtls').extract_method(true)<CR>", opts)

        -- DAP
        buf_set_keymap(bufnr, "n", "<leader>ddc", "<Cmd>lua require('jdtls').test_class()<CR>", opts)
        buf_set_keymap(bufnr, "n", "<leader>ddm", "<Cmd>lua require('jdtls').test_nearest_method()<CR>", opts)
    end

    buf_set_keymap(bufnr, "n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
    buf_set_keymap(bufnr, "n", "<leader>r", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)

    local augroup = vim.api.nvim_create_augroup("USER_LSP", { clear = true })
    vim.api.nvim_create_autocmd({ "CursorHold" }, {
        group = augroup,
        buffer = bufnr,
        callback = function()
            user.utils.lsp.show_line_diagnostics()
        end,
    })

    -- Set some keybinds conditional on server capabilities
    if client.resolved_capabilities.document_formatting then
        buf_set_keymap(bufnr, "n", "<leader>lf", "<cmd>lua vim.lsp.buf.formatting_sync()<CR>", opts)
    end

    if client.resolved_capabilities.document_range_formatting then
        buf_set_keymap(bufnr, "v", "<leader>lf", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
    end

    -- Setup highlight references of word under cursor using lsp
    if client.resolved_capabilities.document_highlight then
        vim.api.nvim_create_autocmd({ "CursorHold" }, {
            group = augroup,
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.document_highlight()
            end,
        })
        vim.api.nvim_create_autocmd({ "CursorMoved" }, {
            group = augroup,
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.clear_references()
            end,
        })
    end

    if false then
        vim.api.nvim_create_autocmd({ "CursorHold" }, {
            group = augroup,
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.hover()
            end,
        })
    end

    -- Enable formatting on save
    if client.resolved_capabilities.document_formatting then
        vim.api.nvim_create_autocmd({ "BufWritePre" }, {
            group = augroup,
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.formatting_seq_sync()
            end,
        })
        if client.name == "jdt.ls" then
            -- Automatically organize imports for java code
            vim.api.nvim_create_autocmd({ "BufWritePre" }, {
                group = augroup,
                buffer = bufnr,
                callback = function()
                    require("jdtls").organize_imports()
                end,
            })
        end
    end

    -- Setup DAP for java code
    if client.name == "jdt.ls" then
        -- With `hotcodereplace = 'auto' the debug adapter will try to apply code changes
        -- you make during a debug session immediately.
        -- Remove the option if you do not want that.
        require("jdtls").setup_dap { hotcodereplace = "auto" }
    end
end

return M
