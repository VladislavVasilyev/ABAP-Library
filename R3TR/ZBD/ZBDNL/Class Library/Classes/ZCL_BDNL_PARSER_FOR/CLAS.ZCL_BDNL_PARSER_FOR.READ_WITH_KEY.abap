method read_with_key.

  constants
  : cs_dimension      type string value `^(([A-Z0-9\_]+)\>|\/(CPMB)\/([A-Z0-9\_]+)\>)`
  , cs_dimwattr       type string value `^\~\<([A-Z0-9\_]+)\>`
  , cs_func           type string value `^([A-Z0-9\_]+)\>\s\(`
  .

  data
  : ld_s__custlink    type zbnlt_s__cust_link
  , ld_v__token       type string
*  , ld_s__container   type zbnlt_s__stack_container
  .

  clear e_t__custlink.

  while gr_o__cursor->gd_f__end ne abap_true.

    if gr_o__cursor->get_token( ) = zblnc_keyword-dot.
      exit.
    endif.

*    ld_s__container =
    zcl_bdnl_container=>check_table( i_v__tablename ).

    if gr_o__cursor->check_tokens( q = 1 regex = cs_dimension ) = abap_true.
      ld_s__custlink-tg-dimension = gr_o__cursor->get_token( esc = abap_true ).

      if gr_o__cursor->check_tokens( q = 2 regex = cs_dimwattr ) = abap_true.
        ld_s__custlink-tg-attribute = gr_o__cursor->get_token( esc = abap_true trn = 2 ).
      endif.

      call method zcl_bdnl_container=>check_dim
        exporting
          tablename = i_v__tablename
          dimension = ld_s__custlink-tg-dimension
          attribute = ld_s__custlink-tg-attribute.
    else.
      ld_v__token = gr_o__cursor->get_token( ).
      raise exception type zcx_bdnl_syntax_error
            exporting textid = zcx_bdnl_syntax_error=>zcx_unable_interpret
                      token  = ld_v__token
                      index  = gr_o__cursor->gd_v__index .
    endif.

    if gr_o__cursor->get_token( esc = abap_true ) = zblnc_keyword-equal.
      if gr_o__cursor->check_tokens( q = 2 regex = cs_func ) = abap_true. " Если функция
        call method zcl_bdnl_parser_service=>get_func
          exporting
            i_r__cursor   = gr_o__cursor
          importing
            e_v__funcname = ld_s__custlink-func_name
            e_t__param    = ld_s__custlink-param
            e_r__data     = ld_s__custlink-data.
      else.
        if gr_o__cursor->check_letter( ) = abap_true.
          ld_s__custlink-const = gr_o__cursor->get_token( esc = abap_true ).
        elseif gr_o__cursor->get_token(  ) = zblnc_keyword-cspace.
          ld_s__custlink-clear = abap_true.
          gr_o__cursor->get_token( esc = abap_true ).
        else.
          ld_s__custlink-tablename = gr_o__cursor->get_token( ).

*          ld_s__container =
          zcl_bdnl_container=>check_table( ld_s__custlink-tablename ).

          gr_o__cursor->get_token( esc = abap_true ).

          if gr_o__cursor->get_token( ) = zblnc_keyword-tilde.
            gr_o__cursor->get_token( esc = abap_true ).

            if gr_o__cursor->check_tokens( q = 1 regex = cs_dimension ) = abap_true.
              ld_s__custlink-sc-dimension = gr_o__cursor->get_token( esc = abap_true ).

              if gr_o__cursor->check_tokens( q = 2 regex = cs_dimwattr ) = abap_true.
                ld_s__custlink-sc-attribute = gr_o__cursor->get_token( esc = abap_true trn = 2 ).
              endif.

              call method zcl_bdnl_container=>check_dim
                exporting
                  tablename = ld_s__custlink-tablename
                  dimension = ld_s__custlink-sc-dimension
                  attribute = ld_s__custlink-sc-attribute.

            else.
              ld_v__token = gr_o__cursor->get_token( ).
              raise exception type zcx_bdnl_syntax_error
                    exporting textid = zcx_bdnl_syntax_error=>zcx_unable_interpret
                              token  = ld_v__token
                              index  = gr_o__cursor->gd_v__index .
            endif.
          else.
            raise exception type zcx_bdnl_syntax_error
                  exporting textid = zcx_bdnl_syntax_error=>zcx_expected
                            token  = zblnc_keyword-equal
                            index  = gr_o__cursor->gd_v__index .
          endif.
        endif.

      endif.
      append ld_s__custlink to e_t__custlink.
      clear ld_s__custlink.

    else.
      raise exception type zcx_bdnl_syntax_error
        exporting textid = zcx_bdnl_syntax_error=>zcx_expected
                  token  = zblnc_keyword-equal
                  index  = gr_o__cursor->gd_v__index .
    endif.

  endwhile.

endmethod.
