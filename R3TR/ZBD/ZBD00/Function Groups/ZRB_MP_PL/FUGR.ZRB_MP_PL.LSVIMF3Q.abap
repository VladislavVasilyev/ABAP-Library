*---------------------------------------------------------------------*
*       FORM AEND_TO_ANZG                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM aend_to_anzg.
* was not used 'til 4.6C
  IF status-action EQ anzeigen.
    MESSAGE i001(sv).
  ELSE.
    IF NOT vim_oc_inst IS INITIAL.
* new selection because of different authorisation? --> Message
* >>>check whether there's really a difference between upd and show<<<
      MESSAGE s764(sv).
*   Veränderte Auswahl von Datensätzen.
    ENDIF.
*    CLEAR: <status>-mk_xt,
*           <status>-mk_to,
*           block_sw.
*    PERFORM beenden.
  ENDIF.
ENDFORM.
