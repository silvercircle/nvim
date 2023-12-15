# How to configure LSP

First of all, this configuration is not meant to work **out-of-the-box** as a full-featured *IDE* or 
something like that. It can, but this needs some additional work.

## How to install language servers?

In most cases, the `Mason` plugin will do it as long as you have the prerequisites installed on your 
system. Generally, you need a working *Python* and *Node.js* with its package manager *npm*, because many 
language servers are written in Javascript and use the Node.js infrastructure. For the Java and Scala 
language servers, you'll need fully working environments. At least JDK 17 is required

## How to configure language servers

For most, this is done in `lua/lsp.lua`. See below for a list of supported language servers. You also 
have to tell Neovim where the language servers are installed. In `lua.config.lua` there is a table 
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


