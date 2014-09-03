method DDIF_DOMA_GET.

  call function 'DDIF_DOMA_GET'
    exporting
      name          = name
      state         = state
      langu         = langu
    importing
      gotstate      = gotstate
      dd01v_wa      = dd01v_wa
    tables
      dd07v_tab     = dd07v_tab
    exceptions
      illegal_input = 1
      others        = 2.

  if gotstate is initial.
    sy-subrc = 2.
  endif.

  mac__module_raise ddif_doma_get
  : 1 illegal_input
  , 2 not_existing
  , 3 others
  .

endmethod.
