method GET_DTELNM.

  data
  : ls_dimension type line of ty_t_dim_list
  .

  field-symbols
  : <lt_dimension> type zcl_bd00_model=>ty_t_dim_list
  , <ls_dimension> type line of zcl_bd00_model=>ty_t_dim_list
  , <result>       type any
  .

  assign gr_t__dimension->* to <lt_dimension>.

  ls_dimension-dimension = dimension.
  ls_dimension-attribute = attribute.

  read table <lt_dimension>
       from   ls_dimension
       assigning <ls_dimension>.

  check sy-subrc = 0.
  dtelnm = <ls_dimension>-dtelnm.

endmethod.
