method create_global_td.
  data
  : lt_types               type ty_t_string
  , lt_types_tab           type ty_t_string
  , lt_global_data         type ty_t_string
  .

  field-symbols
  : <ls_object_reestr>     type ty_s_object_reestr
  , <ls_definition>        type ty_s_definition
  .

  loop at it_object_reestr
     assigning <ls_object_reestr>.

    if sy-tabix = 1.
      read table     <ls_object_reestr>-definition
           with key   id = id_code-type_tab
           assigning <ls_definition>.

      append lines of <ls_definition>-code to lt_types_tab.
    endif.

    read table     <ls_object_reestr>-definition
         with key   id = id_code-type
         assigning <ls_definition>.

    append lines of <ls_definition>-code to lt_types.

    read table <ls_object_reestr>-definition
         with key id = id_code-global_reference
         assigning <ls_definition>.

    append lines of <ls_definition>-code to lt_global_data.

  endloop.

  append lines of lt_types                          to et_code.
  append ` `                                        to et_code.
  append lines of lt_types_tab                      to et_code.
  append ` `                                        to et_code.
  append lines of lt_global_data                    to et_code.
  append ` `                                        to et_code.
  append `data gt_range type zbd0t_ty_t_range_kf.`  to et_code.
  append ` `                                        to et_code.

endmethod.
