local M = {}
local CC_config = require('colorformat.misc.config')
local CC_install = require("colorformat.misc.installation")
local CC_converter = require('colorformat.misc.converter')
local CC_utils = require("colorformat.misc.utils")
local CC_buffer = require("colorformat.misc.buffer_helpers")
local vim = vim

M.setup = function(options)
  -- Merge the user-provided options with the default options
  CC_config.options = vim.tbl_deep_extend("keep", options or {}, CC_config.options)
  -- Enable keymap if they are not disableds
  if not CC_config.options.disable_keymaps then
    local keymaps_opts = {buffer = 0, silent = true}
    local filetypes = CC_config.options.filetypes or 'css'
    -- Create the keymaps for the specified filetypes
    vim.api.nvim_create_autocmd('FileType', {
      desc = 'colorformat.nvim keymaps',
      pattern = filetypes,
      callback = function()
        vim.keymap.set('v', '<leader>cn', ":lua require('colorformat').get_color_name()<CR>", keymaps_opts)
        vim.keymap.set('v', '<leader>c#', ":lua require('colorformat').get_color_conversion('hex')<CR>", keymaps_opts)
        vim.keymap.set('v', '<leader>ch', ":lua require('colorformat').get_color_conversion('hsl')<CR>", keymaps_opts)
        vim.keymap.set('v', '<leader>cl', ":lua require('colorformat').get_color_conversion('lch')<CR>", keymaps_opts)
        vim.keymap.set('v', '<leader>cr', ":lua require('colorformat').get_color_conversion('rgb')<CR>", keymaps_opts)
      end,
    })
  end
  -- Show virtual text if the option is enabled
  if CC_config.options.display_virtual_text then
    M.virtual_text()
  end
end

M.virtual_text = function()
  M.namespace = vim.api.nvim_create_namespace("color-commander")
  -- Change filtype format from "*.css" to "css"
  local filetypes = {}
  for _, filetype in ipairs(CC_config.options.filetypes) do
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
  -- Get current line content
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local line_content = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
  -- Paste the hex value at the cursor selection
  local result, initial = CC_converter.color_value(line_content, virtual_text, mode)
  local pos_text, select_text = CC_buffer.capture_visual_selection()
  CC_utils.update_color(initial, select_text, result, pos_text)
end

M.get_color_name = function()
  CC_install.check_if_colornames_exist()
  -- Read the JSON file containing the color names
  local ok, data = pcall(CC_utils.read_json)
  if not ok then
    return
  end
  -- Get current line content
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local line_content = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
  -- Get the nearest color name to the target hex value and paste it at the cursor
  local result, initial = CC_converter.color_value(line_content, nil, "hex")
  local pos_text, select_text = CC_buffer.capture_visual_selection()
  local color_names = data or {}
  CC_utils.update_color(initial, select_text, result, pos_text, color_names)
end

M.get_color_virtual = function()
  -- Get the current line content
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local line_content = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
  -- Extract color details
  local virtual_text = {}
  CC_converter.color_value(line_content, virtual_text)
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
