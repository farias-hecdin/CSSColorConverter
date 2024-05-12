local M = {}
local vim = vim
local cph = require('CSSPluginHelpers')

--- INFO: config section ------------------------------------------------------

-- Options table with default values
M.options = {
  -- <boolean> Display virtual text for color variables
  display_virtual_text = true,
  -- <string> Format for target color (e.g. "hex" for hexadecimal)
  target_color_format = "hex",
  -- <boolean> Indicates whether keymaps are disabled
  disable_keymaps = false,
}

--- INFO: init section --------------------------------------------------------

M.setup = function(options)
  -- Merge the user-provided options with the default options
  M.options = vim.tbl_deep_extend("keep", options or {}, M.options)
  -- Enable keymap if they are not disableds
  if not M.options.disable_keymaps then
    local keymaps_opts = {buffer = 0, silent = true}
    -- Create the keymaps for the specified filetypes
    vim.api.nvim_create_autocmd('FileType', {
      desc = 'CSSColorConverter.nvim keymaps',
      pattern = 'css',
      callback = function()
        vim.keymap.set('v', '<leader>cn', ":lua require('CSSColorConverter').get_color_name()<CR>", keymaps_opts)
        vim.keymap.set('v', '<leader>c#', ":lua require('CSSColorConverter').get_color_conversion('hex')<CR>", keymaps_opts)
        vim.keymap.set('v', '<leader>ch', ":lua require('CSSColorConverter').get_color_conversion('hsl')<CR>", keymaps_opts)
        vim.keymap.set('v', '<leader>cl', ":lua require('CSSColorConverter').get_color_conversion('lch')<CR>", keymaps_opts)
        vim.keymap.set('v', '<leader>cr', ":lua require('CSSColorConverter').get_color_conversion('rgb')<CR>", keymaps_opts)
      end,
    })
  end
  -- Show virtual text if the option is enabled
  if M.options.display_virtual_text then
    M.virtual_text()
  end
end

-- Get the virtual color text for the current line
local get_color_virtual = function()
  local namespace = vim.api.nvim_create_namespace("csscolorconverter")
  local line, line_content = cph.get_current_line_content()
  local virtual_text = {}
  M.color_value(line_content, virtual_text)
  cph.show_virtual_text(virtual_text, line, namespace)
end

M.virtual_text = function()
  -- Create an autocommand to call the get_color_virtual() function
  vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter", "CursorMoved"}, {
    pattern = "*.css",
    callback = function()
      get_color_virtual()
    end,
  })
end

M.get_color_conversion = function(mode, virtual_text)
  local _, line_content = cph.get_current_line_content()
  -- Paste the hex value at the cursor selection
  local result, initial = M.color_value(line_content, virtual_text, mode)
  local pos_text, select_text = cph.capture_visual_selection()
  M.update_color(initial, select_text, result, pos_text)
end

-- Get the color name for the current selection
M.get_color_name = function()
  local _, line_content = cph.get_current_line_content()
  -- Read the JSON file containing the color names
  M.check_if_colornames_exist()
  local ok, data = pcall(M.read_json)
  if not ok then
    return
  end
  -- Get the nearest color name to the target hex value and paste it at the cursor
  local result, initial = M.color_value(line_content, nil, "hex")
  local pos_text, select_text = cph.capture_visual_selection()
  local color_names = data or {}
  M.update_color(initial, select_text, result, pos_text, color_names)
end


--- INFO: Find the nearest color ----------------------------------------------

-- Find the nearest color to a target color from a list of colors
local function color_distance(r1, g1, b1, r2, g2, b2)
  return math.sqrt((r2 - r1) ^ 2 + (g2 - g1) ^ 2 + (b2 - b1) ^ 2)
end

M.nearest_color = function(target_hex, color_list)
  local min_distance = 1e9
  local nearest_color = nil
  local tr, tg, tb = M.hex_to_rgb(target_hex)
  -- Iterate through the list of colors
  for _, color in ipairs(color_list) do
    local r, g, b = M.hex_to_rgb(color.hex)
    local distance = color_distance(tr, tg, tb, r, g, b)
    if distance < min_distance then
      min_distance = distance
      nearest_color = color
    end
  end
  return nearest_color
end

--- INFO: Convert X color values to ---------------------------------------------

-- Convert HEX color values to RGB color values
M.hex_to_rgb = function(hex)
  hex = hex:gsub("#","")
  return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

-- Convert HSL color values to RGB color values (thanks to: https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua)
local function hue_to_rgb(p, q, t)
  if t < 0 then t = t + 1 end
  if t > 1 then t = t - 1 end
  if t < 0.1667 then return p + (q - p) * 6 * t end
  if t < 0.5 then return q end
  if t < 0.6667 then return p + (q - p) * (0.6667 - t) * 6 end
  return p
end

M.hsl_to_rgb = function(h, s, l)
  local r, g, b
  if s == 0 then
    r, g, b = l, l, l
  else
    local q
    if l < 0.5 then q = l * (1 + s) else q = l + s - l * s end
    local p = 2 * l - q

    r = hue_to_rgb(p, q, h + 0.3333)
    g = hue_to_rgb(p, q, h)
    b = hue_to_rgb(p, q, h - 0.3333)
  end

  return r * 255, g * 255, b * 255
end

-- Convert HSL color values to HEX color values
M.hsl_to_hex = function(h, s, l)
  local r, g, b = M.hsl_to_rgb(h*0.00277778, s*0.01, l*0.01)
  return string.format("#%02x%02x%02x", r, g, b)
end

-- Convert LAB color values to LCH color values
M.lab_to_lch = function(l, a, b)
  local c = math.sqrt(a*a + b*b)
  local h = math.atan(b, a)
  if h < 0 then h = h + 2*math.pi end
  -- h = h * 180 / math.pi
  h = h * 57.29577951308232

  return l, c, h
end

-- Convert LCH color values to HEX color values (thanks to: https://stackoverflow.com/a/75850608/22265190)
M.lch_to_hex = function(l, c, h)
  local a = math.floor(c * math.cos(math.rad(h)) + 0.5)
  local b = math.floor(c * math.sin(math.rad(h)) + 0.5)
  -- Reference white values for CIE 1964 10° Standard Observer
  local xw, yw, zw = 0.948110, 1.00000, 1.07304

  local fy = (l + 16) / 116
  local fx = fy + (a / 500)
  local fz = fy - (b / 200)

  local x = xw * ((fx^3 > 0.008856) and fx^3 or ((fx - 16 / 116) / 7.787))
  local y = yw * ((fy^3 > 0.008856) and fy^3 or ((fy - 16 / 116) / 7.787))
  local z = zw * ((fz^3 > 0.008856) and fz^3 or ((fz - 16 / 116) / 7.787))

  local R = x * 3.2406 - y * 1.5372 - z * 0.4986
  local G = -x * 0.9689 + y * 1.8758 + z * 0.0415
  local B = x * 0.0557 - y * 0.2040 + z * 1.0570

  R = R > 0.0031308 and 1.055 * R^(1 / 2.4) - 0.055 or 12.92 * R
  G = G > 0.0031308 and 1.055 * G^(1 / 2.4) - 0.055 or 12.92 * G
  B = B > 0.0031308 and 1.055 * B^(1 / 2.4) - 0.055 or 12.92 * B

  R = math.floor(math.max(math.min(R, 1), 0) * 255 + 0.5)
  G = math.floor(math.max(math.min(G, 1), 0) * 255 + 0.5)
  B = math.floor(math.max(math.min(B, 1), 0) * 255 + 0.5)

  return string.format("#%02x%02x%02x", R, G, B)
end

-- Convert RGB color values to HSL color values (thanks to: https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua)
M.rgb_to_hsl = function(r, g, b)
  r, g, b = r / 255, g / 255, b / 255
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s, l
  l = (max + min) / 2

  if max == min then
    h, s = 0, 0
  else
    local d = max - min
    if l > 0.5 then s = d / (2 - max - min) else s = d / (max + min) end
    if max == r then
      h = (g - b) / d
      if g < b then h = h + 6 end
    elseif max == g then h = (b - r) / d + 2
    elseif max == b then h = (r - g) / d + 4
    end
    h = h / 6
  end
  return M.round((h * 360), 0), M.round((s * 100), 0), M.round((l * 100), 0)
end

-- Convert RGB color values to HEX color values
local function hex_to_string(number)
  local chars = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"}
  local low = number % 16
  local high = math.floor(number * 0.0625) % 16
  return chars[high+1] .. chars[low+1]
end

M.rgb_to_hex = function(r, g, b)
  return "#" .. hex_to_string(r) .. hex_to_string(g) .. hex_to_string(b)
end

-- Convert RGB color values to XYZ color values
M.rgb_to_xyz = function(R, G, B)
  local r = (R / 255)
  local g = (G / 255)
  local b = (B / 255)

  if r > 0.04045 then r = ((r + 0.055) / 1.055)^2.4 else r = r / 12.92 end
  if g > 0.04045 then g = ((g + 0.055) / 1.055)^2.4 else g = g / 12.92 end
  if b > 0.04045 then b = ((b + 0.055) / 1.055)^2.4 else b = b / 12.92 end

  local x = r * 0.4124 + g * 0.3576 + b * 0.1805
  local y = r * 0.2126 + g * 0.7152 + b * 0.0722
  local z = r * 0.0193 + g * 0.1192 + b * 0.9505

  return x * 100, y * 100, z * 100
end

-- Convert XYZ color values to LAB color values
M.xyz_to_lab = function(x, y, z)
  local function f(t)
    if t > 0.008856 then
      return t^(1/3)
    else
      return 7.787 * t + 16/116
    end
  end

  local xn, yn, zn = 95.047, 100.0, 108.883 -- Reference white D65
  x, y, z = x / xn, y / yn, z / zn

  local l = 116 * f(y) - 16
  local a = 500 * (f(x) - f(y))
  local b = 200 * (f(y) - f(z))

  return l, a, b
end

--- INFO: Convert colors -------------------------------------------------------------

M.color_value = function(line_content, virtual_text, mode)
  local color_formats = {
    { key = "rgb", pattern = "rgb%(%d+, %d+, %d+%)", value = "rgb%((%d+), (%d+), (%d+)%)" },
    { key = "hsl", pattern = "hsl%(%d+, %d+%p?, %d+%p?%)", value = "hsl%((%d+), (%d+)%p?, (%d+)%p?%)" },
    { key = "lch", pattern = "lch%(%d+%.?%d+%p? %d+%.?%d+ %d+%.?%d+%)", value = "lch%((%d+%.?%d+)%p? (%d+%.?%d+) (%d+%.?%d+)%)" },
    { key = "#", pattern = "#[%x][%x][%x][%x][%x][%x]", value = "" }
  }

  local send_to_virtual_text = virtual_text or {}
  local target_format = mode or string.lower(M.options.target_color_format)
  local result = {}
  local initial_value = {}

  for _, format in ipairs(color_formats) do
    local matches = string.gmatch(line_content, format.pattern)

    for input in matches do
      local current_format = format.key
      local n1, n2, n3 = 0, 0, 0
      -- to HEX color
      if target_format == "hex" then
        if current_format == "rgb" then
          result[#result + 1] = M.hex_to_rgb(select(1, string.match(input, format.value)))
        elseif current_format == "hsl" then
          result[#result + 1] = M.hsl_to_hex(select(1, string.match(input, format.value)))
        elseif current_format == "lch" then
          result[#result + 1] = M.lch_to_hex(select(1, string.match(input, format.value)))
        else
          result[#result + 1] = input
        end
      -- to RGB color
      elseif target_format == "rgb" then
        local text_style = 'rgb(%d, %d, %d)'
        if current_format == "#" then
          n1, n2, n3 = M.hex_to_rgb(input)
          result[#result + 1] = string.format(text_style, n1, n2, n3)
        elseif current_format == "hsl" then
          for x, y, z in string.gmatch(input, format.value) do
            n1, n2, n3 = M.hex_to_rgb(M.hsl_to_hex(tonumber(x), tonumber(y), tonumber(z)))
            result[#result + 1] = string.format(text_style, n1, n2, n3)
          end
        elseif current_format == "lch" then
          for x, y, z in string.gmatch(input, format.value) do
            n1, n2, n3 = M.hex_to_rgb(M.lch_to_hex(tonumber(x), tonumber(y), tonumber(z)))
            result[#result + 1] = string.format(text_style, n1, n2, n3)
          end
        else
          result[#result + 1] = input
        end
      -- to HSL color
      elseif target_format == "hsl" then
        local text_style = 'hsl(%d, %d, %d)'
        if current_format == "rgb" then
          for x, y, z in string.gmatch(input, format.value) do
            n1, n2, n3 = M.rgb_to_hsl(tonumber(x), tonumber(y), tonumber(z))
            result[#result + 1] = string.format(text_style, n1, n2, n3)
          end
        elseif current_format == "lch" then
          for x, y, z in string.gmatch(input, format.value) do
            n1, n2, n3 = M.rgb_to_hsl(M.hex_to_rgb(M.lch_to_hex(tonumber(x), tonumber(y), tonumber(z))))
            result[#result + 1] = string.format(text_style, n1, n2, n3)
          end
        elseif current_format == "#" then
          n1, n2, n3 = M.rgb_to_hsl(M.hex_to_rgb(input))
          result[#result + 1] = string.format(text_style, n1, n2, n3)
        else
          result[#result + 1] = input
        end
      -- to LCH color
      elseif target_format == "lch" then
        local text_style = 'lch(%.1f%% %.1f %.1f)'
        if current_format == "#" then
          n1, n2, n3 = M.hex_to_rgb(input)
          n1, n2, n3 = M.lab_to_lch(M.xyz_to_lab(M.rgb_to_xyz(n1, n2, n3)))
          result[#result + 1] = string.format(text_style, n1, n2, n3)
        elseif current_format == "rgb" then
          for x, y, z in string.gmatch(input, format.value) do
            n1, n2, n3 = M.lab_to_lch(M.xyz_to_lab(M.rgb_to_xyz(tonumber(x), tonumber(y), tonumber(z))))
            result[#result + 1] = string.format(text_style, n1, n2, n3)
          end
        elseif current_format == "hsl" then
          for x, y, z in string.gmatch(input, format.value) do
            n1, n2, n3 = M.lab_to_lch(M.xyz_to_lab(M.rgb_to_xyz(M.hex_to_rgb(M.hsl_to_hex(tonumber(x), tonumber(y), tonumber(z))))))
            result[#result + 1] = string.format(text_style, n1, n2, n3)
          end
        else
          result[#result + 1] = input
        end
      end
      initial_value[#initial_value + 1] = input
    end
  end

  if not mode then
    for i = 1, #result do
      table.insert(send_to_virtual_text, result[i])
    end
  end
  return result, initial_value
end

--- INFO: Colornames installation

-- Download a file from a specified URL (thanks to: https://www.reddit.com/r/neovim/comments/pa4yle/help_with_async_in_lua/)
local download_file = function(url, file)
  local Job = require('plenary.job')

  Job:new({
    command = 'curl',
    args = { '-s', url, '-o', file },
    on_start = function() vim.print('[CSSColorConverter] Downloading colornames.json...') end,
    on_exit = function(j, exit_code)
      local status = "[CSSColorConverter] Success!"
      if exit_code ~= 0 then
        status = "[CSSColorConverter] Error!"
      end
      vim.notify(status, vim.log.levels.INFO)
    end,
  }):start()
end

-- Check if colornames.json file exists, and download it if not
M.check_if_colornames_exist = function()
  local install_path, filename = vim.fn.stdpath('data') .. '/CSSColorConverter/', "colornames.json"
  -- Check if a directory exists in this path
  if vim.fn.isdirectory(install_path) ~= 1 then
    vim.fn.mkdir(install_path, 'p')
  end
  -- Check if the file exists in the install path
  if vim.fn.filereadable(install_path .. filename) ~= 1 then
    download_file("https://unpkg.com/color-name-list@10.16.0/dist/colornames.json", install_path .. filename)
    vim.notify('[CSSColorConverter] The colorname.json file has been downloaded.', vim.log.levels.INFO)
  end
end

--- INFO: Utilities

-- to round a number to a specified number of decimal places
M.round = function(number, decimals)
  local power = 10 ^ decimals
  return math.floor(number * power + 0.5) / power
end

-- to read a file and return its content
local function read_file(file)
  local fd = assert(io.open(file, "r"))
  local data = fd:read("*a")
  fd:close()
  return data
end

-- to read a JSON file and return its content as a Lua table
M.read_json = function()
  local fd = read_file(vim.fn.expand('~/.local/share/nvim/colorformat/colornames.json'))
  return vim.json.decode(fd)
end

-- to transform a string by making it lowercase and replacing spaces and symbols with hyphens
local transform_text = function(input)
  local result = string.lower(input)
  result = string.gsub(result, "['’]", "")
  return string.gsub(result, "%W", "-")
end

-- to update a color in the text
M.update_color = function(initial, select_text, result, pos_text, useColorName)
  for i = 1, #initial do
    if select_text and initial[i] == select_text[1] then
      -- If using color names, find the nearest color name
      if useColorName then
        local color_names = M.nearest_color(result[i], useColorName)
        if color_names then
          select_text[1] = transform_text(color_names.name)
          vim.print(string.format("[CSSColorConverter] %s is equal to: %s", result[i], color_names.name))
        end
      -- If not using color names, update the selected text with the result
      else
        select_text[1] = result[i]
        vim.print(string.format("[CSSColorConverter] %s is equal to: %s", initial[i], result[i]))
      end
      cph.change_text(pos_text, select_text)
    end
  end
end

return M
