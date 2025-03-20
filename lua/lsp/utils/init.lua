local validate = vim.validate
local api = vim.api
local lsp = vim.lsp
local nvim_eleven = vim.fn.has 'nvim-0.11' == 1

local iswin = vim.loop.os_uname().version:match 'Windows'

local M = { path = {} }

-- global on_setup hook
M.on_setup = nil
-- Customize LSP behavior via on_attach
local navic = require("nvim-navic")

ON_LSP_ATTACH = function(client, buf)
  if LSPDEF.debug then
    vim.notify("Attaching " .. client.name .. " " .. vim.inspect(client.config.cmd) .. " to buffer nr " .. buf)
  end
  if not vim.tbl_contains(LSPDEF.exclude_navic, client.name) then
    navic.attach(client, buf)
  end
  vim.g.inlay_hints_visible = true
  if client.server_capabilities.inlayHintProvider then
    vim.g.inlay_hints_visible = PCFG.lsp.inlay_hints
    vim.lsp.inlay_hint.enable(PCFG.lsp.inlay_hints)
  end
  if client.name == "rzls" then
    vim.cmd("hi! link @lsp.type.field Member")
  end
end

function M.bufname_valid(bufname)
  if bufname:match '^/' or bufname:match '^[a-zA-Z]:' or bufname:match '^zipfile://' or bufname:match '^tarfile:' then
    return true
  end
  return false
end

function M.validate_bufnr(bufnr)
  if nvim_eleven then
    validate('bufnr', bufnr, 'number')
  end
  return bufnr == 0 and api.nvim_get_current_buf() or bufnr
end

-- Maps lspconfig-style command options to nvim_create_user_command (i.e. |command-attributes|) option names.
local opts_aliases = {
  ['description'] = 'desc',
}

function M.search_ancestors(startpath, func)
  if nvim_eleven then
    validate('func', func, 'function')
  end
  if func(startpath) then
    return startpath
  end
  local guard = 100
  for path in vim.fs.parents(startpath) do
    -- Prevent infinite recursion if our algorithm breaks
    guard = guard - 1
    if guard == 0 then
      return
    end

    if func(path) then
      return path
    end
  end
end

local function escape_wildcards(path)
  return path:gsub('([%[%]%?%*])', '\\%1')
end

function M.root_pattern(...)
  local patterns = M.tbl_flatten { ... }
  return function(startpath)
    startpath = M.strip_archive_subpath(startpath)
    for _, pattern in ipairs(patterns) do
      local match = M.search_ancestors(startpath, function(path)
        for _, p in ipairs(vim.fn.glob(table.concat({ escape_wildcards(path), pattern }, '/'), true, true)) do
          if vim.loop.fs_stat(p) then
            return path
          end
        end
      end)

      if match ~= nil then
        return match
      end
    end
  end
end

function M.get_active_clients_list_by_ft(filetype)
  local clients = M.get_lsp_clients()
  local clients_list = {}
  for _, client in pairs(clients) do
    --- @diagnostic disable-next-line:undefined-field
    local filetypes = client.config.filetypes or {}
    for _, ft in pairs(filetypes) do
      if ft == filetype then
        table.insert(clients_list, client.name)
      end
    end
  end
  return clients_list
end

function M.get_active_client_by_name(bufnr, servername)
  --TODO(glepnir): remove this for loop when we want only support 0.10+
  for _, client in pairs(M.get_lsp_clients { bufnr = bufnr }) do
    if client.name == servername then
      return client
    end
  end
end

-- For zipfile: or tarfile: virtual paths, returns the path to the archive.
-- Other paths are returned unaltered.
function M.strip_archive_subpath(path)
  -- Matches regex from zip.vim / tar.vim
  path = vim.fn.substitute(path, 'zipfile://\\(.\\{-}\\)::[^\\\\].*$', '\\1', '')
  path = vim.fn.substitute(path, 'tarfile:\\(.\\{-}\\)::.*$', '\\1', '')
  return path
end

--- Public functions that can be deprecated once minimum required neovim version is high enough

local function is_fs_root(path)
  if iswin then
    return path:match '^%a:$'
  else
    return path == '/'
  end
end

-- Traverse the path calling cb along the way.
local function traverse_parents(path, cb)
  path = vim.loop.fs_realpath(path)
  local dir = path
  -- Just in case our algo is buggy, don't infinite loop.
  for _ = 1, 100 do
    dir = vim.fs.dirname(dir)
    if not dir then
      return
    end
    -- If we can't ascend further, then stop looking.
    if cb(dir, path) then
      return dir, path
    end
    if is_fs_root(dir) then
      break
    end
  end
end

--- This can be replaced with `vim.fs.relpath` once minimum neovim version is at least 0.11.
function M.path.is_descendant(root, path)
  if not path then
    return false
  end

  local function cb(dir, _)
    return dir == root
  end

  local dir, _ = traverse_parents(path, cb)

  return dir == root
end

--- Helper functions that can be removed once minimum required neovim version is high enough

function M.tbl_flatten(t)
  --- @diagnostic disable-next-line:deprecated
  return nvim_eleven and vim.iter(t):flatten(math.huge):totable() or vim.tbl_flatten(t)
end

function M.get_lsp_clients(filter)
  --- @diagnostic disable-next-line:deprecated
  return nvim_eleven and lsp.get_clients(filter) or lsp.get_active_clients(filter)
end

--- Deprecated functions

--- @deprecated use `vim.fn.isdirectory(path) == 1` instead
--- @param filename string
--- @return boolean
function M.path.is_dir(filename)
  return vim.fn.isdirectory(filename) == 1
end

--- @deprecated use `(vim.loop.fs_stat(path) or {}).type == 'file'` instead
--- @param path string
--- @return boolean
function M.path.is_file(path)
  return (vim.loop.fs_stat(path) or {}).type == 'file'
end

--- @deprecated use `vim.fs.dirname` instead
M.path.dirname = vim.fs.dirname

--- @deprecated use `vim.fs.normalize` instead
M.path.sanitize = vim.fs.normalize

--- @deprecated use `vim.loop.fs_stat` instead
--- @param filename string
--- @return string|false
function M.path.exists(filename)
  local stat = vim.loop.fs_stat(filename)
  return stat and stat.type or false
end

--- @deprecated use `table.concat({"path1", "path2"})` or regular string concatenation instead
function M.path.join(...)
  return table.concat({ ... }, '/')
end

--- @deprecated use `vim.fn.has('win32') == 1 and ';' or ':'` instead
M.path.path_separator = vim.fn.has('win32') == 1 and ';' or ':'

--- @deprecated use `vim.fs.parents(path)` instead
M.path.iterate_parents = vim.fs.parents

--- @deprecated use `vim.fs.dirname(vim.fs.find('.hg', { path = startpath, upward = true })[1])` instead
function M.find_mercurial_ancestor(startpath)
  return vim.fs.dirname(vim.fs.find('.hg', { path = startpath, upward = true })[1])
end

--- @deprecated use `vim.fs.dirname(vim.fs.find('node_modules', { path = startpath, upward = true })[1])` instead
function M.find_node_modules_ancestor(startpath)
  return vim.fs.dirname(vim.fs.find('node_modules', { path = startpath, upward = true })[1])
end

--- @deprecated use `vim.fs.dirname(vim.fs.find('package.json', { path = startpath, upward = true })[1])` instead
function M.find_package_json_ancestor(startpath)
  return vim.fs.dirname(vim.fs.find('package.json', { path = startpath, upward = true })[1])
end

--- @deprecated use `vim.fs.dirname(vim.fs.find('.git', { path = startpath, upward = true })[1])` instead
function M.find_git_ancestor(startpath)
  return vim.fs.dirname(vim.fs.find('.git', { path = startpath, upward = true })[1])
end

return M
