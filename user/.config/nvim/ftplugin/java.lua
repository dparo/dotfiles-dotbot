local servers = require('user.plugins.configs.lsp.servers')
local config = nil

for _, server in ipairs(servers) do
    if server.name == "jdtls" then
        config = server.config
        break
    end
end

require("user.plugins.configs.lsp.utils").update_lsp_config_table(config)

-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
require("jdtls").start_or_attach(config)
