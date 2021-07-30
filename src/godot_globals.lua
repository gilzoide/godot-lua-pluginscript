function GD.print(...)
    local message = table.concat({ ... }, '\t')
    GD.api.godot_print(String(message))
end

function GD.print_warning(...)
    local info = debug.getinfo(2, 'nSl')
    local message = table.concat({ ... }, '\t')
    GD.api.godot_print_warning(message, info.name, info.short_src, info.currentline)
end

function GD.print_error(...)
    local info = debug.getinfo(2, 'nSl')
    local message = table.concat({ ... }, '\t')
    GD.api.godot_print_error(message, info.name, info.short_src, info.currentline)
end

function GD.str(value)
    return GD.api.godot_variant_as_string(Variant(value))
end

function GD.tostring(value)
    return tostring(Variant(value))
end
