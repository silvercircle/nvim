-- simple cmp source for completing items from a word list.
-- based on sample code in the documentation of the CMP plugin at:
-- https://github.com/hrsh7th/nvim-cmp

-- requirements:
-- * plenary
-- * nvim-cmp
--
-- LICENSE: MIT

--- a word list is a simple text file containing one word by line and optionally a translation term, separated
--  by the separation character. This is | by default
--  You can use it to complete long words or common abbreviations.
--  examples:
--
--  mycoolword
--  afk|away from keyboard
--  nvim|Neovim
--  averylongwordidonotwanttotypealways
--
--  and so on.
--  When a translation term is present, it will be used for completion. Otherwise, the word itself will be
--  inserted. A translation term will be shown as documentation float when CMP is active.
--
--  the word files are read at startup but you can refresh them by calling:
--  require("cmp_wordlist").rebuild_list()

local defaults = {
  -- filenames from which the word list is built. They can be absolute filenames or are 
  -- treated a relative to stdpath("config")
  -- all these default values can be changed via setup()
  wordfiles = {
    "wordlist.txt"
  },
  enabled = true,         -- this has currently no effect
  debug = false,
  separator = "|"         -- the character used to separate the word from its translation
}

local source = {}
local conf = {}

local wordlist = {}
local wordfiles = {}
local havewords = {}
local initial_list_built = false

function source.debugmsg(msg)
  if conf.debug == true then
    print(msg)
  end
end

function source.new()
  return setmetatable({}, { __index = source })
end

---Return whether this source is available in the current context or not (optional).
---@return boolean
function source:is_available()
  return true
end

---Return the debug name of this source (optional).
---@return string
function source:get_debug_name()
  return 'wordlist'
end

---Return LSP's PositionEncodingKind.
---@NOTE: If this method is ommited, the default value will be `utf-16`.
---@return lsp.PositionEncodingKind
function source:get_position_encoding_kind()
  return 'utf-16'
end

---Return the keyword pattern for triggering completion (optional).
---If this is ommited, nvim-cmp will use a default keyword pattern. See |cmp-config.completion.keyword_pattern|.
---@return string
function source:get_keyword_pattern()
  return [[\k\+]]
end

---Return trigger characters for triggering completion (optional).
function source:get_trigger_characters()
  return { '.' }
end

---Invoke completion (required).
---@param params cmp.SourceCompletionApiParams
---@param callback fun(response: lsp.CompletionResponse|nil)
function source:complete(params, callback)
--  callback({
--    { label = 'January' },
--    { label = 'February' },
--    { label = 'March' },
--    [...]
--  })
  if initial_list_built == false then
    source:rebuild_list()
    initial_list_built = true
  end
  callback(wordlist)
end

---Resolve completion item (optional). This is called right before the completion is about to be displayed.
---Useful for setting the text shown in the documentation window (`completion_item.documentation`).
---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function source:resolve(completion_item, callback)
  local item = {
    label = completion_item.label
  }
  if completion_item['translation'] ~= nil then
    item.label = completion_item['translation']
    item.detail = "Translates to: " .. completion_item['translation']
  end
  callback(item)
  item = nil
end

---Executed after the item was selected.
---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function source:execute(completion_item, callback)
  callback(completion_item)
end

function source.setup(options)
  conf = vim.tbl_deep_extend('force', defaults, options)
end

function source.add_to_list(file)
  local utils = require("local_utils")
  if vim.fn.filereadable(file) then
    source.debugmsg("Add words from: " .. file)
    local f = io.open(file)
    if f ~= nil then
      local lines = f:lines()
      for line in lines do
        if #line > 0 then
          if string.find(line, "|") ~= nil then
            local elems = utils.string_split(line, conf.separator)
            if havewords[elems[1]] == nil then
              table.insert(wordlist, { label = elems[1], translation = elems[2] })
              havewords[elems[1]] = true
            end
          else
            if havewords[line] == nil then
              table.insert(wordlist, { label = line  })
              havewords[line] = true
            end
          end
        end
      end
      io.close(f)
    end
  end
end

function source:rebuild_list()
  source.debugmsg("List rebuild, start")
  local path = require("plenary.path")
  if #wordfiles == 0 then
    for _,v in pairs(conf.wordfiles) do
      local p = path:new(v)
      if p:is_absolute() and p:is_file() then
        table.insert(wordfiles, p:expand())
      else
        local final_path = path:new(vim.fn.stdpath("config"), p:expand())
        table.insert(wordfiles, final_path:expand())
      end
    end
  end
  for _,v in pairs(wordfiles) do
    source.add_to_list(v)
  end
  source.debugmsg("List rebuilt, holds " .. #wordlist .. " items.")
end

-- Register your source to nvim-cmp.
require('cmp').register_source('wordlist', source)

return source

