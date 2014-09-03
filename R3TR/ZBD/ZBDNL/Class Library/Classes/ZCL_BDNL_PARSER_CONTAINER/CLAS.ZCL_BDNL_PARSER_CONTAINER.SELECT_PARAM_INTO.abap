method select_param_into.

  constants
  : cs_regex_type_table type string value `^(SORTED\sTABLE|HASHED\sTABLE|STANDARD\sTABLE)\>\s\<([A-Z0-9\_]+)\>`
  , cs_standart_table   type string value `^(TABLE)\>\s\<([A-Z0-9\_]+)\>`
  , cs_type_table       type string value `^(MASTER|SAVE)\>`
  , cs_package_size     type string value `^(PACKAGE\sSIZE)\>\s\<([0-9]+)\>`
  .

  data
  : ld_v__token       type string
  , ld_v__express     type string value ``
  , ld_v__mode        type string
  .

  if gr_o__cursor->set_cursor( word = zblnc_keyword-into escape = zblnc_keyword-dot fesc = abap_true ) eq err_index.
    raise exception type zcx_bdnl_syntax_error
          exporting textid    = zcx_bdnl_syntax_error=>zcx_after_select
                    expected  = `$INTO ... `
                    index     = gr_o__cursor->gd_v__cindex.
  endif.

  if gr_o__cursor->check_tokens( q = 3 regex = cs_regex_type_table ) = abap_true.
    e_v__type_table = gr_o__cursor->get_token( esc = abap_true ).
    gr_o__cursor->get_token( esc = abap_true ).
  else.
    if gr_o__cursor->check_tokens( q = 2 regex = cs_standart_table ) = abap_true.
      e_v__type_table = zblnc_keyword-standard.
      gr_o__cursor->get_token( esc = abap_true ).
    else.
      raise exception type zcx_bdnl_syntax_error
        exporting textid   = zcx_bdnl_syntax_error=>zcx_expected
                  expected = ` [SOTRTED|HASHED|STANDARD] TABLE name, after INTO ...`
                  index     = gr_o__cursor->gd_v__index.
    endif.
  endif.

  e_v__tablename  = gr_o__cursor->get_token( esc = abap_true  chn = abap_true ).
  check_table( e_v__tablename ).

**  read table gd_t__stack
**       with key tablename = e_v__tablename
**                transporting no fields.
**
**  if sy-subrc = 0.
**    raise exception type zcx_bdnl_syntax_error
**        exporting textid   = zcx_bdnl_syntax_error=>zcx_has_declarate
**                  token    = e_v__tablename
**                  index    = gr_o__cursor->gd_v__cindex.
**  endif.

*  if gr_o__cursor->check_tokens( q = 1 regex = cs_type_table ) = abap_true.
*    e_v__mode_table = gr_o__cursor->get_token( esc = abap_true ).
*    e_v__package_size = -1.
*
*    if e_v__mode_table = zblnc_keyword-master.
*
*      read table  gd_t__stack
*           with key mode_table = zblnc_keyword-master
*           transporting no fields.
*
*      if sy-subrc eq 0.
*        raise exception type zcx_bdnl_syntax_error
*            exporting textid   = zcx_bdnl_syntax_error=>zcx_one_master
*                 index    = gr_o__cursor->gd_v__index.
*      endif.
*
*      if gr_o__cursor->check_tokens( q = 3 regex = cs_package_size ) = abap_true.
*        e_v__package_size = gr_o__cursor->get_token( esc = abap_true trn = 3 ).
*      endif.
*    endif.
*  else.
*    e_v__mode_table = zblnc_keyword-save.
*  endif.

endmethod.
