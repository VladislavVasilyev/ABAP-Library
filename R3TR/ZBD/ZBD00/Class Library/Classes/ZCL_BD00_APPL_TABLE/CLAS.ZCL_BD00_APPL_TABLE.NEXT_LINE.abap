method next_line.

  data
  : ld_s__class_reg type ty_s_class_reg
  , ld_v__id        type zbd0t_id_rules
  .

  ld_v__id = id.

  if id is not supplied.
    ld_v__id = gd_v__default_rule.
  endif.

  raise event ev_read_data_after_rfc_call.

  if gd_s__last_read-id ne ld_v__id.
    read table          gd_t__class_reg
         with table key id = ld_v__id
         into           gd_s__last_read.
  endif.

  e_st = gd_s__last_read-class->next(  ).

  raise event ev_change_line.

endmethod.
