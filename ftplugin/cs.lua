local folds_query = [[

body: [
  (enum_member_declaration_list)
] @fold

alternative: [
  (block)
] @fold

accessors: (accessor_list) @fold

initializer: (initializer_expression) @fold

[
  (namespace_declaration)
  (class_declaration)
  (record_declaration)
  (method_declaration)
  (switch_statement)
  (switch_section)
  (if_statement)
  (for_statement)
  (foreach_statement)
  (while_statement)
  (do_statement)
  (try_statement)
  (catch_clause)
  (comment)
  (preproc_if)
  (preproc_elif)
  (preproc_else)
  (using_directive)+
] @fold

]]

vim.treesitter.query.set("c_sharp", "folds", folds_query)
