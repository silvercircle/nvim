# Auto-completion
This configuration provides two different auto-completion systems which can be selected via 
`Tweaks.completion.version`. Allowed values are {==blink==} and {==nvim-cmp==}

## [Blink.cmp](https://github.com/Saghen/blink.cmp)
Blink is a relatively modern completion engine that focuses on performance and easy configuration. 
Ideally, it should work well with its defaults, nevertheless, a [configuration file](https://github.com/silvercircle/nvim/blob/main/lua/plugins/blink.lua){: class="red"} is provided.

## [Nvim-Cmp](https://github.com/hrsh7th/nvim-cmp)
This is the older system, available as an alternative. Its [configuration file](https://github.com/silvercircle/nvim/blob/main/lua/plugins/cmp_setup.lua)
can be found 

!!! Note

    This configuration uses a fork of nvim-cmp called [magazine](https://github.com/iguanacucumber/magazine.nvim).
    It is fully compatible to `nvim-cmp` and can use the same configuration files. It includes some performance
    optimizations and is compatible with all cmp addons and completion sources.

## Differences between blink.cmp and nvim-cmp
*Blink.cmp* is considered to be more modern and offers better performance when using the rust-based 
search implementation. It should als be easier to setup and customize. Feature-wise, *Blink.cmp* and 
*nvim-cmp* are likely on par with each other. They both offer advanced features like ghost text, 
signature help, can work with snippets from various sources and enjoy strong support by 3rd parties in 
form of completion sources.
