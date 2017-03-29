TypeBeat - Agnostic parser of the `Content-Type` in OCaml
=========================================================

TypeBeat is a pure implementation of the parsing of the `Content-Type`'s value
(see [RFC822](https://tools.ietf.org/html/rfc822)
and [RFC2045](https://tools.ietf.org/html/rfc2045)). The reason of this *light*
library is to compute a complexe rule. Indeed, it's __hard__ to parse the value
of the `Content-Type`, believe me.

So it's a common library if you want to know the value of the `Content-Type` and
don't worry, we respect the standard. We saved
the [IANA](https://www.iana.org/assignments/media-types/media-types.xhtml)
database too.

## Instalation

TypeBeat can be installed with `opam`:

    opam install type-beat

## Explanation

TypeBeat uses the cool and funny [Angstrom](https://github.com/) library to
parse the value of the `Content-Type`. If you want to implement an e-mail parser
(like [MrMime](https://github.com/oklm-wsh/MrMime)) or an HTTP server
([CoHTTP](https://github.com/mirage/ocaml-cohttp)), firstly, these already
exist, too bad.

This parser handles the complexe rule like the `CFWS` token and others weird
rules from olds and stupids RFCs. The point is to centralize in one library
(because you can find the `Content-Type` crazy rule in some differents
protocols) this parser.

Then, the API was thinked to be *easy to use*:

```ocaml
val of_string : string -> (content, error) result
val of_string_raw : string -> int -> int -> (content * int, error) result
```

The first transform the `string` to a `Content-Type` value. The second is
generally used by another parser (like an HTTP protocol parser) to parse a part
of the `string` and return how many byte(s) the parser compute.

If you are a warrior of the Angstrom library, you can use the parser:

```ocaml
val parser : content Angstrom.t
```

But the parser does not terminate because we have the `CFWS` token at the end.
What that means? The parser expect an `End of input` or any character different
than `wsp` (and you can produce that by `Angstrom.Unbuffered.Complete`) to check
than the hypothetic next line is a new field. Because, as you know, we can write
something like:

```
Content-Type: text/html;^CRLF
 charset="utf-8"
```

And it still valid (see RFC822)!

Another point is that this library has all
of [IANA](https://www.iana.org/assignments/media-types/media-types.xhtml) media
type database (dated from 2016-06-01), so we recognize the IANA media type
automatically.

## Build Requirements

 * OCaml >= 4.01.0
 * [Angstrom](https://github.com/inhabitedtype/angstrom)
 * `topkg`, `ocamlfind` and `ocamlbuild` to build the project

## Improvement

If you want something from the RFC822, I can provide that in this library.
