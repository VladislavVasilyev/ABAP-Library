method GET_CODE_ADD_LINE.
  data
      : lt_code   type ty_t_string
      , lt_const  type zcl_bd00_appl_ctrl=>ty_t_const
      , ls_str    type string
      .

  field-symbols
      : <ls_const>  type zcl_bd00_appl_ctrl=>ty_s_const
      .


  mac__append_to_itab code
   :`method add.`
   ,` field-symbols <table>     type ty_table.`
   ,` assign        gr_table->* to   <table>.`
   .

*  lt_const = io_tg->get_const( io_line ) .

  if lt_const is initial.

*    case zcl_bd00_model=>type_relation( io_model = io_tg->go_model
*                                        io_fline = io_key->go_model ).
*      when zcl_bd00_model=>cs_eny_to_one.
*        mac__append_to_itab code
*          :` field-symbols <fline> type ty_fline.`
*          ,` assign go_fline->line->* to <fline>.`
*          ,` move-corresponding <fline> to ls_key.`
*          ,` read table <table> from ls_key reference into lr_result.`
*          ,` set_result( ir_result = lr_result ).`
*          ,` e_eod = abap_true.`
*          .
*      when zcl_bd00_model=>cs_eny_to_more_uk.
*        get_code_full_key( exporting name = `<fline>` io_model = io_tg->go_model importing code = lt_code  ).
*
*        mac__append_to_itab code
*          :` field-symbols <fline> type ty_fline.`
*          ,` assign go_fline->line->* to <fline>.`
*          ,` if gv_index = 0.`
*          ,`  loop at <table> reference into lr_result`
*          ,`       where`
*          .
*
*        append lines of lt_code to code.
*
*        mac__append_to_itab code
*          :`   append lr_result to gt_result.`
*          ,`  endloop.`
*          ,` endif.`
*          ,` e_eod = next_line( ).`
*          .
*
*      when others.
*    endcase.

  else.
    mac__append_to_itab code
      :` field-symbols <line>    type ty_fline.`
      ,` assign go_line->line->* to <line>.`
      ,` move-corresponding <line> to ls_key.`
      .

    loop at lt_const
      assigning <ls_const>.
        concatenate `   ls_key-` <ls_const>-tg ` = ` ```` <ls_const>-const ```.`  into ls_str.
        append ls_str to code.
    endloop.




* begin of zbd0c_type_add_line
* , collect           type zbd00
* , insert            type zbd00
* , append            type zbd00
*
    mac__append_to_itab code
      :`   case mode.`
      ,`    when zbd0c_type_add_line-collect.`
      ,`     collect ls_key into <table>.`
      ,`    when zbd0c_type_add_line-insert.`
      ,`     insert ls_key into table <table>.`
      ,`    when zbd0c_type_add_line-append.`
      ,`     append ls_key to <table>.`
      ,`   endcase.`
      .

  endif.

  mac__append_to_itab code
   :`endmethod.`
   .

endmethod.
