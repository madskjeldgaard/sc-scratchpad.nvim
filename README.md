# sc-scratchpad.nvim
![screenshot](assets/screen.gif) 

## Installation

Using [vim-plugin](https://github.com/junegunn/vim-plug)

```vim
Plug 'madskjeldgaard/sc-scratchpad.nvim'
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use 'madskjeldgaard/sc-scratchpad.nvim'
```

## Setup

```lua
require"sc-scratchpad".setup({
	keymaps = {
		toggle = "<space>",
		send = "<C-E>",
	},
	position = "50%",
	width = "50%",
	height = "50%",
})
```
