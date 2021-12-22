# Changelog
## [Unreleased](https://github.com/gilzoide/godot-lua-pluginscript/compare/0.4.0...HEAD)

### Changed

- **BREAKING CHANGE**: `Array` and `Pool*Array`'s `__index` and `__newindex`
  metamethods now use 1-based indices to match Lua tables.
  For 0-based indexing, use `get`/`set` or `safe_get`/`safe_set` instead.


## [0.4.0](https://github.com/gilzoide/godot-lua-pluginscript/releases/tag/0.4.0)
### Added

- Support for running without JIT enabled
- Support for iOS builds
- `export` function, an alias for `property` that always marks the property as
  exported

### Fixed

- Quote `CODE_SIGN_IDENTITY` argument passed to `codesign` invocations
- ABI mismatch for math types in Linux x86_64 + Mono ([#4](https://github.com/gilzoide/godot-lua-pluginscript/issues/4#issuecomment-985423759))

### Changed

- **BREAKING CHANGE**: properties are not exported by default. Either pass
  a usage with the `PropertyUsage.EDITOR` bit set or call `export` instead of
  `property`


## [0.3.1](https://github.com/gilzoide/godot-lua-pluginscript/releases/tag/0.3.1)
### Added

- Support for `codesign`ing OSX builds directly from make invocation.
  The optional parameters are `CODE_SIGN_IDENTITY` and `OTHER_CODE_SIGN_FLAGS`.
- `LUA_BIN` option for specifying a Lua command other than `lua` when building
- `native-luajit` make target, used by CI
- `unzip-to-build` make target, for unzipping artifacts from CI to build folder

### Fixed

- `strip` invocation on OSX builds
- Update build GitHub Actions workflow with newer build pipeline

### Changed

- Added `build/.gdignore` to distribution, to stop Godot from trying to import
  `build/jit/*.lua` files
- Added default values for `MACOSX_DEPLOYMENT_TARGET`, making it an optional
  parameter for OSX builds


## [0.3.0](https://github.com/gilzoide/godot-lua-pluginscript/releases/tag/0.3.0)
### Added

- `EditorExportPlugin` for minifying Lua scripts with `LuaSrcDiet` on
  release exports. Minification may be turned off with the
  `lua_pluginscript/export/minify_on_release_export` project setting.

### Changed

- Release builds' init Lua script are minified with `LuaSrcDiet` and libraries
  are now `strip`ed, resulting in smaller dynamic libraries
- HGDN functions are now compiled with static visibility and unused GDNative
  extensions are excluded, also resulting in smaller dynamic libraries
- Makefile targets for cross-compiling for Windows were renamed from
  `cross-windows*` to `mingw-windows*`

### Fixed

- `PoolByteArray.extend` when called with a string argument


## [0.2.0](https://github.com/gilzoide/godot-lua-pluginscript/releases/tag/0.2.0)
### Added

- `Array.join` method, similar to `PoolStringArray.join`
- Project Settings for setting up `package.path` and `package.cpath`
- Bundle LuaJIT's `jit/*.lua` modules in build folder

### Fixed

- Error handler now uses `tostring` to stringify the incoming parameter,
  avoiding type errors. It also checks for the result of `string.match`, so it
  does not errors if the message is not in the format expected.
- Loading of C modules now uses absolute library paths, so that files found in
  patterns like `res://*` are correctly loaded.
- Always try loading active library, so that dynamic loader knows about `lua*`
  symbols when loading C modules.
- `Pool*Array`s' `__gc` metamethod


## [0.1.0](https://github.com/gilzoide/godot-lua-pluginscript/releases/tag/0.1.0)
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


## [r1](https://github.com/gilzoide/godot-lua-pluginscript/releases/tag/r1)
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
