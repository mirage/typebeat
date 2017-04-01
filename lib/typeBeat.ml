module Rfc2045 = TypeBeat_rfc2045
module Rfc822  = TypeBeat_rfc822
module Iana    = TypeBeat_iana

type ty      = Rfc2045.ty
type subty   = Rfc2045.subty
type value   = Rfc2045.value

type content = Rfc2045.content =
  { ty         : Rfc2045.ty
  ; subty      : Rfc2045.subty
  ; parameters : (string * Rfc2045.value) list }

let pp = Format.fprintf

let pp_ty fmt = function
  | `Text         -> pp fmt "text"
  | `Image        -> pp fmt "image"
  | `Audio        -> pp fmt "audio"
  | `Video        -> pp fmt "video"
  | `Application  -> pp fmt "application"
  | `Message      -> pp fmt "message"
  | `Multipart    -> pp fmt "multipart"
  | `Ietf_token s -> pp fmt "ietf:\"%s\"" s
  | `X_token s    -> pp fmt "x:\"%s\"" s

let pp_subty fmt = function
  | `Ietf_token s -> pp fmt "ietf:\"%s\"" s
  | `X_token s    -> pp fmt "x:\"%s\"" s
  | `Iana_token s -> pp fmt "iana:%s" s

let pp_value fmt = function
  | `String s -> pp fmt "%S" s
  | `Token s  -> pp fmt "\"%s\"" s

let pp_lst ~sep pp_data fmt lst =
  let rec aux = function
    | [] -> ()
    | [ x ] -> pp_data fmt x
    | x :: r -> pp fmt "%a%a" pp_data x sep (); aux r
  in aux lst

let pp_parameter fmt (key, value) =
  pp fmt "%s = %a" key pp_value value

let pp fmt { ty; subty; parameters; } =
  pp fmt "{@[<hov>type = %a/%a;@ parameters = [@[<hov>%a@]]@]}"
    pp_ty ty
    pp_subty subty
    (pp_lst ~sep:(fun fmt () -> pp fmt ";@ ") pp_parameter) parameters

let make ?(parameters = []) ty subty =
  let parameters = List.map (fun (k, v) -> (String.lowercase_ascii k, v)) parameters in
  { ty; subty; parameters }

let default =
  { ty = `Text
  ; subty = `Iana_token "plain"
  ; parameters = ["charset", `Token "us-ascii"] }

open Angstrom.Unbuffered

type error =
  [ `Invalid of (string * string list)
  | `Incomplete ]

let parser = Rfc2045.content

let of_string_with_crlf s =
  let rec aux second_time = function
    | Fail (_, path, err) -> Error (`Invalid (err, path))
    | Partial { continue; _ } ->
      if second_time
      then Error `Incomplete
      else aux true @@ continue (`String s) Complete (* avoid the CFWS token *)
    | Done (_, v) -> Ok v
  in

  aux false @@ parse ~input:(`String s) Angstrom.(Rfc2045.content <* option () Rfc822.cfws <* Rfc822.crlf <* commit)

  (* XXX(dinosaure): the last CFWS was due to: 'Content-Type: CFWS content-value
                     CFWS CRLF'. the [content] handles the CFWS token inside the
                     Content-Type's value but not in the field value (as we can
                     find in RFC2045). with this, we can put a comment after the
                     Content-Type's value. Otherwise, we expect directly the
                     CRLF line-break without any comment.
   *)

let of_string s = of_string_with_crlf (s ^ "\r\n")

let of_string_raw s off len =
  let s = String.sub s off len in

  let rec aux second_time = function
    | Fail (_, path, err) -> Error (`Invalid (err, path))
    | Partial {  continue; _ } ->
      if second_time
      then Error `Incomplete
      else aux true @@ continue (`String s) Complete (* avoid the CFWS token *)
    | Done (committed, v) -> Ok (v, committed)
  in

  aux false @@ parse ~input:(`String s) Angstrom.(Rfc2045.content <* option () Rfc822.cfws <* Rfc822.crlf <* commit)
