method ddif_view_put.

  call function 'DDIF_VIEW_PUT'
    exporting
      name              = name
      dd25v_wa          = dd25v_wa
      dd09l_wa          = dd09l_wa
    tables
      dd26v_tab         = dd26v_tab
      dd27p_tab         = dd27p_tab
      dd28j_tab         = dd28j_tab
      dd28v_tab         = dd28v_tab
    exceptions
      view_not_found    = 1
      name_inconsistent = 2
      view_inconsistent = 3
      put_failure       = 4
      put_refused       = 5
      others            = 6.

  mac__module_raise ddif_view_put
  : 1  view_not_found
  , 2  name_inconsistent
  , 3  view_inconsistent
  , 4  put_failure
  , 5  put_refused
  , 6  others.

endmethod.
