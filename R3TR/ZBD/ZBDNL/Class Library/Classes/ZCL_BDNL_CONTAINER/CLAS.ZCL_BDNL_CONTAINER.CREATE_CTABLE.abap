method create_ctable.

  if gd_f__init = abap_true.
    " сбросить индекс
    gr_o__container->reset_index( ).
    e_f__create = abap_true. " для логирования
    return.
  endif.

  if gr_o__container is bound.
    gr_o__container->clear( ).
  endif.

  if gd_s__param-appl_id = zblnc_keyword-custom.


  else.
    create object gr_o__container
      exporting
        i_appset_id = gd_s__param-appset_id
        i_appl_id   = gd_s__param-appl_id
        i_type_pk   = gd_s__param-tech_type_table
        it_dim_list = gd_s__param-dim_list
        it_const    = gd_s__param-const.
  endif.

  gd_f__init = abap_true.
  e_f__create = abap_true.

*  else.
*    e_f__create = abap_false.
*    e_o__table = gr_o__container.
*  endif.

endmethod.
