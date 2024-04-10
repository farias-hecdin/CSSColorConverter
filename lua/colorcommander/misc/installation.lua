local M = {}
local vim = vim

-- Thanks to: https://www.reddit.com/r/neovim/comments/pa4yle/help_with_async_in_lua/
local download_file = function(url, file)
  local plenary = require('plenary')

  plenary.job:new({
    command = 'curl',
    args = { '-s', url, '-o', file },
    on_start = function() vim.print('[ColorCommander.nvim] Downloading colornames.json...') end,
    on_exit = function(j, exit_code)
      local status = "[ColorCommander.nvim] Success!"
      if exit_code ~= 0 then
        status = "[ColorCommander.nvim] Error!"
      end
      vim.notify(status, vim.log.levels.INFO)
    end,
  }):start()
end

M.check_if_colornames_exist = function()
  local install_path, filename = vim.fn.stdpath('data') .. '/colorcommander/', "colornames.json"
  -- Check if a directory exists in this path
  if vim.fn.isdirectory(install_path) ~= 1 then
    vim.fn.mkdir(install_path, 'p')
  end
  -- Check if the file exists in the install path
  if vim.fn.filereadable(install_path .. filename) ~= 1 then
    download_file("https://unpkg.com/color-name-list@10.16.0/dist/colornames.json", install_path .. filename)
    local message = '[ColorCommander.nvim] The colorname.json file has been downloaded.'
    vim.notify(message, vim.log.levels.INFO)
  end
end

return M
