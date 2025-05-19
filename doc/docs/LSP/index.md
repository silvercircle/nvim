# How to configure LSP

First of all, this configuration is not meant to work **out-of-the-box** as a full-featured *IDE* or 
something like that. It can, but this needs some additional work. The system has been designed with 
flexibility in mind — to support different ways of installing language servers. It is only tested on 
Linux (including WSL)

!!! Note

    The following applies to standard LSP server configurations only. It does not cover **Java**,
    **Scala** or **C** which are handled by dedicated plugins. The language servers for Java, Scala and 
    C# can also be installed with Mason though.

## How to install language servers?

In most cases, the `Mason` plugin will do it as long as you have the prerequisites installed on your 
system. Generally, you need a working *Python* and *Node.js* with its package manager *npm*, because many 
language servers are written in Javascript and use the Node.js infrastructure. For the Java and Scala 
language servers, you'll need fully working environments. At least JDK 17 is required for Java and Scala 
language servers. Some language servers must be built from source and will thus require the necessary 
tools. One example for such a server is `gopls`, the language server for the Go programming language. 
Installing it requires a working Go installation.


To interact with Mason simply issue the command

> Mason

on the command line.

## How to configure language servers

The file [lua/lspdef.lua](https://github.com/silvercircle/nvim/blob/main/lua/lspdef.lua) is the main 
source of configuration data. It is processed in `lua/lsp/config/init.lua` and consists of a large table 
defining a list of supported server configurations and a corresponding list of server binary locations. 
Additionally, it contains data to configure the locations of the Java and C# language servers. This way 
ensures a most flexible system that can use language servers installed in many different ways. You could 
install all of them manually without the help of Mason and tell Neovim where to find them.

### Customizing lspdef.lua

You can either edit this file directly or make a copy of it. The latter method will prevent your 
configuration from being overwritten when you update these dotfiles from the repository. The copy must be named 
`lspdef_user.lua` and reside in the same directory, next to `lspdef.lua`. If such a file exists, it will 
be loaded **instead** of `lspdef.lua`.

Each entry in the `serverconfigs` table is defined as follows:
```lua
  -- this entry has a custom configuration in lsp/serverconfig/lua_ls.lua
  ["lua_ls"]                = { active = true,
    cmd = jp(M.masonbinpath, 'lua-language-server')
  },
```

Each entry is a key-value pair where the key is a string corresponding to the server name as defined by 
the `nvim-lspconfig` plugin. The value is a table with the following fields:

    @field  active  boolean
    @field  cmd     string

The string in square brackets is the name of the language server. You can freely choose this and **it 
does not have to match the name of the LSP executable**. So it would be perfectly valid to use `["cpp"]` 
as the name for your C++ language server and then point the `cmd` field to `clangd`. You'll then have to 
provide a `lua/lsp/serverconfig/cpp.lua` file to set options for `clangd`.

The `cmd` field has the same format as the `cmd` field in a server configuration. It must be a list of strings with 
a minimum of one entry. The first value (`cmd[1]`) is the executable of the language server. Unless it 
can be found in your `$PATH`, it must be specified with a full, absolute path and file name. The remaining 
entries contain parameters which are passed to the language server executable.

A valid entry would look like the following:

    cmd = { "/usr/bin/lua-language-server", '--logpath=' .. vim.fn.stdpath("state") }

This has two entries, the executable and one command line argument (--logpath).

## LSP configuration files

For each language server in `lspdef.serverconfigs` there **MUST** be a corresponding language server 
configuration file in the `lua/lsp/serverconfig` directory. For example, 
`lua/lsp/serverconfig/clangd.lua` will be used for the `["clangd"]` entry in `lspdef`. Entries, for which 
no such file is found will be silently skipped or, in case you have enabled `debug` in `lspdef`, you'll 
receive a notification.

### Anatomy of a server configuration file

Here is an example (for the LUA language server). The return value must be of type `table` and must 
contain the required fields (see below).
```lua
return {
  root_markers = {'.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml',
                  'selene.yml' },
  filetypes = { "lua" },
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
        workspaceEvent = "OnSave",
        disable = {
          "param-type-mismatch",
          "undefined-field",
          "invisible"
        }
      },
      hint = {
        enable = true
      },
      runtime = {
        version = "LuaJIT", -- Lua 5.1/LuaJIT
      },
      telemetry = {
        enable = false
      },
      window = {
        progressBar = true
      }
    }
  }
}
```

As you can see, the server configuration file must return a table. The fields are documented in Neovim 
documentation, the important ones are:

* `cmd` - This is optional. When missing, it is added from the `lspdef` entry. When present, only the 
  first element (the path and filename of the LSP server executable is replaced from `lspdef`). This 
  gives some flexibility and allows you to use configuration files downloaded from the net without having 
  to edit them for your LSP install locations. You simply edit `lspdef` and that's about it.

* `root_markers` - A list of filename patterns that are usually be found in the root directory of a 
  project.

* `filetypes` - list of filetypes that will use this LSP server.

* `settings` - server specific settings

* `attach_config` - must be a `function(client, buf)` similar to `on_attach` functions. This will be 
  injected at the end of the global `ON_LSP_ATTACH` handler. It can be used to adjust capabilities or set 
  other options.

## Supported languages and language servers:

* C and C++ using Clangd. It is recommended to install Clangd with your operating system tools like 
  *apt-get* or *dnf* on Linux distributions. Usually, this gives you a working Clang version in your 
  **$PATH**.

* Java via *jdtls*. This is a very powerful and full-featured language server for the Java language that 
  supports major build systems like *Gradle* and *Maven*. It uses the 
  [nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls) plugin, so please read the documentation 
  there. This is not implemented as an ordinary LSP server, instead it uses a file type plugin in 
  `ftplugin/java.lua` that does all the setup.

* C# via [nvim-roslyn](https://github.com/seblyng/roslyn.nvim). This is an alternative to the well-known 
  OmniSharp, using the new C# devkit language server developed by Microsoft. This is the same language 
  server that also powers the Visual Studio Code C# toolset and is based on the Roslyn compiler infrastructure. 
  You can learn more about it. It has limited support for Razor and Blazor pages using the **rzls** 
  language server and requires a working `dotnet` installation on your system.

* Markdown via *marksman*. Install it from mason, make sure the path is correct in `config.lua`.

* LaTeX via *texlab*. You can install it manually or via mason.

* Scala via *metals*. This uses the [nvim-metals](https://github.com/scalameta/nvim-metals) plugin. 
  You have to install *Scala*, *Metals*, *Coursier* and *sbt* and verify that everything works. Adjust 
  the path for the *metals* binary in `config.lua`. This is probably one of the harder things to setup, 
  but that's just how it is.

* Ada via *als* (Ada language server). This is mostly untested, because I do not use this language. It 
  requires a working *GNAT* installation.

* Python via *Basedpyright*. This requires *npm*. Installs via `Mason`.
