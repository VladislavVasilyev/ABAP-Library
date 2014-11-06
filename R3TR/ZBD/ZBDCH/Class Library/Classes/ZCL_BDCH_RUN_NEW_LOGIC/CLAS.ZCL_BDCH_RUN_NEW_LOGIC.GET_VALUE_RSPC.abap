method get_value_rspc.

  data
  : ld_v__value type string
  , ld_v__len   type i
  , ld_v__para  type ujd_runparam-param_name
  .

  find regex `\%[A-Z\_]+\%` in i_v__value.

  if sy-subrc = 0.
    ld_v__value    = i_v__value+1.
    ld_v__len      = strlen( ld_v__value ) - 1.
    ld_v__value    = ld_v__value(ld_v__len).

    try .
        ld_v__para = ld_v__value.
        call method do_config->if_ujd_config~get_parameter
          exporting
            i_parameter       = ld_v__para
          importing
            e_parameter_value = ld_v__value.
      catch cx_ujd_datamgr_error cx_uj_db_error.
        ld_v__value = i_v__value.
    endtry.
  else.
    ld_v__value = i_v__value.
  endif.

  find regex `\$[A-Z\_]+\$` in ld_v__value.

  if sy-subrc = 0.
    ld_v__value    = ld_v__value+1.
    ld_v__len      = strlen( ld_v__value ) - 1.
    ld_v__value    = ld_v__value(ld_v__len).

    select single low
      from tvarvc
      into ld_v__value
      where name = ld_v__value
        and type = `P`
        and numb = space.
  endif.

  e_v__value = ld_v__value.

endmethod.
