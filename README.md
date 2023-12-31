> 📌 Use Google Translate to read this file in your native language.

# ColorCommander.nvim

Este plugin para Neovim ofrece funcionalidades para trabajar con diferentes modelos de color, como `hex`, `rgb`, `hsl` y `lch`. Permite convertir los colores entre estos modelos, visualizar su valor en un texto virtual e identificar su nombre correspondiente.

## Requerimientos

* [`neovim`](https://github.com/neovim/neovim) >= 0.7
* [`plenary.nvim`](https://github.com/nvim-lua/plenary.nvim)
* [`curl`](https://curl.se)

### Instalación

Usando [`folke/lazy.nvim`](https://github.com/folke/lazy.nvim):

```lua
{
    'farias-hecdin/ColorCommander.nvim',
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
require('colorcommander').setup({{
    show_virtual_text = true, -- <boolean> Mostrar el texto virtual.
    virtual_text_to_hex = "lch", -- <string> Texto virtual para los colores hex ('rgb', 'hsl' o 'lch').
    disable_keymaps = false, -- <boolean> Desabihilitar los atajos de teclado.
    filetypes = { "css", "scss", "sass" }, -- <table> Archivos admitidos.
})
```

### Comandos y atajos de teclado

| Comandos           | Descripción                         |
| -------------      | ----------------------------------- |
| `ColorNameInstall` | Descargar la lista de nombres de colores |
| `ColorToName`      | Identificar el nombre del color |
| `ColorPaste`       | Retornar el valor del texto virtual |
| `ColorToHex`       | Convertir el color a `hex` |
| `ColorToRgb`       | Convertir el color a `rgb` |
| `ColorToHsl`       | Convertir el color a `hsl` |
| `ColorToLch`       | Convertir el color a `lch` |

Estos son los atajos de teclado predeterminados:

```lua
vim.api.nvim_set_keymap("n", "<leader>cn", ":ColorToName<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>cp", ":ColorPaste<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>ch", ":ColorToHex<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>cr", ":ColorToRgb<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>ch", ":ColorToHsl<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>cl", ":ColorToLch<CR>", { noremap = true, silent = true })
```

Puedes desactivar los atajos de teclado predeterminados estableciendo `disable_keymaps` en `true`

## Agradecimientos a

* [`jsongerber/nvim-px-to-rem`](https://github.com/jsongerber/nvim-px-to-rem): Ha sido la base e inspiración para este plugin.
* [`meodai/color-names`](https://github.com/meodai/color-names): Por proveer la lista de nombres de colores.

## Plugins similares

[`colortils.nvim`](https://github.com/nvim-colortils/colortils.nvim)

## Licencia

ColorCommander.nvim está bajo la licencia MIT. Consulta el archivo `LICENSE` para obtener más información.
