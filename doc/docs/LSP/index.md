# How to configure LSP

First of all, this configuration is not meant to work **out-of-the-box** as a full-featured *IDE* or 
something like that. It can, but this needs some additional work.

## How to install language servers?

In most cases, the `Mason` plugin will do it as long as you have the prerequisites installed on your 
system. Generally, you need a working *Python* and *Node.js* with its package manager *npm*, because many 
language servers are written in Javascript and use the Node.js infrastructure. For the Java and Scala 
language servers, you'll need fully working environments. At least JDK 17 is required for Java and Scala 
language servers.

You do not *have* to use `Mason` though. You can install language servery any way you want and it will 
work as long as you tell Neovim where they are by editing the `vim.g.lsp_server_bin` table in 
`config.lua`.

## How to configure language servers

For most, this is done in `lsp/_defaults.lua`. See below for a list of supported language servers. You also 
have to tell Neovim where the language servers are installed. In `lua/config.lua`, there is a table 
`vim.g.lsp_server_bin` that holds the paths for all supported servers. Check the *Mason* documentation 
where it will install the language servers. On Linux, this is usually `$HOME/.local/share/nvim/mason`.

## Supported languages and language servers:

* C and C++ using Clangd. It is recommended to install Clangd with your operating system tools like 
  *apt-get* or *dnf* on Linux distributions. Usually, this gives you a working Clang version in your 
  **$PATH**.

* Java via *jdtls*. This is a very powerful and full-featured language server for the Java language that 
  supports major build systems like *Gradle* and *Maven*. It uses the 
  [nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls) plugin, so please read the documentation 
  there.

* C# via *csharp_ls*. This is an alternative to the well-known OmniSharp, based on the Roslyn compiler 
  infrastructure. You can learn more about it 
  [here](https://github.com/razzmatazz/csharp-language-server). This works with minimal configuration and 
  requires a `dotnet` installation on your system.

* Markdown via *marksman*. Install it from mason, make sure the path is correct in `config.lua`.

* LaTeX via *texlab*. You can install it manually or via mason.

* Scala via *metals*. This uses the [nvim-metals](https://github.com/scalameta/nvim-metals) plugin. 
  You have to install *Scala*, *Metals*, *Coursier* and *sbt* and verify that everything works. Adjust 
  the path for the *metals* binary in `config.lua`. This is probably one of the harder things to setup, 
  but that's just how it is.

* Ada via *als* (Ada language server). This is mostly untested, because I do not use this language. It 
  requires a working *GNAT* installation.

* Python via *Pyright*. This requires *npm*, because that is basically the Visual Studio Code python 
  language server extracted. Installs via `Mason`.
