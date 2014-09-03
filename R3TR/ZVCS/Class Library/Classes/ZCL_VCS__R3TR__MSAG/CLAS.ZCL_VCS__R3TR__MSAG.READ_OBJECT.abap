method READ_OBJECT.

  data
  : lr_x__call_module_error type ref to zcx_vcs__call_module_error
  , ld_s__msag              type ty_s__msag
  .

  move i_s__tadir-obj_name to ld_s__msag-name.

  try.
      call method zcl_vcs_r3tr___tech=>message_classes_get_info
        exporting
          i_v__messageclassname = ld_s__msag-name
        importing
          e_t__class            = ld_s__msag-t100.
    catch zcx_vcs__call_module_error into lr_x__call_module_error.
      raise exception type zcx_vcs_objects_read__r3tr
        exporting
          previous = lr_x__call_module_error
          object   = i_s__tadir-object
          obj_name = i_s__tadir-obj_name.
  endtry.

  e_s__source = ld_s__msag.

endmethod.
