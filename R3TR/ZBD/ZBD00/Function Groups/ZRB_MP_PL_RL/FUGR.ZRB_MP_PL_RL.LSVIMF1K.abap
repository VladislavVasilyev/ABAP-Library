*&--------------------------------------------------------------------*
*&      Form DELETE_CHECK_KEYRANGE                                    *
*&--------------------------------------------------------------------*
* check keyrange for delete                                           *
*---------------------------------------------------------------------*
FORM delete_check_keyrange.
  LOCAL: extract, total, <table1>.
  DATA: dck_specmode_safe LIKE vim_special_mode.

  CLEAR sy-subrc.
  CHECK x_header-customauth CO sap_cust_ctrl_classes OR
        vim_ale_keyspec_check NE space OR
        vim_sync_keyspec_check NE space.
  dck_specmode_safe = vim_special_mode.
  PERFORM move_extract_to_view_wa.
  IF status-mode EQ list_bild.
    vim_special_mode = vim_delete.
  ELSE.
    CLEAR vim_special_mode.
  ENDIF.
  CLEAR vim_keyrange_alr_checked.
  PERFORM check_allowed_keyranges.
  IF sy-subrc NE 0. "vim_import_profile check in check_allowed_keyranges
    IF status-mode EQ list_bild.
      CASE status-type.
        WHEN einstufig.
          CALL SCREEN liste.
          IF ok_code EQ 'IGN '. function = ok_code. ENDIF.
        WHEN zweistufig.
          PERFORM process_detail_screen USING 'C'.
          status-mode = list_bild.
      ENDCASE.
    ENDIF.
    IF vim_ale_keyspec_check NE space OR  "never delete ALE-locked or
       vim_sync_key_lock_del NE space.    "SYNC-locked keys HW 718225
      function = 'IGN '.
    ENDIF.
    CLEAR: sy-subrc, ok_code.
    CASE function.
      WHEN 'IGN '. sy-subrc = 4.
      WHEN 'ABR '. sy-subrc = 8.
    ENDCASE.
  ENDIF.
* CLEAR VIM_SPECIAL_MODE.
  vim_special_mode = dck_specmode_safe.
  function = 'DELE'.
ENDFORM.                               "delete_check_keyrange
