module gura

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
	escape_sequences        = {
		'b':  '\b'
		'f':  '\f'
		'n':  '\n'
		'r':  '\r'
		't':  '\t'
		'"':  '"'
		'\\': '\\'
		'$':  '$'
	}

	multiline_quote   = '"""'
	single_line_quote = '"'
)

// RuleResult defines the return type for GuraParser.match_rule
type RuleResult = Any | MatchResult

type Rule = fn (mut p GuraParser) ?RuleResult

// MatchResultType
enum MatchResultType {
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
fn new_match_result_with_value(result_type MatchResultType, value Any) RuleResult {
	return MatchResult{
		result_type: result_type
		value: value
	}
}

// new_match_result returns a result without value
fn new_match_result(result_type MatchResultType) RuleResult {
	return MatchResult{
		result_type: result_type
	}
}

fn (mr MatchResult) str() string {
	return '$mr.result_type -> $mr.value'
}
