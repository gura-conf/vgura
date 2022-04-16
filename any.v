module gura

pub const (
	null = Null{}
)

// `Any` is a sum type that lists the possible types to be decoded and used.
pub type Any = Null
	| []Any
	| bool
	| u8
	| f32
	| f64
	| i16
	| i64
	| i8
	| int
	| map[string]Any
	| string
	| u16
	| u32
	| u64

// `Null` struct is a simple representation of the `null` value in GURA.
pub struct Null {}

pub fn (_ Null) str() string {
	return 'null'
}

pub fn (m map[string]Any) value(key string) ?Any {
	// return m[key] ?
	key_split := key.split('.')
	// util.printdbg(@MOD + '.' + @STRUCT + '.' + @FN, ' getting "${key_split[0]}"')
	if key_split[0] in m.keys() {
		value := m[key_split[0]] or {
			return error(@MOD + '.' + @STRUCT + '.' + @FN + ' key "$key" does not exist')
		}
		// `match` isn't currently very suitable for these types of sum type constructs...
		if value is map[string]Any {
			nm := (value as map[string]Any)
			next_key := key_split[1..].join('.')
			if next_key == '' {
				return value
			}
			return nm.value(next_key)
		}
		return value
	}
	return error(@MOD + '.' + @STRUCT + '.' + @FN + ' key "$key" does not exist')
}

pub fn (a []Any) as_strings() []string {
	mut sa := []string{}
	for any in a {
		sa << any.string()
	}
	return sa
}

// to_json returns `Any` as a JSON encoded string.
pub fn (a map[string]Any) to_json() string {
	mut str := '{'
	for key, val in a {
		str += ' "$key": $val.to_json(),'
	}
	str = str.trim_right(',')
	str += ' }'
	return str
}

// to_json returns `Any` as a JSON encoded string.
pub fn (a Any) to_json() string {
	match a {
		Null {
			return 'null'
		}
		string {
			return '"$a.str()"'
		}
		map[string]Any {
			mut str := '{'
			for key, val in a {
				str += ' "$key": $val.to_json(),'
			}
			str = str.trim_right(',')
			str += ' }'
			return str
		}
		[]Any {
			mut str := '['
			for val in a {
				str += ' $val.to_json(),'
			}
			str = str.trim_right(',')
			str += ' ]'
			return str
		}
		else {
			return a.str()
		}
	}
}

// str returns the string representation of the `Any` type.
pub fn (f Any) str() string {
	if f is string {
		return f
	} else {
		return f.str_with_indentation(0)
	}
}

// as_map uses `Any` as a map.
pub fn (f Any) as_map() map[string]Any {
	if f is map[string]Any {
		return f
	} else if f is []Any {
		mut mp := map[string]Any{}
		for i, fi in f {
			mp['$i'] = fi
		}
		return mp
	}
	return {
		'0': f
	}
}

// string returns `Any` as a string.
pub fn (a Any) string() string {
	match a {
		string { return a as string }
		else { return a.str() }
	}
}

// int uses `Any` as an integer.
pub fn (f Any) int() int {
	match f {
		int { return f }
		i64, f32, f64, bool { return int(f) }
		else { return 0 }
	}
}

// i64 uses `Any` as a 64-bit integer.
pub fn (f Any) i64() i64 {
	match f {
		i64 { return f }
		int, f32, f64, bool { return i64(f) }
		else { return 0 }
	}
}

// u64 uses `Any` as a 64-bit unsigned integer.
pub fn (f Any) u64() u64 {
	match f {
		u64 { return f }
		int, i64, f32, f64, bool { return u64(f) }
		else { return 0 }
	}
}

// f32 uses `Any` as a 32-bit float.
pub fn (f Any) f32() f32 {
	match f {
		f32 { return f }
		int, i64, f64 { return f32(f) }
		else { return 0.0 }
	}
}

// f64 uses `Any` as a float.
pub fn (f Any) f64() f64 {
	match f {
		f64 { return f }
		int, i64, f32 { return f64(f) }
		else { return 0.0 }
	}
}

// arr uses `Any` as an array.
pub fn (f Any) arr() []Any {
	if f is []Any {
		return f
	} else if f is map[string]Any {
		mut arr := []Any{}
		for _, v in f {
			arr << v
		}
		return arr
	}
	return [f]
}

// bool uses `Any` as a bool
pub fn (f Any) bool() bool {
	match f {
		bool { return f }
		string { return f.bool() }
		else { return false }
	}
}

fn (value Any) str_with_indentation(indentation_level int) string {
	return match value {
		[]Any {
			'[${value.map(it.str_with_indentation(indentation_level)).join(', ')}]'
		}
		map[string]Any {
			if value.len == 0 {
				'empty\n'
			} else {
				'\n${' '.repeat(indentation_level)}${encode_with_indentation(value,
					indentation_level + 1)}'
			}
		}
		bool {
			value.str()
		}
		f32 {
			value.str()
		}
		f64 {
			value.str()
		}
		i16 {
			value.str()
		}
		i64 {
			value.str()
		}
		i8 {
			value.str()
		}
		int {
			value.str()
		}
		string {
			'"$value"'
		}
                u8 {
			value.str()
		}
		u16 {
			value.str()
		}
		u32 {
			value.str()
		}
		u64 {
			value.str()
		}
		Null {
			value.str()
		}
	}
}
