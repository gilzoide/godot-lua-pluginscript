tool
extends EditorPlugin

var _lua_repl

func _enter_tree() -> void:
	_lua_repl = preload("lua_repl.tscn").instance()
	var repl_button = add_control_to_bottom_panel(_lua_repl, "Lua REPL")


func _exit_tree() -> void:
	if _lua_repl:
		remove_control_from_bottom_panel(_lua_repl)
		_lua_repl.free()
		_lua_repl = null
