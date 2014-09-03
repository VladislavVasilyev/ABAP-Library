method check_dimension.

  read table gd_t__dimensions
       with table key dimension = dimension
                      attribute = attribute
                      transporting no fields.

  if sy-subrc = 0.
    e = abap_true.
  else.
    e = abap_false.
  endif.

endmethod.
