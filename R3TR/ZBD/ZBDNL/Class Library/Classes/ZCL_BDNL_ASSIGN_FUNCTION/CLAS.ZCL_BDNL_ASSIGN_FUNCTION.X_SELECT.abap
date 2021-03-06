method x_select.

  data
  : ld_v__appset                            type uj_appset_id
  , ld_v__appl                              type uj_appl_id
  , ld_v__user                              type uj_user_id
  , ld_v_stat                               type string
  , it_script_logic_hashtable	              type ujk_t_script_logic_hashtable
  , ld_s__result                            type ty_s__result
  .

  field-symbols
  : <ld_s__result>                          type ty_s__result
  .

  concatenate `%E%` `,` i01 `,` i02 `,` i03 into ld_v_stat.

  if i04 is supplied.
    ld_v__appset = i04.
  else.
    ld_v__appset = zcl_bd00_context=>gv_appset_id.
  endif.

  if i05 is supplied.
    ld_v__appl = i05.
  else.
    ld_v__appl = zcl_bd00_context=>gv_appl_id.
  endif.

  concatenate ld_v_stat `|` ld_v__appset `|` ld_v__appl into ld_s__result-key.

  read table cd_t__x_select
    from ld_s__result
    assigning <ld_s__result>.

  if sy-subrc = 0.
    e = <ld_s__result>-e.
    return.
  endif.

  ld_v__user = zcl_bd00_context=>gd_s__user_id-user_id.

  cl_uj_context=>set_cur_context( i_appset_id = ld_v__appset i_appl_id = ld_v__appl is_user = zcl_bd00_context=>gd_s__user_id ).

  call method cl_ujk_select=>check_select
    exporting
      i_appset                  = ld_v__appset
      i_application             = ld_v__appl
      i_user                    = ld_v__user
      i_string_statement        = ld_v_stat
      it_script_logic_hashtable = it_script_logic_hashtable
    importing
      e_result                  = e.

  ld_s__result-e = e.

  insert ld_s__result into table cd_t__x_select.

endmethod.
