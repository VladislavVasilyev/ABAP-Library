method READ_OBJECT.

  data
  : lr_x__call_module_error type ref to zcx_vcs__call_module_error
  , ld_s__table             type ty_s__tabl
  .


  move
  : i_s__tadir-obj_name to ld_s__table-name
  .

  try.
      call method zcl_vcs_r3tr___lib__ddif=>ddif_tabl_get
        exporting
          name      = ld_s__table-name
          langu     = i_s__tadir-masterlang
        importing
          gotstate  = ld_s__table-gotstate
          dd02v_wa  = ld_s__table-dd02v_wa
          dd09l_wa  = ld_s__table-dd09l_wa
          dd03p_tab = ld_s__table-dd03p_tab
          dd05m_tab = ld_s__table-dd05m_tab
          dd08v_tab = ld_s__table-dd08v_tab
          dd12v_tab = ld_s__table-dd12v_tab
          dd17v_tab = ld_s__table-dd17v_tab
          dd35v_tab = ld_s__table-dd35v_tab
          dd36m_tab = ld_s__table-dd36m_tab.

      select single tabclass
        from dd02l
        into ld_s__table-tabclass
        where tabname eq ld_s__table-name.



    catch zcx_vcs__call_module_error into lr_x__call_module_error.
      raise exception type zcx_vcs_objects_read__r3tr
        exporting
          previous = lr_x__call_module_error
          object   = i_s__tadir-object
          obj_name = i_s__tadir-obj_name.
  endtry.


   e_s__source = ld_s__table.

endmethod.
