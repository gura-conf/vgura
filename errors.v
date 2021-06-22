module vgura

pub struct ParseError {
pub:
	code int
	line int
	msg  string
	pos  int
}

pub fn new_parse_error(pos int, line int, msg string) IError {
	return &ParseError{
		pos: pos
		line: line
		msg: '$msg at line $line position $pos'
	}
}

fn check_parse_error(err IError) IError {
	if err is ParseError {
		return err
	}
	panic(err.msg)
}

pub struct DuplicatedVariableError {
pub:
	code int
	msg  string
}

pub fn new_duplicated_variable_error(msg string) IError {
	return &DuplicatedVariableError{
		msg: msg
	}
}

pub struct InvalidIndentationError {
pub:
	code int
	msg  string
}

pub fn new_invalid_indentation_error(msg string) IError {
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

pub fn new_variable_not_defined_error(key string, msg string) IError {
	return &VariableNotDefinedError{
		key: key
		msg: msg
	}
}
