module vgura

fn test_comment() {
	mut gp := GuraParser{}

	gp.init('# This is a comment')
	if result := comment(mut gp) {
		match_result := result as MatchResult
		assert match_result.result_type == .comment_line
	} else {
		panic(err)
	}

	gp.init('')
	if _ := comment(mut gp) {
		panic('This should not happen since the input text does not contain #')
	} else {
		assert err !is none
	}
}

fn test_ws_with_indentation() {
	mut gp := GuraParser{}

	ws_str := ' '.repeat(4)
	gp.init(ws_str)
	if result := ws_with_indentation(mut gp) {
		indentation_level := result as Any as int
		assert indentation_level == ws_str.len
	} else {
		panic(err)
	}

	gp.init('\t')
	if _ := ws_with_indentation(mut gp) {
		panic('This should not happen since tabs are not allowed')
	} else {
		assert err !is none
	}
}

fn test_ws() {
	mut gp := GuraParser{}

	ws_str := ' '.repeat(4)
	gp.init(ws_str)
	if count := ws(mut gp) {
		assert count as Any as int == ws_str.len
	} else {
		panic(err)
	}

	gp.init('\t')
	if count := ws(mut gp) {
		assert count as Any as int == 1
	} else {
		panic(err)
	}

	gp.init('text')
	if count := ws(mut gp) {
		assert count as Any as int == 0
	} else {
		panic(err)
	}
}

fn test_eat_ws_and_new_lines() {
	mut gp := GuraParser{}

	ws_and_new_lines_str := ' \f\v\r\n\t\t\t\n'
	gp.init(ws_and_new_lines_str)
	if count := eat_ws_and_new_lines(mut gp) {
		assert count as Any as int == ws_and_new_lines_str.len
	} else {
		panic(err)
	}

	gp.init('text')
	if count := eat_ws_and_new_lines(mut gp) {
		assert count as Any as int == 0
	} else {
		panic(err)
	}
}

fn test_gura_import() {
	mut gp := GuraParser{}

	file_name := 'file.ura'
	gp.init('import "$file_name"')
	if result := gura_import(mut gp) {
		match_result := result as MatchResult
		file_to_import := match_result.value as string
		assert match_result.result_type == .import_line
		assert file_to_import == file_name
	} else {
		panic(err)
	}

	gp.init('text')
	if _ := gura_import(mut gp) {
		panic('This should never happen')
	} else {
		assert err !is none
	}
}

fn test_quoted_string_with_var() {
	mut gp := GuraParser{}

	str := 'text'
	gp.init('"$str"')
	if result := quoted_string_with_var(mut gp) {
		result_str := result as Any as string
		assert result_str == str
	} else {
		panic(err)
	}

	gp.init('"text')
	if _ := quoted_string_with_var(mut gp) {
		panic('This should never happen')
	} else {
		assert err !is none
	}
}

fn test_any_type() {
	mut gp := GuraParser{}

	number := 9.4
	gp.init('$number')
	if result := any_type(mut gp) {
		match_result := result as MatchResult
		value := match_result.value as f64
		assert match_result.result_type == .primitive
		assert value == number
	} else {
		panic(err)
	}

	gp.init('# This is a useless line')
	if _ := any_type(mut gp) {
		panic('This should never happen')
	} else {
		assert err is none
	}
}

fn test_primitive() {
	mut gp := GuraParser{}

	number := 9.4
	gp.init('$number')
	if result := primitive_type(mut gp) {
		match_result := result as MatchResult
		value := match_result.value as f64
		assert match_result.result_type == .primitive
		assert value == number
	} else {
		panic(err)
	}

	gp.init('# This is a useless line')
	if _ := primitive_type(mut gp) {
		panic('This should never happen')
	} else {
		assert err !is none
	}
}

fn test_complex_type() {
	mut gp := GuraParser{}

	list := ['value1', 'value2', 'value3'].map(Any(it))
	gp.init('["value1", "value2", "value3"]')
	if result := complex_type(mut gp) {
		match_result := result as MatchResult
		value := match_result.value as []Any
		assert match_result.result_type == .list
		assert value == list
	} else {
		panic(err)
	}

	gp.init('# This is a useless line')
	if _ := complex_type(mut gp) {
		panic('This should never happen')
	} else {
		assert err is none
	}
}

fn test_complex_type_expression_1() {
	mut gp := GuraParser{}

	gp.init('
# Apache configuration
apache:
    virtual_host: "10.10.10.4"
    port: 81
')
	if result := complex_type(mut gp) {
		expected := map{
			'apache': Any(map{
				'virtual_host': Any('10.10.10.4')
				'port':         Any(81)
			})
		}

		match_result := result as MatchResult
		value := match_result.value as []Any
		object := value[0] as map[string]Any
		assert match_result.result_type == .expression
		assert expected == object
	} else {
		panic(err)
	}

	gp.init('# This is a useless line')
	if _ := complex_type(mut gp) {
		panic('This should never happen')
	} else {
		assert err is none
	}
}

fn test_complex_type_expression_2() {
	mut gp := GuraParser{}

	gp.init('
# Nginx configuration
nginx:
    host: "127.0.0.1"
    port: 80

# Apache configuration
apache:
    virtual_host: "10.10.10.4"
    port: 81
')
	if result := complex_type(mut gp) {
		expected := map{
			'nginx':  Any(map{
				'host': Any('127.0.0.1')
				'port': Any(80)
			})
			'apache': Any(map{
				'virtual_host': Any('10.10.10.4')
				'port':         Any(81)
			})
		}

		match_result := result as MatchResult
		value := match_result.value as []Any
		object := value[0] as map[string]Any
		assert match_result.result_type == .expression
		assert expected == object
	} else {
		panic(err)
	}

	gp.init('# This is a useless line')
	if _ := complex_type(mut gp) {
		panic('This should never happen')
	} else {
		assert err is none
	}
}

fn test_complex_type_expression_3() {
	mut gp := GuraParser{}

	gp.init('
# Services configuration
services:
    nginx:
        host: "127.0.0.1"
        port: 80
    apache:
        virtual_host: "10.10.10.4"
        port: 81
')
	if result := complex_type(mut gp) {
		expected := map{
			'services': Any(map{
				'nginx':  Any(map{
					'host': Any('127.0.0.1')
					'port': Any(80)
				})
				'apache': Any(map{
					'virtual_host': Any('10.10.10.4')
					'port':         Any(81)
				})
			})
		}

		match_result := result as MatchResult
		value := match_result.value as []Any
		object := value[0] as map[string]Any
		assert match_result.result_type == .expression
		assert expected == object
	} else {
		panic(err)
	}

	gp.init('# This is a useless line')
	if _ := complex_type(mut gp) {
		panic('This should never happen')
	} else {
		assert err is none
	}
}

fn test_variable_value() {
	mut gp := GuraParser{}

	gp.init('\$USER')
	if expected_user := gp.get_var_value('USER') {
		if result := variable_value(mut gp) {
			match_result := result as MatchResult
			user := match_result.value
			assert match_result.result_type == .primitive
			assert expected_user == user
		} else {
			panic(err)
		}
	} else {
		panic(err)
	}

	gp.init('# This is a useless line')
	if _ := variable_value(mut gp) {
		panic('This should never happen')
	} else {
		assert err !is none
	}
}

fn test_variable() {
	mut gp := GuraParser{}

	gp.init('\$var: 9.4')
	if result := variable(mut gp) {
		match_result := result as MatchResult
		assert match_result.result_type == .variable

		if value := gp.get_var_value('var') {
			assert value as f64 == 9.4
		} else {
			panic(err)
		}
	} else {
		panic(err)
	}

	gp.init('# This is a useless line')
	if _ := variable(mut gp) {
		panic('This should never happen')
	} else {
		assert err !is none
	}
}

fn test_list() {
	mut gp := GuraParser{}

	values := ['value1', 'value2', 'value3'].map(Any(it))
	gp.init('["value1", "value2", "value3"]')
	if result := list(mut gp) {
		match_result := result as MatchResult
		value := match_result.value as []Any
		assert match_result.result_type == .list
		assert value == values
	} else {
		panic(err)
	}

	gp.init('# This is a useless line')
	if _ := list(mut gp) {
		panic('This should never happen')
	} else {
		assert err !is none
	}
}

fn test_useless_line() {
	mut gp := GuraParser{}

	gp.init('# This is a useless line')
	if result := useless_line(mut gp) {
		match_result := result as MatchResult
		assert match_result.result_type == .useless_line
	} else {
		panic(err)
	}
}

fn test_key() {
	mut gp := GuraParser{}

	gp.init('key:')
	if result := key(mut gp) {
		matched_key := result as Any as string
		assert matched_key == 'key'
	} else {
		panic(err)
	}

	gp.init('text')
	if _ := key(mut gp) {
		panic('This should never happen')
	} else {
		assert err !is none
	}
}

fn test_null() {
	mut gp := GuraParser{}

	expected_value := Null{}
	gp.init('$expected_value.str()')
	if result := null(mut gp) {
		match_result := result as MatchResult
		value := match_result.value as Null
		assert match_result.result_type == .primitive
		assert value == expected_value
	} else {
		panic(err)
	}

	gp.init('# This is a useless line')
	if _ := null(mut gp) {
		panic('This should never happen')
	} else {
		assert err !is none
	}
}

fn test_boolean() {
	mut gp := GuraParser{}

	expected_value := true
	gp.init('$expected_value.str()')
	if result := boolean(mut gp) {
		match_result := result as MatchResult
		value := match_result.value as bool
		assert match_result.result_type == .primitive
		assert value == expected_value
	} else {
		panic(err)
	}

	gp.init('# This is a useless line')
	if _ := boolean(mut gp) {
		panic('This should never happen')
	} else {
		assert err !is none
	}
}

fn test_number() {
	mut gp := GuraParser{}

	expected_value := 9.78
	gp.init('$expected_value.str()')
	if result := number(mut gp) {
		match_result := result as MatchResult
		value := match_result.value as f64
		assert match_result.result_type == .primitive
		assert value == expected_value
	} else {
		panic(err)
	}

	gp.init('# This is a useless line')
	if _ := number(mut gp) {
		panic('This should never happen')
	} else {
		assert err !is none
	}
}
