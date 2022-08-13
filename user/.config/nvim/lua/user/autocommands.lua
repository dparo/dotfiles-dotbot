-- Associate to specific path patterns a filetype
require("filetype").setup {
    overrides = {
        complex = {
            ["*.mutt-.*"] = "mail",
            [".*/.config/i3/config"] = "i3config",
            [".envrc"] = "sh",
            [".direnvrc"] = "sh",
            ["direnvrc"] = "sh",
        },
    },
}

local function augroup(group_name, map)
    local group = vim.api.nvim_create_augroup(group_name, { clear = true })

    for _, tbl in map do
        local event = tbl[1]
        local opts = tbl[2]
        opts.group = group
        vim.api.nvim_create_autocmd(event, opts)
    end
end

-- Skeletons for new files
local skeleton_aucmds = vim.api.nvim_create_augroup("USER_SKELETONS", { clear = true })
vim.api.nvim_create_autocmd(
    { "BufNewFile" },
    { group = skeleton_aucmds, pattern = "*.{h}", command = [[0r ~/.config/nvim/skeletons/c.h]] }
)
vim.api.nvim_create_autocmd(
    { "BufNewFile" },
    { group = skeleton_aucmds, pattern = "*.{hpp}", command = [[0r ~/.config/nvim/skeletons/c.hpp]] }
)
vim.api.nvim_create_autocmd(
    { "BufNewFile" },
    { group = skeleton_aucmds, pattern = "*.{js}", command = [[0r ~/.config/nvim/skeletons/js.js]] }
)
vim.api.nvim_create_autocmd(
    { "BufNewFile" },
    { group = skeleton_aucmds, pattern = "*.{sh,bash}", command = [[0r ~/.config/nvim/skeletons/sh.sh]] }
)
vim.api.nvim_create_autocmd({ "BufNewFile" }, {
    group = skeleton_aucmds,
    pattern = ".envrc,.direnvrc,direnvrc",
    command = [[0r ~/.config/nvim/skeletons/.envrc]],
})
vim.api.nvim_create_autocmd(
    { "BufNewFile" },
    { group = skeleton_aucmds, pattern = "Makefile", command = [[0r ~/.config/nvim/skeletons/Makefile]] }
)

local filetypes_aucmds = vim.api.nvim_create_augroup("USER_FILETYPES", { clear = true })
vim.api.nvim_create_autocmd({ "FileType" }, {
    group = filetypes_aucmds,
    pattern = "gitcommit,gitrebase,gitconfig",
    callback = function()
        vim.bo.bufhidden = "delete"
    end,
})
vim.api.nvim_create_autocmd({ "FileType" }, {
    group = filetypes_aucmds,
    pattern = "gitcommit",
    callback = function()
        vim.bo.wrap = true
    end,
})
vim.api.nvim_create_autocmd({ "FileType" }, {
    group = filetypes_aucmds,
    pattern = "gitcommit,markdown",
    callback = function()
        vim.bo.spell = true
    end,
})

-- Stop comment continuation when entering a new line inside a comment
vim.api.nvim_create_autocmd(
    { "BufWritePost" },
    { group = filetypes_aucmds, pattern = "", command = [[setlocal formatoptions-=cro]] }
)

vim.api.nvim_create_autocmd(
    { "BufWritePost" },
    { group = filetypes_aucmds, pattern = "*.config/i3/config", command = [[silent !i3-msg restart]] }
)
vim.api.nvim_create_autocmd(
    { "BufWritePost" },
    { group = filetypes_aucmds, pattern = "*.config/sxhkd/sxhkdrc", command = [[silent !pkill -USR1 -x sxhkd]] }
)

local USER_augroup = vim.api.nvim_create_augroup("USER_LUA", { clear = true })
-- Reload the buffer if it was changed externally
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
    group = USER_augroup,
    pattern = "*",
    command = [[if mode() != 'c' | checktime | endif]],
})

-- Notification after file change
vim.api.nvim_create_autocmd({ "FileChangedShellPost" }, {
    group = USER_augroup,
    pattern = "*",
    command = [[echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None]],
})

-- Reset cursor when vim exits
vim.api.nvim_create_autocmd({ "VimLeave" }, {
    group = USER_augroup,
    pattern = "*",
    command = [[silent !echo -ne "\033]112\007"]],
})

-- Readjusts window dimension when vim changes size
vim.api.nvim_create_autocmd({ "VimResized" }, {
    group = USER_augroup,
    pattern = "*",
    command = [[tabdo wincmd =]],
})

vim.api.nvim_create_autocmd({ "WinEnter" }, {
    group = USER_augroup,
    pattern = "*",
    command = [[set cursorline]],
})

vim.api.nvim_create_autocmd({ "WinLeave" }, {
    group = USER_augroup,
    pattern = "*",
    command = [[set nocursorline]],
})

-- Create parent directory of file when saving if it does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    group = USER_augroup,
    pattern = "*",
    command = [[call mkdir(expand("<afile>:p:h"), "p")]],
})

-- When editing a file, always jump to the last known cursor position.
-- Don't do it when the position is invalid, when inside an event handler
-- (happens when dropping a file on gvim) and for a commit message (it's
--  likely a different one than last time).
-- NOTE(dparo): 5 Jan 2022:
--     Disabled, since it conflicts with cmdline syntax `$> nvim +{line} <file>`
--     and thus I cannot spawn neovim from the command line at a specific line location
--     (eg useful when using gdb, or external shell scripts)
vim.api.nvim_create_autocmd({ "BufReadPre" }, {
    group = USER_augroup,
    pattern = "make",
    command = [[if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit' | exe "normal! g`\"" | endif ]],
})

-- Post build
vim.api.nvim_create_autocmd({ "QuickfixCmdPost" }, {
    group = USER_augroup,
    pattern = "make",
    callback = user.post_build,
})

vim.api.nvim_create_autocmd({ "TextYankPost" }, {
    group = USER_augroup,
    pattern = "*",
    command = [[silent! lua require('vim.highlight').on_yank({higroup = 'Search', timeout = 200})]],
})
