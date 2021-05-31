module vgura

import os

pub struct GuraParser {
	Parser
mut:
	variables          map[string]Any
	indent_char        &string = 0
	indentation_levels []int
	imported_files     []string
}

// parse parses a text in gura format and returns a dict with all the parsed values
pub fn (mut gp GuraParser) parse(text string) ?map[string]Any {
	gp.init_params()
	if result := gp.run() {
		if !gp.assert_end() {
			return new_parse_error(gp.pos + 1, gp.line, 'Expected end of string but got ${gp.text[
				gp.pos + 1]}')
		}
		return result
	}
	return none
}

// get_text_with_imports gets final text taking in consideration imports in original text
pub fn (mut gp GuraParser) get_text_with_imports(original_text string, parent_dir_path string, imported_files ...string) (string, []string) {
	gp.init_params(original_text)
	computed_files := gp.compute_imports(parent_dir_path, imported_files)
	return gp.text, computed_files
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
	gp.compute_imports('', [])
	result := gp.maybe_match(expression) or { return err }
	eat_ws_and_new_lines(mut gp)
	return result.value[0]
}

// init_params sets the params to start parsing from a specific text
fn (mut gp GuraParser) init_params(text string) {
	gp.text = text
	gp.pos = -1
	gp.line = 0
	gp.len = text.len - 1
}
