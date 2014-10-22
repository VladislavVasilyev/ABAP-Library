method create_tablefordown.

*  if gd_f__init ne abap_true.

  if gr_o__container is bound.
    gr_o__container->clear( ).
  endif.

  create object gr_o__container
    exporting
      i_appset_id  = gd_s__param-appset_id
      i_appl_id    = gd_s__param-appl_id
      i_type_pk    = zbd0c_ty_tab-has_unique_dk
      it_const     = gd_s__param-const
      if_auto_save = abap_true.

  gd_f__init = abap_true.
  e_f__create = abap_true.

*  else.
*    e_f__create = abap_false.
*    e_o__table = gr_o__container.
*  endif.

endmethod.
