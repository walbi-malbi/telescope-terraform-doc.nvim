# telescope-terraform-doc.nvim

An extension for the telescope.nvim to find terraform resources and view document.

[![asciicast](https://asciinema.org/a/566416.svg)](https://asciinema.org/a/566416)

## Get Started

Install with lazy

```lua
{
	"walbi-malbi/telescope-terraform-doc.nvim",
	config = function()
		require("telescope").load_extension("tfdoc")
	end,
},
```

## Mappings

|Keymap|Description|
|:-|:-|
|\<CR\>| open document in floating window |
|\<C-t\>| open document in new tab |
|\<C-v\>| open document in vsplit window |
|\<C-x\>| open document in split window |

## Require

- curl
- [glow](https://github.com/charmbracelet/glow)

## Usage

official or partner provider

```
:Telescope tfsec provider=aws
```

specific provider version

```
:Telescope tfsec provider=aws version=4.50.0
```

community provider

```
:Telescope tfsec provider=devops-rob/terracurl
```
