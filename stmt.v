module vgura

// new_line matches with a new line
fn new_line(mut gp GuraParser) ? {
	if res := gp.char('\f\v\r\n') {
		gp.line++
	}
}

// comment matches with a comment
fn comment(mut gp GuraParser) ?MatchResult {
	gp.keyword('#')
	for gp.pos < gp.len {
		char := gp.text[gp.pos + 1]
		gp.pos++
		if '\f\v\r\n'.contains(char) {
			gp.line++
			break
		}
	}

	return new_match_result(.comment_line)
}

// ws_with_indentation matches with white spaces taking into consideration indentation levels
fn ws_with_indentation(mut gp GuraParser) ?int {
	mut indentation_level := 0

	for gp.pos < gp.len {
		if blank := gp.keyword(' ', '\t') {
			if blank == '\t' {
				return new_invalid_indentation_error('Tabs are not allowed to define indentation blocks')
			}

			indentation_level++
		}
	}

	return indentation_level
}

// ws matches white spaces (blank and tabs)
fn ws(mut gp GuraParser) ? {
	for {
		if _ := gp.keyword(' ', '\t') {
			continue
		} else {
			break
		}
	}
}

// eat_ws_and_new_lines consumes all the white spaces and end of line
fn eat_ws_and_new_lines(mut gp GuraParser) ? {
	for {
		if _ := gp.char(' \f\v\r\n\t') {
			continue
		} else {
			break
		}
	}
}

// gura_import matches import sentence
fn gura_import(mut gp GuraParser) ?MatchResult {
	gp.keyword('import')
	gp.char(' ')
	file_to_import := gp.maybe_match(quoted_string_with_var) or { return err }
	gp.maybe_match(ws) or { return err }
	if _ := gp.maybe_match(new_line) {
		// ignore this case
	}
	return new_match_result_with_value(.import_line, &file_to_import)
}

// quoted_string_with_var matches with a quoted string(with a single quotation mark) taking into consideration a variable inside it.
// There is no special character escaping here
fn quoted_string_with_var(mut gp GuraParser) ?string {
	quote := keyword('"')
	mut chars := []string{}

	for {
		if char := gp.char('') {
			if char == quote {
				break
			}

			// computes variables values in string
			if char == '$' {
				var_name := gp.get_var_name()
				chars << gp.get_var_value(var_name)
			} else {
				chars << char
			}
		}
	}

	return chars.join('')
}

// any_type matches with any primitive or complex type
fn any_type(mut gp GuraParser) ?Any {
	if results := gp.maybe_match(primitive_type) {
		return result
	}

	return gp.maybe_match(complex_type)
}

// primitive_type matches with a primitive value: null, bool, string (all of four kind of strings), number or variables values
fn primitive_type(mut gp GuraParser) ?Primitive {
	if _ := gp.maybe_match(ws) {
		// ignore
	}
	return gp.maybe_match(null, boolean, basic_string, literal_string, number, variable_value)
}

// complex_type matches with a list or another complex expression
fn complex_type(mut gp GuraParser) ?Complex {
	return gp.maybe_match(list, expression)
}

// variable_value matches with an already defined variable and gets its value
fn variable_value(mut gp GuraParser) ?Primitive {
	keyword('$') or { return err }
	if key := gp.maybe_match(unquoted_string) {
		return get_var_value(string(key))
	}
	return none
}
