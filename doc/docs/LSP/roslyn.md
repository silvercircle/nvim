# Roslyn (C#)

LSP support for C# is difficult and covered by dedicated plugins supporting the Roslyn-based C# Dev Kit 
language server by Microsoft. This is a far better solution than 
[OmniSharp](https://github.com/OmniSharp/omnisharp-roslyn) which now seems to be in maintenance mode, no 
longer receiving major updates. Since the Roslyn language servers does some non-standard things not 
covered by Neovim's LSP client implementation, it's easier to integrate it with an extra plugin.

## Requirements

* A [working installation](https://dotnet.microsoft.com/en-us/download) of Microsoft .NET (aka DotNet). 
  The command `dotnet` must be on your `$PATH` and it should at least be version 8. Find out with `dotnet 
  --version`.

## Neovim Plugins used

The relevant plugins for C# support on this configuration are [the Roslyn 
plugin](https://github.com/seblyng/roslyn.nvim) and the [Razor language server 
plugin](https://github.com/tris203/rzls.nvim). The latter is optional, but recommended if you plan to 
edit Razor/Blazor pages in your project. The configuration file for the plugin is 
[`lua/plugins/roslyn.lua`](https://github.com/silvercircle/nvim/blob/main/lua/plugins/roslyn.lua)

## Supported features

* Code analysis, diagnostics
* Formatting (including `.editorconfig` support)
* auto-completion, symbol search, including workspace symbols.
* Semantic highlighting

## For installing the language server, you basically have two options

* Install via Mason but this needs a custom Mason registry to be configured. Neither the Roslyn nor the 
  RZLS server are currently covered by the official Mason registry.

* Manually install the server, by downloading it from [Microsoft's release page](https://dev.azure.com/azure-public/vside/_artifacts/feed/vs-impl)

Please refer to the Roslyn plugin documentation for more.

> Make sure, you configure `server_bin["roslyn"]` in `lspdef.lua` with the path of the installed language 
server.

## Note for Linux users

The Roslyn language server makes heavy use of Linux' `inotify` feature. On larger projects with many 
files, it might run out of available handles and you would have to tune the following `sysctl` settings:

    fs.inotify.max_user_watches
    fs.inotify.max_user_instances

Increase them from the default values (depends on distribution) as needed.
