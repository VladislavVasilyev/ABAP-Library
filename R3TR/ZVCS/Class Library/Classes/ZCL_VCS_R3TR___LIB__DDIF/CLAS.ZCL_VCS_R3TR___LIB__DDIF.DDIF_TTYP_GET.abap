method DDIF_TTYP_GET.

  call function 'DDIF_TTYP_GET'
    exporting
      name          = name
      state         = state
      langu         = langu
    importing
      gotstate      = gotstate
      dd40v_wa      = dd40v_wa
    tables
      dd42v_tab     = dd42v_tab
    exceptions
      illegal_input = 1
      others        = 2.

  if gotstate is initial.
    sy-subrc = 2.
  endif.

  mac__module_raise ddif_ttyp_get
  : 1 illegal_input
  , 2 not_existing
  , 3 others
  .

endmethod.
