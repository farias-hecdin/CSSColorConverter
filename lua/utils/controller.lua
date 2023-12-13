local M = {}
local hex = require("converters.color_hex")
local rgb = require("converters.color_rgb")
local other = require('converters.color_xyz_and_lab')

function M.hexToLch(target)
  local a, b, c = hex.hexToRgb(target)
  a, b, c = rgb.rgbToXyz(a, b, c)
  a, b, c = other.xyzToLab(a, b, c)
  return other.labToLch(a, b, c)
end

function M.hexToHsl(target)
  return hex.hexToHsl(target)
end

function M.hexToRgb(target)
  return hex.hexToRgb(target)
end

return M
