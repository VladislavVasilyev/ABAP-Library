*&--------------------------------------------------------------------*
*&      Form AFTER_SAVING                                             *
*&--------------------------------------------------------------------*
* process after-treatment of saving                                   *
*&--------------------------------------------------------------------*
FORM after_saving.
  DATA: dummy.
  DATA  e071_loctab TYPE vim_ko200_tab_type.

  IF x_header-texttbexst <> space AND  "SW Texttransl ..
     vim_abort_saving EQ space.
    IF x_header-frm_tl_upd NE space.
      PERFORM (x_header-frm_tl_upd) IN PROGRAM.
    ELSE.
      PERFORM vim_texttab_db_update.
    ENDIF.
  ENDIF.                               ".. TEXTTRANSL
  IF vim_abort_saving = space AND vim_called_by_cluster = space.
    PERFORM vim_add_img_notices_pai USING 'S'
                                    CHANGING dummy.
  ENDIF.
  IF x_header-frm_af_sav NE space.
    PERFORM (x_header-frm_af_sav) IN PROGRAM.
  ENDIF.
*    Call synchronizer
  IF vim_abort_saving EQ space.
    REFRESH e071_loctab.
    APPEND e071 TO e071_loctab.
    PERFORM vim_synchronizer_call
                  USING e071_loctab[]
                        corr_keytab[]
                        'X'.
  ENDIF.
  IF <status>-selected CO 'NUD'.
    CLEAR <status>-selected.
  ENDIF.
  IF vim_abort_saving = space AND vim_import_profile NE space.
* build up BC-Set import log
    PERFORM vim_bc_logs_put CHANGING vim_bc_entry_list.
  ENDIF.
  CLEAR vim_abort_saving.
* log end of database changes
  CALL FUNCTION 'VIEW_WRITE_CHANGELOG_HEADER'
    EXPORTING
      viewname = x_header-viewname
      bastab   = x_header-bastab
      begin    = space
      clidep   = x_header-clidep.
  TRANSLATE vim_adjust_middle_level_mode USING 'XLSL'.
ENDFORM.                               "after_saving
