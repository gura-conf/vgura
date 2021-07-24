module vgura

// rule_debug is a helper function to debug parser calls
[inline]
fn rule_debug(rule string) {
	debug('Parsing rule $rule')
}

[inline]
fn match_rule_debug(matched bool, msg string) {
	debug(if matched { '	MATCHED $msg' } else { '	DIDN\'T MATCH $msg' })
}

// debug is a helper function to print debug info
[inline]
fn debug(info string) {
	$if debug ? {
		println(info)
	}
}
