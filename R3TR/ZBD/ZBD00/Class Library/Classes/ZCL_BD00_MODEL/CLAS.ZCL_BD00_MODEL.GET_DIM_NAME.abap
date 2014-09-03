method GET_DIM_NAME.

  field-symbols
  : <lt_dimension> type zcl_bd00_model=>ty_t_dim_list
  , <ls_dimension> type line of zcl_bd00_model=>ty_t_dim_list
  .

  assign gr_t__dimension->* to <lt_dimension>.

  read table <lt_dimension>
       with key   tech_alias = tech_alias
       assigning <ls_dimension>.

  check sy-subrc = 0.
  dim_name-dimension = <ls_dimension>-dimension.
  dim_name-attribute = <ls_dimension>-attribute.

endmethod.
