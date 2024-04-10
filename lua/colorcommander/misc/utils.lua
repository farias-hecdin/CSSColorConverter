local M = {}
local CC_buffer = require("colorcommander.misc.buffer_helpers")
local CC_nearest_color = require('colorcommander.colors.nearest')
local vim = vim

local function read_file(file)
  local fd = assert(io.open(file, "r"))
  local data = fd:read("*a")
  fd:close()
  return data
end

M.round = function(number, decimals)
  local power = 10 ^ decimals
  return math.floor(number * power + 0.5) / power
end

M.read_json = function()
  local fd = read_file(vim.fn.expand('~/.local/share/nvim/colorcommander/colornames.json'))
  return vim.json.decode(fd)
end

M.transform_text = function(input)
  local result = string.lower(input)
  -- Replace spaces and symbols with hyphens
  result = string.gsub(result, "['’]", "")
  return string.gsub(result, "%W", "-")
end

M.update_color = function(initial, select_text, result, pos_text, useColorName)
  for i = 1, #initial do
    if select_text and initial[i] == select_text[1] then
      if useColorName then
        local color_names = CC_nearest_color.nearest_color(result[i], useColorName)
        select_text[1] = M.transform_text(color_names.name)
        vim.print(string.format("[ColorCommander.nvim] %s is equal to: %s", result[i], color_names.name))
      else
        select_text[1] = result[i]
        vim.print(string.format("[ColorCommander.nvim] %s is equal to: %s", initial[i], result[i]))
      end
      CC_buffer.change_text(pos_text, select_text)
    end
  end
end

return M
