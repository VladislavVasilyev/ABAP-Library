method FILTER_PRIM.

  data
  : ld_s__stack type zbnlt_s__stack_range
  , ld_v__token type string
  .

  while gr_o__cursor->gd_f__end ne abap_true. "gr_o__cursor->next_token( ) <> end_token.

    case gr_o__cursor->get_token( esc = abap_true ).
      when zblnc_keyword-filter.

        call method filter_statements
          importing
            e_s__stack = ld_s__stack.

        append ld_s__stack to gd_t__range.

      when zblnc_keyword-filters.
        if gr_o__cursor->get_token(  ) = zblnc_keyword-end.
          gr_o__cursor->get_token( esc = abap_true ).
          if gr_o__cursor->get_token(  ) = zblnc_keyword-dot.
            gr_o__cursor->get_token( esc = abap_true ).
            exit.
          else.
            raise exception type zcx_bdnl_syntax_error
                  exporting textid    = zcx_bdnl_syntax_error=>zcx_expected
                            expected  = zblnc_keyword-dot
                            index     = gr_o__cursor->gd_v__index .
          endif.
        else.
          raise exception type zcx_bdnl_syntax_error
                exporting textid    = zcx_bdnl_syntax_error=>zcx_after_filters
                          expected  = zblnc_keyword-end
                          index     = gr_o__cursor->gd_v__index .
        endif.
      when others.
        raise exception type zcx_bdnl_syntax_error
          exporting textid = zcx_bdnl_syntax_error=>zcx_unable_interpret
                    token  = ld_v__token
                    index  = gr_o__cursor->gd_v__index .
    endcase.
  endwhile.

endmethod.
