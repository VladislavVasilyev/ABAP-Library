*---------------------------------------------------------------------*
*       FORM VIM_SET_ALE_EDIT_LOCK                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM VIM_SET_ALE_EDIT_LOCK.
  DATA: I_EDITLOCK(1) TYPE C.

  VIM_LAST_OBJH_VIEW = VIEW_NAME.
  REFRESH VIM_ALE_KEYSPEC_OBJTAB.
  IF X_HEADER-FLAG EQ SPACE.           "standard transport required
    PERFORM VIM_CHECK_ALE_EDIT_LOCK USING E071-OBJECT I_EDITLOCK.
    VIM_ALE_EDIT_LOCK = I_EDITLOCK.
    IF VIM_ALE_EDIT_LOCK NE SPACE. EXIT. ENDIF.
  ENDIF.
  IF X_HEADER-FRM_E071 NE SPACE. "individual transport objects exist
    IF VIM_CORR_OBJ_VIEWNAME NE X_HEADER-VIEWNAME.
      PERFORM (X_HEADER-FRM_E071) IN PROGRAM (SY-REPID).
      CLEAR VIM_CORR_OBJ_VIEWNAME.
    ENDIF.
    LOOP AT VIM_CORR_OBJTAB.
      PERFORM VIM_CHECK_ALE_EDIT_LOCK USING VIM_CORR_OBJTAB-OBJECT
                                            I_EDITLOCK.
      VIM_ALE_EDIT_LOCK = I_EDITLOCK.
      IF VIM_ALE_EDIT_LOCK NE SPACE. EXIT. ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                               "vim_set_ale_edit_lock
