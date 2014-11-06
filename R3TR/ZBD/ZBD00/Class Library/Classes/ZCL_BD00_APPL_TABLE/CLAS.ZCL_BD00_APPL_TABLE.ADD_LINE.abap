method add_line.
*  data
*     : f_change_class type rs_bool value abap_true
*     , ls_class_reg   like line of gd_t__class_reg
*     , ls_signature   type ty_signature
*     .

*  ls_signature-type = zcl_bd00_int_table=>method-add.
*  ls_signature-object = io_line.
*
*  if gr_s__last_add is bound.
*    if gr_s__last_add->signature = ls_signature.
*      f_change_class          = abap_false.
*    endif.
*  endif.
*
*  if f_change_class = abap_true.
*    read table       gt_class_reg
*      with table key signature = ls_signature
*      reference into gr_s__last_add.
*
*    if sy-subrc <> 0 .
*      ls_class_reg-signature = ls_signature.
*      ls_class_reg-class     = zcl_bd00_int_table=>create_add( io_tg = me io_line = io_line ).
*      insert ls_class_reg into table gt_class_reg reference into gr_s__last_add.
*    endif.
*  endif.
*
*  gr_s__last_add->class->add( mode ).
*  go_line = gr_s__last_add->class->go_line.

endmethod.
