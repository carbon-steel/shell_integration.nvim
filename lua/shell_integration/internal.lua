local M = {}

local uv = vim.loop

local pipe, err_name, err_msg = uv.new_pipe(false)

if pipe == nil then
    vim.api.nvim_err_writeln(err_name .. ": " .. err_msg)
    return
end

local pipeName = vim.fn.tempname()

assert(pipe:bind(pipeName))

pipe:listen(128, function()
    local client, err_name, err_msg = uv.new_pipe(true)
    if not client then
        vim.api.nvim_err_writeln(err_name .. ": " .. err_msg)
        return
    end
    assert(pipe:accept(client))
    client:read_start(function (err, data)
        if err then
            vim.api.nvim_err_writeln(err)
            return
        end
        if data then
            vim.schedule(function ()
                vim.cmd.enew()
                local buf = vim.api.nvim_get_current_buf()
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(data, "\n"))
            end)
        else
            client:close()
        end
    end)
end)

-- TODO: Do server pipes need to be closed?
-- vim.api.nvim_create_autocmd("VimLeave", {
--     callback = pipe:close
-- })

vim.env.SHELL_INTEGRATION_PIPE_NAME = pipeName

return M
