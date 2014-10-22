method create_line.

  data
      : lt_appl_comp         type abap_component_tab
      , lt_tech_comp         type abap_component_tab
      , ls_comp         type abap_componentdescr
      .

  field-symbols
      : <gs_key>        like line of gd_t__key_list
      , <ls_dimensions> type line of ty_s_key_list-dimensions
      .

  read table gd_t__key_list index 1
       assigning <gs_key>.

  loop at <gs_key>-dimensions
       assigning <ls_dimensions>.
    ls_comp-type = <ls_dimensions>-ty_elem.
    ls_comp-name = <ls_dimensions>-tech_alias.
    append ls_comp to lt_tech_comp.

    check gd_f__write_on = abap_true.
    ls_comp-name = <ls_dimensions>-dimension.
    append ls_comp to lt_appl_comp.
  endloop.

  gd_s__handle-st-tech_name = cl_abap_structdescr=>create( p_components = lt_tech_comp
                                                           p_strict     = abap_false ).

  call function 'ZBD00_DATA_WRAP'
    exporting
      i_t_data         = gd_s__handle-st-tech_name->components
      i_unicode_result = rs_c_true
    importing
      e_outdata_uc     = gd_v__comp_uc.

  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.



  field-symbols <ld_s__components> type abap_compdescr.
  data ld_v_comp type abap_keydescr.
  loop at gd_s__handle-st-tech_name->components
      assigning <ld_s__components>.

    ld_v_comp = <ld_s__components>-name.
    append ld_v_comp to gd_t__components.
  endloop.

  check gd_f__write_on = abap_true.
  gd_s__handle-st-appl_name = cl_abap_structdescr=>create( p_components = lt_appl_comp
                                                           p_strict     = abap_false ).


endmethod.
