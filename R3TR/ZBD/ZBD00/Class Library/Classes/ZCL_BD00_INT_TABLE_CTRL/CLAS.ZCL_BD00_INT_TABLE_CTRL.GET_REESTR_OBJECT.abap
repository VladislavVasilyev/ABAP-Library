method get_reestr_object.

  data
  : ls_reestr_object type ty_s_object_reestr
  , lt_code          type ty_t_string
  , ls_definition    type ty_s_definition
  , cnt              type i value 0
  , l_index          type zcl_bd00_int_table=>var_index
  , lo_object        type ref to zcl_bd00_appl_ctrl
  .

  field-symbols
  : <ls_cust_link>   type zcl_bd00_appl_ctrl=>ty_s_cust_link
  .

*╔═══════════════════════════════════════════════════════════════════╗
  clear cnt.
  ls_reestr_object-object ?= it_link-main.
  ls_reestr_object-id      = cnt.
  l_index = `0`.
  concatenate `gr_o__` l_index into ls_reestr_object-name.

  ls_reestr_object-definition = get_definition( i_index = l_index
                                                io_model = it_link-main->gr_o__model ).

  insert ls_reestr_object into table et_reestr_object.
  clear ls_reestr_object.
*╚═══════════════════════════════════════════════════════════════════╝

*╔═══════════════════════════════════════════════════════════════════╗
  if it_link-rule_link is not initial.
    loop at it_link-rule_link
      assigning <ls_cust_link>
        where object is bound or
              data   is bound.

      if <ls_cust_link>-object is bound.
        move <ls_cust_link>-object ?to lo_object.

        read table et_reestr_object
             with key object = lo_object
             transporting no fields.

        check sy-subrc <> 0.

        add 1 to cnt.
        ls_reestr_object-id      = cnt.
        l_index = cnt.

        concatenate `gr_o__` l_index into ls_reestr_object-name.

        ls_reestr_object-object ?= <ls_cust_link>-object.
        ls_reestr_object-definition = get_definition( i_index  = l_index
                                                      io_model = lo_object->gr_o__model ).

      elseif <ls_cust_link>-data is bound.
        read table et_reestr_object
             with key data = <ls_cust_link>-data
             transporting no fields.

        check sy-subrc <> 0.

        add 1 to cnt.
        ls_reestr_object-id      = cnt.
        l_index = cnt.

        concatenate `gr_v__` l_index into ls_reestr_object-name.
        ls_reestr_object-data ?= <ls_cust_link>-data.
        ls_reestr_object-definition = get_definition( i_index  = l_index
                                                      ir_data  = <ls_cust_link>-data ).
      endif.

      insert ls_reestr_object into table et_reestr_object.
      clear ls_reestr_object.
    endloop.
  endif.
*╚═══════════════════════════════════════════════════════════════════╝
endmethod.
