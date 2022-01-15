# Known limitations

- Calling methods on Lua scripts from background threads without a proper
  threading library for Lua will most likely break, since the Lua engine is not
  thread-safe.
- Lua scripts cannot inherit other scripts, not even other Lua scripts at the
  moment.
- PluginScript instances in editor are not reloaded when a script is edited.
  That means that adding/removing/updating an exported property won't show in
  the editor and `tool` scripts won't be reloaded until the project is reopened.
  This is a limitation of Godot's PluginScript implementation (tested in Godot
  3.4).
