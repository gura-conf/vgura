module main

import os
import gura_conf.vgura { encode, parse }

fn main() {
	file_path := os.join_path(@VMODROOT, 'example', 'example.ura')
	gura_str := os.read_file(file_path) ?

	if d := parse(gura_str) {
		println('Parser finished successfully')
		println('')
		println(encode(d))
	} else {
		if err !is none {
			println('Parser finished with error')
			panic(err)
		}
	}
}
