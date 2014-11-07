method prim.

*  constants
*  : cs_read                   type string value `\$READ`
*  : cs_calc_begin             type string value `\$CALC`.

  data
  : lr_o__assign              type ref to zcl_bdnl_parser_calc
  , ld_s__containers          type zbnlt_s__stack_container
  , ld_s__assign              type zbnlt_s__stack_assign
  , ld_s__search              type zbnlt_s__stack_search
*  , ld_f__search_close        type rs_bool " флаг закрытия блока поиска
  , ld_v__tablename           type zbnlt_v__tablename
  , ld_f__commit              type abap_bool
  , ld_f__clear               type abap_bool
  , ld_f__print               type abap_bool
  , ld_v__checkturn           type i
  , ld_t__check               type zbnlt_t__stack_check
  , ld_t__allcheck            type zbnlt_t__stack_check
  .

  field-symbols
  : <ld_s__rules>             type zbnlt_s__for_rules
  .

  if gd_f__with_key = abap_true.
    call method read_with_key
      exporting
        i_v__tablename = gd_v__for_table
      importing
        e_t__custlink  = gd_t__where.

    if gr_o__cursor->get_token( esc = abap_true ) ne zblnc_keyword-dot.
      raise exception type zcx_bdnl_syntax_error
            exporting textid = zcx_bdnl_syntax_error=>zcx_expected
                      token  = zblnc_keyword-dot
                      index  = gr_o__cursor->gd_v__index .
    endif.
  endif.

  append initial line to gd_t__rules assigning <ld_s__rules>.

  while gr_o__cursor->gd_f__end ne abap_true.

*--------------------------------------------------------------------*
* $SEARCH BEGIN.
*--------------------------------------------------------------------*
    case gr_o__cursor->get_token( esc = abap_true ).
      when zblnc_keyword-read.

        call method read_statements
          importing
            e_s__stack = ld_s__search.

        if ld_t__allcheck is not initial.
          ld_s__search-check = ld_t__allcheck.
          clear
          : ld_t__allcheck
          , ld_v__checkturn.
        endif.

        append ld_s__search to <ld_s__rules>-search.
        clear ld_s__search.

*--------------------------------------------------------------------*
* $CHECK COND.
*--------------------------------------------------------------------*
      when zblnc_keyword-check.
        add 1 to ld_v__checkturn.

        ld_t__check = zcl_bdnl_parser_service=>get_check( i_r__cursor = gr_o__cursor i_v__turn = ld_v__checkturn ).
        append lines of ld_t__check to ld_t__allcheck.
        clear ld_t__check.
*--------------------------------------------------------------------*
* $CALC TABLENAME FOR FOUND.
* $CALC TABLENAME FOR NOT FOUND.
*--------------------------------------------------------------------*
      when zblnc_keyword-calc.

*        ld_f__search_close = abap_true.

        call method parser__calc
          importing
            e_v__tablename = ld_s__assign-tablename
            e_f__found     = ld_s__assign-f_found.

        create object lr_o__assign
          exporting
            i_v__tablename = ld_s__assign-tablename
            i_r__cursor    = gr_o__cursor
            i_v__for_table = gd_v__for_table.

        call method lr_o__assign->get_stack
          importing
            e_t__link     = ld_s__assign-link
            e_v__exp      = ld_s__assign-exp
            e_t__variable = ld_s__assign-variables
            e_f__continue = ld_s__assign-f_continue
            e_t__check    = ld_s__assign-check.

        append ld_s__assign to  <ld_s__rules>-assign.

        free lr_o__assign.

*--------------------------------------------------------------------*
* $CONTINUE
*--------------------------------------------------------------------*
      when zblnc_keyword-continue.
        <ld_s__rules>-f_continue = abap_true.

        if gr_o__cursor->get_token( esc = abap_true ) ne zblnc_keyword-dot.
          raise exception type zcx_bdnl_syntax_error
                exporting textid    = zcx_bdnl_syntax_error=>zcx_expected
                          expected  = zblnc_keyword-dot
                          index     = gr_o__cursor->gd_v__cindex .
        endif.

*--------------------------------------------------------------------*
* $NEXTFOR
*--------------------------------------------------------------------*
      when zblnc_keyword-nextfor.

        if ld_t__allcheck is not initial.
          ld_s__search-check = ld_t__allcheck.
          append ld_s__search to <ld_s__rules>-search.
          clear
          : ld_t__allcheck
          , ld_v__checkturn.
        endif.

        if gr_o__cursor->get_token( esc = abap_true ) ne zblnc_keyword-dot.
          raise exception type zcx_bdnl_syntax_error
                exporting textid    = zcx_bdnl_syntax_error=>zcx_expected
                          expected  = zblnc_keyword-dot
                          index     = gr_o__cursor->gd_v__cindex .
        endif.

        append initial line to gd_t__rules assigning <ld_s__rules>.

*--------------------------------------------------------------------*
* $EXITFOR
*--------------------------------------------------------------------*
      when zblnc_keyword-exitfor.

        if ld_t__allcheck is not initial.
          ld_s__search-check = ld_t__allcheck.
          append ld_s__search to <ld_s__rules>-search.
          clear
          : ld_t__allcheck
          , ld_v__checkturn.
        endif.

        if gr_o__cursor->get_token( esc = abap_true ) ne zblnc_keyword-dot.
          raise exception type zcx_bdnl_syntax_error
                exporting textid    = zcx_bdnl_syntax_error=>zcx_expected
                          expected  = zblnc_keyword-dot
                          index     = gr_o__cursor->gd_v__cindex .
        endif.

        while gr_o__cursor->gd_f__end ne abap_true.

          clear
          : ld_f__commit
          , ld_f__clear
          , ld_f__print
          .

          case gr_o__cursor->get_token( ).
              "$COMMIT
            when zblnc_keyword-commit.
              gr_o__cursor->get_token( esc = abap_true ).
              ld_f__commit = abap_true.
              " $CLEAR
            when zblnc_keyword-clear.
              gr_o__cursor->get_token( esc = abap_true ).
              ld_f__clear = abap_true.
              " $PRINT
            when zblnc_keyword-print.
              gr_o__cursor->get_token( esc = abap_true ).
              ld_f__print = abap_true.
            when zblnc_keyword-endfor.
              exit.
          endcase.

          while gr_o__cursor->gd_f__end ne abap_true.

            ld_v__tablename = gr_o__cursor->get_token( ).

            if ld_v__tablename = zblnc_keyword-dot.
              gr_o__cursor->get_token( esc = abap_true ).
              exit.
            endif.

            ld_s__containers = zcl_bdnl_container=>check_table( ld_v__tablename ).

            if ld_f__commit = abap_true.
              if ld_s__containers-f_write = abap_false.
                raise exception type zcx_bdnl_syntax_error
                         exporting textid = zcx_bdnl_syntax_error=>zcx_no_can_save
                                   tablename  = ld_v__tablename
                                   index  = gr_o__cursor->gd_v__index .
              endif.
            endif.

            gr_o__cursor->get_token( esc = abap_true ).

            case abap_true.
              when ld_f__commit.
                insert ld_v__tablename into table gd_t__commit .
              when ld_f__clear.
                insert ld_v__tablename into table gd_t__clear .
              when ld_f__print.
                insert ld_v__tablename into table gd_t__print .
            endcase.

          endwhile.
        endwhile.

*--------------------------------------------------------------------*
* ENDFOR
*--------------------------------------------------------------------*
      when zblnc_keyword-endfor.

        if ld_t__allcheck is not initial.
          ld_s__search-check = ld_t__allcheck.
          append ld_s__search to <ld_s__rules>-search.
          clear
          : ld_t__allcheck
          , ld_v__checkturn.
        endif.

        if gr_o__cursor->get_token( esc = abap_true ) ne zblnc_keyword-dot.
          raise exception type zcx_bdnl_syntax_error
                exporting textid    = zcx_bdnl_syntax_error=>zcx_expected
                          expected  = zblnc_keyword-dot
                          index     = gr_o__cursor->gd_v__cindex .
        else.
          exit.
        endif.

*--------------------------------------------------------------------*
* OTHERS
*--------------------------------------------------------------------*
      when others.
        raise exception type zcx_bdnl_syntax_error
          exporting textid = zcx_bdnl_syntax_error=>zcx_unable_interpret
                    token  = gr_o__cursor->gd_v__ctoken
                    index  = gr_o__cursor->gd_v__cindex .
    endcase.

  endwhile.

endmethod.
