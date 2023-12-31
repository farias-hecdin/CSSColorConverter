local M = {}
local vim = vim

-- Check if a file or directory exists in this path (Thanks to: https://stackoverflow.com/a/40195356)
local function dir_exists(fdir)
  local ok, err = os.rename(fdir, fdir)
  if not ok then
    return false, err
  end
  return true
end

local download_file = function(url, file)
  -- Thanks to: https://www.reddit.com/r/neovim/comments/pa4yle/help_with_async_in_lua/
  local job = require('plenary.job')

  job:new({
    command = 'curl',
    args = { url, '-s', '-o', file },
    on_start = function()
      vim.print('[ColorCommander.nvim] Downloading colornames.json...')
    end,
    on_exit = function(j, exit_code)
      local type = "[ColorCommander.nvim] Success!"
      if exit_code ~=0 then
        type = "[ColorCommander.nvim] Error!"
      end
      vim.print(type)
    end,
  }):start()
end

M.installation = function()
  local path, filename = vim.fn.expand('~/.local/share/nvim/colorcommander/'), "colornames.json"
  -- Check if a directory exists in this path
  if not dir_exists(path) then
    os.execute("mkdir -p " .. path)
    download_file("https://unpkg.com/color-name-list@10.16.0/dist/colornames.json", path .. filename)
  else
    vim.print('[ColorCommander.nvim] The colorname.json file has been downloaded.')
  end
end

return M
