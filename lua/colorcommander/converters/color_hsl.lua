-- Thanks to: https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua
local M = {}

M.hslToRgb = function(h, s, l)
  local r, g, b
  if s == 0 then
    r, g, b = l, l, l
  else
    local function hue2rgb(p, q, t)
      if t < 0 then t = t + 1 end
      if t > 1 then t = t - 1 end
      if t < 1/6 then return p + (q - p) * 6 * t end
      if t < 1/2 then return q end
      if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
      return p
    end

    local q
    if l < 0.5 then q = l * (1 + s) else q = l + s - l * s end
    local p = 2 * l - q

    r = hue2rgb(p, q, h + 1/3)
    g = hue2rgb(p, q, h)
    b = hue2rgb(p, q, h - 1/3)
  end

  return r * 255, g * 255, b * 255
end

M.hslToHex = function(h, s, l)
  local r, g, b = M.hslToRgb(h/360, s/100, l/100)
  return string.format("#%02x%02x%02x", r, g, b)
end

-- function M.replaceHexWithHSL()
--   local line_number = vim.api.nvim_win_get_cursor(0)[1]
--   local line_content = vim.api.nvim_buf_get_lines(0, line_number - 1, line_number, false)[1]
--
--   for hex in line_content:gmatch("#[0-9a-fA-F]+") do
--     local hsl = M.hexToHSL(hex)
--     line_content = line_content:gsub(hex, hsl)
--   end
--
--   vim.api.nvim_buf_set_lines(0, line_number - 1, line_number, false, { line_content })
-- end

return M
