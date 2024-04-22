local M = {}
local config = require('colorformat.misc.config')
local install = require("colorformat.misc.installation")
local converter = require('colorformat.misc.converter')
local utils = require("colorformat.misc.utils")
local buffer = require("colorformat.misc.buffer_helpers")
local vim = vim

M.setup = function(options)
  -- Merge the user-provided options with the default options
  config.options = vim.tbl_deep_extend("keep", options or {}, config.options)
  -- Enable keymap if they are not disableds
  if not config.options.disable_keymaps then
    local keymaps_opts = {buffer = 0, silent = true}
    local filetypes = config.options.filetypes or 'css'
    -- Create the keymaps for the specified filetypes
    vim.api.nvim_create_autocmd('FileType', {
      desc = 'colorformat.nvim keymaps',
      pattern = filetypes,
      callback = function()
        local keymaps = {
          { '<leader>cn', ":lua require('colorformat').get_color_name()<CR>" },
          { '<leader>c#', ":lua require('colorformat').get_color_conversion('hex')<CR>" },
          { '<leader>ch', ":lua require('colorformat').get_color_conversion('hsl')<CR>" },
          { '<leader>cl', ":lua require('colorformat').get_color_conversion('lch')<CR>" },
          { '<leader>cr', ":lua require('colorformat').get_color_conversion('rgb')<CR>" },
        }
        for _, keymap in ipairs(keymaps) do
          vim.keymap.set('v', keymap[1], keymap[2], keymaps_opts)
        end
      end,
    })
  end
  -- Show virtual text if the option is enabled
  if config.options.display_virtual_text then
    M.virtual_text()
  end
end

M.virtual_text = function()
  M.namespace = vim.api.nvim_create_namespace("color-commander")
  -- Change filtype format from "*.css" to "css"
  local filetypes = {}
  for _, filetype in ipairs(config.options.filetypes) do
    table.insert(filetypes, "*" .. filetype)
  end
  -- Create an autocomman to call the M.get_color_virtual() function
  vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter", "CursorMoved", "CursorMovedI"}, {
    pattern = filetypes,
    callback = function()
      M.get_color_virtual()
    end,
  })
end

M.get_color_conversion = function(mode, virtual_text)
  local _, line_content = utils.get_current_line_content()
  -- Paste the hex value at the cursor selection
  local result, initial = converter.color_value(line_content, virtual_text, mode)
  local pos_text, select_text = buffer.capture_visual_selection()
  utils.update_color(initial, select_text, result, pos_text)
end

M.get_color_name = function()
  local _, line_content = utils.get_current_line_content()
  -- Read the JSON file containing the color names
  install.check_if_colornames_exist()
  local ok, data = pcall(utils.read_json)
  if not ok then
    return
  end
  -- Get the nearest color name to the target hex value and paste it at the cursor
  local result, initial = converter.color_value(line_content, nil, "hex")
  local pos_text, select_text = buffer.capture_visual_selection()
  local color_names = data or {}
  utils.update_color(initial, select_text, result, pos_text, color_names)
end

M.get_color_virtual = function()
  local line, line_content = utils.get_current_line_content()
  -- Extract color details
  local virtual_text = {}
  converter.color_value(line_content, virtual_text)
  -- Remove existing extmark
  local extmark = vim.api.nvim_buf_get_extmark_by_id(0, M.namespace, M.namespace, {})
  if extmark ~= nil then
    vim.api.nvim_buf_del_extmark(0, M.namespace, M.namespace)
  end
  -- Create extmark if virtual text is present
  if #virtual_text > 0 then
    vim.api.nvim_buf_set_extmark(0, tonumber(M.namespace), (line - 1), 0,
      {
        virt_text = { {table.concat(virtual_text, " "), "Comment"} },
        id = M.namespace,
        priority = 100,
      }
    )
  end
end

return M
