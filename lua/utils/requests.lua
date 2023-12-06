local M = {}

-- Thanks to: https://stackoverflow.com/a/71565184/22265190
M.fetch_data = function()
  local found_data = nil  -- will be nil or 1
  local curl_data = io.popen("curl -s -k https://unpkg.com/color-name-list@10.16.0/dist/colornames.json")

  if curl_data then    -- io.popen worked.
    found_data = curl_data:read("*a")  -- read entire file into string my_ip
    curl_data:close()         -- close the file (pipe)
  end
  return found_data
end

return M
