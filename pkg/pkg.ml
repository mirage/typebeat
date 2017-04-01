#!/usr/bin/env ocaml
#use       "topfind";;
#require   "topkg";;

open Topkg

let () =
  Pkg.describe "type-beat" @@ fun c ->

  Ok [ Pkg.lib "pkg/META"
     ; Pkg.doc "README.md"
     ; Pkg.doc "CHANGES.md"
     ; Pkg.lib ~exts:Exts.module_library "lib/typeBeat"
     ; Pkg.test "test/test" ]
