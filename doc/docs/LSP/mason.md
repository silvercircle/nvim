# Mason (plugin)
[Mason](https://github.com/williamboman/mason.nvim) is a Neovim plugin that downloads, installs and 
upgrades LSP servers, DAP Adapters, linters and formatters for many different languages. While it is not 
a requirement to use it, it's strongly recommended.

Mason is invoked from within Neovim with the command `Mason`. By default it will install plugins to 
`stdpath("data")/mason`. On Linux, that would be `$HOME/.local/share/nvim/mason`. Within this directory, 
Mason will create various subdirectories of which the `bin` directory is of particular interest. This is 
where the executables of all installed language servers can be found. You can add this to your `$PATH` or 
simply configure it via [Lspdef](index.md#customizing-lspdeflua). Mason, by default, uses a registry for 
installable packages and can be configured to use 3rd party registries for packages that are not 
available in the default registry.

{==

Using unchecked registries can pose a security hazard. Please understand, that downloading and installing 
from sites you cannot fully trust can always result in security breaches. While the default Mason 
registry should be relatively safe — the author does watch it and all language servers are downloaded and 
installed from official repositories — third party registries might be not so well audited.

==}


