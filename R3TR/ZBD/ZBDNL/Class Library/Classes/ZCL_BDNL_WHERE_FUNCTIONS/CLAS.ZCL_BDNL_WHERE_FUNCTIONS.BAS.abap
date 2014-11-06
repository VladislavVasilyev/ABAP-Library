method bas.

  data
  : ld_v__member      type string
  , ld_t__member      type table of string
  , ld_t__param       type zbnlt_t__param
  , ld_v__dimension   type uj_dim_name
  , ld_v__appset_id   type uj_appset_id
*  , lv_user           type uj0_s_user
*  , lo_security       type ref to cl_uje_check_security

  .

  if i02 is supplied.
    ld_v__dimension = i02.
  else.
    ld_v__dimension = dimension.
  endif.

  if i03 is supplied.
    ld_v__appset_id = i03.
  else.
    ld_v__appset_id = appset_id.
  endif.


  if appset_id is initial or
     dimension is initial.
    "error
  endif.

  if attribute is not initial.
    "error
  endif.

  ld_v__member = i01.

*  create object lo_security.
*  lv_user-user_id = lo_security->d_server_admin_id.
  cl_uj_context=>set_cur_context( i_appset_id = ld_v__appset_id is_user = zcl_bd00_context=>gd_s__user_id ).

  condense ld_v__member no-gaps.
  split ld_v__member at `,` into table ld_t__member.

  loop at ld_t__member into ld_v__member.
    ld_v__member = cl_ujk_util=>bas( i_dim_name = ld_v__dimension i_member = ld_v__member ).
    split ld_v__member at ',' into table ld_t__param.
    append lines of ld_t__param to e.
  endloop.

  sort e.
  delete adjacent duplicates from e.

endmethod.
