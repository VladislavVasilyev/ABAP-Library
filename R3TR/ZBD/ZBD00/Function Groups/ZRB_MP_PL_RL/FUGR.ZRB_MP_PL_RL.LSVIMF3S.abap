*---------------------------------------------------------------------*
*       FORM VIM_CHECK_ALE_EDIT_LOCK                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM VIM_CHECK_ALE_EDIT_LOCK USING VALUE(VCAEL_OBJECT) LIKE E071-OBJECT
                                   VCAEL_LOCK TYPE C.
  DATA: OBJ_TYPE LIKE OBJH-OBJECTTYPE, OBJ_NAME LIKE OBJH-OBJECTNAME.

* OBJ_NAME = VIEW_NAME.
  OBJ_NAME = MASTER_NAME.
  CASE VCAEL_OBJECT.
    WHEN VIM_VIEW_TYPE.                "-> view
      OBJ_TYPE = VIM_VIEW.
    WHEN TRANSP_OBJECT.                "-> tables
      OBJ_TYPE = VIM_TABL.
    WHEN VIM_CLUS_TYPE.                "-> viewcluster
      OBJ_TYPE = VIM_CLST.
    WHEN VIM_TRAN_TYPE.                "-> individual transaction
      OBJ_TYPE = VIM_TRAN.
    WHEN OTHERS.                       "-> may be LOGO object ?
      OBJ_TYPE = VIM_LOGO. OBJ_NAME = VCAEL_OBJECT.
*     SELECT SINGLE * FROM OBJH WHERE OBJECTNAME EQ OBJ_NAME "required ?
*                                 AND OBJECTTYPE EQ OBJ_TYPE.
*     IF SY-SUBRC NE 0. CLEARVCAEL_LOCK. EXIT. ENDIF. "no logo-object
  ENDCASE.
  CALL FUNCTION 'ALE_EDIT_CHECK'
       EXPORTING
            OBJECTTYPE      = OBJ_TYPE
            OBJECTNAME      = OBJ_NAME
       IMPORTING
            SOMEKEYS_NOEDIT = VIM_ALE_KEYSPEC_CHECK
       EXCEPTIONS
            NO_CALL         = 1
            NO_EDIT         = 2.
  IF SY-SUBRC GT 1.
    VCAEL_LOCK = 'X'.
    VIM_ALE_MSGID = SY-MSGID. VIM_ALE_MSGNO = SY-MSGNO.
    VIM_ALE_MSGV1 = SY-MSGV1. VIM_ALE_MSGV2 = SY-MSGV2.
    VIM_ALE_MSGV3 = SY-MSGV3. VIM_ALE_MSGV4 = SY-MSGV4.
  ELSE.
    CLEAR VCAEL_LOCK.
    IF VIM_ALE_KEYSPEC_CHECK NE SPACE AND OBJ_TYPE NE VIM_LOGO.
      VIM_ALE_KEYSPEC_OBJTAB-ONAME = OBJ_NAME.
      VIM_ALE_KEYSPEC_OBJTAB-OTYPE = OBJ_TYPE.
      APPEND VIM_ALE_KEYSPEC_OBJTAB.
    ENDIF.
  ENDIF.
ENDFORM.                               "vim_check_ale_edit_lock
