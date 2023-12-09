> 📌 Use Google Translate to read this file in your native language.

# ColorCommander.nvim

Este plugin para Neovim ofrece funcionalidades para trabajar con colores HEX, RGB, HSL y LSH. Permite convertir los colores a formato HEX y visualizar su valor en un texto virtual, además de identificar el nombre del color.

## Requerimientos:

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
    show_virtual_text = true,
    show_virtual_text_to_hex = { "lch" },
    disable_keymaps = false,
    filetypes = { "css", "scss", "sass" },
})
```

### Comandos y atajos de teclado

| Comandos           | Descripción                         |
| -------------      | ----------------------------------- |
| `ColorToName`      | Identifica el nombre de un color a partir de su código (HEX, RGB, HSL o LCH) |
| `ColorNameInstall` | Descarga la lista de nombres de colores |
| `ColorPaste`       | Retorna el valor del texto virtual |

Estos son los atajos de teclado predeterminados:

```lua
vim.api.nvim_set_keymap("n", "<leader>cn", ":ColorToName<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>cp", ":ColorPaste<CR>", { noremap = true, silent = true })
```
Puedes desactivar los atajos de teclado predeterminados estableciendo `disable_keymaps` en `true`

## Agradecimientos a

* [`jsongerber/nvim-px-to-rem`](https://github.com/jsongerber/nvim-px-to-rem): Ha sido la base e inspiración para este plugin.
* [`meodai/color-names`](https://github.com/meodai/color-names): Por proveer la lista de nombres de colores.

## Plugins similares

[`colortils.nvim`](https://github.com/nvim-colortils/colortils.nvim)

## Licencia

ColorCommander.nvim está bajo la licencia MIT. Consulta el archivo `LICENSE` para obtener más información.

