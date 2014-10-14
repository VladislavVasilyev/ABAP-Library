method cmd_from.

  constants
  : cs__regex     type string value `^([A-Z0-9\_]+)\>\~(\<([A-Z0-9\_]+)\>|\$GENERATE\>)`
  , cs__regex1    type string value `^\$BP\>\~(\<([A-Z0-9\_]+)\>|\/(CPMB)\/([A-Z0-9\_]+)\>)`
  , cs__regex2    type string value `^([A-Z0-9\_]+)\>`
  .

  data
  : ld_v__express     type string
  , ld_v__token       type string
  , ld_v__index       type i
  , ld_v__infocube    type rsinfoprov
  .

  if gr_o__cursor->check_tokens( q = 3 regex = cs__regex ) = abap_true.

    e_appset_id = gr_o__cursor->get_token( esc = abap_true ). " read APPSET_ID

    select single appset_id from uja_appset_info     " check appset
           into   e_appset_id
           where  appset_id = e_appset_id.

    if sy-subrc <> 0.
      raise exception type zcx_bdnl_syntax_error
             exporting textid    =  zcx_bdnl_syntax_error=>zcx_appset_unknow
                       appset_id = e_appset_id
                       index     = gr_o__cursor->gd_v__index.
    endif.

    gr_o__cursor->get_token( esc = abap_true ).
    ld_v__index = gr_o__cursor->gd_v__index.

    " read APPLICATION_ID
    e_appl_id = ld_v__token = gr_o__cursor->get_token( ).

    if e_appl_id = zblnc_keyword-generate.
      gr_o__cursor->get_token( esc = abap_true ).
      e_appl_obj ?= zcl_bd00_application=>get_customize_application( i_appset_id = e_appset_id ).
      return.
    endif.

    if e_appl_id = zblnc_keyword-custom.
      gr_o__cursor->get_token( esc = abap_true ).
      e_appl_obj ?= zcl_bd00_application=>get_customize_application( i_appset_id = e_appset_id ).
      return.
    endif.

    select single application_id from uja_appl
        into e_appl_id
        where appset_id = e_appset_id
          and application_id = e_appl_id.

    if sy-subrc <> 0.
      e_dim_name = ld_v__token = gr_o__cursor->get_token( ).

      select single dimension
             from   uja_dimension
             into   e_dim_name
             where  appset_id = e_appset_id
               and  dimension = e_dim_name.

      if sy-subrc <> 0.
        raise exception type zcx_bdnl_syntax_error
         exporting textid    =  zcx_bdnl_syntax_error=>zcx_appl_or_dim_unknow
                   appset_id = e_appset_id
                   token     = ld_v__token
                   index     = ld_v__index.
      else.
        e_appl_obj ?= zcl_bd00_application=>get_dimension( i_appset_id = e_appset_id i_dimension = e_dim_name ).
        clear e_appl_id.
      endif.
    else.
      e_appl_obj ?= zcl_bd00_application=>get_application( i_appset_id = e_appset_id i_appl_id = e_appl_id ).
    endif.

    gr_o__cursor->get_token( esc = abap_true ).

  elseif gr_o__cursor->check_tokens( q = 3 regex = cs__regex1 ) = abap_true.
    e_appset_id = gr_o__cursor->get_token( esc = abap_true trn = 1 ).

    gr_o__cursor->get_token( esc = abap_true )." ~
    ld_v__index = gr_o__cursor->gd_v__index.

    e_appl_id = ld_v__infocube = gr_o__cursor->get_token( esc = abap_true ).

    select single infocube
        from rsdcube
        into e_appl_id
        where infocube = e_appl_id
          and objvers = `A`.

    if sy-subrc <> 0.
      raise exception type zcx_bdnl_syntax_error
            exporting textid    = zcx_bdnl_syntax_error=>zcx_infocube_unknow
                      appl_id   = e_appl_id
                      index     = ld_v__index.
    else.
      e_appl_obj ?= zcl_bd00_application=>get_infocube( i_infocube = ld_v__infocube ).
    endif.

  else.
    raise exception type zcx_bdnl_syntax_error
      exporting textid   = zcx_bdnl_syntax_error=>zcx_expected
                expected = `APPSET~APPLICATION or $BP~INFOCUBE`
                index     = gr_o__cursor->gd_v__index.
  endif.

endmethod.
