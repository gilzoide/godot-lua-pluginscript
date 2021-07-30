local lps_scripts = {}
local lps_instances = {}

local function pointer_to_index(ptr)
    return tonumber(ffi.cast('uintptr_t', ptr))
end

ffi.C.lps_language_desc.add_global_constant = function(_data, name, value)
    _G[name] = value:unbox()
end

-- Scripts
local loadstring = loadstring or load
ffi.C.lps_script_init_cb = function(manifest, path, source)
    path = tostring(path)
    source = tostring(source)
    local script, err = loadstring(source, path)
    if not script then
        GD.print_error('Error parsing script: ' .. err)
        return GD.ERR_PARSE_ERROR
    end
    local success, metadata = pcall(script)
    if not success then
        GD.print_error('Error loading script: ' .. metadata)
        return GD.ERR_SCRIPT_FAILED
    end
    if type(metadata) ~= 'table' then
        GD.print_error(path .. ': script must return a table')
        return GD.ERR_SCRIPT_FAILED
    end
    local metadata_index = pointer_to_index(touserdata(metadata))
    lps_scripts[metadata_index] = metadata
    -- TODO: load metadata into manifest struct
    manifest.data = ffi.cast('void *', metadata_index)
    return GD.OK
end

ffi.C.lps_language_desc.script_desc.finish = function(data)
    lps_scripts[pointer_to_index(data)] = nil
end

-- Instances
