if CFG.scalafolds_done == true then return end

CFG.scalafolds_done = true
local scalafolds = [[
(call_expression
  (block) @fold)

(if_expression
  (block) @fold)

(lambda_expression
  (block) @fold)

[
  (class_definition)
  (trait_definition)
  (object_definition)
  (function_definition)
  (val_definition)
  (import_declaration)
  (while_expression)
  (do_while_expression)
  (for_expression)
  (try_expression)
  (catch_clause)
  (case_block)
  (if_expression)
  (match_expression)
] @fold

]]

vim.treesitter.query.set("scala", "folds", scalafolds)
