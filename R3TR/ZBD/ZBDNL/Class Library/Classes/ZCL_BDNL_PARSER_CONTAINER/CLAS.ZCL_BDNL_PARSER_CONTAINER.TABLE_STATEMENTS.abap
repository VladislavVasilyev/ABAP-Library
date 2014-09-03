method table_statements.

  constants
  : cs__regex   type string value `^([A-Z0-9\_]+)\>\~\<([A-Z0-9\_]+)\>`
  , cs_for_down type string value `^(FOR\sDOWNLOAD\sTO)\>`
  .

  data
  : ld_v__index         type i
  , ld_v__token         type string
  , ld_f__fordown       type rs_bool
  .

  clear e_s__stack.

  e_s__stack-tablename  = gr_o__cursor->get_token( esc = abap_true chn = abap_true ).
  check_table( e_s__stack-tablename ).

*  read table gd_t__stack
*       with key tablename = e_s__stack-tablename
*       transporting no fields.
*
*  if sy-subrc = 0.
*    raise exception type zcx_bdnl_syntax_error
*        exporting textid   = zcx_bdnl_syntax_error=>zcx_has_declarate
*                  token    = e_s__stack-tablename
*                  index    = gr_o__cursor->gd_v__index.
*  endif.

  if gr_o__cursor->check_tokens( q = 3 regex = cs_for_down ) = abap_true.
    gr_o__cursor->get_token( trn = 3 esc = abap_true ).

    e_s__stack-command = zblnc_keyword-tablefordown.
    e_s__stack-type_table = zblnc_keyword-hashed.

    call method cmd_from
      importing
        e_appset_id = e_s__stack-appset_id
        e_appl_id   = e_s__stack-appl_id
        e_appl_obj  = e_s__stack-appl_obj.

    select dimension from uja_dim_appl
           into table e_s__stack-dimension
           where appset_id = e_s__stack-appset_id
             and application_id = e_s__stack-appl_id
           order by dimension ascending .
  elseif gr_o__cursor->check_tokens( q = 1 regex = zblnc_keyword-s_for ) = abap_true.
    gr_o__cursor->get_token( trn = 1 esc = abap_true ).
    call method cmd_from
      importing
        e_appset_id = e_s__stack-appset_id
        e_appl_id   = e_s__stack-appl_id
        e_appl_obj  = e_s__stack-appl_obj.

* $FIELDS
    if gr_o__cursor->get_token( ) = zblnc_keyword-fields.
      gr_o__cursor->get_token( esc = abap_true ).

      e_s__stack-command = zblnc_keyword-ctable.
      e_s__stack-type_table = zblnc_keyword-hashed.

      call method select_param_fields
        exporting
          i_appset_id          = e_s__stack-appset_id
          i_appl_id            = e_s__stack-appl_id
          i_v__type_table      = e_s__stack-type_table
          i_appl_obj           = e_s__stack-appl_obj
        importing
          e_t__alias           = e_s__stack-alias
          e_t__dimlist         = e_s__stack-dim_list
          e_t__key_list        = e_s__stack-kyf_list
          e_v__tech_type_table = e_s__stack-tech_type_table
          e_t__dimension       = e_s__stack-dimension
          e_f__write           = e_s__stack-f_write.
    endif.
  endif.

  if gr_o__cursor->get_token(  ) = zblnc_keyword-const.
    gr_o__cursor->get_token( esc = abap_true ).
    call method table_param_const
      exporting
        i_appset_id  = e_s__stack-appset_id
        i_appl_id    = e_s__stack-appl_id
        i_f__fordown = ld_f__fordown
      importing
        e_t__const   = e_s__stack-const.
  endif.

  if gr_o__cursor->get_token( esc = abap_true ) ne zblnc_keyword-dot.
    raise exception type zcx_bdnl_syntax_error
          exporting textid = zcx_bdnl_syntax_error=>zcx_unable_interpret
                    token  = ld_v__token
                    index  = gr_o__cursor->gd_v__index .
  endif.


endmethod.
