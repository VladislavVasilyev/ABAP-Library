method get_stack1.

  data
  : lr_o__containers      type ref to zcl_bdnl_parser_container
  , lr_o__container       type ref to zcl_bdnl_container
  , lr_o__parser          type ref to zcl_bdnl_parser
  , lr_o__for             type ref to zcl_bdnl_parser_for
  , ld_s__script          type ty_s__filterpools
  , ld_v__pathscript      type string
  , ld_v__index           type i
  , ld_s__stack           type zbnlt_s__stack
  , ld_s__for             type zbnlt_s__for
  , ld_v__cnt_includeif   type i
  , ld_f__includeif       type rs_bool
  , ld_t__includeif       type table of rs_bool
  .

  field-symbols
  : <ld_s__range>         type zbnlt_s__stack_range
  , <ld_s__containers>    type zbnlt_s__stack_container
  , <ld_s__containers1>   type zbnlt_s__container
  , <ld_f__includeif>     type rs_bool
  .

  create object gr_o__cursor
    exporting
      i_t__variable    = gd_t__variable
      i_v__appset      = gd_v__appset
      i_v__application = gd_v__application
      i_v__filename    = gd_v__filename.

  zcl_bdnl_parser=>cr_o__cursor = gr_o__cursor.

  gr_o__cursor->create_token( ).

  while gr_o__cursor->gd_f__end = abap_false.

*--------------------------------------------------------------------*
* PROCESS INCUDEIF.
*--------------------------------------------------------------------*
    if ld_f__includeif = abap_true.
      if gr_o__cursor->get_token( ) = zblnc_keyword-includeif or
         gr_o__cursor->get_token( ) = zblnc_keyword-endincludeif.
      else.
        gr_o__cursor->get_token( esc = abap_true  ).
        if gr_o__cursor->gd_f__end = abap_true.
          exit.
        endif.
        continue.
      endif.
    endif.

    case gr_o__cursor->get_token( esc = abap_true ).

*--------------------------------------------------------------------*
* $INCLUDEIF COND_EXP.
*--------------------------------------------------------------------*
      when zblnc_keyword-includeif.
        " Чтение условий
        if ld_f__includeif eq abap_false.
          case if_expr( get = abap_false ).
            when true. "
              ld_f__includeif = abap_false.
            when false. " пропустить вложение до $ENDINCLUDEIF или до конца программы.
              ld_f__includeif = abap_true.
          endcase.
        else.
          if_expr( get = abap_false ).
          ld_f__includeif =  abap_true.
        endif.

        append ld_f__includeif to ld_t__includeif.
        ld_v__cnt_includeif = sy-tabix.


*--------------------------------------------------------------------*
* $ENDINCLUDEIF
*--------------------------------------------------------------------*
      when zblnc_keyword-endincludeif.

        if gr_o__cursor->get_token( esc = abap_true  ) <> zblnc_keyword-dot.
          raise exception type zcx_bdnl_syntax_error
          exporting textid    = zcx_bdnl_syntax_error=>zcx_expected
                    expected  = zblnc_keyword-dot
                    index     = gr_o__cursor->gd_v__cindex .
        endif.

        delete ld_t__includeif index ld_v__cnt_includeif.
        ld_v__cnt_includeif = lines( ld_t__includeif ).
        if ld_v__cnt_includeif = 0.
          ld_f__includeif = abap_false.
        else.
          read table ld_t__includeif index ld_v__cnt_includeif into ld_f__includeif.
        endif.


*--------------------------------------------------------------------*
* $CONTAINERS BEGIN.
*     .......
* $CONTAINERS END.
*--------------------------------------------------------------------*
      when zblnc_keyword-containers.

        " check syntax
        if gr_o__cursor->get_token( esc = abap_true ) ne zblnc_keyword-begin.
          raise exception type zcx_bdnl_syntax_error
          exporting textid    = zcx_bdnl_syntax_error=>zcx_expected
                  expected  = zblnc_keyword-dot
                  index     = gr_o__cursor->gd_v__cindex .
        else.
          if gr_o__cursor->get_token( esc = abap_true ) ne zblnc_keyword-dot.
            raise exception type zcx_bdnl_syntax_error
                  exporting textid    = zcx_bdnl_syntax_error=>zcx_expected
                            expected  = zblnc_keyword-dot
                            index     = gr_o__cursor->gd_v__cindex .
          endif.
        endif.

        add 1 to stack-turn.

        create object lr_o__containers
          exporting
            i_r__cursor     = gr_o__cursor
            i_t__range      = stack-range
            i_t__containers = stack-containers.

        call method lr_o__containers->get_stack
          importing
            stack  = ld_s__stack-containers
            stack1 = ld_s__stack-containers1.

*---> старый стек
        loop at ld_s__stack-containers assigning <ld_s__containers>.
          <ld_s__containers>-turn = stack-turn.

          if ld_f__includeif = abap_false.
            append <ld_s__containers> to stack-containers.
          endif.
        endloop.
*---< старый стек

        " перевод на новый стек
        loop at ld_s__stack-containers1 assigning <ld_s__containers1>.
          lr_o__container ?= <ld_s__containers1>-container.
          lr_o__container->set_turn( stack-turn ).
          if ld_f__includeif = abap_false.
            append <ld_s__containers1> to stack-containers1.
          endif.
        endloop.


*--------------------------------------------------------------------*
* $FILTERS BEGIN.
*     .......
* $FILTERS END.
*--------------------------------------------------------------------*
      when zblnc_keyword-filters.

        " check syntax
        if gr_o__cursor->get_token( esc = abap_true ) ne zblnc_keyword-begin.
          raise exception type zcx_bdnl_syntax_error
          exporting textid  = zcx_bdnl_syntax_error=>zcx_expected
                  expected  = zblnc_keyword-dot
                  index     = gr_o__cursor->gd_v__cindex .
        else.
          if gr_o__cursor->get_token( esc = abap_true ) ne zblnc_keyword-dot.
            raise exception type zcx_bdnl_syntax_error
                  exporting textid    = zcx_bdnl_syntax_error=>zcx_expected
                            expected  = zblnc_keyword-dot
                            index     = gr_o__cursor->gd_v__cindex .
          endif.
        endif.

        create object lr_o__containers
          exporting
            i_r__cursor = gr_o__cursor.

        ld_s__stack-range = lr_o__containers->get_filters( ).

        loop at ld_s__stack-range assigning <ld_s__range>.

          read table stack-range
               with key name = <ld_s__range>-name
               transporting no fields.

          if sy-subrc ne 0.
            if ld_f__includeif = abap_false.
              append <ld_s__range> to stack-range.
            endif.
          else."error

          endif.
        endloop.
        clear ld_s__stack.


*--------------------------------------------------------------------*
* $FOR TABLENAME PACKAGE SIZE #######.
*     .......
* $ENDFOR.

* $FOR TABLENAME.
*     .......
* $NEXTFOR.
*     .......
* $EXITFOR.
*   $COMMIT TABNAME.
*   $CLEAR  TABNAME.
* $ENDFOR.
*--------------------------------------------------------------------*
      when zblnc_keyword-for.

        call method parser__for
          exporting
            i_t__container   = stack-containers
          importing
            e_v__tablename   = ld_s__for-tablename
            e_v__packagesize = ld_s__for-packagesize.

        create object lr_o__for
          exporting
            i_r__cursor    = gr_o__cursor
            i_t__container = stack-containers
            i_v__for_table = ld_s__for-tablename.

        ld_s__for-rules = lr_o__for->get_stack( ).
        ld_s__for-commit = lr_o__for->gd_t__commit.
        ld_s__for-clear = lr_o__for->gd_t__clear.

        ld_s__for-turn = stack-turn.
        if ld_f__includeif = abap_false.
          append ld_s__for to stack-for.
        endif.

*--------------------------------------------------------------------*
* $FILTER-POOLS path_filterpools.
*--------------------------------------------------------------------*
      when zblnc_keyword-filterpools.

        ld_v__index = gr_o__cursor->gd_v__index.
        if  gr_o__cursor->check_tokens( q = 8 f_nospace = abap_true regex = `\<([A-Z0-9\_]+)\/([A-Z0-9\_]+)\/([A-Z0-9\_]+)\.(LGF)\.` ) = abap_true.
          ld_v__pathscript = gr_o__cursor->get_tokens( q = 7 f_nospace = abap_true ).
          gr_o__cursor->get_token( trn = 8 esc = abap_true  ).
          split ld_v__pathscript at `/` into ld_s__script-appset_id ld_s__script-appl_id ld_s__script-script.
        elseif gr_o__cursor->check_tokens( q = 6 f_nospace = abap_true regex = `\<([A-Z0-9\__]+)\/([A-Z0-9\__]+)\.LGF\.\>` ) = abap_true.
          split ld_s__script-script at `/` into ld_s__script-appl_id ld_s__script-script.
        elseif gr_o__cursor->check_tokens( q = 4 f_nospace = abap_true regex = `\<([A-Z0-9\__]+)\.LGF\.\>` ) = abap_true.

        endif.

        read table gd_t__filterpools from ld_s__script transporting no fields.

        if sy-subrc = 0.
          raise exception type zcx_bdnl_syntax_error
                exporting textid = zcx_bdnl_syntax_error=>zcx_recursive_filterpools
                          token  = ld_v__pathscript
                          index  = ld_v__index .
        else.
          insert ld_s__script into table gd_t__filterpools.
        endif.

        create object lr_o__parser
          exporting
            i_v__appset      = ld_s__script-appset_id
            i_v__application = ld_s__script-appl_id
            i_v__filename    = ld_s__script-script
            i_t__variable    = gd_t__variable.

        ld_s__stack = lr_o__parser->get_stack1( ).

        zcl_bdnl_parser=>cr_o__cursor = gr_o__cursor.

        loop at ld_s__stack-range assigning <ld_s__range>.

          read table stack-range
               with key name = <ld_s__range>-name
               transporting no fields.

          if sy-subrc ne 0.
            if ld_f__includeif = abap_false.
              append <ld_s__range> to stack-range.
            endif.
          else."error

          endif.
        endloop.
        clear ld_s__stack.

*--------------------------------------------------------------------*
* OTHERS
*--------------------------------------------------------------------*
      when others.
        if gr_o__cursor->gd_f__end ne abap_true.
          raise exception type zcx_bdnl_syntax_error
          exporting textid = zcx_bdnl_syntax_error=>zcx_unable_interpret
                    token  = gr_o__cursor->gd_v__ctoken
                    index  = gr_o__cursor->gd_v__cindex .
        endif.
        exit.
    endcase.
  endwhile.

endmethod.
