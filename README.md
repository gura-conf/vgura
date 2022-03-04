<div align="center">
<h1>V Gura</h1>

[vlang.io](https://vlang.io) |
[Docs](https://gura-conf.github.io/vgura) |
[Changelog](#) |
[Contributing](https://github.com/gura-conf/vgura/blob/main/CONTRIBUTING.md)

</div>

<div align="center">

[![Continuous Integration][workflowbadge]][workflowurl]
[![Deploy Documentation][deploydocsbadge]][deploydocsurl]
[![License: MIT][licensebadge]][licenseurl]

</div>

```v ignore
>>> import gura { raw_parse, raw_encode }
>>> data := raw_parse('text: "Hello World!"') ?
>>> println(data)
{'text': gura.Any('Hello World!')}
>>> raw_encode(data)
text: "Hello World!"
```

## Installation

**Via vpm**

```sh
$ v install gura
```

**Via [vpkg](https://github.com/v-pkg/vpkg)**

```sh
$ vpkg get https://github.com/gura-conf/vgura
```

Done. Installation completed.

## Testing

To test the module, just type the following command:

```sh
$ ./bin/test # execute `./bin/test -h` to know more about the test command
```

## License

[MIT](LICENSE)

## Contributors

<a href="https://github.com/gura-conf/vgura/contributors">
  <img src="https://contrib.rocks/image?repo=gura-conf/vgura"/>
</a>

Made with [contributors-img](https://contrib.rocks).

[workflowbadge]: https://github.com/gura-conf/vgura/actions/workflows/ci.yml/badge.svg
[deploydocsbadge]: https://github.com/gura-conf/vgura/actions/workflows/deploy-docs.yml/badge.svg
[licensebadge]: https://img.shields.io/badge/License-MIT-blue.svg
[workflowurl]: https://github.com/gura-conf/vgura/actions/workflows/ci.yml
[deploydocsurl]: https://github.com/gura-conf/vgura/actions/workflows/deploy-docs.yml
[licenseurl]: https://github.com/gura-conf/vgura/blob/main/LICENSE
