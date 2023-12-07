local M = {}
local hex = require("utils.color_hex")
local rgb = require("utils.color_rgb")
local other = require('utils.color_xyz_and_lab')

function M.hexToLch(target)
  local r, g, b = hex.hexToRgb(target)
  local x, y, z = rgb.rgbToXyz(r, g, b)
  local L, A, B = other.xyzToLab(x, y, z)
  return other.labToLch(L, A, B)
end

return M
