module gura

import os

struct GuraParser {
	Parser
mut:
	variables          map[string]Any
	indentation_levels []int
	imported_files     map[string]bool
}

// encode generates a gura string from a dictionary
fn (gp GuraParser) encode(data map[string]Any, indentation_level int) string {
	mut result := ''
	for key, value in data {
		indentation := ' '.repeat(indentation_level * 4)
		result = '$result$indentation$key: '
		result = '$result${value.str_with_indentation(indentation_level)}'
		result = '$result\n'
	}
	return result
}

// parse parses a text in gura format and returns a dict with all the parsed values
fn (mut gp GuraParser) parse(text string) ?map[string]Any {
	gp.init(text)
	if result := gp.run() {
		if !gp.is_end() {
			return new_parse_error(gp.pos + 1, gp.line, 'Expected end of string but got ${gp.text[
				gp.pos + 1..gp.pos + 2]}')
		}
		return result
	} else {
		return err
	}
}

// get_text_with_imports gets final text taking in consideration imports in original text
fn (mut gp GuraParser) get_text_with_imports(original_text string, parent_dir_path string) ?string {
	gp.init(original_text)
	gp.compute_imports(parent_dir_path) ?
	return gp.text
}

// compute_imports computes all the import sentences in Gura file taking into consideration relative paths to imported files
fn (mut gp GuraParser) compute_imports(parent_dir_path string) ? {
	mut files_to_import := []string{}

	// first, consumes all the import sentences to replace all of them
	for gp.pos < gp.len {
		if rule_result := gp.maybe_match(gura_import, variable, useless_line) {
			match_result := rule_result as MatchResult
			// check, it could be a comment
			if match_result.result_type == .import_line {
				files_to_import << match_result.value as string
			}
		} else {
			if err is none {
				break
			}
			return err
		}
	}

	mut final_content := ''

	for file_name in files_to_import {
		// gets the final file path considering parent directory
		file_path := if parent_dir_path == '' {
			file_name
		} else {
			os.join_path(parent_dir_path, file_name)
		}

		// files can be imported only once.This prevents circular reference
		if file_path in gp.imported_files {
			return new_duplicated_import_error('file $file_path has been already imported')
		}

		// checks if file exists
		if !os.is_file(file_path) {
			return new_file_not_found_error('file $file_path does not exists')
		}

		content := os.read_file(file_path) ?
		mut aux_parser := GuraParser{}
		next_parent_dir_path := os.dir(file_path)
		content_with_imports := aux_parser.get_text_with_imports(content, next_parent_dir_path) ?

		final_content += '$content_with_imports\n'

		gp.imported_files[file_path] = true
	}

	// sets as new text
	gp.init('$final_content${gp.text[gp.pos + 1..]}')
}

// get_var_name gets a variable name
fn (mut gp GuraParser) get_var_name() ?string {
	mut var_name := ''

	for {
		if var_name_char := gp.char(key_acceptable_chars) {
			var_name += var_name_char
		} else {
			if err is none {
				break
			}
			return err
		}
	}

	return var_name
}

// get_var_value gets a variable value for a specific key from defined variables in file or as environment variable
fn (mut gp GuraParser) get_var_value(key string) ?Any {
	if key in gp.variables {
		return gp.variables[key] or { return none }
	}

	env := os.environ()
	if key in env {
		return env[key]
	}

	return new_variable_not_defined_error(key, 'Variable $key is not defined in Gura nor as env variable')
}

fn (mut gp GuraParser) run() ?map[string]Any {
	gp.compute_imports('') ?
	debug('Parser starting . . .')
	result := gp.match_rule(expression) ?
	debug('Parser finished')
	debug('Executing last `eat_ws_and_new_lines` . . .')
	eat_ws_and_new_lines(mut gp) ?
	debug('`eat_ws_and_new_lines` finished')
	// expression result as .value of type `[]Any` and a map[string]Any at possition `0`
	match_result := result as MatchResult
	res := match_result.value as []Any
	return res[0] as map[string]Any
}

// init sets the params to start parsing from a specific text
fn (mut gp GuraParser) init(text string) {
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
