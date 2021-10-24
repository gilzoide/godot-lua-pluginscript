# Changelog
## [Unreleased]
### Added
- `Array.join` method, similar to `PoolStringArray.join`
- Project Settings for setting up `package.path` and `package.cpath`

### Fixed
- Error handler now uses `tostring` to stringify the incoming parameter,
  avoiding type errors. It also checks for the result of `string.match`, so it
  does not errors if the message is not in the format expected.
- Loading of C modules now uses absolute library paths, so that files found in
  patterns like `res://*` are correctly loaded.
- Always try loading active library, so that dynamic loader knows about `lua*`
  symbols when loading C modules.


## [0.1.0]
### Added
- `GD._VERSION`
- `Object.null`
- Call `Object.set` on `Object.__newindex`
- Stack trace to error message when loading script fails
- Initialize known properties when instantiating script
- Unit test infrastructure
- Android ARMv7/ARM64/x86/x86_64 builds
- [plugin] REPL history, with up/down keys choosing previous/next line

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


[Unreleased]: https://github.com/gilzoide/godot-lua-pluginscript/compare/0.1.0...HEAD
[0.1.0]: https://github.com/gilzoide/godot-lua-pluginscript/releases/tag/0.1.0
[r1]: https://github.com/gilzoide/godot-lua-pluginscript/releases/tag/r1
