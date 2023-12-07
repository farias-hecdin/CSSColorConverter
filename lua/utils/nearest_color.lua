local M = {}
local hex = require('utils.color_hex')

local color_distance = function(r1, g1, b1, r2, g2, b2)
  return math.sqrt((r2 - r1) ^ 2 + (g2 - g1) ^ 2 + (b2 - b1) ^ 2)
end

M.nearest_color = function(target_hex, color_list)
  local min_distance = 1e9
  local nearest_color = nil
  local hexToRgb = hex.hexToRgb
  local tr, tg, tb = hexToRgb(target_hex)

  for _, color in ipairs(color_list) do
    local r, g, b = hexToRgb(color.hex)
    local distance = color_distance(tr, tg, tb, r, g, b)

    if distance < min_distance then
      min_distance = distance
      nearest_color = color
    end
  end

  return nearest_color
end

return M
