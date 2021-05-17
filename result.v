module vgura

pub const (
	// Number chars
	basic_numbers_chars     = '0-9'
	hex_oct_bin             = 'A-Fa-fxob'
	// The rest of the chars are defined in hex_oct_bin
	inf_and_nan             = 'in'
	// IMPORTANT: '-' char must be last, otherwise it will be interpreted as a range
	acceptable_number_chars = '$basic_numbers_chars$hex_oct_bin${inf_and_nan}Ee+._-'
	// acceptable chars for keys
	key_acceptable_chars    = '0-9A-Za-z_-'
)

// `Any` is a sum type that lists the possible types to be decoded and used.
pub type Any = Null | []Any | bool | f32 | f64 | i64 | int | map[string]Any | string |
	u64

// `Null` struct is a simple representation of the `null` value in GURA.
pub struct Null {
	is_null bool = true
}

// MatchResultType
pub enum MatchResultType {
	useless_line
	pair
	comment_line
	import_line
	variable
	expression
}

// MatchResult
pub struct MatchResult {
	result_type MatchResultType
	value       ?Any = none
}

// new_match_result_with_value returns a result with value
pub fn new_match_result_with_value(result_type MatchResultType, value Any) MatchResult {
	return MatchResult{
		result_type: result_type
		value: value
	}
}

// new_match_result returns a result without value
pub fn new_match_result(result_type MatchResultType) MatchResult {
	return MatchResult{
		result_type: result_type
	}
}

pub fn (mr MatchResult) str() string {
	return '$mr.result_type -> $mr.value'
}
