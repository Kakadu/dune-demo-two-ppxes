### Demo about PPX that generated input for another PPX

```
opam pin add ppx_sexp_conv --dev-repo
make
```

In this demo we want to link to PPX rewriters together: `first/first.ml`
which annotates all types with `[@@deriving sexp]` and `ppx_sexp_conv`.
The problem is that two rewriters doesn't apply one after another without
special options. For example, let's process file `hello/hello_world.ml`.

Original file:

```ocaml
let () = print_endline "asdfasdfa"

type t = Int

let x = sexp_of_asdf
```

After `dune exec first/pp_combined.exe -- hello/hello_world.ml` only `first`
is applied

```ocaml
let () = print_endline "asdfasdfa"
type asdf =
  | Int [@@deriving sexp]
let x = sexp_of_asdf
```

No changes after `dune exec first/pp_combined.exe -- hello/hello_world.ml -apply first,deriving`

```ocaml
let () = print_endline "asdfasdfa"
type asdf =
  | Int [@@deriving sexp]
let x = sexp_of_asdf
```

To run both rewriters with should pass `-no-merge` switch

`dune exec first/pp_combined.exe -- hello/hello_world.ml -apply first,deriving -no-merge -pretty`

```ocaml
let () = print_endline "asdfasdfa"
type asdf =
  | Int [@@deriving sexp]
let asdf_of_sexp =
  (let _tp_loc = "hello/hello_world.ml.asdf" in
   function
   | Ppx_sexp_conv_lib.Sexp.Atom ("int"|"Int") -> Int
   | Ppx_sexp_conv_lib.Sexp.List ((Ppx_sexp_conv_lib.Sexp.Atom
       ("int"|"Int"))::_) as sexp ->
       Ppx_sexp_conv_lib.Conv_error.stag_no_args _tp_loc sexp
   | Ppx_sexp_conv_lib.Sexp.List ((Ppx_sexp_conv_lib.Sexp.List _)::_) as sexp
       -> Ppx_sexp_conv_lib.Conv_error.nested_list_invalid_sum _tp_loc sexp
   | Ppx_sexp_conv_lib.Sexp.List [] as sexp ->
       Ppx_sexp_conv_lib.Conv_error.empty_list_invalid_sum _tp_loc sexp
   | sexp -> Ppx_sexp_conv_lib.Conv_error.unexpected_stag _tp_loc sexp :
  Ppx_sexp_conv_lib.Sexp.t -> asdf)
let sexp_of_asdf =
  (function | Int -> Ppx_sexp_conv_lib.Sexp.Atom "Int" : asdf ->
                                                           Ppx_sexp_conv_lib.Sexp.t)
let x = sexp_of_asdf
```

We have a solution for running rewriter manually but there is still a problem with
running rewriters automatically. For example, it's not obvious what should be
written in `hello/dune` to apply both transformations for `hello/hello_world.ml`.
Any ideas?
