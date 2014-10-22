*---------------------------------------------------------------------*
*       FORM VIM_MARK_AND_PROCESS                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM VIM_MARK_AND_PROCESS USING VALUE(VMAP_EXIX) TYPE I
                                VALUE(VMAP_OKCODE) LIKE OK_CODE
                                VMAP_NBR TYPE I VMAP_RC TYPE I.
  DATA: VMAP_I_RC TYPE I.
  READ TABLE TOTAL WITH KEY <VIM_xEXTRACT_KEY> BINARY SEARCH. "#EC *
  <MARK> = MARKIERT. ADD 1 TO MARK_TOTAL.
  MODIFY TOTAL INDEX SY-TABIX.
  <XACT> = <ACTION>.
  <XMARK> = MARKIERT. ADD 1 TO MARK_EXTRACT.
  MODIFY EXTRACT.
  PERFORM VIM_PROCESS_VIEW_ENTRY USING VMAP_EXIX VMAP_OKCODE VMAP_I_RC.
  IF VMAP_I_RC EQ 0.
    ADD 1 TO VMAP_NBR.
  ELSE.
    VMAP_RC = VMAP_I_RC.
  ENDIF.
ENDFORM.                               "vim_mark_and_process
