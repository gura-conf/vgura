module main

import math
import vgura { Any, encode, parse }

fn main() {
	data := map{
		'inf':          Any(math.inf(1))
		'complex_data': Any(map{
			'text':              Any('value')
			'more_complex_data': Any(map{
				'number': Any(2.)
			})
		})
	}

	println(encode(data))

	mut gura_str := '
# This is a Gura document.
title: "Gura Example"

an_object:
    username: "Stephen"
    pass: "Hawking"
    null_value: null
    number_value: 6.0

# Line breaks are OK when inside arrays
hosts: [
  "alpha",
  "omega"
]'.str()

	println('PARSING: $gura_str')

	if d := parse(gura_str) {
		println('Parser finished')
		println('Result:')
		println(encode(d))
	} else {
		println(err)
	}
}
