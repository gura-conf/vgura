module gura

pub struct ParseError {
	Error
pub:
	msg  string
	line int
	pos  int
}

fn new_parse_error(pos int, line int, msg string) IError {
	return &ParseError{
		pos: pos
		line: line
		msg: msg
	}
}

pub fn (err &ParseError) msg() string {
	return '$err.msg at line $err.line position $err.pos'
}

fn check_parse_error(err IError) ?RuleResult {
	if err is ParseError {
		return none
	}
	// if it is not a ParseError, return it to stop parsing
	return err
}

pub struct DuplicatedImportError {
	Error
pub:
	msg string
}

fn new_duplicated_variable_error(msg string) IError {
	return &DuplicatedImportError{
		msg: msg
	}
}

pub fn (err &DuplicatedImportError) msg() string {
	return err.msg
}

pub struct DuplicatedVariableError {
	Error
pub:
	msg string
}

fn new_duplicated_import_error(msg string) IError {
	return &DuplicatedVariableError{
		msg: msg
	}
}

pub fn (err &DuplicatedVariableError) msg() string {
	return err.msg
}

pub struct FileNotFoundError {
	Error
pub:
	msg string
}

fn new_file_not_found_error(msg string) IError {
	return &FileNotFoundError{
		msg: msg
	}
}

pub fn (err &FileNotFoundError) msg() string {
	return err.msg
}

pub struct InvalidIndentationError {
	Error
pub:
	msg string
}

fn new_invalid_indentation_error(msg string) IError {
	return &InvalidIndentationError{
		msg: msg
	}
}

pub fn (err &InvalidIndentationError) msg() string {
	return err.msg
}

pub struct VariableNotDefinedError {
	Error
pub:
	key string
	msg string
}

fn new_variable_not_defined_error(key string, msg string) IError {
	return &VariableNotDefinedError{
		key: key
		msg: msg
	}
}

pub fn (err &VariableNotDefinedError) msg() string {
	return err.msg
}
