module vgura

// Base parser
pub struct GuraParser {
mut:
	cache map[string]string
	len   int
	line  int
	post  int
	text  string
}

// assert_end returns if the parser has reached the end of file
pub fn (p Parser) assert_end() bool {
	return p.pos >= p.len
}

// split_char_ranges returns a list of chars from a list of chars which could contain char ranges (i.e. a-z or 0-9)
pub fn (p Parser) split_char_ranges(chars string) ?string {
	if chars in p.cache {
		return p.cache[chars]
	}

	mut result := ''
	mut idx := 0
	mut len := chars.len

	for idx < len {
		if idx + 2 < len && chars[idx + 1] == '-' {
			if chars[idx] >= chars[idx + 2] {
				return error('Bad character error')
			}

			result = '$result${chars[idx..idx + 3]}'
			idx += 3
			continue
		}

		result = '$result${chars[idx]}'
		idx += 1
	}

	p.cache[chars] = result
	return result
}

// char matches a list of specific chars and returns the first that matched
pub fn (p Parser) char(maybe_chars ?string) ?string {
	if p.assert_end() {
		if chars := maybe_chars {
			return new_parse_error(p.pos + 1, p.line, 'Expected [$chars] but got end of string')
		}
		return new_parse_error(p.pos + 1, p.line, 'Expected character but got end of string')
	}

	next_char := p.text[p.pos + 1]

	if chars := maybe_chars {
		for char_range in p.split_char_ranges(chars) {
			if char_range.len == 1 {
				if next_char == char_range {
					p.pos += 1
					return next_char
				}
			} else if char_range[0] <= next_char && next_char <= char_range[2] {
				p.pos += 1
				return next_char
			}
		}

		return new_parse_error(p.pos + 1, p.line, 'Expected [$chars] but got $next_char')
	}

	p.pos += 1
	return next_char
}

// keyword matches specific keywords
pub fn (p Parser) keyword(keywords ...string) ?string {
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
