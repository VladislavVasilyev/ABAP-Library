method GET_FILTER.

  clear
  : et_filter_tab
  , e_filter_str.

  data: lo_manager            type ref to cl_ujd_selection_mgr,
        lo_manager_ms         type ref to cl_ujd_selection_mgr, " for member selection
        lt_tab                type string_table,
        l_dimstr              type string,
        l_memstr              type string,
        lt_tabnew             type string_table,
        ls_tabnew             type string,
        l_new_selection       type string.

  field-symbols:
                 <ls_tab>     type string.

  lo_manager = cl_ujd_selection_mgr=>get_selection( if_filter_all = abap_false ).

  " RUN LOGIC/OWNERSHIP CALC FOR INTERNAL TABLE
  lo_manager->get_single_select_tb( exporting i_selection = i_selection
                                    importing et_member_list = et_filter_tab
                                   ).

  if i_memberselection is not initial.

    lo_manager_ms = cl_ujd_selection_mgr=>get_selection( if_filter_all = abap_false if_one_dimension = abap_true ).

    split i_memberselection at gd_s__badi_param-splitter into table lt_tab.

    loop at lt_tab assigning <ls_tab>.
      " RUN LOGIC FOR STRING
      split <ls_tab> at gd_s__badi_param-equal into l_dimstr l_memstr.
      lo_manager_ms->get_member_list_str( exporting i_selection = l_memstr
                                          importing e_selection = l_new_selection ).
      concatenate l_dimstr gd_s__badi_param-equal l_new_selection into ls_tabnew.
*      ls_tabnew = l_new_selection.
      append ls_tabnew to lt_tabnew.
    endloop.

    concatenate lines of lt_tabnew into e_filter_str separated by gd_s__badi_param-splitter.
  endif.

endmethod.
