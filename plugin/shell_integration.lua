local plugin = require('shell_integration')

vim.api.nvim_create_user_command("Fs", function ()
    plugin.from_socket(vim.api.nvim_get_current_win())
end, {})
