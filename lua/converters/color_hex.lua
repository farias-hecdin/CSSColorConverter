local M = {}
local rgb = require("converters.color_rgb")

function M.hexToRgb(hex)
  hex = hex:gsub("#","")
  return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

function M.hexToHsl(hex)
  local r, g, b = M.hexToRgb(hex)
  return rgb.rgbToHsl(r, g, b)
end

return M
