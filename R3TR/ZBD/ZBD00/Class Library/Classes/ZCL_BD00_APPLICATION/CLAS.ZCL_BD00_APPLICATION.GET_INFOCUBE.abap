method get_infocube.

  field-symbols  <ls_reestr> like line of reestr.

  read table reestr
       assigning <ls_reestr>
       with key infocube = i_infocube.

  if sy-subrc = 0.
    e_obj = <ls_reestr>-obj.
  else.
    create object e_obj
      exporting
        i_infocube = i_infocube.
  endif.

endmethod.
