--- @brief <pre>help
--- *vim.fs.exists()*
--- Use |uv.fs_stat()| to check a file's type, and whether it exists.
---
--- Example:
---
--- >lua
---   if vim.uv.fs_stat(file) then
---     vim.print("file exists")
---   end
--- <

local uv = vim.uv

local M = {}

-- Can't use `has('win32')` because the `nvim -ll` test runner doesn't support `vim.fn` yet.
local sysname = uv.os_uname().sysname:lower()
local iswin = not not (sysname:find('windows') or sysname:find('mingw'))
local os_sep = iswin and '\\' or '/'

--- Split a Windows path into a prefix and a body, such that the body can be processed like a POSIX
--- path. The path must use forward slashes as path separator.
---
--- Does not check if the path is a valid Windows path. Invalid paths will give invalid results.
---
--- Examples:
--- - `//./C:/foo/bar` -> `//./C:`, `/foo/bar`
--- - `//?/UNC/server/share/foo/bar` -> `//?/UNC/server/share`, `/foo/bar`
--- - `//./system07/C$/foo/bar` -> `//./system07`, `/C$/foo/bar`
--- - `C:/foo/bar` -> `C:`, `/foo/bar`
--- - `C:foo/bar` -> `C:`, `foo/bar`
---
--- @param path string Path to split.
--- @return string, string, boolean : prefix, body, whether path is invalid.
local function split_windows_path(path)
  local prefix = ''

  --- Match pattern. If there is a match, move the matched pattern from the path to the prefix.
  --- Returns the matched pattern.
  ---
  --- @param pattern string Pattern to match.
  --- @return string|nil Matched pattern
  local function match_to_prefix(pattern)
    local match = path:match(pattern)

    if match then
      prefix = prefix .. match --[[ @as string ]]
      path = path:sub(#match + 1)
    end

    return match
  end

  local function process_unc_path()
    return match_to_prefix('[^/]+/+[^/]+/+')
  end

  if match_to_prefix('^//[?.]/') then
    -- Device paths
    local device = match_to_prefix('[^/]+/+')

    -- Return early if device pattern doesn't match, or if device is UNC and it's not a valid path
    if not device or (device:match('^UNC/+$') and not process_unc_path()) then
      return prefix, path, false
    end
  elseif match_to_prefix('^//') then
    -- Process UNC path, return early if it's invalid
    if not process_unc_path() then
      return prefix, path, false
    end
  elseif path:match('^%w:') then
    -- Drive paths
    prefix, path = path:sub(1, 2), path:sub(3)
  end

  -- If there are slashes at the end of the prefix, move them to the start of the body. This is to
  -- ensure that the body is treated as an absolute path. For paths like C:foo/bar, there are no
  -- slashes at the end of the prefix, so it will be treated as a relative path, as it should be.
  local trailing_slash = prefix:match('/+$')

  if trailing_slash then
    prefix = prefix:sub(1, -1 - #trailing_slash)
    path = trailing_slash .. path --[[ @as string ]]
  end

  return prefix, path, true
end

--- Expand tilde (~) character at the beginning of the path to the user's home directory.
---
--- @param path string Path to expand.
--- @param sep string|nil Path separator to use. Uses os_sep by default.
--- @return string Expanded path.
local function expand_home(path, sep)
  sep = sep or os_sep

  if vim.startswith(path, '~') then
    local home = uv.os_homedir() or '~' --- @type string

    if home:sub(-1) == sep then
      home = home:sub(1, -2)
    end

    path = home .. path:sub(2) --- @type string
  end

  return path
end

--- @param path string Path to remove
--- @param ty string type of path
--- @param recursive? boolean
--- @param force? boolean
local function rm(path, ty, recursive, force)
  --- @diagnostic disable-next-line:no-unknown
  local rm_fn

  if ty == 'directory' then
    if recursive then
      for file, fty in vim.fs.dir(path) do
        rm(M.joinpath(path, file), fty, true, force)
      end
    elseif not force then
      error(string.format('%s is a directory', path))
    end

    rm_fn = uv.fs_rmdir
  else
    rm_fn = uv.fs_unlink
  end

  local ret, err, errnm = rm_fn(path)
  if ret == nil and (not force or errnm ~= 'ENOENT') then
    error(err)
  end
end

--- @class vim.fs.rm.Opts
--- @inlinedoc
---
--- Remove directories and their contents recursively
--- @field recursive? boolean
---
--- Ignore nonexistent files and arguments
--- @field force? boolean

--- Remove files or directories
--- @since 13
--- @param path string Path to remove
--- @param opts? vim.fs.rm.Opts
function M.rm(path, opts)
  opts = opts or {}

  local stat, err, errnm = uv.fs_stat(path)
  if stat then
    rm(path, stat.type, opts.recursive, opts.force)
  elseif not opts.force or errnm ~= 'ENOENT' then
    error(err)
  end
end

--- Convert path to an absolute path. A tilde (~) character at the beginning of the path is expanded
--- to the user's home directory. Does not check if the path exists, normalize the path, resolve
--- symlinks or hardlinks (including `.` and `..`), or expand environment variables. If the path is
--- already absolute, it is returned unchanged. Also converts `\` path separators to `/`.
---
--- @param path string Path
--- @return string Absolute path
function M.abspath(path)
  -- Expand ~ to user's home directory
  path = expand_home(path)

  -- Convert path separator to `/`
  path = path:gsub(os_sep, '/')

  local prefix = ''

  if iswin then
    prefix, path = split_windows_path(path)
  end

  if prefix == '//' or vim.startswith(path, '/') then
    -- Path is already absolute, do nothing
    return prefix .. path
  end

  -- Windows allows paths like C:foo/bar, these paths are relative to the current working directory
  -- of the drive specified in the path
  local cwd = (iswin and prefix:match('^%w:$')) and uv.fs_realpath(prefix) or uv.cwd()
  assert(cwd ~= nil)
  -- Convert cwd path separator to `/`
  cwd = cwd:gsub(os_sep, '/')

  -- Prefix is not needed for expanding relative paths, as `cwd` already contains it.
  return vim.fs.joinpath(cwd, path)
end

--- Gets `target` path relative to `base`, or `nil` if `base` is not an ancestor.
---
--- Example:
---
--- ```lua
--- vim.fs.relpath('/var', '/var/lib') -- 'lib'
--- vim.fs.relpath('/var', '/usr/bin') -- nil
--- ```
---
--- @param base string
--- @param target string
--- @param opts table? Reserved for future use
--- @return string|nil
function M.relpath(base, target, opts)
  --vim.validate('base', base, 'string')
  --vim.validate('target', target, 'string')
  --vim.validate('opts', opts, 'table', true)

  base = vim.fs.normalize(M.abspath(base))
  target = vim.fs.normalize(M.abspath(target))
  if base == target then
    return '.'
  end

  local prefix = ''
  if iswin then
    prefix, base = split_windows_path(base)
  end
  base = prefix .. base .. (base ~= '/' and '/' or '')

  return vim.startswith(target, base) and target:sub(#base + 1) or nil
end

return M
