*&--------------------------------------------------------------------*
*&      Form  VIM_PROCESS_VIEW_ENTRY                                  *
*&--------------------------------------------------------------------*
* process current function for view entry                             *
*&--------------------------------------------------------------------*
FORM VIM_PROCESS_VIEW_ENTRY USING VALUE(VPVE_EXIX) TYPE I
                                  VALUE(VPVE_OKCODE) LIKE OK_CODE
                                  VPVE_RC TYPE I.
  DATA: FUNCTION_SAFE LIKE FUNCTION.
  CLEAR VPVE_RC.
  NEXTLINE = EXIND = VPVE_EXIX.
  FUNCTION_SAFE = FUNCTION.
  FUNCTION = OK_CODE = VPVE_OKCODE.
  PERFORM MOVE_EXTRACT_TO_VIEW_WA.
  CASE STATUS-TYPE.
    WHEN EINSTUFIG.
*     CALL SCREEN LISTE.
      PERFORM VIM_IMP_CALL_SCREEN USING LISTE.
    WHEN ZWEISTUFIG.
*     PERFORM MOVE_EXTRACT_TO_VIEW_WA.
      PERFORM PROCESS_DETAIL_SCREEN USING 'C'.
  ENDCASE.
  IF OK_CODE EQ 'IGN '. VPVE_RC = 4. CLEAR OK_CODE. EXIT. ENDIF.
  IF FUNCTION EQ 'ABR '. VPVE_RC = 8. CLEAR FUNCTION. EXIT. ENDIF.
  FUNCTION = FUNCTION_SAFE.
ENDFORM.                               "vim_process_view_entry
