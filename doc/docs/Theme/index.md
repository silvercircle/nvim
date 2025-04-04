# Theme documentation

This Neovim configuration comes with its own advanced theme engine that offers some special features and 
multiple color schemes based on well-known themes. At the moment, other themes may or may not work, but 
the goal is to improve this situation. It is possible to completely disable the integrated theme engine 
and install theme plugins like on any other Neovim installation.

## Welcome to Darkmatter
The theme is called **Darkmatter** and provides the following features:

The theme engine supports multiple schemes and can switch between them on-the-fly. Each scheme is a 
collection of color palette(s) background colors and style rules. Four schemes are included in 
`lua/darkmatter/schemes`, but more can be added.

  * Frankengruv - a gruvbox inspired theme
  * Transylvania - Inspired by the famous Dracula color scheme.
  * One Darker - A revival of the One Dark scheme.
  * Dark - a Sonokai inspired dark theme

#### Background modes
The **theme** supports different background color tones, independent of the color palette. *Cold* (a cool 
medium gray with a slight blue-ish hue), *Warm* (lower color temperature, slightly red-ish tint), 
*Deepdark* (very dark, almost black background) and *OLED*, a pitch black background designed to save 
battery on modern OLED displays.

#### Saturation / brightness / contrast
Three levels of color saturation. *Vivid*, *Medium* and *Pastel*. Vivid normally uses the natural colors 
as defined by the color scheme with high contrast and brightness. Medium and Pastel use de-saturated 
colors with lower contrast and brightness. Switching between them

* Fully transparent or opaque background - can be changed while Neovim is running.

* Ability to customize color palettes with plugins

* Supports highlighting plugins to define your own highlight groups. Useful for plugins not supported by 
  default.

* Keyboard shortcuts to change theme settings on the fly. No need to restart Neovim.

* Treesitter and LSP semantic tokens support. Support for some 3rd party syntax plugins is included or 
  can be added by theme plugins.

* optionally, sync the background color when using the Kitty terminal.

## Configuration

