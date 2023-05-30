local M = {}

local function contains(tbl, val)
    if val == nil then
        return false
    end
    for _,e in pairs(tbl) do
        if e == val then
            return true
        end
    end
    return false
end

M.toggle = function ()
    local bufnrs = vim.api.nvim_list_bufs()

    if not contains(bufnrs, _G.TERMBUF) then
        vim.api.nvim_command("terminal")
        vim.bo.buflisted = false
        _G.TERMBUF = vim.api.nvim_get_current_buf()
        vim.api.nvim_command("startinsert")
    elseif _G.TERMOPEN then
        pcall(vim.api.nvim_command, "buffer #")
    else
        vim.api.nvim_set_current_buf(_G.TERMBUF)
    end

    _G.TERMOPEN = not _G.TERMOPEN
end

M.setup = function(opts)
    if opts.auto_insert ~= false then
        vim.api.nvim_create_augroup("Toggleterm", {})
        vim.api.nvim_create_autocmd("BufEnter", {
            group       = "Toggleterm",
            pattern     = "term://*",
            desc        = "enter insert mode in terminals",
            callback    = function ()
                vim.api.nvim_command([[startinsert]])
            end
        })
    end

    if opts.key ~= nil then
        vim.keymap.set({'n', 't'}, opts.key, function () return M.toggle() end, {noremap = true, silent = true, desc = 'Toggle term'})
    end

end

return M
