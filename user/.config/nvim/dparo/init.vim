lua require "funcs"
lua require "dparo.options"
lua require "dparo.keymaps"
lua require "dparo.plugins"

exe "source" $MY_CONFIG_PATH . "/setupColorscheme.vim"
exe "source" $MY_CONFIG_PATH . "/setupAutocommands.vim"
exe "source" $MY_CONFIG_PATH . "/abbr.vim"
