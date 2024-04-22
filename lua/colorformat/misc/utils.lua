local M = {}
local buffer = require("colorformat.misc.buffer_helpers")
local nearest = require('colorformat.colors.nearest')
local vim = vim

-- to read a file and return its content
local function read_file(file)
  local fd = assert(io.open(file, "r"))
  local data = fd:read("*a")
  fd:close()
  return data
end

-- to round a number to a specified number of decimal places
M.round = function(number, decimals)
  local power = 10 ^ decimals
  return math.floor(number * power + 0.5) / power
end

-- to read a JSON file and return its content as a Lua table
M.read_json = function()
  local fd = read_file(vim.fn.expand('~/.local/share/nvim/colorformat/colornames.json'))
  return vim.json.decode(fd)
end

-- to transform a string by making it lowercase and replacing spaces and symbols with hyphens
M.transform_text = function(input)
  local result = string.lower(input)
  result = string.gsub(result, "['’]", "")
  return string.gsub(result, "%W", "-")
end

-- to update a color in the text
M.update_color = function(initial, select_text, result, pos_text, useColorName)
  for i = 1, #initial do
    if select_text and initial[i] == select_text[1] then
      -- If using color names
      if useColorName then
        local color_names = nearest.nearest_color(result[i], useColorName)
        if color_names then
          select_text[1] = M.transform_text(color_names.name)
          vim.print(string.format("[Colorformat.nvim] %s is equal to: %s", result[i], color_names.name))
        end
      else
        select_text[1] = result[i]
        vim.print(string.format("[Colorformat.nvim] %s is equal to: %s", initial[i], result[i]))
      end
      buffer.change_text(pos_text, select_text)
    end
  end
end

-- to get the content of the current line
M.get_current_line_content = function()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local line_content = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
  return line, line_content
end

return M
