method prim.

  data
  : cs_func                 type string value `^([A-Z0-9\_]+)\>\s\(`
  .

  data
  : ld_v__varname              type string
  , ld_v__varval               type string
*  , ld_s__custlink             type zbnlt_s__cust_link
  , ld_t__function             type zbnlt_t__function
  , lr_v__data                 type ref to data
  , lr_x__static_check         type ref to cx_static_check
  , ld_v__index                type i
  .


  field-symbols
  : <ld_s__function>           type zbnlt_s__function
  , <ld_v__varval>             type any
  .

*  break-point.

  while gr_o__cursor->gd_f__end ne abap_true.

*    clear ld_s__custlink.

    " get variables
    gr_o__cursor->get_token( ).
    " check variables
    if  gr_o__cursor->check_variable( ) = abap_true.
      gr_o__cursor->get_token( esc = abap_true ).
      ld_v__varname = gr_o__cursor->gd_v__varname.

      if gr_o__cursor->get_token( ) = zblnc_keyword-equal.
        gr_o__cursor->get_token( esc = abap_true ).

        if gr_o__cursor->check_tokens( q = 2 regex = cs_func ) = abap_true. " Если функция
          ld_v__index = gr_o__cursor->gd_v__cindex.

          call method zcl_bdnl_parser_service=>get_assign_function
            exporting
              i_r__cursor   = gr_o__cursor
            importing
              e_t__function = ld_t__function
              e_r__data     = lr_v__data.

          try.
              loop at ld_t__function assigning <ld_s__function>.
                call method zcl_bdnl_assign_function=>(<ld_s__function>-func_name)
                  parameter-table
                    <ld_s__function>-bindparam.
              endloop.
            catch cx_static_check into lr_x__static_check.
*              ld_v__varname = lr_x__static_check->get_text( ).

              raise exception type zcx_bdnl_syntax_error
              exporting textid = zcx_bdnl_syntax_error=>zcx_err_in_function
                        token1  = <ld_s__function>-func_name
*                        message = ld_v__varname
                        index  = ld_v__index
                        previous = lr_x__static_check.
          endtry.


          assign  lr_v__data->* to <ld_v__varval>.
          ld_v__varval = <ld_v__varval>.

        else.
          if gr_o__cursor->check_letter( )   = abap_true or
             gr_o__cursor->check_variable( ) = abap_true.
            ld_v__varval = gr_o__cursor->get_token( esc = abap_true ).
          elseif gr_o__cursor->get_token( ) = zblnc_keyword-cspace.
            clear ld_v__varval.
          else.
            raise exception type zcx_bdnl_syntax_error
            exporting textid = zcx_bdnl_syntax_error=>zcx_unable_interpret
                      token  = gr_o__cursor->gd_v__ctoken
                      index  = gr_o__cursor->gd_v__cindex .
          endif.
        endif.

        " set variable
        call method gr_o__cursor->set_variable
          exporting
            name  = ld_v__varname
            value = ld_v__varval.

      else.
        raise exception type zcx_bdnl_syntax_error
        exporting textid    = zcx_bdnl_syntax_error=>zcx_expected
                  expected  = zblnc_keyword-equal
                  index     = gr_o__cursor->gd_v__index .
      endif.

      if gr_o__cursor->get_token( esc = abap_true ) ne zblnc_keyword-dot.
        raise exception type zcx_bdnl_syntax_error
              exporting textid    = zcx_bdnl_syntax_error=>zcx_expected
                        expected  = zblnc_keyword-dot
                        index     = gr_o__cursor->gd_v__index .
      endif.

    elseif  gr_o__cursor->get_token( ) = zblnc_keyword-variables.
      gr_o__cursor->get_token( esc = abap_true ).
      if gr_o__cursor->get_token( esc = abap_true ) = zblnc_keyword-end.
        if gr_o__cursor->get_token( esc = abap_true  ) = zblnc_keyword-dot.
          exit.
        else.
          raise exception type zcx_bdnl_syntax_error
                exporting textid    = zcx_bdnl_syntax_error=>zcx_expected
                          expected  = zblnc_keyword-dot
                          index     = gr_o__cursor->gd_v__cindex .
        endif.
      else.
        raise exception type zcx_bdnl_syntax_error
              exporting textid    = zcx_bdnl_syntax_error=>zcx_after_containers
                        expected  = zblnc_keyword-end
                        index     = gr_o__cursor->gd_v__cindex .
      endif.
    else.
      raise exception type zcx_bdnl_syntax_error
            exporting textid = zcx_bdnl_syntax_error=>zcx_unable_interpret
                      token  = gr_o__cursor->gd_v__ctoken
                      index  = gr_o__cursor->gd_v__cindex .
    endif.

  endwhile.

endmethod.
