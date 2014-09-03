method table_param_const.

  constants
  : cs_dimension     type string value `^([A-Z0-9\_]+)\>`
  , cs_dimwattr      type string value `^\~\<([A-Z0-9\_]+)\>`
  , cs_cond          type string value `^(EQ|=)`
  , cs_beetwen       type string value `^([A-Z0-9\_]+)\>\sAND\s([A-Z0-9\_]+)\>`
  , cs_func          type string value `^([A-Z0-9\_]+)\>\s\(`
  .

  data
  : ld_s__const         type zbd0t_ty_s_constant
  , ld_v__token         type string
  , ld_v__express       type string value ``
  , ld_v__filter_name   type string
  , ld_t__params        type zbnlt_t__param
  , ld_v__params        type line of zbnlt_t__param
  .

  " проверка
  while gr_o__cursor->gd_f__end ne abap_true. "gr_o__cursor->next_token( ) <> end_token.

    if gr_o__cursor->get_token( ) = zblnc_keyword-dot.
      "error
      exit.
    endif.

    clear
    : ld_s__const
    .

    if gr_o__cursor->check_tokens( q = 1 regex = cs_dimension ) = abap_true.
      ld_s__const-dimension = gr_o__cursor->get_token( esc = abap_true ).

      " check dimension
      select single dimension from uja_dim_appl
           into ld_s__const-dimension
           where appset_id      = i_appset_id
             and application_id = i_appl_id
             and dimension      = ld_s__const-dimension.
      if sy-subrc <> 0.
        raise exception type zcx_bdnl_syntax_error
              exporting textid    = zcx_bdnl_syntax_error=>zcx_dimension
                        appset_id = i_appset_id
                        appl_id   = i_appl_id
                        dimension = ld_s__const-dimension
                        index     = gr_o__cursor->gd_v__index.
      endif.

      if gr_o__cursor->check_tokens( q = 2 regex = cs_dimwattr ) = abap_true.
        ld_s__const-attribute = gr_o__cursor->get_token( esc = abap_true trn = 2 ).

        "check attribute
        select single attribute_name from uja_dim_attr
               into ld_s__const-attribute
               where appset_id      = i_appset_id
                 and dimension      = ld_s__const-dimension
                 and attribute_name = ld_s__const-attribute.
        if sy-subrc <> 0.
          raise exception type zcx_bdnl_syntax_error
            exporting textid    = zcx_bdnl_syntax_error=>zcx_attribute
                      dimension = ld_s__const-dimension
                      attribute = ld_s__const-attribute
                      index     = gr_o__cursor->gd_v__index.
        endif.
      endif.
    else.
      ld_v__token = gr_o__cursor->get_token( ).
      raise exception type zcx_bdnl_syntax_error
            exporting textid = zcx_bdnl_syntax_error=>zcx_unable_interpret
                      token  = ld_v__token
                      index  = gr_o__cursor->gd_v__index .
    endif.


    if gr_o__cursor->check_tokens( q = 1 regex = cs_cond ) = abap_true.
      ld_v__token = gr_o__cursor->get_token( esc = abap_true ).

      if gr_o__cursor->check_tokens( q = 2 regex = cs_func ) = abap_true and
         ( ld_v__token = zblnc_keyword-equal or ld_v__token = zblnc_keyword-eq ).

        ld_t__params = process_function( ).

        loop at ld_t__params into ld_v__params.
          ld_s__const-const = ld_v__params.
          exit.
        endloop.
      else.
        ld_s__const-const = gr_o__cursor->get_token( esc = abap_true ).
        insert ld_s__const into table e_t__const.
      endif.
    else.
      ld_v__token = gr_o__cursor->get_token( ).
      raise exception type zcx_bdnl_syntax_error
            exporting textid = zcx_bdnl_syntax_error=>zcx_unable_interpret
              token  = ld_v__token
              index  = gr_o__cursor->gd_v__index .
    endif.

  endwhile.

endmethod.
