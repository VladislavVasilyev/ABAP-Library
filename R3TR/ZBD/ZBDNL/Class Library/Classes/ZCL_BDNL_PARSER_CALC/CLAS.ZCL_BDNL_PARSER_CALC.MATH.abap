method math.

  constants
  : cs_func             type string value `^([A-Z0-9\_]+)\>\s\(`
  .

  data
  : ld_s__variable      type zbnlt_s__math_var
  , ld_v__variable      type string
  , ld_v__exp           type string
  , ld_v__varcnt        type c value `0`
  , ld_v__token         type string
  , ld_s__container     type zbnlt_s__stack_container
  , lr_o__appl          type ref to zcl_bd00_application
  , ld_v__infocube      type rsinfoprov
  , ld_v__cntkyf        type i
  .

  field-symbols
  : <ld_s__appldimn>    type zbd00_s_dimn
  .

  while gr_o__cursor->gd_f__end ne abap_true. "gr_o__cursor->next_token( ) <> end_token.
    ld_v__token = gr_o__cursor->get_token( ).

    case ld_v__token.
      when `+` or `-` or `/` or `*` or `(` or `)`.
        gr_o__cursor->get_token( esc = abap_true ).
        concatenate e_v__exp ld_v__token into e_v__exp separated by space.
      when zblnc_keyword-dot.
        exit.
      when others.
        if gr_o__cursor->check_letter( )   = abap_true or
           gr_o__cursor->check_variable( ) = abap_true .
          ld_v__token = gr_o__cursor->get_token( esc = abap_true ).
          concatenate e_v__exp ld_v__token into e_v__exp separated by space.
        elseif  gr_o__cursor->check_num( )  = abap_true .
          ld_v__token = gr_o__cursor->get_token( esc = abap_true ).
          concatenate e_v__exp ld_v__token  into e_v__exp separated by space.
        elseif gr_o__cursor->check_tokens( q = 2 regex = cs_func ) = abap_true.
          create data ld_s__variable-data type uj_keyfigure.
          call method process_function
            importing
              e_v__funcname = ld_s__variable-func_name
              e_t__param    = ld_s__variable-param.
          add 1 to ld_v__varcnt.
          concatenate `V` ld_v__varcnt                into ld_s__variable-varname .
          ld_v__variable = ld_s__variable-varname.
          concatenate e_v__exp ld_v__variable into e_v__exp separated by space.
          append ld_s__variable to e_t__varible.
        else.
          clear ld_v__cntkyf.
          gr_o__cursor->get_token( esc = abap_true ).
          ld_v__variable = ld_s__variable-varname = ld_s__variable-tablename = ld_v__token.

          read table gd_t__containers
               with key tablename = ld_s__variable-tablename
               into ld_s__container.

          if ld_s__container-appset_id = zblnc_keyword-bp.
            ld_v__infocube = ld_s__container-appl_id.
            lr_o__appl ?= zcl_bd00_application=>get_infocube( i_infocube = ld_v__infocube ).
          endif.

          if gr_o__cursor->get_token( ) = zblnc_keyword-tilde.
            gr_o__cursor->get_token( esc = abap_true ).
            add 1 to ld_v__varcnt.

            concatenate `V` ld_v__varcnt                into ld_s__variable-varname .
            ld_v__variable = ld_s__variable-varname.

            ld_s__variable-dimension  = gr_o__cursor->get_token( esc = abap_true ).
            if gr_o__cursor->get_token( ) = zblnc_keyword-tilde.
              gr_o__cursor->get_token( esc = abap_true ).
              ld_s__variable-attribute = gr_o__cursor->get_token( esc = abap_true ).
            endif.
          elseif ld_s__container-appset_id = zblnc_keyword-bp.
            loop at lr_o__appl->gd_t__dimensions assigning <ld_s__appldimn> where type = zcl_bd00_application=>cs_kf.
              add 1 to ld_v__cntkyf.
            endloop.
            if ( lines( ld_s__container-kyf_list ) = 0 or lines( ld_s__container-kyf_list ) > 1 ) and ld_v__cntkyf > 1 .
              raise exception type zcx_bdnl_syntax_error
                    exporting textid    = zcx_bdnl_syntax_error=>zcx_more_one_param
                              tablename = ld_s__variable-tablename
                              index     = gr_o__cursor->gd_v__index.
            endif.
          endif.
          concatenate e_v__exp ld_v__variable into e_v__exp separated by space.
          append ld_s__variable to e_t__varible.
        endif.
    endcase.
  endwhile.

endmethod.
