method SET_CH.

  data
  : ls_dimension    type line of zcl_bd00_model=>ty_t_dim_list
  .

  field-symbols
  : <lt_dimension>  type zcl_bd00_model=>ty_t_dim_list
  , <ls_dimension>  type zcl_bd00_model=>ty_s_dim_list
  , <result>        type any
  .

  assign gr_o__model->gr_t__dimension->* to <lt_dimension>.

  ls_dimension-dimension = dimension.
  ls_dimension-attribute = attribute.

  translate
  : ls_dimension-dimension to upper case
  , ls_dimension-attribute to upper case
  .

  read table     <lt_dimension>
       from      ls_dimension
       assigning <ls_dimension>.

  assign gr_o__line->line->(<ls_dimension>-tech_alias) to <result>.

  check <result> is assigned.

  <result> = value.

endmethod.
