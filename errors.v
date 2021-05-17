module vgura

pub struct ParseError {
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
