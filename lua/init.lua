local socket = vim.fn.serverstart('127.0.0.1:')
vim.env.NVIM_SHELL_INTEGRATION = socket

local using_windows = vim.loop.os_uname().sysname == "Windows_NT"
local bin_dir = vim.fn.expand('%:p:h:h') .. "/bin"
vim.env.PATH = vim.env.PATH .. (using_windows and ";" or ":") .. bin_dir
