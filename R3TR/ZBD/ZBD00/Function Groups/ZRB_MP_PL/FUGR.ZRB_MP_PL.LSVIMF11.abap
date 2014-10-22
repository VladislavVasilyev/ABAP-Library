*&--------------------------------------------------------------------*
*&      Form  BEFORE_LEAVING_FRAME_FUNCTION.                          *
*&--------------------------------------------------------------------*
* do all the things necessary before leaving the frame function unit  *
*&--------------------------------------------------------------------*
FORM before_leaving_frame_function
                        USING value(exit_form) LIKE vimdesc-frm_bf_end.

  DATA: prc TYPE sy-subrc, dummy TYPE c, dummi TYPE i.                   "#EC NEEDED

  IF <status>-corr_enqud NE space.
    CALL FUNCTION 'DEQUEUE_E_TRKORR'
      EXPORTING
        trkorr = <status>-corr_nbr.
*             X_TRKORR = E02.
    CLEAR <status>-corr_enqud.
  ENDIF.
  CLEAR <status>-corr_nbr.
  CLEAR <status>-initializd.
  CLEAR <initial>. <vim_client_initial> = sy-mandt.
  IF ( maint_mode EQ anzeigen OR maint_mode EQ transportieren ) AND
     vim_corr_obj_viewname NE space.
    CLEAR vim_corr_obj_viewname.
  ENDIF.
  PERFORM vim_reset_texttab USING view_name.        "SW Texttransl
  CALL FUNCTION 'VIEW_RESET_LANGUAGES'."SW Texttransl
  CLEAR: als_active, als_enabled, als_langus_selected. "Clear ALS flags
  REFRESH als_sel_langus.
  IF exit_form NE space.
    PERFORM (exit_form) IN PROGRAM.
  ENDIF.
  CLEAR function.
  FREE vim_bc_entry_list.
  CLEAR vim_actlinks.
  CLEAR: <status>-bcfixnochg, vim_bc_chng_allowed,
         <status>-bcfixdelinfosent.
** test getting profiles: begin
*  IF SY-UNAME = 'FRENZELU' OR SY-UNAME = 'ROSENTHAL'    "UF Profile
*   OR SY-UNAME = 'BUEHLERM'.
*    CALL FUNCTION 'SCPR_MEMORY_DELETE'.
*  ENDIF.
** test getting profiles: end
  CLEAR vim_oc_inst.
*  refresh vim_dba_sel_kept.                              "UF210200
*delete after_nonkey flag in check_range.
  PERFORM check_range IN PROGRAM saplsvix
             USING space 0 'E' space space space
             CHANGING dummy prc.
ENDFORM.                               "before_leaving_frame_function
