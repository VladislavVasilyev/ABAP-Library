method COLLECT_FUNCAREA.

  data
  : lr_x__call_module_error type ref to zcx_vcs__call_module_error
  .

  data
  : t_includes type standard table of ty_s__include-include
  , w_include like line of t_includes
  , program like  sy-repid
  , fugr_is_functionmodule_name
  , lv_progname type progname
  , oasis type ty_s__include.

  concatenate cs_sapl area into program.

      call method zcl_vcs_r3tr___tech=>rs_get_all_includes
        exporting
          program                      = program
*       WITH_INACTIVE_INCLS          = ' '
*       WITH_RESERVED_INCLUDES       =
        importing
          includetab                   = t_includes.


      loop at t_includes into w_include.

        clear fugr_is_functionmodule_name.

        call method zcl_vcs_r3tr___tech=>rs_progname_split
          exporting
            progname_with_namespace     = w_include
          importing
            fugr_is_functionmodule_name = fugr_is_functionmodule_name.

        if fugr_is_functionmodule_name eq 'X'.
* Funktionsbaustein
          delete t_includes.
          continue.
        endif.

        move w_include to lv_progname.
        free oasis-source.
        call method zcl_vcs_r3tr___tech=>read_source
          exporting
            i_v__name   = lv_progname
          importing
            e_t__source = oasis-source.

        move w_include to oasis-include.
        append oasis to e_t__includes.
        free oasis.
*
      endloop.

endmethod.
