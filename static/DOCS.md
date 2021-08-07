<div align="center">
<h1>V Gura</h1>

[vlang.io](https://vlang.io) |
[Docs](https://gura-conf.github.io/vgura) |
[Changelog](#) |
[Contributing](https://github.com/gura-conf/vgura/blob/main/CONTRIBUTING.md)

</div>

```v ignore
>>> import gura { parse, encode }
>>> data := parse('text: "Hello World!"') ?
>>> println(data)
{'text': gura.Any('Hello World!')}
>>> encode(data)
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

[workflowbadge]: https://github.com/gura-conf/vgura/workflows/Build%20and%20Test%20with%20deps/badge.svg
[validatedocsbadge]: https://github.com/gura-conf/vgura/workflows/Validate%20Docs/badge.svg
[licensebadge]: https://img.shields.io/badge/License-MIT-blue.svg
[workflowurl]: https://github.com/gura-conf/vgura/commits/main
[validatedocsurl]: https://github.com/gura-conf/vgura/commits/main
[licenseurl]: https://github.com/gura-conf/vgura/blob/main/LICENSE
