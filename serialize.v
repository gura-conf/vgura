module gura

pub interface Serializable {
	from_gura(f map[string]Any)
	to_gura() map[string]Any
}

// raw_parse parses a text in Gura format
pub fn raw_parse(text string) ?map[string]Any {
	mut gp := GuraParser{}
	return gp.parse(text)
}

// raw_encode generates a Gura string from a dictionary
pub fn raw_encode(data map[string]Any) string {
	mut gp := GuraParser{}
	return gp.encode(data, 0)
}

// parse is a generic function that parses a gura string into the target type.
pub fn parse<T>(src string) ?T {
	res := raw_parse(src)?
	mut typ := T{}
	typ.from_gura(res)
	return typ
}

// encode is a generic function that encodes a type into a gura string.
pub fn encode<T>(typ T) string {
	gura_object := typ.to_gura()
	return raw_encode(gura_object)
}

fn encode_with_indentation(data map[string]Any, indentation int) string {
	mut gp := GuraParser{}
	return gp.encode(data, indentation)
}
