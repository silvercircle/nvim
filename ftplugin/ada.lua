-- enhance folding for scala. fold if/else, catch and lambda blocks
if CFG.adahl_done == true then return end

CFG.adahl_done = true

local adafolds = [[

[
  (package_declaration)
  (generic_package_declaration)
  (package_body)
  (subprogram_body)
  (block_statement)
  (if_statement)
  (elsif_statement_item)
  (loop_statement)
  (gnatprep_declarative_if_statement)
  (gnatprep_if_statement)
] @fold

]]

local adahl = [[
[
  "abort"
  "abs"
  "abstract"
  "accept"
  "access"
  "all"
  "array"
  "at"
  "begin"
  "body"
  "declare"
  "delay"
  "delta"
  "digits"
  "do"
  "end"
  "entry"
  "exit"
  "generic"
  "interface"
  "is"
  "limited"
  "new"
  "null"
  "of"
  "others"
  "out"
  "overriding"
  "package"
  "pragma"
  "private"
  "protected"
  "range"
  "separate"
  "subtype"
  "synchronized"
  "tagged"
  "task"
  "terminate"
  "type"
  "until"
  "when"
] @keyword

"record" @keyword.type

[
  "aliased"
  "constant"
  "renames"
] @keyword.modifier

[
  "with"
  "use"
] @keyword.import

[
  "function"
  "procedure"
] @keyword.function

[
  "and"
  "in"
  "not"
  "or"
  "xor"
] @keyword.operator

[
  "while"
  "loop"
  "for"
  "parallel"
  "reverse"
  "some"
] @keyword.repeat

"return" @keyword.return

[
  "case"
  "if"
  "else"
  "then"
  "elsif"
  "select"
] @keyword.conditional

[
  "exception"
  "raise"
] @keyword.exception

(comment) @comment @spell

(string_literal) @string

(character_literal) @string

(numeric_literal) @number

; Highlight the name of subprograms
(procedure_specification
  name: (_) @function)

(function_specification
  name: (_) @function)

(package_declaration
  name: (_) @function)

(package_body
  name: (_) @function)

(generic_instantiation
  name: (_) @function)

(entry_declaration
  .
  (identifier) @function)

; Some keywords should take different categories depending on the context
(use_clause
  "use" @keyword.import
  "type" @keyword.import)

(with_clause
  "private" @keyword.import)

(with_clause
  "limited" @keyword.import)

(use_clause
  (_) @module)

(with_clause
  (_) @module)

(loop_statement
  "end" @keyword.repeat)

(if_statement
  "end" @keyword.conditional)

(loop_parameter_specification
  "in" @keyword.repeat)

(loop_parameter_specification
  "in" @keyword.repeat)

(iterator_specification
  [
    "in"
    "of"
  ] @keyword.repeat)

(range_attribute_designator
  "range" @keyword.repeat)

(raise_statement
  "with" @keyword.exception)

(gnatprep_declarative_if_statement) @keyword.directive

(gnatprep_if_statement) @keyword.directive

(gnatprep_identifier) @keyword.directive

(subprogram_declaration
  "is" @keyword.function
  "abstract" @keyword.function)

(aspect_specification
  "with" @keyword.function)

(full_type_declaration
  "is" @keyword.type)

(subtype_declaration
  "is" @keyword.type)

(record_definition
  "end" @keyword.type)

(full_type_declaration
  (_
    "access" @keyword.type))

(array_type_definition
  "array" @keyword.type
  "of" @keyword.type)

(access_to_object_definition
  "access" @keyword.type)

(access_to_object_definition
  "access" @keyword.type
  [
    (general_access_modifier
      "constant" @keyword.type)
    (general_access_modifier
      "all" @keyword.type)
  ])

(range_constraint
  "range" @keyword.type)

(signed_integer_type_definition
  "range" @keyword.type)

(index_subtype_definition
  "range" @keyword.type)

(record_type_definition
  "abstract" @keyword.type)

(record_type_definition
  "tagged" @keyword.type)

(record_type_definition
  "limited" @keyword.type)

(record_type_definition
  (record_definition
    "null" @keyword.type))

(private_type_declaration
  "is" @keyword.type
  "private" @keyword.type)

(private_type_declaration
  "tagged" @keyword.type)

(private_type_declaration
  "limited" @keyword.type)

(task_type_declaration
  "task" @keyword.type
  "is" @keyword.type)

; Gray the body of expression functions
(expression_function_declaration
  (function_specification)
  "is"
  (_) @attribute)

(subprogram_declaration
  (aspect_specification) @attribute)

; Highlight full subprogram specifications
;(subprogram_body
;    [
;       (procedure_specification)
;       (function_specification)
;    ] @function.spec
;)
((comment) @comment.documentation
  .
  [
    (entry_declaration)
    (subprogram_declaration)
    (parameter_specification)
  ])

(compilation_unit
  .
  (comment) @comment.documentation)

(component_list
  (component_declaration)
  .
  (comment) @comment.documentation)

(enumeration_type_definition
  (identifier)
  .
  (comment) @comment.documentation)

[
  "("
  ")"
  "["
  "]"
  "<"
  ">"
] @punctuation.bracket

[
  "."
  ","
  ":"
  ";"
] @punctuation.delimiter

[
  "mod"
  "rem"
  "=>"
  "="
  ":="
  "+"
  "-"
  "/"
  "*"
  ">"
  "<"
  "&"
  ">="
  "<="
  "**"
  "/="
] @operator

]]

vim.treesitter.query.set("ada", "highlights", adahl)
vim.treesitter.query.set("ada", "folds", adafolds)

