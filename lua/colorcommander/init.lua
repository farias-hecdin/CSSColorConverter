local vLog = require("colorcommander.log").info

local M = {}
local CC_config = require('colorcommander.misc.config')
local CC_install = require("colorcommander.misc.installation")
local CC_converter = require('colorcommander.misc.converter')
local CC_utils = require("colorcommander.misc.utils")
local CC_nearest_color = require('colorcommander.colors.nearest')
local vim = vim

M.setup = function(options)
  -- Merge the user-provided options with the default options
  CC_config.options = vim.tbl_deep_extend("keep", options or {}, CC_config.options)
  -- Create user commands
  local user_command = vim.api.nvim_create_user_command
  local commands = {
    {"ColorToName", M.get_colorname},
    {"ColorNameInstall", CC_install.installation},
    {"ColorPaste", function() M.get_color(false, {}) end},
    {"ColorToHsl", function() M.get_color('hsl') end},
    {"ColorToHex", function() M.get_color('hex') end},
    {"ColorToLch", function() M.get_color('lch') end},
    {"ColorToRgb", function() M.get_color('rgb') end},
  }
  for _, command in ipairs(commands) do
    user_command(command[1], command[2], {})
  end
  -- Create keymaps
  local keymap_opts = { noremap = true, silent = true }
  if not CC_config.options.disable_keymaps then
    local keymaps = {
      { "<leader>cn", ":ColorToName<CR>" },
      { "<leader>cp", ":ColorPaste<CR>" },
      { "<leader>ch", ":ColorToHsl<CR>" },
      { "<leader>c#", ":ColorToHex<CR>" },
      { "<leader>cl", ":ColorToLch<CR>" },
      { "<leader>cr", ":ColorToRgb<CR>" },
    }
    for _, keymap in ipairs(keymaps) do
      vim.api.nvim_set_keymap("n", keymap[1], keymap[2], keymap_opts)
    end
  end
  -- Show virtual text (if enabled)
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
  local result = CC_converter.color_value(line_content, virtual_text, mode)
  CC_utils.paste_at_cursor(false, result)
end

M.get_colorname = function()
  -- Get current line content
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local line_content = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
  -- Read the JSON file containing the color names
  local color_names = {}
  local ok, data = pcall(CC_utils.read_json)
  if not ok then vim.print('Error!')
    return
  end
  color_names = data or {}
  -- Find the nearest color name to the target hex value
  local target_hex = CC_converter.color_value(line_content, nil)
  color_names = CC_nearest_color.nearest_color(target_hex, color_names)
  if color_names ~= 'nil' then
    local res = CC_utils.transform_text(color_names.name)
    vim.print('[ColorCommander.nvim] ' .. target_hex .. ' is equal to: ' .. color_names.name)
    -- Transform the color name and paste at the cursor position
    CC_utils.paste_at_cursor(true, res)
  end
end

M.get_color_details = function()
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
        virt_text = { { table.concat(virtual_text, " "), "Comment" } },
        id = M.namespace,
        priority = 100,
      }
    )
  end
end

return M
