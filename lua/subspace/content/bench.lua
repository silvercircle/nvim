local function one(bufnr)
  local modified = vim.api.nvim_get_option_value("modified", { buf = bufnr })
end

local function two(bufnr)
  local modified = vim.bo[bufnr].modified
end

local function three(bufnr)
  local modified = vim.api.nvim_buf_get_option(bufnr, "modified")
end

local function bench(func, iterations, bufnr)
  local starttime = os.clock()
  for _ = 1, (iterations or 1e5) do
    func(bufnr)
  end

  local endtime = os.clock()
  return endtime - starttime
end

print(string.format("Two   time: %.6f seconds", bench(two, 1e6, 0)))
print(string.format("One   time: %.6f seconds", bench(one, 1e6, 0)))
print(string.format("Three time: %.6f seconds", bench(three, 1e6, 0)))

