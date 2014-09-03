method READ_OBJECT.

  data
  : lr_x__call_module_error type ref to zcx_vcs__call_module_error
  , ld_s__prog  type ty_s__prog
  .

  move
  : i_s__tadir-obj_name     to ld_s__prog-name
  .

  data: source_extended type standard table of abaptxt255.

  try.
      call method zcl_vcs_r3tr___tech=>rpy_program_read
        exporting
          language         = sy-langu
          program_name     = ld_s__prog-name
          with_includelist = space
        importing
          prog_inf         = ld_s__prog-prog_inf
          source_extended  = source_extended
          textelements     = ld_s__prog-textpool-textpool.

      ld_s__prog-source[] = source_extended[].

      " read title
      select single text
             from trdirt
             into ld_s__prog-title
             where name = ld_s__prog-name.

      if ld_s__prog-source is initial.
      call method zcl_vcs_r3tr___tech=>read_source
        exporting
          i_v__name   = ld_s__prog-name
        importing
          e_t__source = ld_s__prog-source.
    endif.

    call method collect_dynpro
      exporting
        progname    = ld_s__prog-name
      importing
        e_t__dynpro = ld_s__prog-dynpros.


**********************************************************************
* Save TXT
**********************************************************************
      data ld_s__txtsource type zvcst_s__source_path.

      ld_s__txtsource-pathnode = `/SOURCE`.
*      ld_s__txtsource-pathname = `/NAME`.
      append  ld_s__txtsource to e_t__txtsource.


  catch zcx_vcs__call_module_error into lr_x__call_module_error.
      raise exception type zcx_vcs_objects_read__r3tr
        exporting
          previous = lr_x__call_module_error
          object   = i_s__tadir-object
          obj_name = i_s__tadir-obj_name.
endtry.

  e_s__source = ld_s__prog.

endmethod.
