method create_local_td.

  data
  : lt_type_st             type ty_t_string
  , lt_type_tab            type ty_t_string
  , lt_ref_st              type ty_t_string
  , lt_ref_tab             type ty_t_string
  , lt_object              type ty_t_string
  , ls_object              type string
  .

  field-symbols
  : <ls_object_reestr>     type ty_s_object_reestr
  , <ls_definition>        type ty_s_definition
  .

  loop at it_object_reestr
    assigning <ls_object_reestr>.

    if it_rule_link-main = <ls_object_reestr>-object.

      read table <ls_object_reestr>-definition
           with key id = id_code-field_tab
           assigning <ls_definition>.

      append lines of <ls_definition>-code to et_field_symbols.

      read table <ls_object_reestr>-definition
          with key id = id_code-assign_tab
          assigning <ls_definition>.

      append lines of <ls_definition>-code to et_assign_symbols.

      case it_rule_link-type.
        when method-assign.
          case i_mode_add .
            when zbd0c_mode_add_line-change.
              read table <ls_object_reestr>-definition
                   with key id = id_code-field_st
                   assigning <ls_definition>.

              append lines of <ls_definition>-code to et_field_symbols.

              read table <ls_object_reestr>-definition
                   with key id = id_code-assign_st
                   assigning <ls_definition>.

              append lines of <ls_definition>-code to et_assign_symbols.
            when others.
              read table <ls_object_reestr>-definition
                   with key id = id_code-field_cst
                   assigning <ls_definition>.

              append lines of <ls_definition>-code to et_field_symbols.

              read table <ls_object_reestr>-definition
                   with key id = id_code-assign_cst
                   assigning <ls_definition>.

              append lines of <ls_definition>-code to et_assign_symbols.
          endcase.

          if it_rule_link-main = it_rule_link-default.
            read table <ls_object_reestr>-definition
                 with key id = id_code-field_st
                 assigning <ls_definition>.

            append lines of <ls_definition>-code to et_field_symbols.

            read table <ls_object_reestr>-definition
                 with key id = id_code-assign_st
                 assigning <ls_definition>.

            append lines of <ls_definition>-code to et_assign_symbols.
          endif.

          continue.
      endcase.
    endif.

    read table <ls_object_reestr>-definition
         with key id = id_code-field_st
         assigning <ls_definition>.

    append lines of <ls_definition>-code to et_field_symbols.

    read table <ls_object_reestr>-definition
      with key id = id_code-assign_st
      assigning <ls_definition>.

    append lines of <ls_definition>-code to et_assign_symbols.

  endloop.

endmethod.
