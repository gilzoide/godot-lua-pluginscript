# Changelog
## [Unreleased]
### Added
- `Object.null`
- Call `Object.set` on `Object.__newindex`
- REPL history, with up/down keys choosing previous/next line
- Stack trace to error message when loading script fails
- Initialize known properties when instantiating script
- Unit test infrastructure


### Fixed
- Properties with `nil` as default value not accesible from Lua
- Call `Array.duplicate` using API 1.1 instead of 1.0
- `Array.duplicate` and `Array.slice` return value GC
- Call `Dictionary.duplicate` using API 1.2 instead of 1.0
- `VariantType` used for float properties
- Calling `NodePath()` returns an empty NodePath, rather than one with the path `"nil"`


## [r1]
### Added
- Lua PluginScript language
- Embedded LuaJIT
- Metatypes for all Godot basic types
- `yield` function similar to GDScript's
- Script validation and template source code
- Editor plugin with a simple REPL
- Package searcher for Lua and C modules that work with paths relative to
  the `res://` folder and/or exported games' executable path
- API documentation


[Unreleased]: https://github.com/gilzoide/godot-lua-pluginscript/compare/r1...HEAD
[r1]: https://github.com/gilzoide/godot-lua-pluginscript/releases/tag/r1
