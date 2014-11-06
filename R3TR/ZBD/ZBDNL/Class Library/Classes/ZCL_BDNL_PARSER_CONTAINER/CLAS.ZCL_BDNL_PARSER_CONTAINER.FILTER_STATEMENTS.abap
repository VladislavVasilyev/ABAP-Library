method filter_statements.

  constants
  : cs__name            type string value `^([A-Z0-9\_]+)\>`
*  , cs__regex_in_where  type string value `^([A-Z0-9\_]+)\>\s\<([A-Z0-9\_]+)\>\s\$WHERE\>`
  .

  data
*  : ld_v__index         type i
  : ld_v__token         type string
  , ld_v__appset_id     type uj_appset_id
  , lr_o__appset        type ref to zcl_bd00_application
  .

  clear e_s__stack.

  if gr_o__cursor->check_tokens( q = 1 regex = cs__name ) = abap_true. " name

    e_s__stack-name = gr_o__cursor->get_token( esc = abap_true ).

    read table gd_t__range
         with key name = e_s__stack-name
         transporting no fields.

    if sy-subrc eq 0.
      raise exception type zcx_bdnl_syntax_error
            exporting textid   = zcx_bdnl_syntax_error=>zcx_has_declarate
                      token    = e_s__stack-name
                      index    = gr_o__cursor->gd_v__index.
    endif.
  else.
    ld_v__token = gr_o__cursor->get_token( ).
    raise exception type zcx_bdnl_syntax_error
      exporting textid = zcx_bdnl_syntax_error=>zcx_unable_interpret
                token  = ld_v__token
                index  = gr_o__cursor->gd_v__index .
  endif.


  if gr_o__cursor->get_token( ) =  zblnc_keyword-from.
    gr_o__cursor->get_token( esc = abap_true ).

    ld_v__appset_id = gr_o__cursor->get_token( ). " read APPSET_ID

    select single appset_id from uja_appset_info     " check appset
           into   ld_v__appset_id
           where  appset_id = ld_v__appset_id.

    if sy-subrc <> 0.
      raise exception type zcx_bdnl_syntax_error
             exporting textid    =  zcx_bdnl_syntax_error=>zcx_appset_unknow
                       appset_id = ld_v__appset_id
                       index     = gr_o__cursor->gd_v__index.
    endif.

    gr_o__cursor->get_token( esc = abap_true ).

  endif.

  if gr_o__cursor->get_token( ) =  zblnc_keyword-where.
    gr_o__cursor->get_token( esc = abap_true ).

    lr_o__appset = zcl_bd00_application=>get_customize_application( i_appset_id = ld_v__appset_id ).

    try.
        call method select_param_where
          exporting
            i_appset_id = ld_v__appset_id
            i_appl_obj  = lr_o__appset
          importing
            e_t__range  = e_s__stack-range.
      catch zcx_bdnl_exception. "если ошибка дойти до точки
        clear e_s__stack.
        while gr_o__cursor->gd_f__end ne abap_true. "gr_o__cursor->next_token( ) <> end_token.
          ld_v__token = gr_o__cursor->get_token( ).
          if ld_v__token = zblnc_keyword-dot.
            exit.
          else.
            gr_o__cursor->get_token( esc = abap_true ).
          endif.
        endwhile.
    endtry.

  else.
    raise exception type zcx_bdnl_syntax_error
          exporting textid    = zcx_bdnl_syntax_error=>zcx_after_filter
                    expected  = zblnc_keyword-where
                    index     = gr_o__cursor->gd_v__index .
  endif.

  if gr_o__cursor->get_token( ) ne zblnc_keyword-dot.
    raise exception type zcx_bdnl_syntax_error
          exporting textid    = zcx_bdnl_syntax_error=>zcx_expected
                    expected  = zblnc_keyword-dot
                    index     = gr_o__cursor->gd_v__index .
  endif.

  ld_v__token = gr_o__cursor->get_token( esc = abap_true ).

endmethod.
