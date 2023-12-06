> 📌 Use Google Translate to read this file in your native language.

# ColorCommander.nvim

Este plugin para Neovim ofrece funcionalidades para trabajar con colores HEX, RGB, HSL y LSH. Permite convertir los colores a formato HEX y visualizar su valor en un texto virtual, además de identificar el nombre del color.

## Instalación

- Usando `[folke/lazy.nvim](https://github.com/folke/lazy.nvim)`:

```lua
{
    'farias-hecdin/ColorCommander.nvim',
    config = true,
    -- Si quieres configurar algunas opciones, sustituye la línea anterior con:
    -- config = function()
    --    require('colorcommander').setup({})
    -- end,
}
```

## Configuracion

Estas son las opciones de configuración predeterminadas:

```lua
require('colorcommander').setup({
    show_virtual_text = true,
    disable_keymaps = false,
    filetypes = { "css", "scss", "sass" },
})
```

## Comandos y atajos de teclado

### Comandos

| Comandos           | Descripcion                         |
| -------------      | ----------------------------------- |
| `ColorToName`      | Identifica el nombre de un color a partir de su código (HEX, RGB, HSL o LCH) |
| `ColorNameInstall` | Descarga la lista de nombres de colores |

### Atajos de teclado

Estos son los atajos de teclado predeterminados:

```lua
vim.api.nvim_set_keymap("n", "<leader>cn", ":ColorToName<CR>", { noremap = true, silent = true })
```
Puedes desactivar los atajos de teclado predeterminados estableciendo `disable_keymaps` en `true`

## Agradecimientos a

* [nvim-px-to-rem](https://github.com/jsongerber/nvim-px-to-rem): ha sido la base e inspiración para este plugin.

## Plugins similares

* [colortils.nvim](https://github.com/nvim-colortils/colortils.nvim)

## Licencia

ColorCommander.nvim está bajo la licencia MIT. Consulta el archivo `LICENSE` para obtener más información.
