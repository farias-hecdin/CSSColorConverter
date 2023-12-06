local M = {}

local hex_to_rgb = function(target_hex)
  local hex = target_hex
  hex = hex:gsub("#","")
  return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

local color_distance = function(r1, g1, b1, r2, g2, b2)
  return math.sqrt((r2 - r1) ^ 2 + (g2 - g1) ^ 2 + (b2 - b1) ^ 2)
end

M.nearest_color = function(target_hex, color_list)
  local min_distance = 1e9
  local nearest_color = nil
  local tr, tg, tb = hex_to_rgb(target_hex)

  for _, hex in ipairs(color_list) do
    local r, g, b = hex_to_rgb(hex.hex)
    local distance = color_distance(tr, tg, tb, r, g, b)

    if distance < min_distance then
      min_distance = distance
      nearest_color = hex
    end
  end

  return nearest_color
end

return M
