local install_path = vim.fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
local packer_bootstrap = nil

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    -- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#1e222a" })
    -- print "Cloning packer .."

    packer_bootstrap = vim.fn.system {
        "git",
        "clone",
        "--depth",
        "1",
        "https://github.com/wbthomason/packer.nvim",
        install_path,
    }

    vim.fn.system {
        "rm",
        "-rf",
        vim.env.HOME .. "/.config/nvim/plugin/packer_compiled.lua"
    }

    vim.cmd[[packadd packer.nvim]]
    packer_bootstrap = true
end


-- Use a protected call so we don't error out on first use of this plugin (if it is not yet installed)
local status_ok, packer = pcall(require, "packer")
if not status_ok then
    return
end


local function reload(params)
    params = params or {}
    local packer = require "packer"

    vim.cmd("source " .. vim.fn.fnameescape("~/.config/nvim/lua/user/plugins/init.lua"))
    if params.sync then
        pcall(packer.sync)
    else
        pcall(packer.compile)
    end
end


core.utils.augroup("reload_packer_user_config", {
    { {"BufWritePost" }, { pattern = "~/.config/nvim/lua/user/plugins/init.lua",
        callback = function()
            reload({sync=false})
        end
    } },
    { {"BufWritePost" }, { pattern =  "~/.config/nvim/lua/user/plugins/configs/*",
        callback = function()
            reload({sync=false})
        end
    } },
})


-- Have packer use a popup window
packer.init {
    auto_clean = true,
    autoremove = true,
    compile_on_sync = true,

    -- NOTE(dparo): 5 Jan 2022
    --     Disabled since it conflicts with `nvim --headless PackerSync` install:
    --     See issue #751 (https://github.com/wbthomason/packer.nvim/issues/751),
    --     it this problem will ever be fixed, you can re-enable this line
    -- max_jobs = 4,
    display = {
        working_sym = "ﲊ",
        error_sym = "✗ ",
        done_sym = " ",
        removed_sym = " ",
        moved_sym = "",
        prompt_border = "single",
        open_fn = function()
            return  require("packer.util").float { border = "rounded" }
        end,
    },
    luarocks = {
        python_cmd = "python3",
    },
}


return packer.startup(function(use)
    -- Packer can manage itself
    use "wbthomason/packer.nvim"

    local plugins = require("user.plugins")
    for _, plugin in ipairs(plugins) do
        use(plugin)
    end

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
        require("packer").sync()
    end
end)
