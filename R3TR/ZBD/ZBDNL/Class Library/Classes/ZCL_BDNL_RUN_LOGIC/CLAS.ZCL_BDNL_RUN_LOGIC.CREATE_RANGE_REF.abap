method create_range_ref.

  data
  : ld_t__components        type abap_component_tab
  , ld_s__components        type abap_componentdescr
  , lr_o__handle            type ref to cl_abap_structdescr
  , lr_s__struct            type ref to data
  .

  field-symbols
  : <struct>                type any
  .

  ld_s__components-name = `SIGN`.
  ld_s__components-type = cl_abap_elemdescr=>get_c( 1 ).
  append ld_s__components to ld_t__components.

  ld_s__components-name = `OPTION`.
  ld_s__components-type = cl_abap_elemdescr=>get_c( 2 ).
  append ld_s__components to ld_t__components.

  if type is supplied.
    ld_s__components-name = `LOW`.
    ld_s__components-type ?= cl_abap_elemdescr=>describe_by_name( type ).
    append ld_s__components to ld_t__components.

    ld_s__components-name = `HIGH`.
    ld_s__components-type ?= cl_abap_elemdescr=>describe_by_name( type ).
    append ld_s__components to ld_t__components.
  elseif i_ref is supplied.
    ld_s__components-name = `LOW`.
    ld_s__components-type ?= cl_abap_elemdescr=>describe_by_data_ref( i_ref ).
    append ld_s__components to ld_t__components.

    ld_s__components-name = `HIGH`.
    ld_s__components-type ?= cl_abap_elemdescr=>describe_by_data_ref( i_ref ).
    append ld_s__components to ld_t__components.
  endif.

  lr_o__handle = cl_abap_structdescr=>create( p_components =  ld_t__components
                                               p_strict     = abap_false ).

  create data lr_s__struct type handle lr_o__handle.

  assign lr_s__struct->* to <struct>.

  create data ref like standard table of <struct> with non-unique default key.

endmethod.
