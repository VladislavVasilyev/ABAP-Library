*---------------------------------------------------------------------*
*       FORM GET_KEYTAB                                               *
*---------------------------------------------------------------------*
*       read table e071k                                              *
*---------------------------------------------------------------------*
FORM GET_KEYTAB.
  LOCAL: E071.
  LOOP AT VIM_CORR_OBJTAB INTO E071.
    CALL FUNCTION 'TRINT_READ_COMM_KEYS'
         EXPORTING
              WI_APPENDING = 'X'
              WI_E071      = E071
              WI_TRKORR    = <STATUS>-CORR_NBR
         TABLES
              WT_E071K     = CORR_KEYTAB.
  ENDLOOP.
  CLEAR: <STATUS>-KEYTBMODFD, GET_CORR_KEYTAB, <STATUS>-KEYTBINVLD.
ENDFORM.
