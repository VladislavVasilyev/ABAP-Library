method READ_OBJECT.

  data
  : lr_x__call_module_error type ref to zcx_vcs__call_module_error
  , ld_s__view              type ty_s__view
  .

  move
  : i_s__tadir-obj_name to ld_s__view-name
  .

  try.
      call method zcl_vcs_r3tr___lib__ddif=>ddif_view_get
        exporting
          name      = ld_s__view-name
          langu     = i_s__tadir-masterlang
        importing
          gotstate  = ld_s__view-gotstate
          dd25v_wa  = ld_s__view-dd25v_wa
          dd09l_wa  = ld_s__view-dd09l_wa
          dd26v_tab = ld_s__view-dd26v_tab
          dd27p_tab = ld_s__view-dd27p_tab
          dd28j_tab = ld_s__view-dd28j_tab
          dd28v_tab = ld_s__view-dd28v_tab.

    e_s__source = ld_s__view.

    catch zcx_vcs__call_module_error into lr_x__call_module_error.
      raise exception type zcx_vcs_objects_read__r3tr
        exporting
          previous = lr_x__call_module_error
          object   = i_s__tadir-object
          obj_name = i_s__tadir-obj_name.
  endtry.
endmethod.
