method read_object.

  data
  : lr_x__call_module_error type ref to zcx_vcs__call_module_error
  , ld_s__dtel            type ty_s__dtel
  .

  move
  : i_s__tadir-obj_name     to ld_s__dtel-name
  .

  try.
      call method zcl_vcs_r3tr___lib__ddif=>ddif_dtel_get
        exporting
          name     = ld_s__dtel-name
          langu    = sy-langu
        importing
          gotstate = ld_s__dtel-gotstate
          dd04v_wa = ld_s__dtel-dd04v_wa
          tpara_wa = ld_s__dtel-tpara_wa.

* Rueckgabe
    catch zcx_vcs__call_module_error into lr_x__call_module_error.
      raise exception type zcx_vcs_objects_read__r3tr
        exporting
          previous = lr_x__call_module_error
          object   = i_s__tadir-object
          obj_name = i_s__tadir-obj_name.
  endtry.

  e_s__source = ld_s__dtel.

endmethod.
