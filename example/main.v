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

	gura_str := '
# This is a Gura document.
title: "Gura Example"

an_object:
    username: "Stephen"
    pass: "Hawking"
'.str()

	if d := parse(gura_str) {
		println('Parser finished')
		println('Result:')
		println(d)
	} else {
		println(err)
	}
}
