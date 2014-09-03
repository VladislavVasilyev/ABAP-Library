method ddif_tabl_put.

  call function 'DDIF_TABL_PUT'
    exporting
      name              = name
      dd02v_wa          = dd02v_wa
      dd09l_wa          = dd09l_wa
    tables
      dd03p_tab         = dd03p_tab
      dd05m_tab         = dd05m_tab
      dd08v_tab         = dd08v_tab
      dd35v_tab         = dd35v_tab
      dd36m_tab         = dd36m_tab
    exceptions
      tabl_not_found    = 1
      name_inconsistent = 2
      tabl_inconsistent = 3
      put_failure       = 4
      put_refused       = 5
      others            = 6.

  mac__module_raise ddif_tabl_put
  : 1 tabl_not_found
  , 2 name_inconsistent
  , 3 tabl_inconsistent
  , 4 put_failure
  , 5 put_refused
  , 6 others.

endmethod.
