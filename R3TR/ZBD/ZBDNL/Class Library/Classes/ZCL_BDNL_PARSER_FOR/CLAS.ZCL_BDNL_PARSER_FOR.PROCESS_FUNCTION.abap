method process_function.

  data
  : ld_v__funcindex       type i
  , lr_o__classdescr      type ref to cl_abap_classdescr
  , ld_s__method          type abap_methdescr
  , ld_s__funcparam       type zbnlt_s__func_param
  .

  e_v__funcname   = gr_o__cursor->get_token( esc = abap_true ).
  ld_v__funcindex = gr_o__cursor->gd_v__cindex.

  lr_o__classdescr ?= cl_abap_classdescr=>describe_by_name( `ZCL_BDNL_ASSIGN_FUNCTION`  ).

  read table lr_o__classdescr->methods
       with key name = e_v__funcname
       into ld_s__method.

  if sy-subrc = 0.
    gr_o__cursor->get_token( esc = abap_true ). " esc (

    while gr_o__cursor->gd_f__end ne abap_true.

      clear ld_s__funcparam.
      ld_s__funcparam-const = gr_o__cursor->get_token( esc = abap_true ).

      " ожидается или запятая или скобка
      if gr_o__cursor->get_token(  ) = zblnc_keyword-tilde.
        gr_o__cursor->get_token( esc = abap_true ).

        ld_s__funcparam-tablename = ld_s__funcparam-const.
        clear ld_s__funcparam-const.

        ld_s__funcparam-field-dimension = gr_o__cursor->get_token( esc = abap_true ).

        if gr_o__cursor->get_token(  ) = zblnc_keyword-tilde.
          gr_o__cursor->get_token( esc = abap_true ).
          ld_s__funcparam-field-attribute = gr_o__cursor->get_token( esc = abap_true ).
        endif.
      endif.

      append ld_s__funcparam to e_t__param.

      if gr_o__cursor->get_token(  ) = zblnc_keyword-close_parenthesis.
        gr_o__cursor->get_token( esc = abap_true ).
        exit.
      elseif gr_o__cursor->get_token(  ) = zblnc_keyword-comma.
        gr_o__cursor->get_token( esc = abap_true ).
        continue.
      else.
        raise exception type zcx_bdnl_syntax_error
          exporting textid   = zcx_bdnl_syntax_error=>zcx_expected
                    expected = `) or ,`
                    index     = gr_o__cursor->gd_v__index.
      endif.
    endwhile.
  else.
    raise exception type zcx_bdnl_syntax_error
      exporting textid = zcx_bdnl_syntax_error=>zcx_where_func_not_defined
        token  = e_v__funcname
        index  = ld_v__funcindex .
  endif.

endmethod.
