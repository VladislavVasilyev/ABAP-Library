method select_param_where.

  constants
  : cs_dimension        type string value `^([A-Z0-9\_]+)\>`
  , cs_dimwattr         type string value `^\~\<([A-Z0-9\_]+)\>`
  , cs_cond             type string value `^(EQ|NE|LT|GT|LE|GE|CO|CN|CA|NA|CS|NS|CP|NP|BETWEEN|BT|=|<>|>=|<=|>|<)`
  , cs_beetwen          type string value `^([A-Z0-9\_]+)\>\sAND\s([A-Z0-9\_]+)\>`
  , cs_from_filter      type string value `^(FROM\sFILTER)\>`
  , cs_func             type string value `^([A-Z0-9\_]+)\>\s\(`
  .

  data
  : ld_s__range         type uj0_s_sel
  , ld_v__token         type string
  , ld_v__express       type string value ``
  , ld_v__filter_name   type string
  , ld_s__frange        type zbnlt_s__stack_range
  , ld_t__params        type zbnlt_t__param
  , ld_v__params        type line of zbnlt_t__param
  , lr_o__appl          type ref to zcl_bd00_application
  , ld_v__infocube      type rsinfoprov
  , lo_security       type ref to cl_uje_check_security
  , lv_user           type uj0_s_user
  .

  zcl_bdnl_where_functions=>appset_id = i_appset_id.
  zcl_bdnl_where_functions=>appl_id   = i_appl_id.
* установка контекста
  create object lo_security.
  lv_user-user_id = lo_security->d_server_admin_id.
  cl_uj_context=>set_cur_context( i_appset_id = i_appset_id is_user = lv_user ).

*  try.
*      if i_appset_id = zblnc_keyword-bp.
*        ld_v__infocube = i_appl_id.
*        lr_o__appl ?= zcl_bd00_application=>get_infocube( i_infocube = ld_v__infocube ).
*      else.
*        lr_o__appl ?= zcl_bd00_application=>get_application( i_appset_id = i_appset_id i_appl_id = i_appl_id ).
*      endif.
*    catch zcx_bd00_create_obj.
*  endtry.

  " проверка
  while gr_o__cursor->gd_f__end ne abap_true. "gr_o__cursor->next_token( ) <> end_token.

    if gr_o__cursor->get_token( ) = zblnc_keyword-dot or
       gr_o__cursor->get_token( ) = zblnc_keyword-notsupress.
      "error
      exit.
    endif.

    clear
    : ld_s__range
    .

    " FROM FILTER
    if gr_o__cursor->check_tokens( q = 2 regex = cs_from_filter ) = abap_true.
      gr_o__cursor->get_token( trn = 2 esc = abap_true ).
      if gr_o__cursor->check_tokens( q = 1 regex = cs_dimension ) = abap_true.
        ld_v__filter_name = gr_o__cursor->get_token( esc = abap_true ).

        read table gd_t__range
             with key name = ld_v__filter_name
             into ld_s__frange.
        if sy-subrc = 0.
          e_t__range = ld_s__frange-range.
        else.
          raise exception type zcx_bdnl_syntax_error
           exporting textid = zcx_bdnl_syntax_error=>zcx_filter_unknow
                     token  = ld_v__filter_name
                     index  = gr_o__cursor->gd_v__index .
        endif.
      else.
        raise exception type zcx_bdnl_syntax_error
              exporting textid = zcx_bdnl_syntax_error=>zcx_unable_interpret
                token  = ld_v__token
                index  = gr_o__cursor->gd_v__index .
      endif.
      exit.
    endif.

    clear
    : zcl_bdnl_where_functions=>dimension
    , zcl_bdnl_where_functions=>attribute
    .

    if gr_o__cursor->check_tokens( q = 1 regex = cs_dimension ) = abap_true.
      ld_s__range-dimension = zcl_bdnl_where_functions=>dimension = gr_o__cursor->get_token( esc = abap_true ).

      " check dimension
      if i_appl_id is supplied.
        if i_appl_obj->check_dimension( dimension = ld_s__range-dimension attribute = space ) = abap_false.
          raise exception type zcx_bdnl_syntax_error
                exporting textid    = zcx_bdnl_syntax_error=>zcx_dimension
                          appset_id = i_appset_id
                          appl_id   = i_appl_id
                          dimension = ld_s__range-dimension
                          index     = gr_o__cursor->gd_v__cindex.
        endif.
      else.
        select single dimension from uja_dim_appl
              into ld_s__range-dimension
              where appset_id      = i_appset_id
                and dimension      = ld_s__range-dimension.

        if sy-subrc <> 0.
          raise exception type zcx_bdnl_syntax_error
                exporting textid    = zcx_bdnl_syntax_error=>zcx_dimension
                          appset_id = i_appset_id
                          dimension = ld_s__range-dimension
                          index     = gr_o__cursor->gd_v__index.
        endif.
      endif.

      if gr_o__cursor->check_tokens( q = 2 regex = cs_dimwattr ) = abap_true.
        ld_s__range-attribute = zcl_bdnl_where_functions=>attribute = gr_o__cursor->get_token( esc = abap_true trn = 2 ).
        if i_appl_id is supplied.
           if i_appl_obj->check_dimension( dimension = ld_s__range-dimension attribute = ld_s__range-attribute ) = abap_false.
            raise exception type zcx_bdnl_syntax_error
              exporting textid    = zcx_bdnl_syntax_error=>zcx_attribute
                        dimension = ld_s__range-dimension
                        attribute = ld_s__range-attribute
                        index     = gr_o__cursor->gd_v__index.
          endif.
        else.
          select single dimension attribute_name
                 from uja_dim_attr
                 into (ld_s__range-dimension,ld_s__range-attribute)
                 where appset_id = i_appset_id and dimension = ld_s__range-dimension and attribute_name = ld_s__range-attribute.

          if sy-subrc <> 0.
            raise exception type zcx_bdnl_syntax_error
              exporting textid    = zcx_bdnl_syntax_error=>zcx_attribute
                        dimension = ld_s__range-dimension
                        attribute = ld_s__range-attribute
                        index     = gr_o__cursor->gd_v__index.
          endif.

        endif.
      endif.
    else.
      ld_v__token = gr_o__cursor->get_token( ).
      raise exception type zcx_bdnl_syntax_error
            exporting textid = zcx_bdnl_syntax_error=>zcx_unable_interpret
                      token  = ld_v__token
                      index  = gr_o__cursor->gd_v__index .
    endif.

    ld_s__range-sign = `I`.

    if gr_o__cursor->get_token( ) = zblnc_keyword-not.
      gr_o__cursor->get_token( esc = abap_true ).
      ld_s__range-sign = `E`.
    endif.

    if gr_o__cursor->check_tokens( q = 1 regex = cs_cond ) = abap_true.
      ld_v__token = gr_o__cursor->get_token( esc = abap_true ).

      call method select_where_opt
        exporting
          token  = ld_v__token
        importing
          option = ld_s__range-option.

      if gr_o__cursor->check_tokens( q = 2 regex = cs_func ) = abap_true and
         ( ld_v__token = zblnc_keyword-equal or ld_v__token = zblnc_keyword-eq ).

        ld_t__params = process_function( ).

        loop at ld_t__params into ld_v__params.
          ld_s__range-low = ld_v__params.
          append ld_s__range to e_t__range.
        endloop.
      else.
        if ld_s__range-option = zblnc_keyword-bt.
          if gr_o__cursor->check_tokens( q = 3 regex = cs_beetwen ) = abap_true.
            ld_s__range-low = gr_o__cursor->get_token( esc = abap_true ).
            ld_s__range-high = gr_o__cursor->get_token( esc = abap_true trn = 2 ).
          else.
            raise exception type zcx_bdnl_syntax_error
                  exporting textid = zcx_bdnl_syntax_error=>zcx_after_beetween
                            index  = gr_o__cursor->gd_v__index .
          endif.

        else.
          ld_s__range-low = gr_o__cursor->get_token( esc = abap_true ).
        endif.
        append ld_s__range to e_t__range.
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
