method check_dim.

  data
  : ld_s__reestr type ty_s__reestr
  , ld_v__string type string
  .

  field-symbols
  : <ld_s__reestr> type ty_s__reestr
  .

  ld_s__reestr-tablename = tablename.
  ld_s__reestr-script    = cd_v__current_script .


  read table cd_t__table_reestr from ld_s__reestr  assigning <ld_s__reestr>.

  if sy-subrc <> 0.
    raise exception type zcx_bdnl_syntax_error
            exporting textid = zcx_bdnl_syntax_error=>zcx_table_not_defined
                      token  = tablename
                      index  = zcl_bdnl_parser=>cr_o__cursor->gd_v__cindex .
  else.
    e_s__param = <ld_s__reestr>-container->gd_s__param.
  endif.

  if dimension is not initial and attribute is not initial.
    "check dimension and attribute
    read table e_s__param-dimension
         with key dimension = dimension
                  attribute = attribute
                  transporting no fields.

    if sy-subrc ne 0.
      concatenate dimension `~` attribute into ld_v__string.
      raise exception type zcx_bdnl_syntax_error
            exporting textid = zcx_bdnl_syntax_error=>zcx_no_component_exists
                      token  = ld_v__string
                      tablename = tablename
                      index  = zcl_bdnl_parser=>cr_o__cursor->gd_v__cindex  .
    endif.
  elseif dimension is not initial.
    read table e_s__param-dimension
         with key dimension = dimension
                  attribute = space
                  transporting no fields.

    if sy-subrc ne 0.
      ld_v__string = dimension.
      raise exception type zcx_bdnl_syntax_error
            exporting textid = zcx_bdnl_syntax_error=>zcx_no_component_exists
                      token  = ld_v__string
                      tablename = tablename
                      index = zcl_bdnl_parser=>cr_o__cursor->gd_v__cindex  .
    endif.

  endif.

endmethod.
