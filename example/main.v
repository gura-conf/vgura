module main

import math
import vgura

fn main() {
	data := map{
		'inf':          vgura.Any(math.inf(1))
		'complex_data': vgura.Any(map{
			'text':              vgura.Any('value')
			'more_complex_data': vgura.Any(map{
				'number': vgura.Any(2.)
			})
		})
	}
	text := vgura.encode(data)
	println(text)
}
