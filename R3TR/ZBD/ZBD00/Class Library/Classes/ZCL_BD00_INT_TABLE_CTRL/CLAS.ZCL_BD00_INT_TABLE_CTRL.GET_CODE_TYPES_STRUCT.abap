method get_code_types_struct.

  data
  : ls_code     type string
  , lv_type     type string
  .

  field-symbols
  : <ls_key> type zcl_bd00_model=>ty_s_key_list
  , <ls_dimension> type zcl_bd00_model=>ty_s_dim_list
  , <ls_code> type string
  .

  refresh code.

  read table io_model->gd_t__key_list
       assigning <ls_key>
       with key nkey = zcl_bd00_model=>cs_pk.

  append `types` to code.

  append `: begin of %n%` to code assigning <ls_code>.
  replace `%n%` into <ls_code> with name.

  loop at <ls_key>-dimensions
      assigning <ls_dimension>.

    move <ls_dimension>-dtelnm to lv_type.

    condense lv_type no-gaps.

    append `  , %n% type %t%` to code assigning <ls_code>.

    replace
    :`%n%` into <ls_code> with <ls_dimension>-tech_alias
    ,`%t%` into <ls_code> with lv_type
    .

    translate <ls_code> to lower case.
  endloop.

  append `, end of %n%.` to code assigning <ls_code>.
  replace `%n%` into <ls_code> with name.
endmethod.
