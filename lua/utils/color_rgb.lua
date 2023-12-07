local M = {}

function M.rgbToHex(r, g, b)
  local function hexToString(number)
    local chars = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"}
    local low = number % 16
    local high = math.floor(number / 16) % 16
    return chars[high+1] .. chars[low+1]
  end

  local res = "#" .. hexToString(r) .. hexToString(g) .. hexToString(b)
  return res
end

-- Thanks to: https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua
function M.rgbToHsl(r, g, b)
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s, l = 0, 0, (max + min) / 2

  if max == min then
    h, s = 0, 0
  else
    local d = max - min
    if l > 0.5 then s = d / (2 - max - min) else s = d / (max + min) end
    if max == r then
      h = (g - b) / d
      if g < b then h = h + 6 end
    elseif max == g then
      h = (b - r) / d + 2
    elseif max == b then
      h = (r - g) / d + 4
    end
    h = h / 6
  end

  return h * 360, s * 100, l * 100
end

function M.rgbToXyz(r, g, b)
  local r = (r / 255)
  local g = (g / 255)
  local b = (b / 255)

  if r > 0.04045 then r = ((r + 0.055) / 1.055)^2.4 else r = r / 12.92 end
  if g > 0.04045 then g = ((g + 0.055) / 1.055)^2.4 else g = g / 12.92 end
  if b > 0.04045 then b = ((b + 0.055) / 1.055)^2.4 else b = b / 12.92 end

  local x = r * 0.4124 + g * 0.3576 + b * 0.1805
  local y = r * 0.2126 + g * 0.7152 + b * 0.0722
  local z = r * 0.0193 + g * 0.1192 + b * 0.9505

  return x * 100, y * 100, z * 100
end

return M
