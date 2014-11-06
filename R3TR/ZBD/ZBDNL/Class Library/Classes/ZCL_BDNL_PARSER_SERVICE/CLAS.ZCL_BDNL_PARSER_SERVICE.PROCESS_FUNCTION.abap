method process_function.

  data
  : ld_v__funcindex  type i
  , lr_o__classdescr type ref to cl_abap_classdescr
  , ld_s__method     type abap_methdescr
  , ld_s__funcparam  type zbnlt_s__func_param
  , ld_v__numparam   type i
  , ld_s__parameter  type abap_parmdescr
  , lr_o__elemdescr  type ref to cl_abap_elemdescr
  .

  field-symbols
  : <ld_s__variable>        type zbnlt_s__variable
  .

  e_v__funcname   = gr_o__cursor->get_token( esc = abap_true ).
  ld_v__funcindex = gr_o__cursor->gd_v__index.

  lr_o__classdescr ?= cl_abap_classdescr=>describe_by_name( `ZCL_BDNL_ASSIGN_FUNCTION`  ).

  read table lr_o__classdescr->methods
       with key name = e_v__funcname
       into ld_s__method.

  if sy-subrc = 0.
    " create data
    read table  ld_s__method-parameters
          into  ld_s__parameter
          with key name = `E`.

    if sy-subrc = 0.
      case ld_s__parameter-type_kind.
        when cl_abap_elemdescr=>typekind_char.
          lr_o__elemdescr = cl_abap_elemdescr=>get_c( ld_s__parameter-length ).
          create data e_r__data type handle lr_o__elemdescr.
        when cl_abap_elemdescr=>typekind_string.
          lr_o__elemdescr = cl_abap_elemdescr=>get_string(  ).
          create data e_r__data type handle lr_o__elemdescr.
        when cl_abap_elemdescr=>typekind_packed.
          lr_o__elemdescr = cl_abap_elemdescr=>get_p(  p_length = ld_s__parameter-length p_decimals = ld_s__parameter-decimals ).
          create data e_r__data type handle lr_o__elemdescr.
        when cl_abap_elemdescr=>typekind_int.
          lr_o__elemdescr = cl_abap_elemdescr=>get_i( ).
          create data e_r__data type handle lr_o__elemdescr.
        when others.
          create data e_r__data type uj_value.
      endcase.
    endif.

    gr_o__cursor->get_token( esc = abap_true ).

    while gr_o__cursor->gd_f__end ne abap_true.

      clear ld_s__funcparam.
      ld_s__funcparam-const = gr_o__cursor->get_token( ).
      add 1 to ld_v__numparam.
      if ld_s__funcparam-const = zblnc_keyword-comma. " то параметр опциональный
        continue.
      endif.

      if gr_o__cursor->check_letter( ) = abap_true.
        loop at zcl_bdnl_parser=>cr_o__cursor->gd_t__variable assigning <ld_s__variable>.
          replace all  occurrences of <ld_s__variable>-var in ld_s__funcparam-const with <ld_s__variable>-val.
        endloop.
        gr_o__cursor->get_token( esc = abap_true ).
      elseif gr_o__cursor->check_num( ) = abap_true or
             gr_o__cursor->check_variable( ) = abap_true .
        ld_s__funcparam-const = ld_s__funcparam-const.
        gr_o__cursor->get_token( esc = abap_true ).
      else.

        ld_s__funcparam-tablename = ld_s__funcparam-const.
        zcl_bdnl_container=>check_table( ld_s__funcparam-tablename ).
        clear ld_s__funcparam-const.

        gr_o__cursor->get_token( esc = abap_true ).

        " ожидается или запятая или скобка
        if gr_o__cursor->get_token(  ) = zblnc_keyword-tilde.
          gr_o__cursor->get_token( esc = abap_true ).
          clear ld_s__funcparam-const.
          ld_s__funcparam-field-dimension = gr_o__cursor->get_token( esc = abap_true ).
          if gr_o__cursor->get_token(  ) = zblnc_keyword-tilde.
            gr_o__cursor->get_token( esc = abap_true ).
            ld_s__funcparam-field-attribute = gr_o__cursor->get_token( esc = abap_true ).
          endif.

          call method zcl_bdnl_container=>check_dim
            exporting
              tablename = ld_s__funcparam-tablename
              dimension = ld_s__funcparam-field-dimension
              attribute = ld_s__funcparam-field-attribute.
        else.
          ld_s__funcparam-field-dimension = `SIGNEDDATA`.
        endif.
      endif.

      ld_s__funcparam-index = ld_v__numparam.
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
