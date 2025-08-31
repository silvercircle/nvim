-- enhance folding for scala. fold if/else, catch and lambda blocks
if CFG.scalafolds_done == true then return end

CFG.scalafolds_done = true
local scalafolds = [[
(call_expression
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
  (match_expression)
  (if_expression)
] @fold

]]

vim.treesitter.query.set("scala", "folds", scalafolds)
