local M = {}

require('shell_integration.internal')

local bin_dir = ""
-- We include vim.go.rtp here to support including this plugin by adjust rtp and calling require('shell_integration') from a --cmd command.
local paths = vim.tbl_flatten({
    vim.split(vim.go.packpath, ","), --packpath seems to change after initialization
    vim.split(vim.go.rtp, ","), --rtp seems to change after initialization
})
for _, path in ipairs(paths) do
    bin_dir = vim.fn.finddir("shell_integration_bin", path)
    if bin_dir ~= "" then break end
end
assert(bin_dir ~= "", "shell_integration_bin not found")

local using_windows = vim.loop.os_uname().sysname == "Windows_NT"
vim.env.PATH = vim.env.PATH .. (using_windows and ";" or ":") .. vim.fn.fnamemodify(bin_dir, ":p")

M.from_socket = function (window)
    vim.fn.win_gotoid(window)
    vim.cmd.terminal("nc -Ul " .. vim.g.shell_integration_data_channel)
end

return M
