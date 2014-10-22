method create_clear.

  if gd_f__init = abap_true.
    " сбросить индекс
    return.
  endif.

  create object gr_o__container
    exporting
      i_appset_id = gd_s__param-appset_id
      i_appl_id   = gd_s__param-appl_id
      i_type_pk   = zbd0c_ty_tab-has_unique_dk
      it_range    = gd_s__param-range
      if_invert   = abap_true.

  gd_f__init = abap_true.
  e_f__create = abap_true.

endmethod.
