method check_type.

  read table cd_t__stack
      with table key type = type

      transporting no fields.

  if sy-subrc = 0.
    check = abap_true.
  else.
    check = abap_false.
  endif.

endmethod.
