local Fzf = require("fzf-lua")
local Actions = require("fzf-lua.actions")


local M = {}

M.fzf_dir_actions = function()
  local extract_dir = function(item)
    local dir = vim.fn.split(item[1] or "", "\t")[2] or ""
    return vim.fn.isdirectory(dir) and dir or nil
  end

  return {
    enter = function(item)
      local dir = extract_dir(item)
      if dir then
        Fzf.files({ cwd = dir, winopts = Tweaks.fzf.winopts.mini_with_preview })
      end
    end,
    ["ctrl-g"] = function(item)
      local dir = extract_dir(item)
      if dir then
        Fzf.live_grep({ cwd = dir, winopts = Tweaks.fzf.winopts.std_preview_top })
      end
    end,
    ["ctrl-d"] = {
      function(item)
        local dir = extract_dir(item)
        if dir then vim.fn.chdir(dir) end
      end,
      Actions.resume
    },
    ["ctrl-o"] = {
      ---@diagnostic disable-next-line
      function(item, picker)
        vim.schedule(function() require("oil").open(extract_dir(item)) end)
        Fzf.hide()
      end,
    }
  }
end

return M
