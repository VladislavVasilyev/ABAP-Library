method CLASS_CONSTRUCTOR.
data
     : list_user type standard table of string
     .
  on = abap_false.

  select low
    from tvarvc
    into table list_user
    where     name = zcons_bw_debug_user
          and low  = sy-uname.

  if sy-subrc = 0.
    on = abap_true.
  endif.
endmethod.
