local M = {}
local plugin_name = "[ColorCommander.nvim]"
local C = require("core")
local U = require("utils.utils")
local N = require('utils.nearest_color')

M.options = {
  show_virtual_text = true,
  disable_keymaps = false,
  filetypes = {"css", "scss", "sass"},
}

M.setup = function(options)
  options = options or {}
  M.options = vim.tbl_deep_extend("keep", options, M.options)
  -- Create commands
  vim.api.nvim_create_user_command("ColorToName", M.get_colorname, {})
  vim.api.nvim_create_user_command("ColorNameInstall", C.core, {})
  -- and keymaps
  if not M.options.disable_keymaps then
    vim.api.nvim_set_keymap("n", "<leader>cn", ":ColorToName<CR>", { noremap = true, silent = true })
    -- vim.api.nvim_set_keymap("n", "<leader>ch", ":ColorToHex<CR>", { noremap = true, silent = true })
    -- vim.api.nvim_set_keymap("n", "<leader>cH", ":ColorToHsl<CR>", { noremap = true, silent = true })
    -- vim.api.nvim_set_keymap("n", "<leader>cr", ":ColorToRgb<CR>", { noremap = true, silent = true })
    -- vim.api.nvim_set_keymap("n", "<leader>cl", ":ColorToLch<CR>", { noremap = true, silent = true })
  end

  if M.options.show_virtual_text then
    M.virtual_text()
  end
  return M.options
end

M.virtual_text = function()
  M.namespace = vim.api.nvim_create_namespace("color-commander")
  -- Change filtype format from "*.css" to "css"
  local filetypes = {}
  for _, filetype in ipairs(M.options.filetypes) do
    table.insert(filetypes, "*" .. filetype)
  end

  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "CursorMoved", "CursorMovedI" }, {
    pattern = filetypes,
    callback = function()
      M.get_color_details()
    end,
  })
end

M.get_colorname = function()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local line_content = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
  local target_hex = C.get_hex_value(line_content, nil)
  local res = nil

  local color_names = U.read_json() or nil
  if not color_names then
    vim.print('Error!')
    return
  end

  color_names = N.nearest_color(target_hex, color_names)
  res = color_names.name
  vim.print(plugin_name .. ' ' .. target_hex .. ' equal to: ' .. res)

  res = U.transform_text(res)
  U.paste_at_cursor(res)
end

M.get_color_details = function()
  local virtual_text = {}
  -- Get current line content
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local line_content = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]

  C.get_hex_value(line_content, virtual_text)

  -- Check if an extmark already exists
  local extmark = vim.api.nvim_buf_get_extmark_by_id(0, M.namespace, M.namespace, {})
  if extmark ~= nil then
    vim.api.nvim_buf_del_extmark(0, M.namespace, M.namespace)
  end
  -- Config extmark
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
