method get_type.

  field-symbols
  : <ld_s__dimn> type zbd00_s_dimn
  .

  read table gd_t__dimensions
       with table key dimension = dimension
                      attribute = attribute
                      assigning <ld_s__dimn>.

  if sy-subrc = 0.
    e_type = <ld_s__dimn>-type.
  else.
    clear e_type.
  endif.

endmethod.
