vim.o.background = "dark"
vim.o.guifont="JetBrainsMono Nerd Font:h10.0"


if vim.regex[[^\(linux\|rxvt\|interix\|putty\)\(-.*\)\?$]]:match_str(vim.env.TERM) then
    vim.o.termguicolors = true
elseif vim.regex[[^\(tmux\|screen\|iterm\|xterm\|vte\|gnome\|xterm-kitty\|kitty\|alacritty\)\(-.*\)\?$]]:match_str(vim.env.TERM) then
    vim.o.termguicolors = true

    -- require('colorbuddy').colorscheme('gruvbuddy')
    user.utils.load_color_scheme 'nightfox'
end

local function theme_overrides()
    vim.o.guicursor=[[n:block-Cursor,v:hor10-vCursor,i:ver100-iCursor,n-c-ci-cr-sm-v:blinkon0,i:blinkon10,i:blinkwait10,c-ci-cr:block-cCursor,c:block-cCursor]]


    vim.api.nvim_set_hl(0, "Todo", {bg = "bg"})
    vim.api.nvim_set_hl(0, "Visual", {fg = "#ffffff", bg = "#0000ff", ctermbg = "blue", ctermfg = "white"})

    -- Avoid thick lines in vertical split generated by some themes
    vim.api.nvim_set_hl(0, "VertSplit", {link = "default", fg = "fg", bg = "bg", ctermfg = "none", ctermbg = "none" })

    vim.api.nvim_set_hl(0, "DiagnosticSignError", {ctermfg = "red",  fg = "#FF9999"})
    vim.api.nvim_set_hl(0, "DiagnosticSignWarning", {ctermfg = "yellow",  fg = "#FFFF99"})
    vim.api.nvim_set_hl(0, "DiagnosticSignInformation", {ctermfg = "yellow",  fg = "#FFFF99"})
    vim.api.nvim_set_hl(0, "DiagnosticSignHint", {ctermfg = "green",  fg = "#99FF99"})

    vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", {link = "DiagnosticSignError"})
    vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarning", {link = "DiagnosticSignWarning"})
    vim.api.nvim_set_hl(0, "DiagnosticUnderlineInformation", {link = "DiagnosticSignInformation"})
    vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", {link = "DiagnosticSignHint"})

    vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", {cterm = { undercurl = true }, ctermbg = "none", ctermfg = "none", undercurl = true, sp = "#FF0000", fg = "fg",  bg = "bg"})
    vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarning", {cterm = { undercurl = true }, ctermbg = "none", ctermfg = "none", undercurl = true, sp = "#FFFF00", fg = "fg",  bg = "bg"})
    vim.api.nvim_set_hl(0, "DiagnosticUnderlineInformation", {cterm = { undercurl = true }, ctermbg = "none", ctermfg = "none", undercurl = true, sp = "#FFFF00", fg = "fg",  bg = "bg"})
    vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", {cterm = { undercurl = true}, ctermbg = "none", ctermfg = "none", undercurl = true, sp = "#AAFFAA", fg = "fg",  bg = "bg"})

    -- Nvim Web DevIcons might need to be re-called in a `Colorscheme`
    -- to re-apply cleared highlights if the color scheme changes
    local status_ok, nvim_web_devicons = pcall(require, 'nvim-web-devicons')
    if status_ok then
        nvim_web_devicons.setup {}
    end
end


--- Autocommand for theme overrides
core.utils.augroup("USER_THEME_OVERRIDES", {
    {{ "ColorScheme" }, { group = theme_overrides_aucmd, pattern = "*", callback = theme_overrides} },
})