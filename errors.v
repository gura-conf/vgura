module gura

pub struct ParseError {
pub:
	code int
	line int
	msg  string
	pos  int
}

fn new_parse_error(pos int, line int, msg string) IError {
	return &ParseError{
		pos: pos
		line: line
		msg: '$msg at line $line position $pos'
	}
}

fn check_parse_error(err IError) ?RuleResult {
	if err is ParseError {
		return none
	}
	// if it is not a ParseError, return it to stop parsing
	return err
}

pub struct DuplicatedImportError {
pub:
	code int
	msg  string
}

fn new_duplicated_variable_error(msg string) IError {
	return &DuplicatedImportError{
		msg: msg
	}
}

pub struct DuplicatedVariableError {
pub:
	code int
	msg  string
}

fn new_duplicated_import_error(msg string) IError {
	return &DuplicatedVariableError{
		msg: msg
	}
}

pub struct FileNotFoundError {
pub:
	code int
	msg  string
}

fn new_file_not_found_error(msg string) IError {
	return &FileNotFoundError{
		msg: msg
	}
}

pub struct InvalidIndentationError {
pub:
	code int
	msg  string
}

fn new_invalid_indentation_error(msg string) IError {
	return &InvalidIndentationError{
		msg: msg
	}
}

pub struct VariableNotDefinedError {
pub:
	code int
	key  string
	msg  string
}

fn new_variable_not_defined_error(key string, msg string) IError {
	return &VariableNotDefinedError{
		key: key
		msg: msg
	}
}
