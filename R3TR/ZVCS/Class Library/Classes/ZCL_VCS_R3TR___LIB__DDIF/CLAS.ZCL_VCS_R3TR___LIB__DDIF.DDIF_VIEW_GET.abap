method DDIF_VIEW_GET.

  call function 'DDIF_VIEW_GET'
    exporting
      name          = name
      state         = state
      langu         = langu
    importing
      gotstate      = gotstate
      dd25v_wa      = dd25v_wa
      dd09l_wa      = dd09l_wa
    tables
      dd26v_tab     = dd26v_tab
      dd27p_tab     = dd27p_tab
      dd28j_tab     = dd28j_tab
      dd28v_tab     = dd28v_tab
    exceptions
      illegal_input = 1
      others        = 2.

  if gotstate is initial.
    sy-subrc = 2.
  endif.

  mac__module_raise ddif_view_get
  : 1 illegal_input
  , 2 not_existing
  , 3 others
  .



endmethod.
