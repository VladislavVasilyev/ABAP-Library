method set_line.
   gd_v__index         = i_index.

  if if_copy      = abap_false.
    line          = i_line.
    f_ref_line    = abap_true.
  else.
    field-symbols
    : <line> type any
    , <cline>  type any
    .

    assign
    : i_line->* to <line>
    , cline->*  to <cline>
    .

    move-corresponding <line> to <cline>.
    line   = cline.
    f_ref_line = abap_false.
  endif.
  raise event ev_change_line.
endmethod.
