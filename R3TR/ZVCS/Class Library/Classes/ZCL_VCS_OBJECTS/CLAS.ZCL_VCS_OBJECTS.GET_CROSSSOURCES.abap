method GET_CROSSSOURCES.

  data
  : lr_o__object              type ref to zcl_vcs_objects_stack
  , ld_t__tadir               type zvcst_t__tadir
  , ld_s__tadir               type zvcst_s__tadir
  , ld_t__crosstadir          type zvcst_t__tadir
  , ld_s__type                type zvcst_s__object
  .

  field-symbols
  : <ld_s__tadir>             type zvcst_s__tadir
  .

  ld_s__type-pgmid   = i_s__tadir-pgmid.
  ld_s__type-object  = i_s__tadir-object.

  check zcl_vcs_objects_stack=>check_type( ld_s__type ) = abap_true.

  try.
      lr_o__object ?= zcl_vcs_objects_stack=>get_object( ld_s__type ).
      call method lr_o__object->crosssources
        exporting
          i_s__tadir = i_s__tadir
        importing
          e_t__tadir = ld_t__tadir.

      insert       i_s__tadir into table c_t__tadir. " стек искомых элементов
      loop at ld_t__tadir
           assigning <ld_s__tadir>.
        read table c_t__tadir from <ld_s__tadir>
        transporting no fields.
        check sy-subrc = 0.
        delete ld_t__tadir.
      endloop.

      loop at ld_t__tadir
           assigning <ld_s__tadir>.

        check zcl_vcs_objects_stack=>check_type( ld_s__type ) = abap_true.

        refresh ld_t__crosstadir.
        call method get_crosssources
          exporting
            i_s__tadir = <ld_s__tadir>
          importing
            e_t__tadir = ld_t__crosstadir
          changing
            c_t__tadir = c_t__tadir.

        loop at ld_t__crosstadir
             into ld_s__tadir.
          insert ld_s__tadir into table e_t__tadir.
        endloop.

        insert <ld_s__tadir> into table e_t__tadir.
      endloop.

*      e_t__tadir = ld_t__crosstadir.

    catch cx_sy_move_cast_error cx_sy_dyn_call_error.

  endtry.

endmethod.
