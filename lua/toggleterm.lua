local M = {}

-- TODO: support for multiple terminals

---@param tbl table
---@param val any
local function contains(tbl, val)
    if val == nil then
        return false
    end
    for _, e in pairs(tbl) do
        if e == val then
            return true
        end
    end
    return false
end

M.open = function()
    local bufnrs = vim.api.nvim_list_bufs()

    if not contains(bufnrs, _G.TERMBUF) then -- create new buf for terminal
        vim.api.nvim_command("terminal")
        vim.bo.buflisted = false
        _G.TERMBUF = vim.api.nvim_get_current_buf()
        vim.api.nvim_command("startinsert")

        if _G.toggleterm_cwd then
            vim.api.nvim_input(string.format("cd %s<CR>", vim.fn.expand("#:p:h")))
        end
    else -- switch to buf
        vim.api.nvim_set_current_buf(_G.TERMBUF)
        if _G.toggleterm_cwd then
            vim.api.nvim_command("startinsert")
            vim.api.nvim_input(string.format("cd %s<CR>", vim.fn.expand("#:p:h")))
        end
    end

    _G.TERMOPEN = true
end

---@param start_command string
M.close = function(start_command)
    if vim.fn.expand('#') == "" then
        start_command = start_command or "intro"
        vim.api.nvim_command(start_command)
    else
        vim.api.nvim_command("buffer #")
    end

    _G.TERMOPEN = false
end

---@param start_command string
M.toggle = function(start_command)
    if _G.TERMOPEN then
        M.close(start_command)
    else
        M.open()
    end
end

---@param vert boolean
M.split_open = function(vert)
    if vert == true then
        vim.api.nvim_command("vsplit")
    else
        vim.api.nvim_command("split")
    end
    M.open()
end

---@param start_command string
M.split_close = function(start_command)
    M.close(start_command)
    pcall(vim.api.nvim_win_close, 0, { force = true })
end

---@param vert boolean
---@param start_command string
M.split_toggle = function(vert, start_command)
    if _G.TERMOPEN then
        M.split_close(start_command)
    else
        M.split_open(vert)
    end
end


---@param opts table
M.setup = function(opts)
    -- Initialize TERMOPEN to false
    _G.TERMOPEN = false

    if opts.auto_insert == true then
        vim.api.nvim_create_augroup("Toggleterm", {})
        vim.api.nvim_create_autocmd("BufEnter", {
            group    = "Toggleterm",
            pattern  = "term://*",
            desc     = "enter insert mode in terminals",
            callback = function()
                vim.api.nvim_command([[startinsert]])
            end
        })
    end


    -- Set keys
    if type(opts.keys) == "table" then
        local mappings = {
            tab = function() return M.toggle(opts.start_command) end,
            split = function() return M.split_toggle(false, opts.start_command) end,
            vsplit = function() return M.split_toggle(true, opts.start_command) end
        }
        for ind,opt in pairs(mappings) do
            local key = opts.keys[ind]

            if key ~= nil then
                vim.keymap.set({ 'n', 't' }, key, opt, { noremap = true, silent = true, desc = string.format("Toggle term (%s)", ind) })
            end
        end
    end

    -- Should change the directory every time terminal buf is opened?
    _G.toggleterm_cwd = opts.cwd or false
end

return M
