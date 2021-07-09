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
	text := encode(data)
	println(text)

	gura_str := '
# This is a Gura document.
title: "Gura Example"

an_object:
    username: "Stephen"
    pass: "Hawking"

# Line breaks are OK when inside arrays
hosts: [
  "alpha",
  "omega"
]'

	d := parse(gura_str) or { panic(err) }
	println(encode(d))
}
