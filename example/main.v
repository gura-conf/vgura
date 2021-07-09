module main

import vgura

fn main() {
	a := vgura.parse('text: 2') or { panic(err) }
	println(a)
}
