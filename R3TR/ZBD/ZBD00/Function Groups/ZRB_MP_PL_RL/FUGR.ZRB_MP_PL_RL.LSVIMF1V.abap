*---------------------------------------------------------------------*
*       FORM VIM_ADDRESS_KEYTAB_ENTRIES
*---------------------------------------------------------------------*
* create address related keytab entries
*---------------------------------------------------------------------*
FORM vim_address_keytab_entries USING value(vake_action) TYPE c
                                      vake_rc TYPE i.
  STATICS: sadr2_keylen type syfleng.
  DATA: rc1 LIKE sy-subrc, x030l_wa type x030l.

  if sadr2_keylen is initial.
    CALL FUNCTION 'DDIF_NAMETAB_GET'
      EXPORTING
        tabname           = 'SADR2'
      IMPORTING
        X030L_WA          = x030l_wa
      EXCEPTIONS
        OTHERS            = 2.
    IF sy-subrc = 0.
      sadr2_keylen = x030l_wa-keylen / cl_abap_char_utilities=>charsize.
    else.
      RAISE nametab_get_failed.
    ENDIF.
  endif.
  SELECT SINGLE * FROM sadr WHERE adrnr EQ <address_number>."#EC *
  IF sy-subrc NE 0.
* Übergangslösung Adressumstellung 30F Anfang
    CALL FUNCTION 'ADDR_CONVERT_ADRC_TO_SADR'
      CHANGING
        address_number = <address_number>.
    IF <address_number> NE space.
      SELECT SINGLE * FROM sadr WHERE adrnr EQ <address_number>."#EC *
    ELSE.
      EXIT.
    ENDIF.
  ENDIF.
* Übergangslösung Adressumstellung 30F Ende
  vake_rc = 8.
  PERFORM vim_addr_keytab_entries_intern USING 'SADR' sadr
                                               sadr_keylen
                                               vake_action rc1.
  IF rc1 EQ 0.
    CLEAR vake_rc.
  ELSE.
    IF vake_action EQ pruefen.
      EXIT.
    ENDIF.
  ENDIF.
  SELECT COUNT(*) FROM sadr2 WHERE adrnr EQ sadr-adrnr.
  CLEAR sadr2.
  MOVE: sadr-mandt TO sadr2-mandt,
        sadr-adrnr TO sadr2-adrnr,
        '*' TO sadr2-stdfl.
  IF sy-dbcnt GT 0.                    "only if entries exist
    PERFORM vim_addr_keytab_entries_intern USING 'SADR2' sadr2
                                                 sadr2_keylen
                                                 vake_action rc1.
    IF rc1 EQ 0.
      CLEAR vake_rc.
    ELSE.
      IF vake_action EQ pruefen.
        vake_rc = 8. EXIT.
      ENDIF.
    ENDIF.
  ENDIF.
  SELECT COUNT(*) FROM sadr3 WHERE adrnr EQ sadr-adrnr.
  IF sy-dbcnt GT 0.                    "only if entries exist
    sadr3 = sadr2.
    PERFORM vim_addr_keytab_entries_intern USING 'SADR3' sadr3
                                                 sadr2_keylen
                                                 vake_action rc1.
    IF rc1 EQ 0.
      CLEAR vake_rc.
    ELSE.
      IF vake_action EQ pruefen.
        vake_rc = 8. EXIT.
      ENDIF.
    ENDIF.
  ENDIF.
  SELECT COUNT(*) FROM sadr4 WHERE adrnr EQ sadr-adrnr.
  IF sy-dbcnt GT 0.                    "only if entries exist
    sadr4 = sadr2.
    PERFORM vim_addr_keytab_entries_intern USING 'SADR4' sadr4
                                                 sadr2_keylen
                                                 vake_action rc1.
    IF rc1 EQ 0.
      CLEAR vake_rc.
    ELSE.
      IF vake_action EQ pruefen.
        vake_rc = 8. EXIT.
      ENDIF.
    ENDIF.
  ENDIF.
  SELECT COUNT(*) FROM sadr5 WHERE adrnr EQ sadr-adrnr.
  IF sy-dbcnt GT 0.                    "only if entries exist
    sadr5 = sadr2.
    PERFORM vim_addr_keytab_entries_intern USING 'SADR5' sadr5
                                                  sadr2_keylen
                                                  vake_action rc1.
    IF rc1 EQ 0.
      CLEAR vake_rc.
    ELSE.
      IF vake_action EQ pruefen.
        vake_rc = 8.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                               "vim_address_keytab_entries
