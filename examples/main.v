module main

import os
import gura

struct Nginx {
mut:
	host string
	port int
}

pub fn (mut n Nginx) from_gura(obj map[string]gura.Any) {
	for key, val in obj {
		match key {
			'host' { n.host = val.str() }
			'port' { n.port = val.int() }
			else {}
		}
	}
}

pub fn (p Nginx) to_gura() map[string]gura.Any {
	return {
		'host': gura.Any(p.host)
		'port': gura.Any(p.port)
	}
}

struct Config {
mut:
	nginx Nginx
}

pub fn (mut n Config) from_gura(obj map[string]gura.Any) {
	for key, val in obj {
		match key {
			'local_nginx' {
				n.nginx = Nginx{}
				n.nginx.from_gura(val.as_map())
			}
			else {}
		}
	}
}

pub fn (p Config) to_gura() map[string]gura.Any {
	return {
		'local_nginx': gura.Any(p.nginx.to_gura())
	}
}

fn example() ? {
	file_path := os.join_path(@VMODROOT, 'examples', 'example.ura')
	gura_str := os.read_file(file_path) ?

	d := gura.raw_parse(gura_str) ?
	println('Parser finished successfully')
	println('d.str():')
	println(d)
	println('')
	println('')
	println('Nginx HOST: ${d.value('services.local_nginx.host') ?}')
	println('')
	println(d.to_json())
	println('raw_encode(d):')
	println(gura.raw_encode(d))

	config := gura.parse<Config>(gura_str) ?
	println('Parser finished successfully')
	println('config.str():')
	println(config)
	println('')
	println('encode(config):')
	println(gura.encode<Config>(config))
}

fn main() {
	if _ := example() {
		println('Example finished :D')
	} else {
		if err !is none {
			println('Parser finished with error')
			panic(err)
		}
	}
}
