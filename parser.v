module vgura

import math.util

// Base parser
pub struct Parser {
mut:
	cache map[string][]string
	len   int
	line  int
	pos   int
	text  string
}

pub type Rule = fn (mut p Parser) ?Any

// assert_end returns if the parser has reached the end of file
pub fn (p Parser) assert_end() bool {
	return p.pos >= p.len
}

// split_char_ranges returns a list of chars from a list of chars which could contain char ranges (i.e. a-z or 0-9)
pub fn (mut p Parser) split_char_ranges(chars string) ?[]string {
	if chars in p.cache {
		return p.cache[chars]
	}

	mut result := []string{}
	mut idx := 0
	mut len := chars.len

	for idx < len {
		if idx + 2 < len && chars[idx + 1] == `-` {
			if chars[idx] >= chars[idx + 2] {
				return error('Bad character error')
			}

			result << chars[idx..idx + 3]
			idx += 3
			continue
		}

		result << chars[idx].str()
		idx += 1
	}

	p.cache[chars] = result
	return result
}

// char matches a list of specific chars and returns the first that matched
pub fn (mut p Parser) char(chars string) ?string {
	if p.assert_end() {
		if chars != '' {
			return new_parse_error(p.pos + 1, p.line, 'Expected [$chars] but got end of string')
		}
		return new_parse_error(p.pos + 1, p.line, 'Expected character but got end of string')
	}

	next_char := p.text[p.pos + 1].str()

	if chars != '' {
		if split := p.split_char_ranges(chars) {
			for char_range in split {
				if char_range.len == 1 {
					if next_char == char_range {
						p.pos += 1
						return next_char
					}
				} else if char_range[0].str() <= next_char && next_char <= char_range[2].str() {
					p.pos += 1
					return next_char
				}
			}
		}

		return new_parse_error(p.pos + 1, p.line, 'Expected [$chars] but got $next_char')
	}

	p.pos += 1
	return next_char
}

// keyword matches specific keywords
pub fn (mut p Parser) keyword(keywords ...string) ?string {
	if p.assert_end() {
		return new_parse_error(p.pos + 1, p.line, 'Expected ${keywords.join(',')} but got end of string')
	}

	for keyword in keywords {
		low := p.pos + 1
		high := low + keyword.len

		if p.text[low..high] == keyword {
			p.pos += keyword.len
			return keyword
		}
	}

	return new_parse_error(p.pos + 1, p.line, 'Expected ${keywords.join(',')} but got ${p.text[
		p.pos + 1]}')
}

pub fn (mut p Parser) maybe_match(rules ...Rule) ?Any {
	mut last_error_pos := -1
	mut last_error := error('')
	mut last_error_rules := []Rule{}

	for rule in rules {
		init_pos := p.pos

		if res := rule(mut p) {
			return res
		} else {
			p.pos = init_pos
			if err is ParseError {
				if err.pos > last_error_pos {
					last_error = err
					last_error_pos = err.pos
					last_error_rules = [rule]
				} else {
					if err.pos == last_error_pos {
						last_error_rules << rule
					}
				}
			}
		}
	}

	if last_error_rules.len == 1 {
		return last_error
	}

	last_error_pos = util.imin(p.text.len - 1, last_error_pos)
	return new_parse_error(last_error_pos, p.line, 'Expected $last_error_rules.str() but got ${p.text[last_error_pos]}')
}
