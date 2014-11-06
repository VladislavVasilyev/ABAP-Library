method check_prim.

  constants
  : cs_func                 type string value `^([A-Z0-9\_]+)\>\s\(`
  .

  data
  : ld_s__check             type zbnlt_s__stack_check
  , ld_v__token             type string
  , ld_s__container         type zbnlt_s__stack_container
  , ld_v__infocube          type rsinfoprov
  , lr_o__appl              type ref to zcl_bd00_application
  , ld_v__cntkyf            type i
  , ld_s__variable          type zbnlt_s__math_var
  .

  field-symbols
  : <ld_s__appldimn>    type zbd00_s_dimn
  .

  check get = abap_true.

  ld_v__token = gr_o__cursor->get_token( ).

  case ld_v__token.
    when zblnc_keyword-not.
      gr_o__cursor->get_token( esc = abap_true ).
      return-token = ld_v__token.
*      append return to gd_t__check.
*      check_term( abap_true ).

    when zblnc_keyword-open_parenthesis.          "(
      gr_o__cursor->get_token( esc = abap_true ).
      return-token = ld_v__token.
      append return to gd_t__check.
      return = check_expr( abap_true ).

      if return-token ne zblnc_keyword-close_parenthesis. ").
        raise exception type zcx_bdnl_syntax_error
              exporting textid   = zcx_bdnl_syntax_error=>zcx_inc_le_parent
                        token    = zblnc_keyword-close_parenthesis " )
                        token1   = zblnc_keyword-open_parenthesis  " (
                        index     = gr_o__cursor->gd_v__index.
      else.
        return = check_term( abap_true ).
      endif.


    when zblnc_keyword-and or zblnc_keyword-or.
      gr_o__cursor->get_token( esc = abap_true ).
      return-token = ld_v__token.

    when zblnc_keyword-close_parenthesis. "`)`.
      gr_o__cursor->get_token( esc = abap_true ).
      return-token = ld_v__token.

    when zblnc_keyword-dot.
      gr_o__cursor->get_token( esc = abap_true ).
      return-token = ld_v__token.

    when others.
      if gr_o__cursor->check_letter( )  = abap_true or
       gr_o__cursor->check_variable( ) = abap_true .
        ld_s__check-left-const = gr_o__cursor->get_token( esc = abap_true ).
      elseif gr_o__cursor->check_num( )  = abap_true .
        ld_s__check-left-const = gr_o__cursor->get_token( esc = abap_true ).
      elseif gr_o__cursor->check_tokens( q = 2 regex = cs_func ) = abap_true.
        call method process_function
          importing
            e_v__funcname = ld_s__check-left-func_name
            e_t__param    = ld_s__check-left-param
            e_r__data     = ld_s__check-left-data.
      else.
        gr_o__cursor->get_token( esc = abap_true ).
        ld_s__check-left-tablename = ld_v__token.

        ld_s__container = zcl_bdnl_container=>check_table( ld_s__check-left-tablename ).

        if ld_s__container-appset_id = zblnc_keyword-bp.
          ld_v__infocube = ld_s__container-appl_id.
          lr_o__appl = zcl_bd00_application=>get_infocube( i_infocube = ld_v__infocube ).
        endif.

        if gr_o__cursor->get_token( ) = zblnc_keyword-tilde.
          gr_o__cursor->get_token( esc = abap_true ).

          ld_s__check-left-dimension  = gr_o__cursor->get_token( esc = abap_true ).
          if gr_o__cursor->get_token( ) = zblnc_keyword-tilde.
            gr_o__cursor->get_token( esc = abap_true ).
            ld_s__check-left-attribute = gr_o__cursor->get_token( esc = abap_true ).
          endif.

          call method zcl_bdnl_container=>check_dim
            exporting
              tablename = ld_s__check-left-tablename
              dimension = ld_s__check-left-dimension
              attribute = ld_s__check-left-attribute.

        elseif ld_s__container-appset_id = zblnc_keyword-bp.
          loop at lr_o__appl->gd_t__dimensions assigning <ld_s__appldimn> where type = zcl_bd00_application=>cs_kf.
            add 1 to ld_v__cntkyf.
            ld_s__check-left-dimension = <ld_s__appldimn>-dimension.
          endloop.
          if ( lines( ld_s__container-kyf_list ) = 0 or lines( ld_s__container-kyf_list ) > 1 ) and ld_v__cntkyf > 1 .
            raise exception type zcx_bdnl_syntax_error
                  exporting textid    = zcx_bdnl_syntax_error=>zcx_more_one_param
                            tablename = ld_s__variable-tablename
                            index     = gr_o__cursor->gd_v__index.
          endif.
        else.
          ld_s__check-left-dimension = uj00_cs_fieldname-signeddata.
        endif.
      endif.
      return = ld_s__check.
  endcase.

endmethod.
