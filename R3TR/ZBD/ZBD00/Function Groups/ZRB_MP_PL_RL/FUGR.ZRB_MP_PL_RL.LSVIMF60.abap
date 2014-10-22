*&---------------------------------------------------------------------*
*&  Include           LSVIMF60                                         *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  vim_maintain_single_set
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM vim_maintain_single_set.
  Data: msgno like sy-msgno,
        client_key_field_only(1) type c.

  IF vim_single_entry_function EQ space AND
     ( function NE 'DELE' AND function NE 'SAVE' ).       "HWR
      IF vim_oc_inst IS INITIAL.
        msgno = '005'.
      ELSE.
        READ TABLE dpl_sellist WITH KEY from_auth = space
         TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          msgno = '005'.
        ELSE.
          msgno = '766'.
*   Eingeschränkte Anzeige von Datensätzen.
        ENDIF.
      ENDIF.
    PERFORM vim_send_sv005_or_sv766 USING msgno
                                          'SENDIT'.
  ENDIF.                                                  "HWR
  IF status-type EQ zweistufig AND function NE 'ABR '
     AND function NE 'KOPF'
     AND function NE 'IGN '."SW: nicht ex. Status ZCDGM (1211787/98)
    <status>-firstline = <status>-cur_line = nextline.
    function = 'DETA'.
    IF x_header-delmdtflag NE space.
      TRANSLATE vim_no_mainkey_exists USING
                                        vim_no_mkey_not_procsd_patt.
    ENDIF.
*   Modify EXCL_CUA_FUNCT to remove the "new entries" and "copy entry"
*   functions only in the case of a view with Client as a key field and
*   no other key fields.
    client_key_field_only = 'X'.                          "IG 953007
    LOOP AT x_namtab WHERE keyflag EQ 'X'
                       AND datatype NE 'CLNT'.
      client_key_field_only = ' '.
      EXIT.
    ENDLOOP.
    IF client_key_field_only EQ 'X'.
      IF <status>-st_action EQ 'U' OR <status>-st_action EQ 'A'.
        MOVE 'NEWL' TO excl_cua_funct-function. COLLECT excl_cua_funct.
        MOVE 'KOPE' TO excl_cua_funct-function. COLLECT excl_cua_funct.
        MOVE 'PREV' TO excl_cua_funct-function. COLLECT excl_cua_funct.
        MOVE 'NEXT' TO excl_cua_funct-function. COLLECT excl_cua_funct.
      ENDIF.
    ENDIF.
    PERFORM process_detail_screen USING 'S'.
  ENDIF.
ENDFORM.                    " vim_maintain_single_set
*&---------------------------------------------------------------------*
*&      Form  vim_send_sv005_or_sv766
*&---------------------------------------------------------------------*
*       Send messages only once unless status has not been resetted
*----------------------------------------------------------------------*
*      -->P_MSGNO Message number to be sent as s-message
*      -->P_MODE  SENDIT: Send S-Message if it hasn't been sent before.
*                 RESET:  Reset status.
*----------------------------------------------------------------------*
FORM vim_send_sv005_or_sv766  USING p_msgno like sy-msgno
                                    p_mode TYPE char6.

  STATICS: sent_already TYPE xfeld,
           viewname TYPE viewname.

  IF viewname <> x_header-viewname.
    viewname = x_header-viewname.
    CLEAR sent_already.
  ENDIF.
  CASE p_mode.
    WHEN 'SENDIT'.
      CHECK sent_already = space.
      sent_already = 'X'.
      MESSAGE ID 'SV' TYPE 'S' NUMBER p_msgno.
    WHEN 'RESET'.
      CLEAR sent_already.
  ENDCASE.
ENDFORM.                    " vim_send_sv005_or_sv766
