local function switch_source_header(client, bufnr)
  local method_name = 'textDocument/switchSourceHeader'
  local params = vim.lsp.util.make_text_document_params(bufnr)
  client:request(method_name, params, function(err, result)
    if err then
      error(tostring(err))
    end
    if not result then
      vim.notify('corresponding file cannot be determined')
      return
    end
    vim.cmd.edit(vim.uri_to_fname(result))
  end, bufnr)
end

return {
  cmd = { 'ccls' },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
  root_markers = { 'compile_commands.json', '.ccls', '.git' },
  offset_encoding = 'utf-32',
  -- ccls does not support sending a null root directory
  workspace_required = true,
  reuse_client = function(client, config)
    if client.name == "ccls" and (config.root_dir == "." or config.root_dir == client.root_dir) then
      return true
    else
      return false
    end
  end,
  on_attach_orig = function(client, _)
    vim.api.nvim_buf_create_user_command(0, 'LspCclsSwitchSourceHeader', function()
      switch_source_header(client, 0)
    end, { desc = 'Switch between source/header' })
  end,
}
