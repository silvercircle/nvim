if CFG.csfolds_done == true then return end

CFG.csfolds_done = true
local csfolds = [[

body: [
  (enum_member_declaration_list)
] @fold

alternative: [
  (block)
] @fold

consequence: [
  (block)
] @fold

accessors: (accessor_list) @fold
initializer: (initializer_expression) @fold

[
  (namespace_declaration)
  (class_declaration)
  (record_declaration)
  (method_declaration)
  (accessor_declaration)
  (indexer_declaration)
  (property_declaration)
  (enum_declaration)
  (switch_statement)
  (switch_section)
  (for_statement)
  (foreach_statement)
  (while_statement)
  (do_statement)
  (try_statement)
  (catch_clause)
  (finally_clause)
  (comment)
  (preproc_if)
  (preproc_elif)
  (preproc_else)
  (preproc_region)
  (using_directive)+
] @fold

]]
vim.treesitter.query.set("c_sharp", "folds", csfolds)

