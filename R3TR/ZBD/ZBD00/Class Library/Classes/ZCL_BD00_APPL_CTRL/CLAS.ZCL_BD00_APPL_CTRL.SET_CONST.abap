method set_const.
*╔═══════════════════════════════════════════════════════════════════╗
*║ Установка суперконстант                                           ║
*╚═══════════════════════════════════════════════════════════════════╝
  data
  : ld_s__dimension   type zcl_bd00_model=>ty_s_dim_list
  , ld_s__const       type ty_s_const
  .

  field-symbols
  : <ls_const>        type zbd0t_ty_s_constant
  , <lt_dimension>    type zcl_bd00_model=>ty_t_dim_list
  , <ls_dimension>    type zcl_bd00_model=>ty_s_dim_list
  .

  loop at it_const
      assigning <ls_const>.

    ld_s__dimension-dimension = <ls_const>-dimension.
    ld_s__dimension-attribute = <ls_const>-attribute.

    assign gr_o__model->gr_t__dimension->* to <lt_dimension>.

    translate
    : ld_s__dimension-dimension to upper case
    , ld_s__dimension-attribute to upper case
    .

    read table     <lt_dimension>
       from         ld_s__dimension
       assigning   <ls_dimension>.

    check sy-subrc = 0.

    ld_s__const-tg  = <ls_dimension>-tech_alias.
    ld_s__const-const = <ls_const>-const.

    insert ld_s__const into table gd_t__const.
  endloop.

endmethod.
