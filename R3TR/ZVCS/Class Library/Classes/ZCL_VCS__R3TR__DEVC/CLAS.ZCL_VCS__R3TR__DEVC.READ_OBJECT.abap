method READ_OBJECT.

  data
  : lr_x__call_module_error type ref to zcx_vcs__call_module_error
  , ld_s__devc              type ty_s__devc
  .

  move i_s__tadir-obj_name to ld_s__devc-name.

  try.
      call method zcl_vcs_r3tr___tech=>tr_devclass_get
        exporting
          iv_devclass = ld_s__devc-name
          iv_langu    = i_s__tadir-masterlang
        importing
          es_tdevc    = ld_s__devc-tdevc.
    catch zcx_vcs__call_module_error .
      raise exception type zcx_vcs_objects_read__r3tr
        exporting
          previous = lr_x__call_module_error
          object   = i_s__tadir-object
          obj_name = i_s__tadir-obj_name.
  endtry.

  e_s__source = ld_s__devc.

endmethod.
