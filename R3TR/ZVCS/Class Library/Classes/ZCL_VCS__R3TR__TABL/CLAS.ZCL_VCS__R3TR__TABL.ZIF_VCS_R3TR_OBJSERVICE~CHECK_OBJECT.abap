method ZIF_VCS_R3TR_OBJSERVICE~CHECK_OBJECT.

*  data
*  : ld_v__tabname  type dd02l-tabname
*  , ld_v__tabclass type dd02l-tabclass
*  , ld_s__tadir    type zvcst_s__tadir
*  .
*
*  select single tabname tabclass
*         from dd02l
*         into (ld_v__tabname, ld_v__tabclass)
*         where tabname eq i_s__object-name.
*
*  if sy-subrc <> 0.
*    raise no_check.
*  endif.
*
*  select single *
*         from tadir
*         into ld_s__tadir
*         where pgmid    = zvcsc_r3tr
*           and object   = zvcsc_r3tr_type-tabl
*           and obj_name = ld_v__tabname.
*
*  if sy-subrc <> 0.
*    raise no_check.
*  endif.
*
*  ld_s__tadir-tabclass = ld_v__tabclass.
*  insert ld_s__tadir into table e_t__tadir.

endmethod.
