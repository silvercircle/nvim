-- install and impatient plugin
-- must run at the very beginning

local impatient_path = vim.fn.stdpath("data") .. "/site/pack/impatient.nvim/start/impatient.nvim"
if vim.fn.empty(vim.fn.glob(impatient_path)) == 1 then
  vim.cmd(string.format([[
    execute "!git clone --depth 1 https://github.com/lewis6991/impatient.nvim %s"
  ]], impatient_path))
end

