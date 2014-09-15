method set_context.

  data
  : lo_uj_context type ref to if_uj_context
  , lo_context    type ref to zcl_bd00_context
  .

  gv_appset_id = i_appset_id.
  gv_appl_id   = i_appl_id.
  gd_s__user_id   = i_s__user.

  if i_appset_id is not supplied and i_appl_id is not supplied.
    lo_uj_context ?= cl_uj_context=>get_cur_context( ).

    if lo_uj_context is bound.
*      create object lo_context
*        exporting
*          i_appset_id = lo_uj_context->d_appset_id
*          i_appl_id   = lo_uj_context->d_appl_id.
    endif.
    return.
  endif.

*  create object lo_context
*    exporting
*      i_appset_id = i_appset_id
*      i_appl_id   = i_appl_id.

endmethod.
