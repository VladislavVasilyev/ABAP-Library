method next_line.

  data
  : lr_result   type ref to data
  .

  field-symbols
  : <lr_result> type ref to data
  .

  add_index( ).

  read table gt_result index gv_index
       reference into lr_result.

  if sy-subrc = 0.
    assign lr_result->* to <lr_result>.
    set_result( ir_result = <lr_result> ).
    e_st = zbd0c_found.
  else.
    check lines( gt_result ) < gv_index.
    call method clear_index.
    clear gt_result.
    e_st = zbd0c_not_found.
  endif.

endmethod.
