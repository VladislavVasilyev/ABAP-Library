method select_param_fields.

  constants
  : cs_dimension        type string value `^([A-Z0-9\_]+|\/([A-Z0-9]+)\/([A-Z0-9\_]+))\>`
  , cs_dimwattr         type string value `^\~\<([A-Z0-9\_]+)\>`
  .

  type-pools: zbd0c.

  data
  : ld_f__open_p        type rs_bool
  , ld_v__token         type string
  , ld_s__dim           type zbd00_s_ch_key
  , ld_s__alias         type zbd00_s_alias
  , ld_v__express       type string
  , ld_f__key           type rs_bool
  , ld_f__skipfirst     type rs_bool
  , ld_s__dimension     type zbd0t_ty_s_dim
  , ld_f__uk            type rs_bool
  , ld_v__cnt           type i
  .

  field-symbols
  : <ld_s__dimension>   type zbd0t_ty_s_dim
  , <ld_s__appldim>     type zbd00_s_dimn
  .

  while gr_o__cursor->gd_f__end ne abap_true. "gr_o__cursor->next_token( ) <> end_token.

    ld_v__token = gr_o__cursor->get_token( ).

    if ld_f__skipfirst ne abap_true.
      ld_f__skipfirst = abap_true.

      case ld_v__token."тип таблицы
        when zblnc_keyword-nuk."non-unique-key
          gr_o__cursor->get_token( esc = abap_true ).
          ld_f__key = abap_true.
          case i_v__type_table.
            when zblnc_keyword-sorted.
              if i_appl_id =  zblnc_keyword-generate or i_appl_id =  zblnc_keyword-custom.
                " error хэш таблица или стандарт не может содержать не уникальне поля
                raise exception type zcx_bdnl_syntax_error
                      exporting textid   = zcx_bdnl_syntax_error=>zcx_table_nu
                                index    = gr_o__cursor->gd_v__cindex.
              endif.

              e_v__tech_type_table = zbd0c_ty_tab-srd_non_unique.
              ld_f__uk = abap_true.
              if gr_o__cursor->get_token( ) = zblnc_keyword-open_parenthesis.
                gr_o__cursor->get_token( esc = abap_true ).
                ld_f__open_p = abap_true.
                continue.
              else.
                raise exception type zcx_bdnl_syntax_error
                    exporting textid   = zcx_bdnl_syntax_error=>zcx_expected
                              expected = zblnc_keyword-open_parenthesis
                              index     = gr_o__cursor->gd_v__cindex.
              endif.
            when others.
              " error хэш таблица или стандарт не может содержать не уникальне поля
              raise exception type zcx_bdnl_syntax_error
                  exporting textid   = zcx_bdnl_syntax_error=>zcx_table_nu
                            index    = gr_o__cursor->gd_v__cindex.
          endcase.
        when others."unique-key
          case i_v__type_table.
            when zblnc_keyword-sorted.
              ld_f__key = abap_true.
              e_v__tech_type_table = zbd0c_ty_tab-srd_unique_dk.
            when zblnc_keyword-hashed.
              ld_f__key = abap_true.
              e_v__tech_type_table = zbd0c_ty_tab-has_unique_dk.
            when zblnc_keyword-standard.
              ld_f__key = abap_false.
              e_v__tech_type_table = zbd0c_ty_tab-std_non_unique_dk.
          endcase.

          if ld_v__token = zblnc_keyword-star.
            gr_o__cursor->get_token( esc = abap_true ).

            loop at i_appl_obj->gd_t__dimensions assigning <ld_s__appldim>
              where type = zcl_bd00_application=>cs_dm.
              append <ld_s__appldim>-dimension to e_t__dimension.
            endloop.
            e_f__write = abap_true.
            return.
          endif.

      endcase.
    endif.

    " выход из SELECT
    if ld_v__token = zblnc_keyword-where       or
       ld_v__token = zblnc_keyword-from        or
       ld_v__token = zblnc_keyword-into        or
       ld_v__token = zblnc_keyword-notsupress  or
       ld_v__token = zblnc_keyword-const       or
       ld_v__token = zblnc_keyword-dot.

      if ld_f__open_p = abap_true.
        raise exception type zcx_bdnl_syntax_error
            exporting textid   = zcx_bdnl_syntax_error=>zcx_expected
                      expected = zblnc_keyword-close_parenthesis
                      index     = gr_o__cursor->gd_v__index.
      endif.
      exit.
    elseif ld_v__token = zblnc_keyword-close_parenthesis.
      if ld_f__open_p = abap_true.
        gr_o__cursor->get_token( esc = abap_true ).
        ld_f__open_p = abap_false.
        ld_f__key = abap_false.
        continue.
      endif.
    endif.

    clear
    : ld_s__dim-dimension
    , ld_s__dim-attribute
    , ld_s__alias
    .

    if gr_o__cursor->check_tokens( q = 1 regex = cs_dimension ) = abap_true.
      add 1 to ld_s__dim-orderby.
      ld_s__dim-f_key = ld_f__key.
      ld_s__dim-dimension = gr_o__cursor->get_token( esc = abap_true ).

      if i_appl_obj->check_dimension( dimension = ld_s__dim-dimension attribute = space ) = abap_false.
        raise exception type zcx_bdnl_syntax_error
              exporting textid    = zcx_bdnl_syntax_error=>zcx_dimension
                        appset_id = i_appset_id
                        appl_id   = i_appl_id
                        dimension = ld_s__dim-dimension
                        index     = gr_o__cursor->gd_v__cindex.
      endif.

      if ld_f__uk = abap_true and ld_f__open_p = abap_false.
        e_v__tech_type_table = zbd0c_ty_tab-srd_non_unique.
      endif.

      if gr_o__cursor->check_tokens( q = 2 regex = cs_dimwattr ) = abap_true.
        ld_s__dim-attribute = gr_o__cursor->get_token( esc = abap_true trn = 2 ).

        if i_appl_obj->check_dimension( dimension = ld_s__dim-dimension attribute = space ) = abap_false..
          raise exception type zcx_bdnl_syntax_error
            exporting textid    = zcx_bdnl_syntax_error=>zcx_attribute
                      dimension = ld_s__dim-dimension
                      attribute = ld_s__dim-attribute
                      index     = gr_o__cursor->gd_v__cindex.
        endif.
      endif.

      if i_appl_obj->get_type( dimension = ld_s__dim-dimension attribute = space ) = zcl_bd00_application=>cs_kf.
        insert ld_s__dim-dimension into table e_t__key_list.
      else.
        insert ld_s__dim           into table e_t__dimlist.
      endif.

      ld_s__dimension-dimension = ld_s__dim-dimension.
      ld_s__dimension-attribute = ld_s__dim-attribute.

      append ld_s__dimension to e_t__dimension assigning <ld_s__dimension>.

    else.
      ld_v__token = gr_o__cursor->get_token( ).
      raise exception type zcx_bdnl_syntax_error
        exporting textid = zcx_bdnl_syntax_error=>zcx_unable_interpret
                  token  = ld_v__token
                  index  = gr_o__cursor->gd_v__cindex .
    endif.

    check i_appset_id ne zblnc_keyword-bp.
*--------------------------------------------------------------------*
* ALIASES
*--------------------------------------------------------------------*
    if gr_o__cursor->get_token( ) = zblnc_keyword-as.
      gr_o__cursor->get_token( esc = abap_true ).

      if gr_o__cursor->check_tokens( q = 1 regex = cs_dimension ) = abap_true.
        ld_s__alias-bpc_alias-dimension = gr_o__cursor->get_token( esc = abap_true ).

        if gr_o__cursor->check_tokens( q = 2 regex = cs_dimwattr ) = abap_true.
          ld_s__alias-bpc_alias-attribute = gr_o__cursor->get_token( esc = abap_true ).
        endif.
      else.
        "error
      endif.
      ld_s__alias-bpc_name-dimension = ld_s__dim-dimension.
      ld_s__alias-bpc_name-attribute = ld_s__dim-attribute.

      insert  ld_s__alias into table e_t__alias.

      <ld_s__dimension>-dimension = ld_s__alias-bpc_alias-dimension.
      <ld_s__dimension>-attribute = ld_s__alias-bpc_alias-attribute.

    else.
      continue.
    endif.
  endwhile.

*--------------------------------------------------------------------*
* Проверка полей на возможность сохранения
*--------------------------------------------------------------------*
  e_f__write = abap_true.

  loop at i_appl_obj->gd_t__dimensions assigning <ld_s__appldim>
    where type = zcl_bd00_application=>cs_dm.

    add 1 to ld_v__cnt.

    read table e_t__dimension
         with key dimension = <ld_s__appldim>-dimension
         transporting no fields.

    if sy-subrc <> 0.
      e_f__write = abap_false.
      exit.
    endif.
  endloop.

  if ld_v__cnt <> lines( e_t__dimension ).
    e_f__write = abap_false.
  endif.

endmethod.
