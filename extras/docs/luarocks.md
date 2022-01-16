# Using LuaRocks

Lua modules available at [LuaRocks](https://luarocks.org/) can be installed locally to the project:

```sh
luarocks install --lua-version 5.1 --tree <local modules folder name> <module name>
```

**TIP**: put an empty `.gdignore` file in the local modules folder, so that
Godot doesn't try importing the installed `*.lua` files as Lua scripts.

Adjust the package paths using the [Lua PluginScript project settings](configuring.md)
and scripts should be able to `require` the installed modules.

For example, if the local modules folder is called `localrocks`, add
`res://localrocks/share/lua/5.1/?.lua` and `res://localrocks/share/lua/5.1/?/init.lua`
to **Package Path** and `res://localrocks/lib/lua/5.1/?.so` (change extension
to `.dll` on Windows and possibly `.dylib` on OSX) to **Package C Path**.
