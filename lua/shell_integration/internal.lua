local M = {}

local uv = vim.loop

local pipe, err_name, err_msg = uv.new_pipe(false)

if pipe == nil then
    vim.api.nvim_err_writeln(err_name .. ": " .. err_msg)
    return
end

assert(pipe:bind('/tmp/sock.test'))

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
                local popup_id = require("detour").Detour()
                if not popup_id then
                    return
                end
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

-- vim.g.shell_integration_data_channel = vim.fn.serverstart('nvim_shell_integration')

return M
