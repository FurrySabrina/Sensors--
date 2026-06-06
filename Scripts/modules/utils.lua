
--- Opens a json file and returns the data. (safely)
--- @param file string File to open
--- @return table? Data The data (if successful)
function safe_json_open(file)
    local success, data = pcall(sm.json.open, file)
    if not success then
        print("Error loading file: " .. file)
        return
    end
    if not data then
        print("No data found in file: " .. file)
        return
    end
    return data
end
