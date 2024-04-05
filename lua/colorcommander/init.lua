local vLog = require("colorcommander.log").info

local M = {}
local C = require('colorcommander.utils.config')
local I = require("colorcommander.utils.installation")
local E = require('colorcommander.utils.extraction')
local S = require("colorcommander.utils.scripts")
local N = require('colorcommander.converters.nearest_color')
local vim = vim

M.setup = function(options)
  -- Merge the user-provided options with the default options
  C.options = vim.tbl_deep_extend("keep", options or {}, C.options)
  -- Create user commands
  local user_command = vim.api.nvim_create_user_command
  user_command("ColorToName", M.get_colorname, {})
  user_command("ColorNameInstall", I.installation, {})
  user_command("ColorPaste", function() M.get_color(false, {}) end, {})
  user_command("ColorToHsl", function() M.get_color('hsl') end, {})
  user_command("ColorToHex", function() M.get_color('hex') end, {})
  user_command("ColorToLch", function() M.get_color('lch') end, {})
  user_command("ColorToRgb", function() M.get_color('rgb') end, {})
  -- Create keymaps
  local keymap_opts = { noremap = true, silent = true }
  if not C.options.disable_keymaps then
    local keymaps = {
      { "<leader>cn", ":ColorToName<CR>" },
      { "<leader>cp", ":ColorPaste<CR>" },
      { "<leader>ch", ":ColorToHsl<CR>" },
      { "<leader>cH", ":ColorToHex<CR>" },
      { "<leader>cl", ":ColorToLch<CR>" },
      { "<leader>cr", ":ColorToRgb<CR>" },
    }
    for _, keymap in ipairs(keymaps) do
      vim.api.nvim_set_keymap("n", keymap[1], keymap[2], keymap_opts)
    end
  end
  -- Show virtual text (if enabled)
  if C.options.show_virtual_text then
    M.virtual_text()
  end
end

M.virtual_text = function()
  M.namespace = vim.api.nvim_create_namespace("color-commander")
  -- Change filtype format from "*.css" to "css"
  local filetypes = {}
  local table_insert = table.insert
  for _, filetype in ipairs(C.options.filetypes) do
    table_insert(filetypes, "*" .. filetype)
  end
  -- Create an autocommand
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "CursorMoved", "CursorMovedI" }, {
    pattern = filetypes,
    callback = function()
      M.get_color_details()
    end,
  })
end

M.get_color = function(mode, virtual_text)
  -- Get current line content
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local line_content = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
  -- Paste the hex value at the cursor position
  local res = E.get_hex_value(line_content, virtual_text)
  if mode and res then
    res = E.hex_to(mode, res)
  end
  S.paste_at_cursor(false, res)
end

M.get_colorname = function()
  -- Get current line content
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local line_content = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
  -- Read the JSON file containing the color names
  local color_names = {}
  local ok, data = pcall(S.read_json)
  if not ok then vim.print('Error!')
    return
  end
  color_names = data or {}
  -- Find the nearest color name to the target hex value
  local target_hex = E.get_hex_value(line_content, nil)
  color_names = N.nearest_color(target_hex, color_names)
  if color_names ~= 'nil' then
    local res = S.transform_text(color_names.name)
    vim.print('[ColorCommander.nvim] ' .. target_hex .. ' is equal to: ' .. color_names.name)
    -- Transform the color name and paste at the cursor position
    S.paste_at_cursor(true, res)
  end
end

M.get_color_details = function()
  local virtual_text = {}
  -- Get the current line content
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local line_content = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]

  E.get_hex_value(line_content, virtual_text)
  -- Check if an extmark already exists
  local extmark = vim.api.nvim_buf_get_extmark_by_id(0, M.namespace, M.namespace, {})
  if extmark ~= nil then
    vim.api.nvim_buf_del_extmark(0, M.namespace, M.namespace)
  end
  -- If there is virtual text to display, create an extmark
  if #virtual_text > 0 then
    vim.api.nvim_buf_set_extmark(0, tonumber(M.namespace), (line - 1), 0,
      {
        virt_text = { { table.concat(virtual_text, " "), "Comment" } },
        id = M.namespace,
        priority = 100,
      }
    )
  end
end

return M
