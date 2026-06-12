_dofile = _dofile or dofile
local __RETURN__ = nil
local __ARGS__ = nil
local loaded = {}

--[[

allows to send data to a script when loading it.
local ret1, ret2, ... = dofile("file.lua", arg1, arg2, ...)

allows to get values from dofile arguments.
local arg1, arg2, ... = args()

allows to throw an error from a dofiled script.
throw(ret1, ret2, ...)

]]

--- Loads a file and sends data.
--- @param file string File to load
--- @param ... any Arguments to send
function dofile(file, ...)
    if loaded[file] then
        fwarn({type = "io", func = "dofile"}, "File already loaded: " .. file)
    else
        loaded[file] = true
        fprint({type = "io", func = "dofile"}, "Loading Lua file: " .. file)
    end
    local previous_return = __RETURN__
    local previous_args = __ARGS__
    
    __ARGS__ = {...}
    __RETURN__ = { n = 0 }

    local status, err = pcall(_dofile, file)

    local result = __RETURN__

    __RETURN__ = previous_return
    __ARGS__ = previous_args

    if not status then
        error(err)
    end
    
    return result
end

--- Get arguments from the dofiled script
--- @return any ... Arguments
function args()
    fprint({type = "io", func = "args"}, "Getting arguments")
    if __ARGS__ == nil then return nil end -- sanity check
    return unpack(__ARGS__)
end

--- Send data back to the dofiler script
--- @param ... any Data to send back
function return_values(...)
    fprint({type = "io", func = "return_values"}, "Returning values")
    local len = select('#', ...)

    if not __RETURN__ then
        __RETURN__ = {}
        __RETURN__.n = 0
    end

    __RETURN__.n = len
    
    local args_list = {...}
    for i = 1, len do
        __RETURN__[i] = args_list[i]
    end
end

--- Throws an error from the dofiled script
--- @param ... any Data to send back
function throw(...)
    local len = select('#', ...)

    if not __RETURN__ then
        __RETURN__ = {}
        __RETURN__.n = 0
    end

    __RETURN__.n = len
    
    local args_list = {...}
    for i = 1, len do
        __RETURN__[i] = args_list[i]
    end
    error("<throw> : " .. table.concat(args_list, ", "))
end
