local servers = require "user.plugins.configs.lsp.servers"
local config = nil

for _, server in ipairs(servers) do
    if server.name == "jdtls" then
        config = require("user.plugins.configs.lsp.utils").update_server_config(server.config)
        break
    end
end

-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
require("jdtls").start_or_attach(config)
