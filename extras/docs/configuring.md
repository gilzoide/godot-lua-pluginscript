# Available configurations

## Project Settings
In the `Project -> Project Settings...` window, the following configurations are available:

- **Lua PluginScript/Package Path/Behavior**: Whether templates will replace
  [package.path](https://www.lua.org/manual/5.1/manual.html#pdf-package.path),
  be appended to it or prepended to it.
  Default behavior: `replace`.
- **Lua PluginScript/Package Path/Templates**: List of templates to be
  injected into `package.path`.
  Default templates: `res://?.lua` and `res://?/init.lua`.
- **Lua PluginScript/Package C Path/Behavior**: Whether templates will replace
  [package.cpath](https://www.lua.org/manual/5.1/manual.html#pdf-package.cpath),
  be appended to it or prepended to it.
  Default behavior: `replace`.
- **Lua PluginScript/Package C Path/Templates**: List of templates to be
  injected into `package.cpath`.
  Default templates: `!/?.dll` and `!/loadall.dll` on Windows,
  `!/?.so` and `!/loadall.so` elsewhere.
- **Lua PluginScript/Export/Minify On Release Export**: Whether Lua scritps
  should be minified on release exports.
  Defaults to `true`.

## Configuring `package.path` and `package.cpath`
Templates for `package.path` and `package.cpath` accept paths starting with
Godot's Resource path `res://` and User path `user://`.

Also, the special character `!` represents the executable directory.
When running a standalone build, it will be replaced by the directory of the executable path
([`OS.get_executable_path().get_base_dir()`](https://docs.godotengine.org/en/stable/classes/class_os.html#class-os-method-get-executable-path)).
When opening the project from the editor, it will be replaced by the project root
([`ProjectSettings.globalize_path("res://")`](https://docs.godotengine.org/en/stable/classes/class_projectsettings.html#class-projectsettings-method-globalize-path)).

When the behavior is configured to `replace`, paths coming from the environment
variables `LUA_PATH` and `LUA_CPATH` will also be replaced.

