method READ_OBJECT.

  data
  : lr_x__call_module_error type ref to zcx_vcs__call_module_error
  , ld_s__ttyp              type ty_s__ttyp
  .

  move
  : i_s__tadir-obj_name to ld_s__ttyp-name
  .

  try.
      call method zcl_vcs_r3tr___lib__ddif=>ddif_ttyp_get
        exporting
          name      = ld_s__ttyp-name
          langu     = i_s__tadir-masterlang
        importing
          gotstate  = ld_s__ttyp-gotstate
          dd40v_wa  = ld_s__ttyp-dd40v_wa
          dd42v_tab = ld_s__ttyp-dd42v_tab.

    e_s__source = ld_s__ttyp.

    catch zcx_vcs__call_module_error into lr_x__call_module_error.
      raise exception type zcx_vcs_objects_read__r3tr
        exporting
          previous = lr_x__call_module_error
          object   = i_s__tadir-object
          obj_name = i_s__tadir-obj_name.
  endtry.

endmethod.
