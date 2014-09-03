method get_dimension.

  field-symbols  <ls_reestr> like line of reestr.

  read table reestr
    assigning <ls_reestr>
    with key appset_id = i_appset_id
             appl_id   = i_dimension.

  if sy-subrc = 0.
    e_obj = <ls_reestr>-obj.
  else.
    create object e_obj
      exporting
        i_appset_id = i_appset_id
        i_dimension = i_dimension.
  endif.

endmethod.
