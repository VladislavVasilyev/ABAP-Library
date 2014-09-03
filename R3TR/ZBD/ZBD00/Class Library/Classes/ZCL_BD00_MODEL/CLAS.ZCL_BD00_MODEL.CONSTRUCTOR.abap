method constructor.
  data lv_appset_id type uj_appset_id.
  data lv_appl_id   type uj_appl_id.

  if i_appset_id is supplied and i_appl_id is supplied.
    if i_appset_id is initial.
      lv_appset_id = zcl_bd00_context=>gv_appset_id.
    else.
      lv_appset_id = i_appset_id.
    endif.

    if i_appl_id is initial.
      lv_appl_id = zcl_bd00_context=>gv_appl_id.
    else.
      lv_appl_id = i_appl_id.
    endif.

    gr_o__application =  zcl_bd00_application=>get_application( i_appset_id = lv_appset_id i_appl_id = lv_appl_id ).
    return.
  endif.

  if i_appset_id is supplied and i_dimension is supplied.
    gr_o__application =  zcl_bd00_application=>get_dimension( i_appset_id = i_appset_id i_dimension = i_dimension ).
    return.
  endif.

  if i_appset_id is supplied and i_appl_id is not supplied.
    gr_o__application =  zcl_bd00_application=>get_customize_application( i_appset_id = i_appset_id ).
    return.
  endif.


  if i_infocube is supplied.
    gr_o__application =  zcl_bd00_application=>get_infocube( i_infocube ).
    return.
  endif.

endmethod.
