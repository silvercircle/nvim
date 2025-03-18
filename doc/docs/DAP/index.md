# DAP (Debug Adapter Protocol)
DAP is for debugging what LSP is for writing code. It's an open protocol that connects editors with 
debuggers and allows to perform debugging task from within your editor.

!!! Note

    Currently, the configuration only supports C and C++ debugging via gdb or lldb. However, the 
    necessary prerequisistes, including DAP-UI, are installed. You must install additional DAP connectors
    using [Mason](../LSP/mason.md) and configure them in [`lua/dap/nvim_dap.lua`](https://github.com/silvercircle/nvim/blob/main/lua/dap/nvim_dap.lua)

## C and C++ debugging

