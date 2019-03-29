module Label : sig
  type t = string

  val compare : string -> string -> int
end

module Map : module type of Map.Make(Label)
module Set : module type of Set.Make(Label)

val iana   : Set.t Map.t
