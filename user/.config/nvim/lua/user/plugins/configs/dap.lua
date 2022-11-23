local dap = require "dap"

local path = require "core.os.path"
local nvim_data_path = path.get_nvim_data_path()

-- DAP ui
local dapui = require "dapui"
require("dapui").setup()

-- Automatically open/close the UI when starting/finishing debugging
dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open({nil, true})
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close({nil})
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close({nil})
end

--- Extension for GO/delve
require("dap-go").setup()

dap.adapters.cppdbg = {
    id = "cppdbg",
    type = "executable",
    command = path.concat { nvim_data_path, "mason", "packages", "cpptools", "extension", "debugAdapters", "bin", "OpenDebugAD7" },
}

dap.configurations.cpp = {
    {
        name = "Launch file",
        type = "cppdbg",
        request = "launch",
        program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = true,
        setupCommands = {
            {
                text = "-enable-pretty-printing",
                description = "enable pretty printing",
                ignoreFailures = false,
            },
        },
    },
    {
        name = "Attach to gdbserver :1234",
        type = "cppdbg",
        request = "launch",
        MIMode = "gdb",
        miDebuggerServerAddress = "localhost:1234",
        miDebuggerPath = "/usr/bin/gdb",
        cwd = "${workspaceFolder}",
        program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        setupCommands = {
            {
                text = "-enable-pretty-printing",
                description = "enable pretty printing",
                ignoreFailures = false,
            },
        },
    },
}
