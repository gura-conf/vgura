module vgura

import os

pub struct GuraParser {
	Parser
mut:
	variables          map[string]Any
	indentation_levels []int
	imported_files     []string
}

// encode generates a gura string from a dictionary
pub fn (gp GuraParser) encode(data map[string]Any, indentation_level int, new_line bool) string {
	mut result := ''
	for key, value in data {
		indentation := ' '.repeat(indentation_level * 4)
		result = '$result$indentation$key:'
		result = '$result${value.str_with_indentation(indentation_level)}'
		result = '$result\n'
	}
	return result
}

// parse parses a text in gura format and returns a dict with all the parsed values
pub fn (mut gp GuraParser) parse(text string) ?map[string]Any {
	gp.init_params(text)
	if result := gp.run() {
		if !gp.is_end() {
			return new_parse_error(gp.pos + 1, gp.line, 'Expected end of string but got ${gp.text[
				gp.pos + 1]}')
		}
		return result
	} else {
		return err
	}
}

// get_text_with_imports gets final text taking in consideration imports in original text
pub fn (mut gp GuraParser) get_text_with_imports(original_text string, parent_dir_path string, imported_files ...string) (string, []string) {
	gp.init_params(original_text)
	computed_files := gp.compute_imports(parent_dir_path, ...imported_files)
	return gp.text, computed_files
}

// compute_imports computes all the import sentences in Gura file taking into consideration relative paths to imported files
fn (mut gp GuraParser) compute_imports(parent_dir_path string, imported_files ...string) []string {
	// @todo: Finish this implementation once the rest works
	return []string{}
}

// get_var_name gets a variable name
pub fn (mut gp GuraParser) get_var_name() string {
	mut var_name := ''

	for {
		if var_name_char := gp.char(key_acceptable_chars) {
			var_name += var_name_char
		} else {
			break
		}
	}

	return var_name
}

// get_var_value gets a variable value for a specific key from defined variables in file or as environment variable
pub fn (mut gp GuraParser) get_var_value(key string) ?Any {
	if key in gp.variables {
		return gp.variables[key]
	}

	env := os.environ()
	if key in env {
		return env[key]
	}

	return new_variable_not_defined_error(key, 'Variable $key is not defined in Gura nor as env variable')
}

fn (mut gp GuraParser) run() ?map[string]Any {
	gp.compute_imports('')
	result := gp.match_rule(expression) or { return err } as MatchResult
	eat_ws_and_new_lines(mut gp) or { return err }
	// expression result as .value of type `[]Any` and a map[string]Any at possition `0`
	res := result.value as []Any
	return res[0] as map[string]Any
}

// init_params sets the params to start parsing from a specific text
fn (mut gp GuraParser) init_params(text string) {
	gp.text = text
	gp.pos = -1
	gp.line = 0
	gp.len = text.len - 1
}

// get_last_indentation_level get the last indentation level or null in case it does not exist
fn (mut gp GuraParser) get_last_indentation_level() ?int {
	if gp.indentation_levels.len > 0 {
		return gp.indentation_levels[gp.indentation_levels.len - 1]
	}
	return none
}

// remove_last_indentation_level removes, if exists, the last indentation_level
fn (mut gp GuraParser) remove_last_indentation_level() {
	if gp.indentation_levels.len > 0 {
		gp.indentation_levels.pop()
	}
}

// parse parses a text in Gura format
pub fn parse(text string) ?map[string]Any {
	mut gp := GuraParser{}
	return gp.parse(text)
}

// encode generates a Gura string from a dictionary
pub fn encode(data map[string]Any) string {
	mut gp := GuraParser{}
	return gp.encode(data, 0, true)
}
