local M = {}



function M.update_server_config(config)
    config = config or {}
    config = vim.deepcopy(config)

    if type(config) == "function" then
        config = config()
    end

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

    config.capabilities = capabilities
    config.on_attach = require("user.plugins.configs.lsp.events").on_attach
    config.flags = vim.tbl_deep_extend("force", config.flags or {}, { debounce_text_changes = 500 })

    return config
end


return M