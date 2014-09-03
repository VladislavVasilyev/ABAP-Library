method COLLECT_FMODULES.

  data
  : w_fmodule type ty_s__fmodule
  , t_enlfdir type standard table of enlfdir
  , w_enlfdir like line of t_enlfdir.

  select * from enlfdir into table t_enlfdir
           where area eq area.
  loop at t_enlfdir into w_enlfdir.

    data
    : lr_x__call_module_error type ref to zcx_vcs__call_module_error
    , ld_s__fmodule type ty_s__fmodule
    .

    move w_enlfdir-funcname to ld_s__fmodule-funcname.

** RPY_FUNCTIONMODULE_READ ist wahrscheinlich veraltet
    data: p_param_docu type standard table of rsfdo.

         call method zcl_vcs_r3tr___tech=>rpy_functionmodule_read
          exporting
            functionname       = ld_s__fmodule-funcname
          importing
            area               = ld_s__fmodule-area
            global_flag        = ld_s__fmodule-global_flag
            remote_call        = ld_s__fmodule-remote_call
            update_task        = ld_s__fmodule-update_task
            short_text         = ld_s__fmodule-short_text
*       MULTISOFT          =
            import_parameter   = ld_s__fmodule-t_import
            changing_parameter = ld_s__fmodule-t_change
            export_parameter   = ld_s__fmodule-t_export
            tables_parameter   = ld_s__fmodule-t_tables
            exception_list     = ld_s__fmodule-t_except
            documentation      = p_param_docu
            source             = ld_s__fmodule-source.

        append ld_s__fmodule to e_t__fmodule.

  endloop.

endmethod.
