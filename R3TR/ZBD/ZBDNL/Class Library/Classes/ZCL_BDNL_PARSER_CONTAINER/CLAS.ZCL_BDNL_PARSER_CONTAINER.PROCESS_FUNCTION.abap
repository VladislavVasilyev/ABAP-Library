method process_function.

  data
  : ld_v__funcname   type string
  , ld_v__funcindex  type i
  , lr_o__classdescr type ref to cl_abap_classdescr
  , ld_s__method     type abap_methdescr
  , lt_s__methparam  type abap_parmdescr
  , ld_t__funcparam  type standard table of string
  , ld_v__funcparam  type string
  , ld_s__bindparam  type abap_parmbind
  , ld_t__bindparam  type abap_parmbind_tab
  , ld_v__cntparam   type i value 0
  .

*  zcl_debug=>stop_program( ).

  ld_v__funcname = gr_o__cursor->get_token( esc = abap_true ).
  ld_v__funcindex = gr_o__cursor->gd_v__index.

  lr_o__classdescr ?= cl_abap_classdescr=>describe_by_name( `ZCL_BDNL_WHERE_FUNCTIONS`  ).

  read table lr_o__classdescr->methods
       with key name = ld_v__funcname
       into ld_s__method.

  if sy-subrc = 0.
    gr_o__cursor->get_token( esc = abap_true ).

    while gr_o__cursor->gd_f__end ne abap_true. "gr_o__cursor->next_token( ) <> end_token.

      ld_v__funcparam = gr_o__cursor->get_token( esc = abap_true ).
      append ld_v__funcparam to ld_t__funcparam.

      " ожидается или запятая или скобка
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

    sort ld_s__method-parameters by name ascending.

    loop at ld_s__method-parameters into lt_s__methparam.

      case lt_s__methparam-parm_kind.
        when cl_abap_classdescr=>importing.
          add 1 to ld_v__cntparam.
          read table ld_t__funcparam index ld_v__cntparam reference into ld_s__bindparam-value.
          if sy-subrc = 0.
            ld_s__bindparam-kind = cl_abap_classdescr=>exporting.
            ld_s__bindparam-name = lt_s__methparam-name.
            insert ld_s__bindparam into table ld_t__bindparam.
          endif.
        when cl_abap_classdescr=>exporting.
          ld_s__bindparam-kind = cl_abap_classdescr=>importing.
          get reference of e_t__param into ld_s__bindparam-value.
          ld_s__bindparam-name = lt_s__methparam-name.
          insert ld_s__bindparam into table ld_t__bindparam.
      endcase.



    endloop.

    call method ('ZCL_BDNL_WHERE_FUNCTIONS')=>(ld_v__funcname)
      parameter-table
        ld_t__bindparam.

    if lines( e_t__param ) = 0.
      raise exception type zcx_bdnl_syntax_error
            exporting textid = zcx_bdnl_syntax_error=>zcx_func_where_return0
              token  = ld_v__funcname
              index  = ld_v__funcindex .
    endif.
  else.
    raise exception type zcx_bdnl_syntax_error
      exporting textid = zcx_bdnl_syntax_error=>zcx_where_func_not_defined
        token  = ld_v__funcname
        index  = ld_v__funcindex .
  endif.

endmethod.
