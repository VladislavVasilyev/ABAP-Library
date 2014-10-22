*&--------------------------------------------------------------------*
*&      Form  CHECK_DELIM_NEW_ENTRY                                   *
*&--------------------------------------------------------------------*
* check new entry for delimitation (called from validity period sbscr)*
*---------------------------------------------------------------------*
* BEGDATE ---> E: new begin date /B: new end date                     *
* ENDDATE ---> E: end date /B: begin date                             *
*&--------------------------------------------------------------------*
FORM check_delim_new_entry USING value(begdate) value(enddate).
  LOOP AT total.
    CHECK <vim_tot_mkey_beforex> EQ <vim_f1_beforex> AND
          ( vim_mkey_after_exists EQ space OR
            <vim_tot_mkey_afterx> EQ <vim_f1_afterx> ).
    CHECK <vim_enddate> NE enddate.
    CHECK <action> NE geloescht AND
          <action> NE neuer_geloescht AND
          <action> NE update_geloescht.
    IF x_header-delmdtflag EQ 'E'.     "end date is key field
      CHECK <vim_enddate> GE begdate AND <vim_begdate> LE enddate.
    ELSE.                              "begin date is key field
      CHECK <vim_enddate> LE begdate AND <vim_begdate> GE enddate. "entr
    ENDIF.                             "x_header-delmdtflag eq 'E'
    IF vim_special_mode NE vim_reset.
      MESSAGE w047(sv). "Überlagerte Sätze werden gelöscht
    ELSE.
      MESSAGE i047(sv). "Überlagerte Sätze werden gelöscht
    ENDIF.
    EXIT.
  ENDLOOP.
ENDFORM.                               "check_delim_new_entry
