method DDIF_TABL_GET.

  call function 'DDIF_TABL_GET'
    exporting
      name          = name
      state         = state
      langu         = langu
    importing
      gotstate      = gotstate
      dd02v_wa      = dd02v_wa
      dd09l_wa      = dd09l_wa
    tables
      dd03p_tab     = dd03p_tab
      dd05m_tab     = dd05m_tab
      dd08v_tab     = dd08v_tab
      dd12v_tab     = dd12v_tab
      dd17v_tab     = dd17v_tab
      dd35v_tab     = dd35v_tab
      dd36m_tab     = dd36m_tab
    exceptions
      illegal_input = 1
      others        = 3.

  if gotstate is initial.
    sy-subrc = 2.
  endif.

  mac__module_raise ddif_tabl_get
  : 1 illegal_input
  , 2 not_existing
  , 3 others
  .

endmethod.
