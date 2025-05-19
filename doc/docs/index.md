# Content Index

!!! Note

      This documentation is WIP. It has only recently been started, so there is not much yet, but it's growing 
      almost every day. Before trying to install, please read [the instructions](Install/), particularly 
      the section about [requirements](Install/#requirements)

## What exactly is this all about?
It's all about a [Neovim](https://neovim.io) configuration. You have probably heard the term **dotfiles** 
which usually describes a set of configuration files for one or more programs. The term **dotfiles** 
comes from a convention used by most UNIX-like operating systems: *Configuration files are often hidden 
and hidden files start with a dot in their filenames*. Hence the name dotfiles.

Neovim is no different. Its configuration is normally written in the Lua programming language and — on 
UNIX-like operating systems — resides under `$HOME/.config/nvim`

## Quick overview and design goals
This Neovim configuration is meant to be a general purpose configuration targeting many different use 
cases. It supports a wide range of languages out-of-the-box and can be expanded with relative ease.

The goal of this configuration is to **establish an IDE-like feeling**. If you look for a minimalistic 
configuration or can't stand screen „clutter“, this is probably not for you.

Many things are user-tweakable, but the basic configuration and choice of plugins is not. The following 
choices have been made:

* auto-completion. You can select from the two most popular sources. 
  [Blink.cmp](https://github.com/Saghen/blink.cmp) and [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)

* Picker: [fzf-lua](https://github.com/ibhagwan/fzf-lua) is the default. Therefore, you must have recent 
  versions of **FzF** and other utilities on your system. Please see the [Install](Install/index.md#requirements) section.

## Highlights
* Support for many most common languages. C/C++, C#, Java, Python, TypeScript/JavaScript, Scala, HTML, 
  CSS, JSON, Lua, Markdown, LaTeX and many more.

* All supported languages have support for Treesitter and are ready for LSP

* auto-completion via either blink or nvim-cmp plugins.

* Various means of managing files inside the editor. NvimTree and Oil are integrated by default.

* Integrated theme engine that support Treesitter and semantic highlighting. At the moment, it comes with 
  four different color schemes, based on Gruvbox, Dracula, OneDark and Sonokai. Each scheme has variants 
  to tweak the background color tone, contrast and color-richness.

## [LSP setup](LSP/index.md)
This is probably the most important and most complex setup task. While a lot has been pre-configured you 
will likely still have to configure quite a few things.


