*---------------------------------------------------------------------*
*       FORM ORDER_ADMINISTRATION                                     *
*---------------------------------------------------------------------*
* get client state and transport objects                              *
*---------------------------------------------------------------------*
FORM ORDER_ADMINISTRATION.
  DATA: RC LIKE SY-SUBRC.
  IF STATUS-ACTION EQ ANZEIGEN AND
     VIM_CORR_OBJ_VIEWNAME NE X_HEADER-VIEWNAME.
    CLEAR E071-TRKORR.
    PERFORM GET_TRANSP_INFO.
    VIM_CORR_OBJ_VIEWNAME = X_HEADER-VIEWNAME.
  ENDIF.
  IF X_HEADER-FLAG EQ VIM_TRANSPORT_DENIED.
    MESSAGE S001(SV). EXIT.
  ENDIF.
  IF vim_actopts-transp_off EQ bc_transport_denied.
    EXIT. "HCG No message in BC_Set activation mode
  ENDIF.
  DO.
    CALL FUNCTION 'TR_TASK_OVERVIEW'
         EXPORTING
              IV_USERNAME      = SY-UNAME
              IV_CATEGORY      = OBJH-OBJCATEG
              IV_CLIENT        = SY-MANDT
         EXCEPTIONS
              INVALID_CATEGORY = 01
              OTHERS           = 02.
    RC = SY-SUBRC.
    IF SY-SUBRC EQ 1 AND
       OBJH-OBJCATEG EQ VIM_CUST_SYST OR OBJH-OBJCATEG EQ VIM_APPL.
      OBJH-OBJCATEG = VIM_SYST.
      CONTINUE.
    ENDIF.
    EXIT.
  ENDDO.
  IF RC NE 0.
    MESSAGE ID      SY-MSGID
            TYPE    'I'
            NUMBER  SY-MSGNO
            WITH    SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  CLEAR FUNCTION.
ENDFORM.                               "order_administration
