## TypeBeat - Agnostic parser of the `Content-Type` in OCaml

[![Build Status](https://travis-ci.org/mirage/typebeat.svg?branch=master)](https://travis-ci.org/mirage/typebeat)

TypeBeat is a pure implementation of the parsing of the `Content-Type`'s value
(see [RFC822](https://tools.ietf.org/html/rfc822) and
[RFC2045](https://tools.ietf.org/html/rfc2045)). The reason of this *light*
library is to compute a complex rule. Indeed, it's __hard__ to parse the value
of the `Content-Type`, believe me.

So it's a common library if you want to know the value of the `Content-Type` and
don't worry, we respect the standard. We saved
the [IANA](https://www.iana.org/assignments/media-types/media-types.xhtml)
database too.

## Instalation

TypeBeat can be installed with `opam`:

    opam install type-beat

## Explanation

TypeBeat uses the cool and funny [Angstrom] library to parse the value of the
`Content-Type`. If you want to implement an email parser (like
[MrMime](https://github.com/oklm-wsh/MrMime)) or an HTTP server
([CoHTTP](https://github.com/mirage/ocaml-cohttp)), firstly, these already
exist, too bad.

[Angstrom]: https://github.com/inhabitedtype/angstrom

This parser handles complex rules like the `CFWS` token and other weird rules
from old and stupid RFCs. The point is to centralize all these parsers in one
library (because you can find the `Content-Type` crazy rule in some different
protocols) .

Then, the API was designed to be *easy to use*:

```ocaml
val of_string : string -> (content, error) result
val of_string_raw : string -> int -> int -> (content * int, error) result
```

The first transforms its `string` argument into a `Content-Type` value. The
second is generally used by another parser (like an HTTP protocol parser) to
parse a part of the `string` and return how many bytes the parser consumed.

If you are a __warrior__ of the Angstrom library, you can use the parser:

```ocaml
val parser : content Angstrom.t
```

But the parser does not terminate because we have the `CFWS` token at the end.
What does that mean? The parser expects an `End of input` or any character other
than `wsp` (and you can produce that by `Angstrom.Unbuffered.Complete`) to
check that the hypothetical next line is a new field. Because, as you know, we
can write something like:

```
Content-Type: text/html;^CRLF
 charset="utf-8"
```

And it is still valid (see RFC822)!

Another point is that this library has all of the
[IANA media types database](https://www.iana.org/assignments/media-types/media-types.xhtml)
(dated 2016-06-01), so we recognize the IANA media types
automatically.

## Build Requirements

 * OCaml >= 4.01.0
 * [Angstrom]
 * `topkg`, `ocamlfind` and `ocamlbuild` to build the project

## Improvement

If you want something from the RFC822, I can provide that in this library.
