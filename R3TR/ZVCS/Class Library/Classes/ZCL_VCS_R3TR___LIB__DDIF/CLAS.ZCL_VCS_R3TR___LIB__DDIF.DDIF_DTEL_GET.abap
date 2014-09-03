method DDIF_DTEL_GET.

  call function 'DDIF_DTEL_GET'
    exporting
      name          = name
      state         = state
      langu         = langu
    importing
      gotstate      = gotstate
      dd04v_wa      = dd04v_wa
      tpara_wa      = tpara_wa
    exceptions
      illegal_input = 1
      others        = 3.

  if gotstate is initial.
    sy-subrc = 2.
  endif.

  mac__module_raise ddif_dtel_get
  : 1 illegal_input
  , 2 not_existing
  , 3 others
  .

endmethod.
