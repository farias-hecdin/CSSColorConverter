> [!TIP]
> Use `Google Translate` to read this file in your native language.

# Colorformat.nvim

Este plugin para Neovim proporciona herramientas para trabajar con diferentes modelos de color, incluyendo `hex`, `rgb`, `hsl` y `lch`. Con él, puedes convertir colores entre estos formatos, visualizar su valor en un texto virtual y determinar su nombre correspondiente.

## Requerimientos

* [`neovim`](https://github.com/neovim/neovim) >= 0.7
* [`plenary.nvim`](https://github.com/nvim-lua/plenary.nvim)
* [`curl`](https://curl.se)

### Instalación

Usando [`folke/lazy.nvim`](https://github.com/folke/lazy.nvim):

```lua
{
    'farias-hecdin/Colorformat.nvim',
    dependencies = {
        "nvim-lua/plenary.nvim"
    },
    config = true,
    -- Si quieres configurar algunas opciones, sustituye la línea anterior con:
    -- config = function()
    -- end,
}
```

## Configuración

Estas son las opciones de configuración predeterminadas:

```lua
require('colorformat').setup({{
    display_virtual_text = true, -- <boolean> Mostrar el texto virtual.
    target_color_format = "lch", -- <string> Formato del color del texto virtual ('rgb', 'hsl', 'lch' o 'hex').
    disable_keymaps = false, -- <boolean> Desabihilitar los atajos de teclado.
    filetypes = { "css", "scss", "sass" }, -- <table> Archivos admitidos.
})
```

### Funciones y atajos de teclado

| API                           | Descripción                         |
| ----------------------------- | ----------------------------------- |
| `get_color_name()`            | Identificar el nombre del color |
| `get_color_conversion('hex')` | Convertir el color a `hex` |
| `get_color_conversion('rgb')` | Convertir el color a `rgb` |
| `get_color_conversion('hsl')` | Convertir el color a `hsl` |
| `get_color_conversion('lch')` | Convertir el color a `lch` |

Estos son los atajos de teclado predeterminados:

```lua
local keymaps_opts = {buffer = 0, silent = true}

vim.keymap.set('v', '<leader>cn', ":lua require('colorformat').get_color_name()<CR>", keymaps_opts)
vim.keymap.set('v', '<leader>c#', ":lua require('colorformat').get_color_conversion('hex')<CR>", keymaps_opts)
vim.keymap.set('v', '<leader>ch', ":lua require('colorformat').get_color_conversion('hsl')<CR>", keymaps_opts)
vim.keymap.set('v', '<leader>cl', ":lua require('colorformat').get_color_conversion('lch')<CR>", keymaps_opts)
vim.keymap.set('v', '<leader>cr', ":lua require('colorformat').get_color_conversion('rgb')<CR>", keymaps_opts)
```

Puedes desactivar los atajos de teclado predeterminados estableciendo la opción `disable_keymaps` en `true`

## Agradecimientos a

* [`jsongerber/nvim-px-to-rem`](https://github.com/jsongerber/nvim-px-to-rem): Ha sido la base y fuente de inspiración para este plugin.
* [`meodai/color-names`](https://github.com/meodai/color-names): Por proveer la lista de nombres de colores.

## Plugins similares

[`colortils.nvim`](https://github.com/nvim-colortils/colortils.nvim)

## Licencia

Colorformat.nvim está bajo la licencia MIT. Consulta el archivo `LICENSE` para obtener más información.
