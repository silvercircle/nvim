local Treesitter = {
		TSComment = {fg = C.gray, },
		TSAnnotation = {fg = C.blue, },
		TSAttribute = {fg = C.cyan, },
		TSConstructor = {fg = C.cyan, },
		TSType = {fg = C.cyan, },
		TSTypeBuiltin = {fg = C.orange, },
		TSConditional = {fg = C.yellow, },
		TSException = {fg = C.purple, },
		TSInclude = {fg = C.purple, },
		TSKeywordReturn = {fg = C.purple, },
		TSKeyword = {fg = C.purple, },
		TSKeywordFunction = {fg = C.purple, },
		TSLabel = {fg = C.light_blue, },
		TSNamespace = {fg = C.cyan, },
		TSRepeat = {fg = C.yellow, },
		TSConstant = {fg = C.orange, },
		TSConstBuiltin = {fg = C.orange, },
		TSFloat = {fg = C.orange, },
		TSNumber = {fg = C.orange, },
		TSBoolean = {fg = C.orange, },
		TSCharacter = {fg = C.green, },
		TSError = {fg = C.error_red, },
		TSFunction = {fg = C.blue, },
		TSFuncBuiltin = {fg = C.blue, },
		TSMethod = {fg = C.blue, },
		TSConstMacro = {fg = C.orange, },
		TSFuncMacro = {fg = C.blue, },
		TSVariable = {fg = C.light_blue, },
		TSVariableBuiltin = {fg = C.red, },
		TSProperty = {fg = C.red, },
		TSField = {fg = C.fg, },
		TSParameter = {fg = C.red, },
		TSParameterReference = {fg = C.red, },
		TSSymbol = {fg = C.light_blue, },
		TSText = {fg = C.alt_fg, },
		TSOperator = {fg = C.alt_fg, },
		TSPunctDelimiter = {fg = C.alt_fg, },
		TSTagDelimiter = {fg = C.alt_fg, },
		TSTagAttribute = {fg = C.orange, },
		TSPunctBracket = {fg = C.alt_fg, },
		TSPunctSpecial = {fg = C.purple, },
		TSString = {fg = C.green, },
		TSStringRegex = {fg = C.green, },
		TSStringEscape = {fg = C.green, },
		TSTag = {fg = C.blue, },
		TSEmphasis = {style = "italic", },
		TSUnderline = {style = "underline", },
		TSTitle = {fg = C.fg, },
		TSLiteral = {fg = C.orange, },
		TSURI = {fg = C.orange, style = "underline", },
		TSKeywordOperator = {fg = C.purple, },
		TSStructure = {fg = C.light_blue, },
		TSStrong = {fg = C.blue, style = "bold", },
		TSQueryLinterError = {fg = C.warning_orange, },
		TreesitterContext = {bg = C.tree_gray, },
}

return Treesitter