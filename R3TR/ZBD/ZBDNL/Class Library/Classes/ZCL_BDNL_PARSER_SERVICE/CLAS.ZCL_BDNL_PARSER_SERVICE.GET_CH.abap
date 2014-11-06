method GET_CH.

  data
  : ld_s__bindparam     type abap_parmbind
  .

  field-symbols
  : <data> type any
  .

  free e_s__function.

  e_s__function-func_name = `GET_CH`.

  ld_s__bindparam-kind = cl_abap_classdescr=>importing.
  ld_s__bindparam-name   = `E`.
  ld_s__bindparam-value  = i_r__data.
  insert ld_s__bindparam into table e_s__function-bindparam.

  ld_s__bindparam-kind  = cl_abap_classdescr=>exporting.
  ld_s__bindparam-name  = `I01`.
  get reference of  i_o__obj into ld_s__bindparam-value.
  insert ld_s__bindparam into table e_s__function-bindparam.

  ld_s__bindparam-kind  = cl_abap_classdescr=>exporting.
  ld_s__bindparam-name  = `I02`.
  create data ld_s__bindparam-value type uj_dim_name.
  assign ld_s__bindparam-value->* to <data>.
  <data>  = i_v__dim.
  insert ld_s__bindparam into table e_s__function-bindparam.


  ld_s__bindparam-kind  = cl_abap_classdescr=>exporting.
  ld_s__bindparam-name  = `I03`.
  create data ld_s__bindparam-value type uj_dim_name.
  assign ld_s__bindparam-value->* to <data>.
  <data>  = i_v__attr.
  insert ld_s__bindparam into table e_s__function-bindparam.

endmethod.
