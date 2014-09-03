method set_task_download_for_r3tr.

  data
  : ld_s__task_stack  type zvcst_s__tadir
  .

  field-symbols
  : <ld_s__object>    like line of i_t__object
  .

*  cd_v__path = i_s__path.
*  cd_f__checkreference = abap_false.
  " check object

  ld_s__task_stack-pgmid = zvcsc_r3tr.

  loop at i_t__object
    assigning <ld_s__object>.

    select *
           from  tadir
           into  corresponding fields of ld_s__task_stack
           where pgmid    = <ld_s__object>-pgid
             and object   = <ld_s__object>-type
             and obj_name in <ld_s__object>-obj_range
             and delflag ne abap_true.


      if ld_s__task_stack-object = zvcsc_r3tr_type-tabl.
        select single tabclass
               from dd02l
               into ld_s__task_stack-tabclass
               where tabname = ld_s__task_stack-obj_name.
      endif.


      data
      : ld_v__devclass   type tdevc-devclass
      .

      ld_s__task_stack-pathdevc = ld_v__devclass = ld_s__task_stack-devclass.

      while 1 = 1.
        " check in sub devlcass
        select single parentcl
               from tdevc
               into ld_v__devclass
               where devclass = ld_v__devclass
                 and parentcl <> ``.

        if sy-subrc = 0.
          concatenate ld_v__devclass `\` ld_s__task_stack-pathdevc into ld_s__task_stack-pathdevc.
        else.
          exit.
        endif.
      endwhile.

      insert ld_s__task_stack into table zcl_vcs_objects_stack=>cd_t__task_stack.

    endselect.
  endloop.

endmethod.
