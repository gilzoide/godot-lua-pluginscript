# Building

## Submodules

This project uses git submodules for its dependencies, so be sure to activate
submodules before building.

```sh
# clone this repository and activate submodules in a single command
git clone --recurse-submodules https://github.com/gilzoide/godot-lua-pluginscript.git

# or clone it normally and then activate submodules
git clone https://github.com/gilzoide/godot-lua-pluginscript.git
cd godot-lua-pluginscript
git submodule init
git submodule update
```

## Libraries

Build the libraries using [make](https://www.gnu.org/software/make/) from
project root, specifying the system as target:

```sh
# Choose one of the supported platforms, based on your operating system
make windows64  # x86_64
make windows32  # x86
make linux64    # x86_64
make linux32    # x86
make osx64 \    # multiarch x86_64 + amd64 dylib
    # Optional: deployment target. If absent, uses 10.7 for x86_64 and 11.0 for arm64
    MACOSX_DEPLOYMENT_TARGET=XX.YY \
    # Optional: code sign identity. If absent, `codesign` is not performed
    CODE_SIGN_IDENTITY=<identity> \
    # Optional: additional flags passed to `codesign`
    OTHER_CODE_SIGN_FLAGS=<flags>
    
# Cross-compiling for Windows using MinGW
make mingw-windows64  # x86_64
make mingw-windows32  # x86

# Cross-compiling for Android using NDK
make android-armv7a \   # Android ARMv7
    # Optional: NDK toolchain "bin" folder. Defaults to $ANDROID_NDK_ROOT/toolchains/llvm/prebuild/*/bin
    NDK_TOOLCHAIN_BIN=$ANDROID_NDK_ROOT/toolchains/llvm/prebuild/*/bin   
make android-aarch64 \  # Android ARM64
    NDK_TOOLCHAIN_BIN=$ANDROID_NDK_ROOT/toolchains/llvm/prebuild/*/bin   
make android-x86 \      # Android x86
    NDK_TOOLCHAIN_BIN=$ANDROID_NDK_ROOT/toolchains/llvm/prebuild/*/bin   
make android-x86_64 \   # Android x86_64
    NDK_TOOLCHAIN_BIN=$ANDROID_NDK_ROOT/toolchains/llvm/prebuild/*/bin   

# Cross-compiling for iOS in a OSX environment
make ios64 \    # Dylibs for iOS arm64 and simulator arm64 + x86_64
    # Optional: minimum iOS version to target. If absent, uses 8.0
    IOS_VERSION_MIN=X.Y
    # Optional: code sign identity. If absent, `codesign` is not performed
    CODE_SIGN_IDENTITY=<identity> \
    # Optional: additional flags passed to `codesign`
    OTHER_CODE_SIGN_FLAGS=<flags>
```

The GDNativeLibrary file `lua_pluginscript.gdnlib` is already configured to use
the built files stored in the `build` folder, so that one can use this
repository directly inside a Godot project under the folder `addons/godot-lua-pluginscript`.


## Export plugin

If you plan in using the export plugin, the following is also required:

```sh
make plugin
```


## Distribution ZIP

After building the desired libraries, a distribution zip can be built with:

```sh
make dist
```


## API documentation

The API is documented using [LDoc](https://stevedonovan.github.io/ldoc/manual/doc.md.html)
and may be generated with the following command:

```sh
make docs
```
