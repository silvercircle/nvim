local function foo()
  if Tweaks.use_foldlevel_patch == true then
    vim.wo.fillchars = [[eob: ,fold: ,foldopen:-,foldsep:│,foldclose:+,foldlevel:│]]
    --  --o.fillchars = [[eob: ,fold: ,foldopen:-,foldsep:│,foldclose:+]]
  else
    vim.wo.fillchars = [[eob: ,fold: ,foldopen:-,foldsep:│,foldclose:+]]
  end
  vim.wo.foldcolumn = "1"
  vim.notify("reconfigured fold")
end

vim.schedule(function() foo() end)
