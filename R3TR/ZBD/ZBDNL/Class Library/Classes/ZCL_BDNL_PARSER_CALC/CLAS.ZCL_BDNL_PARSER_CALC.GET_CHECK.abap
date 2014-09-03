method get_check.

*  data
*  : ld_s__check         type zbnlt_s__stack_check
*  , ld_v__token         type string
*  , ld_s__container     type zbnlt_s__stack_container
*  , ld_v__infocube      type rsinfoprov
*  , ld_v__cntkyf        type i
*  , lr_o__appl          type ref to zcl_bd00_application
*  , ld_s__variable      type zbnlt_s__math_var
*  , ld_f__opencond      type rs_bool
*  , ld_v__parenthesis   type i
*  .
*
*  field-symbols
*  : <ld_s__appldimn>    type zbd00_s_dimn
*  .
*  break-point.
*  while gr_o__cursor->next_token( ) <> end_token.
*    clear ld_s__check.
*    ld_s__check-turn = i_v__turn.
*    ld_v__token = gr_o__cursor->get_token( ).
*
*    case ld_v__token.
*
*      when zblnc_keyword-dot.
*        gr_o__cursor->get_token( esc = abap_true ).
*        if ld_v__parenthesis > 0.
*          raise exception type zcx_bdnl_syntax_error
*                exporting textid   = zcx_bdnl_syntax_error=>zcx_inc_le_parent
*                          token    = `(`
*                          token1   = `)`
*                          index     = gr_o__cursor->gd_v__index.
*        endif.
*        exit.
*      when `NOT`.
*        if ld_f__opencond = abap_true.
*          raise exception type zcx_bdnl_syntax_error
*                exporting textid   = zcx_bdnl_syntax_error=>zcx_le_unable_interpret
*                          token    = ld_v__token
*                          index    = gr_o__cursor->gd_v__index.
*        endif.
*
*        gr_o__cursor->get_token( esc = abap_true ).
*        ld_s__check-token = ld_v__token.
*        append ld_s__check to e_t__check.
*        continue.
*      when `AND` or `OR`.
*        if ld_f__opencond = abap_true.
*          ld_f__opencond = abap_false.
*        else.
*          raise exception type zcx_bdnl_syntax_error
*                 exporting textid   = zcx_bdnl_syntax_error=>zcx_le_unable_interpret
*                           token    = ld_v__token
*                           index    = gr_o__cursor->gd_v__index.
*        endif.
*
*        gr_o__cursor->get_token( esc = abap_true ).
*        ld_s__check-token = ld_v__token.
*        append ld_s__check to e_t__check.
*        continue.
*      when `(`.
*        if ld_f__opencond = abap_true.
*          raise exception type zcx_bdnl_syntax_error
*                exporting textid   = zcx_bdnl_syntax_error=>zcx_le_unable_interpret
*                          token    = ld_v__token
*                          index    = gr_o__cursor->gd_v__index.
*        endif.
*
*        gr_o__cursor->get_token( esc = abap_true ).
*        ld_s__check-token = ld_v__token.
*        append ld_s__check to e_t__check.
*        add 1 to ld_v__parenthesis.
*        continue.
*      when `)`.
*        gr_o__cursor->get_token( esc = abap_true ).
*        subtract 1 from ld_v__parenthesis.
*        if ld_v__parenthesis < 0.
*          raise exception type zcx_bdnl_syntax_error
*                exporting textid   = zcx_bdnl_syntax_error=>zcx_inc_le_parent
*                          token    = `)`
*                          token1   = `(`
*                          index     = gr_o__cursor->gd_v__index.
*        endif.
*        continue.
*    endcase.
*
*    if ld_f__opencond = abap_true.
*      raise exception type zcx_bdnl_syntax_error
*      exporting textid   = zcx_bdnl_syntax_error=>zcx_le_unable_interpret
*                token    = ld_v__token
*                index    = gr_o__cursor->gd_v__index.
*    endif.
*
*    ld_f__opencond = abap_false.
*
*    while gr_o__cursor->next_token( ) <> end_token. " logical expressions
*      clear ld_s__check.
*      ld_s__check-turn = i_v__turn.
*      if gr_o__cursor->check_letter( )  = abap_true or
*       gr_o__cursor->check_variable( ) = abap_true .
*        ld_s__check-const = gr_o__cursor->get_token( esc = abap_true ).
*        append ld_s__check to e_t__check.
*      elseif gr_o__cursor->check_num( )  = abap_true .
*        ld_s__check-const = gr_o__cursor->get_token( esc = abap_true ).
*        append ld_s__check to e_t__check.
*      else.
*        gr_o__cursor->get_token( esc = abap_true ).
*        ld_s__check-tablename = ld_v__token.
*
*        read table gd_t__containers
*             with key tablename = ld_s__check-tablename
*             into ld_s__container.
*
*        if ld_s__container-appset_id = zblnc_keyword-bp.
*          ld_v__infocube = ld_s__container-appl_id.
*          lr_o__appl ?= zcl_bd00_application=>get_infocube( i_infocube = ld_v__infocube ).
*        endif.
*
*        if gr_o__cursor->get_token( ) = zblnc_keyword-tilde.
*          gr_o__cursor->get_token( esc = abap_true ).
*
*          ld_s__check-dimension  = gr_o__cursor->get_token( esc = abap_true ).
*          if gr_o__cursor->get_token( ) = zblnc_keyword-tilde.
*            gr_o__cursor->get_token( esc = abap_true ).
*            ld_s__check-attribute = gr_o__cursor->get_token( esc = abap_true ).
*          endif.
*        elseif ld_s__container-appset_id = zblnc_keyword-bp.
*          loop at lr_o__appl->gd_t__dimensions assigning <ld_s__appldimn> where type = zcl_bd00_application=>cs_kf.
*            add 1 to ld_v__cntkyf.
*          endloop.
*          if ( lines( ld_s__container-kyf_list ) = 0 or lines( ld_s__container-kyf_list ) > 1 ) and ld_v__cntkyf > 1 .
*            raise exception type zcx_bdnl_syntax_error
*                  exporting textid    = zcx_bdnl_syntax_error=>zcx_more_one_param
*                            tablename = ld_s__variable-tablename
*                            index     = gr_o__cursor->gd_v__index.
*          endif.
*        endif.
*        append ld_s__check to e_t__check.
*      endif.
*
*      clear ld_s__check.
*      ld_s__check-turn = i_v__turn.
*
*      if ld_f__opencond = abap_true.
*        exit.
*      endif.
*
*      ld_v__token = gr_o__cursor->get_token( ).
*
*      if ld_v__token = `<>` or ld_v__token = `>=` or ld_v__token = `<=` or ld_v__token = `=`
*      or ld_v__token = `NE` or ld_v__token = `GE` or ld_v__token = `LE` or ld_v__token = `EQ`.
*        gr_o__cursor->get_token( esc = abap_true ).
*        ld_s__check-token = ld_v__token.
*        append ld_s__check to e_t__check.
*        ld_f__opencond = abap_true.
*      else.
*        raise exception type zcx_bdnl_syntax_error
*              exporting textid   = zcx_bdnl_syntax_error=>zcx_expected
*                        expected = `LOG EXP`
*                        index     = gr_o__cursor->gd_v__index.
*      endif.
*    endwhile.
*
*
*
*  endwhile.
*
*        raise exception type zcx_bdnl_syntax_error
*              exporting textid   = zcx_bdnl_syntax_error=>zcx_expected
*                        expected = `GOOD`
*                        index     = gr_o__cursor->gd_v__index.


endmethod.
