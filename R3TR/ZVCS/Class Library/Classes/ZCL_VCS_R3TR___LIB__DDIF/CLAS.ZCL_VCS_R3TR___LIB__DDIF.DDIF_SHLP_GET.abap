method DDIF_SHLP_GET.

  call function 'DDIF_SHLP_GET'
    exporting
      name          = name
      state         = state
      langu         = langu
    importing
      gotstate      = gotstate
      dd30v_wa      = dd30v_wa
    tables
      dd31v_tab     = dd31v_tab
      dd32p_tab     = dd32p_tab
      dd33v_tab     = dd33v_tab
    exceptions
      illegal_input = 1
      others        = 2.

  if gotstate is initial.
    sy-subrc = 2.
  endif.

  mac__module_raise ddif_shlp_get
  : 1 illegal_input
  , 2 not_existing
  , 3 others
  .

endmethod.
