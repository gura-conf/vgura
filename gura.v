module vgura

pub struct GuraParser {
	Parser
mut:
	variables          map[string]Any
	indent_char        &string = 0
	indentation_levels []int
	imported_files     []string
}

// load parses a text in gura format and returns a dict with all the parsed values
pub fn (mut gp GuraParser) load(text string) ?map[string]Any {
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

// init_params sets the params to start parsing from a specific text
pub fn (mut gp GuraParser) init_params(text string) {
	gp.text = text
	gp.pos = -1
	gp.line = 0
	gp.len = text.len - 1
}
