method CROSSSOURCES.

  data
  : ld_t__tadir   type zvcst_t__tadir
  .

  field-symbols
  : <ld_s__task_stack>       type zvcst_s__tadir
  , <ld_s__tadir>            type zvcst_s__tadir
  .

  loop at zcl_vcs_objects_stack=>cd_t__task_stack
        assigning <ld_s__task_stack>.

    clear ld_t__tadir.

    call method get_crosssources
      exporting
        i_s__tadir = <ld_s__task_stack>
      importing
        e_t__tadir = ld_t__tadir.

    loop at ld_t__tadir assigning <ld_s__tadir>.

      check <ld_s__tadir> is not initial.

      if <ld_s__tadir>-pgmid = zvcsc_r3tr.
        <ld_s__tadir>-tabclass = get_tabclass( <ld_s__tadir>-obj_name ).
        <ld_s__tadir>-pathdevc = get_pathdevc( <ld_s__tadir>-devclass ).
      endif.

      insert <ld_s__tadir> into table zcl_vcs_objects_stack=>cd_t__task_stack.
    endloop.

  endloop.

endmethod.
