module gura

fn test_split_char_ranges() {
	chars := '0-9A-Za-z_-'
	expected_ranges := ['0-9', 'A-Z', 'a-z', '_', '-']
	ranges := split_char_ranges(chars) or { panic(err) }
	assert ranges == expected_ranges
}
