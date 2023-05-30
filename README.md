# toggleterm.nvim
Toggle terminal in neovim

## Configuration
`opts` is a table that can contain:
- `auto_insert`: if set to true, toggleterm will create an autocommand that will enable insert mode as soon as a terminal buffer is opened
- `key`: if set, it'll create a keybind to toggle the terminal

## Available functions
- `setup`
- `toggle`: function that gets called to toggle terminal. Same one used in `opts.key`

## Examples
Set up for lazy:
```
return {
    'grecodavide/toggleterm.nvim',
    config = function()
        require("toggleterm").setup({key = '<C-t>'})
    end
}
```
