open Base
open Ppxlib
open Ppxlib.Ast_builder.Default

let name = "first"

let () =
  Ppxlib.Driver.register_transformation
    ~impl:(fun ss ->
        let m = object(self)
          inherit Ast_traverse.map as super
          method! structure_item si =
            (* Format.printf "HERRR\n"; *)
            match si.pstr_desc with
            | Pstr_type (flg,tydecls) ->
                (* Format.printf "%s %d\n" __FILE__ __LINE__; *)
                let tds =
                  List.map tydecls
                    ~f:(fun tydecl ->
                        let loc = !Ast_helper.default_loc in
                        {tydecl with ptype_name = {tydecl.ptype_name with txt="asdf"}
                                   ; ptype_attributes =
                                    [ { attr_name = Located.mk ~loc "deriving"
                                      ; attr_loc = Location.none
                                      ; attr_payload = PStr [%str sexp]
                                      }]
                        }
                      )
                in
                { si with pstr_desc = Pstr_type (flg, tds)}

            | _ -> super#structure_item si
        end in
        m#structure ss
    )
    name
