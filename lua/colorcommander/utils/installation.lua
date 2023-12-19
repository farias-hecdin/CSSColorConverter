local M = {}
local vim = vim

-- Check if a file or directory exists in this path (Thanks to: https://stackoverflow.com/a/40195356)
local function exists(file)
  local ok, err, code = os.rename(file, file)
  if not ok then
    if code == 13 then
      -- Permission denied, but it exists
      return true
    end
  end
  return ok, err
end

-- Check if a directory exists in this path
local is_dir = function(path)
  return exists(path)
end

local download_file = function(url, file)
  -- Thank to: https://www.reddit.com/r/neovim/comments/pa4yle/help_with_async_in_lua/
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
  local path, dirname = vim.fn.expand('~/.local/share/nvim/'), "colorcommander"
  local dir, err = is_dir(path .. dirname)

  if not dir then
    os.execute("mkdir " .. path .. dirname)
    download_file(
      "https://unpkg.com/color-name-list@10.16.0/dist/colornames.json",
      path .. dirname .. '/colornames.json'
    )
  else
    vim.print('[ColorCommander.nvim] The colorname.json file has been downloaded.')
  end
end

return M
