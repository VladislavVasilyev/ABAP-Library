method ZIF_VCS_R3TR_OBJSERVICE~CHECK_OBJECT.

*  data
*  : ld_v__dtel  type dd04l-rollname
*  , ld_s__tadir type zvcst_s__tadir
*  .
*
*  select single rollname
*         from dd04l
*         into ld_v__dtel
*         where rollname eq i_s__object-name.
*
*  if sy-subrc ne 0.
*    raise no_check.
*  endif.
*
*  select single *
*         from  tadir
*         into ld_s__tadir
*         where object = zvcsc_r3tr_type-dtel
*           and obj_name = ld_v__dtel.
*
*  if sy-subrc = 0.
*    insert ld_s__tadir into table e_t__tadir.
*  else.
*    raise no_check.
*  endif.

endmethod.
