module vgura

import math
import strconv

// new_line matches with a new line
fn new_line(mut gp GuraParser) ?RuleResult {
	char := gp.char('\f\v\r\n') or { return err }
	gp.line++
	return Any(char)
}

// comment matches with a comment
fn comment(mut gp GuraParser) ?RuleResult {
	gp.keyword('#') or { return err }
	for gp.pos < gp.len {
		char := gp.text[gp.pos + 1..gp.pos + 2]
		gp.pos++
		if '\f\v\r\n'.contains(char) {
			gp.line++
			break
		}
	}

	return new_match_result(.comment_line)
}

// ws_with_indentation matches with white spaces taking into consideration indentation levels
fn ws_with_indentation(mut gp GuraParser) ?RuleResult {
	mut indentation_level := 0

	for gp.pos < gp.len {
		if blank := gp.maybe_keyword(' ', '\t') {
			if blank == '\t' {
				return new_invalid_indentation_error('Tabs are not allowed to define indentation blocks')
			}

			indentation_level++
		} else {
			if err is none {
				// if it is not a blank or new line, returns from the method
				break
			} else {
				return err
			}
		}
	}

	return Any(indentation_level)
}

// ws matches white spaces (blank and tabs)
fn ws(mut gp GuraParser) ?RuleResult {
	for {
		if _ := gp.maybe_keyword(' ', '\t') {
			continue
		} else {
			if err is none {
				break
			}
			return err
		}
	}
	return none
}

// eat_ws_and_new_lines consumes all the white spaces and end of line
fn eat_ws_and_new_lines(mut gp GuraParser) ?RuleResult {
	for {
		if _ := gp.maybe_char(' \f\v\r\n\t') {
			continue
		} else {
			if err is none {
				break
			}
			return err
		}
	}
	return none
}

// gura_import matches import sentence
fn gura_import(mut gp GuraParser) ?RuleResult {
	gp.keyword('import') or { return err }
	gp.char(' ') or { return err }
	file_to_import := gp.match_rule(quoted_string_with_var) or { return err } as Any as string
	gp.match_rule(ws) or { return err }
	if _ := gp.maybe_match(new_line) {
		// ignore this case for now
	} else {
		if err !is none {
			return err
		}
	}
	return new_match_result_with_value(.import_line, file_to_import)
}

// quoted_string_with_var matches with a quoted string(with a single quotation mark) taking into consideration a variable inside it.
// There is no special character escaping here
fn quoted_string_with_var(mut gp GuraParser) ?RuleResult {
	quote := gp.keyword('"') or { return err }
	mut chars := []string{}

	for {
		char := gp.char('') or { return err }
		if char == quote {
			break
		}

		// computes variables values in string
		if char == '$' {
			var_name := gp.get_var_name()
			chars << gp.get_var_value(var_name) or { return err } as string
			continue
		}

		chars << char
	}

	return Any(chars.join(''))
}

// any_type matches with any primitive or complex type
fn any_type(mut gp GuraParser) ?RuleResult {
	if result := gp.maybe_match(primitive_type) {
		return result
	} else {
		if err !is none {
			return err
		}
	}

	return gp.match_rule(complex_type)
}

// primitive_type matches with a primitive value: null, bool, string (all of four kind of strings), number or variables values
fn primitive_type(mut gp GuraParser) ?RuleResult {
	if _ := gp.maybe_match(ws) {
		// ignore this case for now
	} else {
		if err !is none {
			return err
		}
	}
	return gp.match_rule(null, boolean, basic_string, literal_string, number, variable_value)
}

// complex_type matches with a list or another complex expression
fn complex_type(mut gp GuraParser) ?RuleResult {
	return gp.match_rule(list, expression)
}

// variable_value matches with an already defined variable and gets its value
fn variable_value(mut gp GuraParser) ?RuleResult {
	gp.keyword('$') or { return err }
	key := gp.match_rule(unquoted_string) or { return err } as Any as string
	value := gp.get_var_value(key) or { return err } as string
	return Any(value)
}

// variable matches with a variable definition
fn variable(mut gp GuraParser) ?RuleResult {
	gp.keyword('$') or { return err }
	matched_key := gp.match_rule(key) or { return err } as Any as string

	if _ := gp.maybe_match(ws) {
		// ignore this case for now
	} else {
		if err !is none {
			return err
		}
	}

	res := gp.match_rule(basic_string, literal_string, number, variable_value) or { return err } as MatchResult

	if matched_key in gp.variables {
		return new_duplicated_variable_error('Variable $matched_key has been already declared')
	}

	// store as variable
	gp.variables[matched_key] = res.value
	return new_match_result(.variable)
}

// list matches with a list
fn list(mut gp GuraParser) ?RuleResult {
	mut result := []Any{}

	if _ := gp.maybe_match(ws) {
		// ignore this case for now
	} else {
		if err !is none {
			return err
		}
	}

	gp.keyword('[') or { return err }

	for {
		// discards useless lines between elements of array
		if _ := gp.maybe_match(useless_line) {
			continue
		} else {
			if err !is none {
				return err
			}
		}

		if match_result := gp.maybe_match(any_type) {
			item := match_result as MatchResult

			if item.result_type == .expression {
				val := item.value as []Any
				result << val[0]
			} else {
				result << item.value
			}

			if _ := gp.maybe_match(ws) {
				// ignore this case for now
			} else {
				if err !is none {
					return err
				}
			}
			if _ := gp.maybe_match(new_line) {
				// ignore this case for now
			} else {
				if err !is none {
					return err
				}
			}
			if _ := gp.maybe_keyword(',') {
				// ignore this case for now
			} else {
				if err is none {
					break
				} else {
					return err
				}
			}
		} else {
			if err !is none {
				return err
			}
		}
	}

	if _ := gp.maybe_match(ws) {
		// ignore this case for now
	} else {
		if err !is none {
			return err
		}
	}
	if _ := gp.maybe_match(new_line) {
		// ignore this case for now
	} else {
		if err !is none {
			return err
		}
	}
	gp.keyword(']') or { return err }
	return new_match_result_with_value(.list, result)
}

// useless_line matches with a useless line. A line is useless when it contains only whitespaces and / or a comment finishing in a new line
fn useless_line(mut gp GuraParser) ?RuleResult {
	gp.match_rule(ws) or { return err }
	gp.maybe_match(comment) or {
		return if err is none {
			new_parse_error(gp.pos + 1, gp.line, 'It is a valid line')
		} else {
			err
		}
	}
	initial_line := gp.line
	if _ := gp.maybe_match(new_line) {
		// ignore this case for now
	} else {
		if err !is none {
			return err
		}
	}

	if (gp.line - initial_line) != 1 {
		return new_parse_error(gp.pos + 1, gp.line, 'It is a valid line')
	}

	return new_match_result(.useless_line)
}

// expression match any gura expression
fn expression(mut gp GuraParser) ?RuleResult {
	mut result := map[string]Any{}
	mut indentation_level := Any(0)

	for gp.pos < gp.len {
		if match_result := gp.maybe_match(variable, pair, useless_line) {
			item := match_result as MatchResult

			if item.result_type == .pair {
				// item is a key / value pair
				item_value := item.value as []Any
				key := item_value[0] as string
				value := item_value[1]
				indentation := item_value[2]

				if key in result {
					return new_duplicated_variable_error('the key $key has been already defined')
				}

				result[key] = value
				indentation_level = indentation
			}
		} else {
			if err !is none {
				return err
			}
		}

		if _ := gp.maybe_keyword(']', ',') {
			// break if it is the end of the list
			gp.remove_last_indentation_level()
			gp.pos--
			break
		} else {
			if err !is none {
				return err
			}
		}
	}

	if result.len > 0 {
		return new_match_result_with_value(.expression, [Any(result), indentation_level])
	}

	return none
}

// key matches with a key. A key is an unquoted string followed by a colon (:)
fn key(mut gp GuraParser) ?RuleResult {
	key := gp.match_rule(unquoted_string) or { return err }
	gp.keyword(':') or { return err }
	return key
}

// pair matches with a key - value pair taking into consideration the indentation levels.
fn pair(mut gp GuraParser) ?RuleResult {
	pos_before_pair := gp.pos
	if indentation_match := gp.maybe_match(ws_with_indentation) {
		current_identation_level := indentation_match as Any as int

		key_str := gp.match_rule(key) or { return err } as Any as string
		if _ := gp.maybe_match(ws) {
			// ignore this case for now
		} else {
			if err !is none {
				return err
			}
		}
		if _ := gp.maybe_match(new_line) {
			// ignore this case for now
		} else {
			if err !is none {
				return err
			}
		}

		// check if indentation is divisible by 4
		if current_identation_level % 4 != 0 {
			return new_invalid_indentation_error('indentation block ($current_identation_level) must be divisible by 4')
		}

		// check indentation
		if last_indentation_block := gp.get_last_indentation_level() {
			if current_identation_level > last_indentation_block {
				gp.indentation_levels << current_identation_level
			} else if current_identation_level < last_indentation_block {
				gp.remove_last_indentation_level()

				// As the indentation was consumed, it is needed to return to line beginning to get the indentation level
				// again in the previous matching.else, the other match would get indentation level = 0
				gp.pos = pos_before_pair
				// This breaks the parent loop
				return none
			}
		}

		// if none, it is an empty expression and therefore invalid
		if match_result := gp.match_rule(any_type) {
			result := match_result as MatchResult
			// check indentation against parent level
			if result.result_type == .expression {
				value := result.value as []Any
				object_values := value[1]
				indentation_level := value[2] as int

				if indentation_level == current_identation_level {
					return new_invalid_indentation_error('wrong level for parent with key $key_str')
				} else if int(math.abs(current_identation_level - indentation_level)) != 4 {
					return new_invalid_indentation_error('difference between different indentation levels must be 4')
				}

				if _ := gp.maybe_match(new_line) {
					// ignore this case for now
				} else {
					if err !is none {
						return err
					}
				}
				return new_match_result_with_value(.pair, [Any(key_str), object_values,
					Any(current_identation_level),
				])
			}

			if _ := gp.maybe_match(new_line) {
				// ignore this case for now
			} else {
				if err !is none {
					return err
				}
			}
			return new_match_result_with_value(.pair, [Any(key_str), result.value,
				Any(current_identation_level),
			])
		} else {
			if err is none {
				return new_parse_error(gp.pos + 1, gp.line, 'invalid pair')
			} else {
				return err
			}
		}
	} else {
		if err !is none {
			return err
		}
	}
	return none
}

// null consumes null keyword and return Null{}
fn null(mut gp GuraParser) ?RuleResult {
	gp.keyword('null') or { return err }
	return new_match_result_with_value(.primitive, Null{})
}

// boolean parses boolean value
fn boolean(mut gp GuraParser) ?RuleResult {
	boolean_key := gp.keyword('true', 'false') or { return err }
	return new_match_result_with_value(.primitive, boolean_key == 'true')
}

// unquoted_string parses an unquoted string such as a key
fn unquoted_string(mut gp GuraParser) ?RuleResult {
	char := gp.char(key_acceptable_chars) or { return err }
	mut chars := [char]

	for {
		if other_char := gp.maybe_char(key_acceptable_chars) {
			chars << other_char
		} else {
			if err is none {
				break
			}
		}
	}

	return Any(chars.join('').trim_right(' '))
}

// number parses a string checking if it is a number and get its correct value
fn number(mut gp GuraParser) ?RuleResult {
	mut number_type := 'int'

	char := gp.char(number_acceptable_chars) or { return err }
	mut chars := [char]

	for {
		if other_char := gp.maybe_char(number_acceptable_chars) {
			if 'Ee.'.contains(other_char) {
				number_type = 'f64'
			}

			chars << other_char
		} else {
			if err is none {
				break
			}
		}
	}

	number := chars.join('').trim_right(' ')

	if number == 'inf' {
		return new_match_result_with_value(.primitive, math.inf(-1))
	}

	if number == '-inf' {
		return new_match_result_with_value(.primitive, math.inf(1))
	}

	if number == 'nan' {
		return new_match_result_with_value(.primitive, math.nan())
	}

	return if number_type == 'int' {
		new_match_result_with_value(.primitive, number.int())
	} else {
		new_match_result_with_value(.primitive, number.f64())
	}
}

// basic_string matches with a simple / multiline basic string
fn basic_string(mut gp GuraParser) ?RuleResult {
	quote := gp.keyword("'''", "'") or { return err }
	is_multiline := quote == "'''"

	// NOTE: A newline immediately following the opening delimiter will be trimmed. All other whitespace and
	// newline characters remain intact.
	if is_multiline {
		if _ := gp.maybe_char('\n') {
			// ignore this case for now
		} else {
			if err !is none {
				return err
			}
		}
	}

	mut chars := []string{}

	for {
		if _ := gp.maybe_keyword(quote) {
			char := gp.char('') or { return err }

			if char == '\\' {
				escape := gp.char('') or { return err }

				// check backslash followed by a newline to trim all whitespaces
				if is_multiline && escape == '\n' {
					eat_ws_and_new_lines(mut gp) or { return err }
				} else {
					// supports unicode of 16 and 32 bits representation
					if escape == 'u' || escape == 'U' {
						num_chars_code_point := if escape == 'u' { 4 } else { 8 }
						mut code_point := []string{}

						for _ in 0 .. num_chars_code_point {
							code_point_char := gp.char('0-9a-fA-F') or { return err }
							code_point << code_point_char
						}
						hex_value := strconv.parse_int(code_point.join(''), 16, 0) or { return err }
						// @todo: String.fromCharCode(hexValue) // converts from UNICODE to string
						char_value := hex_value.str()
						chars << char_value
					} else {
						// get escaped char
						chars << escape_sequences[escape] or { char }
					}
				}
			} else {
				// computes variables values in string
				if char == '$' {
					var_name := gp.get_var_name()
					chars << gp.get_var_value(var_name) or { return err } as string
				} else {
					chars << char
				}
			}
		} else {
			if err is none {
				break
			}
			return err
		}

		char := gp.char('') or { return err }

		if char == '\\' {
			escape := gp.char('') or { return err }

			// check backslash followed by a newline to trim all whitespaces
			if is_multiline && escape == '\n' {
				eat_ws_and_new_lines(mut gp) or { return err }
			} else {
				// supports unicode of 16 and 32 bits representation
				if escape == 'u' || escape == 'U' {
					num_chars_code_point := if escape == 'u' { 4 } else { 8 }
					mut code_point := []string{}

					for _ in 0 .. num_chars_code_point {
						code_point_char := gp.char('0-9a-fA-F') or { return err }
						code_point << code_point_char
					}
					hex_value := strconv.parse_int(code_point.join(''), 16, 0) or { return err }
					// @todo: String.fromCharCode(hexValue) // converts from UNICODE to string
					char_value := hex_value.str()
					chars << char_value
				} else {
					// get escaped char
					chars << escape_sequences[escape] or { char }
				}
			}
		} else {
			// computes variables values in string
			if char == '$' {
				var_name := gp.get_var_name()
				chars << gp.get_var_value(var_name) or { return err } as string
			} else {
				chars << char
			}
		}
	}

	return new_match_result_with_value(.primitive, chars.join(''))
}

// literal_string matches with a simple / multiline literal string
fn literal_string(mut gp GuraParser) ?RuleResult {
	quote := gp.keyword("'''", "'") or { return err }
	is_multiline := quote == "'''"

	// NOTE: A newline immediately following the opening delimiter will be trimmed. All other whitespace and
	// newline characters remain intact.
	if is_multiline {
		if _ := gp.maybe_char('\n') {
			// ignore this case for now
		} else {
			if err !is none {
				return err
			}
		}
	}

	mut chars := []string{}

	for {
		if _ := gp.maybe_keyword(quote) {
			char := gp.char('') or { return err }
			chars << char
		} else {
			if err is none {
				break
			}
			return err
		}
	}

	return new_match_result_with_value(.primitive, chars.join(''))
}
