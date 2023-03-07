# Changelog
## [Unreleased](https://github.com/gilzoide/godot-lua-pluginscript/compare/0.5.2...HEAD)


## [0.5.2](https://github.com/gilzoide/godot-lua-pluginscript/releases/tag/0.5.2)
### Fixed

- Fixed `undefined symbol: lua_*` when requiring Lua/C modules in POSIX systems
  ([#41](https://github.com/gilzoide/godot-lua-pluginscript/issues/41))


## [0.5.1](https://github.com/gilzoide/godot-lua-pluginscript/releases/tag/0.5.1)
### Fixed

- Plugin initialization on Windows ([#31](https://github.com/gilzoide/godot-lua-pluginscript/issues/31))
- [build] Fixed `make dist` dependencies to include LuaJIT's `jit/*.lua` files
- [build] Fixed `make unzip-to-build` to only copy contents from `build` folder


## [0.5.0](https://github.com/gilzoide/godot-lua-pluginscript/releases/tag/0.5.0)
### Added

- `join` method for all `Pool*Array` metatypes with the same implementation as
  for `Array` and `PoolStringArray`.
- Possibility for using `ClassWrapper`s as `extends` of a script instead of
  their string name. E.g. script: `return { extends = Node }`
- `Object:get_class_wrapper` method that returns the `ClassWrapper` associated
  with the Object's class.
- `ClassWrapper:has_property` method that returns whether a class has a property
  with the passed name. Properties are considered available if they are found in
  the result of `ClassDB:class_get_property_list`.
- Library mapping for `Server` platform pointing to the `linux_x86_64` build.
- `string.quote` function for quoting values.
- [build] Passing `DEBUG=1` to `make docs` adds `--all` flag to `ldoc`, which
  adds documentation for locals.
- [build] Passing `DEBUG_INTERACTIVE=1` to `make test*` makes errors trigger
  a [debugger.lua](https://github.com/slembcke/debugger.lua) breakpoint, for
  debugging tests.

### Fixed

- Return values passed to `lps_coroutine:resume(...)` when calling `GD.yield()`.
- Comparing `Array` and `Pool*Array`s against Lua primitives like `nil` and
  numbers now return `false` instead of raising.
- Support for `false` as the default value for a property.

### Changed

- **BREAKING CHANGE**: `Array` and `Pool*Array`'s `__index` and `__newindex`
  metamethods now use 1-based indices to match Lua tables.
  For 0-based indexing, use `get`/`set` or `safe_get`/`safe_set` instead.
- **BREAKING CHANGE**: property setter functions don't receive property name
  anymore ([#5](https://github.com/gilzoide/godot-lua-pluginscript/issues/5#issuecomment-999876834)).
  That is, instead of `function(self, property_name, value)`, setters now look
  like `function(self, value)`.
- **BREAKING CHANGE**: script instances are now structs instead of tables.
  They still have a backing table for storing data, but indexing now calls
  getter and setter functions for known properties. Use `rawget` and `rawset`
  to bypass getter/setter functions and access the data table directly.
  ([#5](https://github.com/gilzoide/godot-lua-pluginscript/issues/5))
- **BREAKING CHANGE**: `Object.call` now raises instead of failing silently.
  Use `Object.pcall` to protect from errors.


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
