method READ_OBJECT.

  data
  : lr_x__call_module_error type ref to zcx_vcs__call_module_error
  , ld_s__shlp              type ty_s__shlp
  .

  move
  : i_s__tadir-obj_name      to  ld_s__shlp-name
  .

  try.
      call method zcl_vcs_r3tr___lib__ddif=>ddif_shlp_get
        exporting
          name      = ld_s__shlp-name
          state     = 'A'
          langu     = sy-langu
        importing
          gotstate  = ld_s__shlp-gotstate
          dd30v_wa  = ld_s__shlp-dd30v_wa
          dd31v_tab = ld_s__shlp-dd31v_tab
          dd32p_tab = ld_s__shlp-dd32p_tab
          dd33v_tab = ld_s__shlp-dd33v_tab.

    catch zcx_vcs__call_module_error into lr_x__call_module_error.
      raise exception type zcx_vcs_objects_read__r3tr
        exporting
          previous = lr_x__call_module_error
          object   = i_s__tadir-object
          obj_name = i_s__tadir-obj_name.
  endtry.

  e_s__source = ld_s__shlp.

endmethod.
