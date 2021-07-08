module vgura

const (
	// Number chars
	basic_numbers_chars     = '0-9'
	hex_oct_bin             = 'A-Fa-fxob'
	// The rest of the chars are defined in hex_oct_bin
	inf_and_nan             = 'in'
	// IMPORTANT: '-' char must be last, otherwise it will be interpreted as a range
	number_acceptable_chars = '$basic_numbers_chars$hex_oct_bin${inf_and_nan}Ee+._-'
	// acceptable chars for keys
	key_acceptable_chars    = '0-9A-Za-z_-'

	// special characters to be escaped
	escape_sequences        = map{
		'b':  '\b'
		'f':  '\f'
		'n':  '\n'
		'r':  '\r'
		't':  '\t'
		'"':  '"'
		'\\': '\\'
		'$':  '$'
	}
)

// `Any` is a sum type that lists the possible types to be decoded and used.
pub type Any = Null | []Any | bool | byte | f32 | f64 | i16 | i64 | i8 | int | map[string]Any |
	string | u16 | u32 | u64

// `Null` struct is a simple representation of the `null` value in GURA.
pub struct Null {}

pub fn (_ Null) str() string {
	return 'null'
}

// RuleResult defines the return type for GuraParser.maybe_match
pub type RuleResult = MatchResult | Null | []Any | bool | byte | f32 | f64 | i16 | i64 |
	i8 | int | map[string]Any | string | u16 | u32 | u64

pub type Rule = fn (mut p GuraParser) ?RuleResult

// MatchResultType
pub enum MatchResultType {
	useless_line
	pair
	comment_line
	import_line
	variable
	primitive
	complex
	expression
	list
}

// MatchResult is the match result implementation
[heap]
struct MatchResult {
	result_type MatchResultType
	value       Any
}

// new_match_result_with_value returns a result with value
pub fn new_match_result_with_value(result_type MatchResultType, value Any) RuleResult {
	return MatchResult{
		result_type: result_type
		value: value
	}
}

// new_match_result returns a result without value
pub fn new_match_result(result_type MatchResultType) RuleResult {
	return MatchResult{
		result_type: result_type
	}
}

pub fn (mr MatchResult) str() string {
	return '$mr.result_type -> $mr.value'
}

pub fn (value Any) str_with_indentation(indentation_level int) string {
	// return match value {
	// 	[]Any {
	// 		'[${value.map(it.str_with_indentation(indentation_level)).join(', ')}]'
	// 	}
	// 	map[string]Any {
	// 		encode(value, indentation_level + 1)
	// 	}
	// 	else {
	// 		value.str()
	// 	}
	// }
	return ''
}
