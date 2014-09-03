method READ_OBJECT.

  data
  : lr_x__call_module_error type ref to zcx_vcs__call_module_error
  , ld_s__type              type ty_s__type
  .

  move
  : i_s__tadir-obj_name      to ld_s__type-name
  .

  try.
      call method zcl_vcs_r3tr___lib__ddif=>ddif_type_get
        exporting
          name   = ld_s__type-name
        importing
          source = ld_s__type-source
          texts  = ld_s__type-texts.

       data ld_s__txtsource type zvcst_s__source_path.

      ld_s__txtsource-pathnode = `/SOURCE`.
*      ld_s__txtsource-pathname = `/NAME`.
      append  ld_s__txtsource to e_t__txtsource.

      e_s__source = ld_s__type .

    catch zcx_vcs__call_module_error into lr_x__call_module_error.
      raise exception type zcx_vcs_objects_read__r3tr
        exporting
          previous = lr_x__call_module_error
          object   = i_s__tadir-object
          obj_name = i_s__tadir-obj_name.
  endtry.

  e_s__source = ld_s__type.

endmethod.
