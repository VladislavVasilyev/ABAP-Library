method synchr_context.


*try.
  call method cl_uj_context=>set_cur_context
    exporting
      i_appset_id   = gv_appset_id
      is_user       = gd_s__user_id
      i_appl_id     = gv_appl_id
*    i_module_name =
      .
* catch cx_uj_obj_not_found .
*endtry.


endmethod.
