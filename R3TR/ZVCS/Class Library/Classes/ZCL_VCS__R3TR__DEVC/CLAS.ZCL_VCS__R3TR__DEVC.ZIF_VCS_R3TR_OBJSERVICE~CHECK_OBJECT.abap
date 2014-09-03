method ZIF_VCS_R3TR_OBJSERVICE~CHECK_OBJECT.
*
*  data
*  : ld_v__devclass   type tdevc-devclass
*  , ld_t__devclass   type standard table of tdevc-devclass
*  , ld_t__tadir      type standard table of zvcst_s__tadir
*  .
*
*  field-symbols
*  : <ld_s__devclass> like line of ld_t__devclass
*  .
*
*  refresh
*  : e_t__tadir
*  , ld_t__devclass
*  .
*
*  select single devclass
*         from tdevc
*         into ld_v__devclass
*         where devclass = i_s__object-name.
*
*  if sy-subrc <> 0.
*    raise no_check.
*  endif.
*
*  " check in sub devlcass
*  select  devclass
*    from  tdevc
*    into table ld_t__devclass
*    where parentcl = ld_v__devclass.
*
*  append i_s__object-name to ld_t__devclass.
*
*  loop at ld_t__devclass
*       assigning <ld_s__devclass>.
*
*    select *
*           from tadir
*           appending table ld_t__tadir
*           where devclass = <ld_s__devclass>.
*  endloop.
*
*  insert lines of ld_t__tadir into table e_t__tadir.

endmethod.
