method GET_STRUCT_REF.

  data
      : ls_dim_field  like line of it_dim_field
      , lt_components type abap_component_tab
      , ls_components type line of abap_component_tab
      , lo_struct     type ref to cl_abap_structdescr
      .

  loop at it_dim_field
    into ls_components-name.

    check ls_components-name <> ujr0_c_keyfigure.

    ls_components-type = cl_abap_elemdescr=>get_c( 20 ).

    append ls_components to lt_components.
  endloop.

  if if_kf = abap_true.
    ls_components-name = ujr0_c_keyfigure.
    ls_components-type ?= cl_abap_datadescr=>describe_by_name( 'UJ_SDATA' ).
    append ls_components to lt_components.
  endif.

  lo_struct ?= cl_abap_structdescr=>create( p_components = lt_components
                                      p_strict     = abap_false ).

  create data ref type handle  lo_struct.


endmethod.
