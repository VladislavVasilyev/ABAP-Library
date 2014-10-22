*----------------------------------------------------------------------*
*   INCLUDE LSVIMF46                                                   *
*----------------------------------------------------------------------*
* <Address_Number> -> <table1> = View-Workarea (= zu übernehmender
*      Eintrag, aber Adreßnummer des akt. Mandant/System;
*      Adreßnummer wurde in VIM_MODIFY_VIEW_ENTRY ausgetauscht)
* <F1>             -> <table1>(keylen)
* VIM_UPGR_ADDRESS_NUMBER -> Adresse des zu übernehmenden Eintrages
* Achtung: in TOTAL steht NICHT(!) mehr der Eintrag aus akt. Mandant/Sys
*          zur Verfügung wegen Zuweisung  'move <table1> to total'
*          in liste_initialisieren im 'Replace_mode'.
*----------------------------------------------------------------------*
FORM vim_address_adjust.
  DATA: addr_comp_tab TYPE szadr_compare_addr1_tab,
        addr_comp_line TYPE szadr_compare_addr1_line,
        handle TYPE ad_handle,
        create_address(1) TYPE c,
        retcode LIKE  szad_field-returncode,
        error_info LIKE addr_error OCCURS 0 WITH HEADER LINE,
        einfo      LIKE addr_error,
        i_msgv1 LIKE sy-msgv1,
        space_msgv LIKE sy-msgv1 VALUE space,
        dum TYPE i, pos_char TYPE i.

  FIELD-SYMBOLS: <handle_x> TYPE x, <field_loc> TYPE ANY.

* nur neue Adreßpflege!
  CHECK x_header-adrnbrflag = 'N' AND adrnbr_roflag = space.
  ASSIGN handle TO <handle_x> CASTING.
  IF vim_import_mode_active = space.             "interaktive Übernahme
    IF vim_upgr_address_number <> '@ADJUSTED@'.   "cmpwl_addr_adjusted
      EXIT.
    ENDIF.
    IF <address_number> = space.
      <handle_x> = <f1_x>.
*      HANDLE = <F1>.
      create_address = 'X'.
    ELSE.
      READ TABLE vim_locked_addresses FROM <address_number>
                                        TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.                "not yet locked
        CALL FUNCTION 'ADDR_ENQUEUE'
             EXPORTING
                  address_number    = <address_number>
*               MODE_ADRC         = 'E'
             EXCEPTIONS
                  address_not_exist = 1
                  foreign_lock      = 2
                  system_failure    = 3
                  internal_error    = 4.
        CASE sy-subrc.
          WHEN 0.
            INSERT <address_number> INTO TABLE vim_locked_addresses.
          WHEN 1.
            <handle_x> = <f1_x>.
*            HANDLE = <F1>.
            create_address = 'X'.
            CLEAR <address_number>.
          WHEN 2.
            PERFORM vim_process_message
                USING 'SV' 'E' 'E' '049'
                      sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          WHEN OTHERS.
*            i_msgv1 = <table1>.   "HCG Dump when nonchar field in view
            LOOP AT x_namtab.       "HCG write field by field instead
* XB H644658B
              CHECK x_namtab-keyflag NE space.
* Beim Feld f wurden Offset oder Länge angegeben und der Datentyp des
* zuzuweisenden Felds erlaubt keine Teilzugriffe. (Dies ist bei den
* Datentypen I, F und P der Fall.)
              CHECK x_namtab-inttype NE 'I'.
              CHECK x_namtab-inttype NE 'P'.
              CHECK x_namtab-inttype NE 'F'.
* XB H644658E
              ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE <table1>
                                              TO <field_loc>.
              dum = ( x_namtab-position + x_namtab-flength ) /
                            cl_abap_char_utilities=>charsize.
              pos_char = x_namtab-position /
                                      cl_abap_char_utilities=>charsize.
              IF dum <= 50.         "End of field <= Length of sy-msgv1
                WRITE <field_loc> TO i_msgv1+pos_char.
              ELSE.
                dum = 50 - pos_char.
                IF dum GT 0. "Otherwise i_msgv1 just filled up to 50
                  WRITE <field_loc>(dum) TO i_msgv1+pos_char.
                ENDIF.
                EXIT.                               "HCG i_msgv1 filled
              ENDIF.
            ENDLOOP.
            PERFORM vim_process_message
              USING 'SV' 'E' 'E' '050'
                  i_msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDCASE.
      ENDIF.  " SY-SUBRC <> 0.
    ENDIF.   "<Address_Number> = SPACE

  ELSE.  "automat. Übernahme
    IF vim_upgr_address_number = space.
*      i_msgv1 = <table1>.   "HCG Dump when nonchar field in view
      LOOP AT x_namtab.       "HCG write field by field instead
* XB H647964B
              CHECK x_namtab-keyflag NE space.
* Beim Feld f wurden Offset oder Länge angegeben und der Datentyp des
* zuzuweisenden Felds erlaubt keine Teilzugriffe. (Dies ist bei den
* Datentypen I, F und P der Fall.)
              CHECK x_namtab-inttype NE 'I'.
              CHECK x_namtab-inttype NE 'P'.
              CHECK x_namtab-inttype NE 'F'.
* XB H647964E
        ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE <table1>
                                        TO <field_loc>.
        dum = ( x_namtab-position + x_namtab-flength ) /
                      cl_abap_char_utilities=>charsize.
        pos_char = x_namtab-position /
                                cl_abap_char_utilities=>charsize.
        IF dum <= 50.         "End of field <= Length of sy-msgv1
          WRITE <field_loc> TO i_msgv1+pos_char.
        ELSE.
          dum = 50 - pos_char.
          IF dum GT 0. "Otherwise i_msgv1 just filled up to 50
            WRITE <field_loc>(dum) TO i_msgv1+pos_char.
          ENDIF.
          EXIT.                               "HCG i_msgv1 filled
        ENDIF.
      ENDLOOP.
      PERFORM vim_process_message
                USING 'SV' 'I' 'I'  '165'
                    i_msgv1 space_msgv space_msgv space_msgv.
      EXIT.                                          "keine Löschung
    ENDIF.

    addr_comp_line-addrnumber = <address_number>.
    IF <address_number> = space.
      <handle_x> = <f1_x>.
      addr_comp_line-addrhandle = handle.
*      ADDR_COMP_LINE-ADDRHANDLE = <F1>.
*      HANDLE = <F1>.
      create_address = 'X'.
    ENDIF.
    addr_comp_line-remote_addrnumber = vim_upgr_address_number.
    APPEND addr_comp_line TO addr_comp_tab.
    CALL FUNCTION 'ADDR_COMPARE'
      EXPORTING
        rfc_destination = vim_default_rfc_dest-rfcdest
      TABLES
        compare_tab     = addr_comp_tab
      EXCEPTIONS
        rfc_error       = 1
        OTHERS          = 2.
    IF sy-subrc <> 0.
      PERFORM vim_process_message
            USING sy-msgid 'E' 'E'  sy-msgno
                  sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      EXIT.
    ENDIF.
    READ TABLE addr_comp_tab INDEX 1 INTO addr_comp_line.
    IF addr_comp_line-parameter_error = 'X' OR
       addr_comp_line-internal_error = 'X'.
      einfo = addr_comp_line-error_table.
      PERFORM vim_process_message
        USING einfo-msg_id 'E' 'E'  einfo-msg_number
            einfo-msg_var1 einfo-msg_var2 einfo-msg_var3 einfo-msg_var4.
*     Adresse kann nicht abgeglichen werden -> Eintrag verwerfen
      EXIT.
    ENDIF.

    IF addr_comp_line-rem_address_not_exist = 'X'.    "keine Löschung!
*      i_msgv1 = <table1>.   "HCG Dump when nonchar field in view
      LOOP AT x_namtab.       "HCG write field by field instead
* XB H647964B
              CHECK x_namtab-keyflag NE space.
* Beim Feld f wurden Offset oder Länge angegeben und der Datentyp des
* zuzuweisenden Felds erlaubt keine Teilzugriffe. (Dies ist bei den
* Datentypen I, F und P der Fall.)
              CHECK x_namtab-inttype NE 'I'.
              CHECK x_namtab-inttype NE 'P'.
              CHECK x_namtab-inttype NE 'F'.
* XB H647964E
        ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE <table1>
                                        TO <field_loc>.
        dum = ( x_namtab-position + x_namtab-flength ) /
                      cl_abap_char_utilities=>charsize.
        pos_char = x_namtab-position /
                                cl_abap_char_utilities=>charsize.
        IF dum <= 50.         "End of field <= Length of sy-msgv1
          WRITE <field_loc> TO i_msgv1+pos_char.
        ELSE.
          dum = 50 - pos_char.
          IF dum GT 0. "Otherwise i_msgv1 just filled up to 50
            WRITE <field_loc>(dum) TO i_msgv1+pos_char.
          ENDIF.
          EXIT.                               "HCG i_msgv1 filled
        ENDIF.
      ENDLOOP.
      PERFORM vim_process_message
              USING 'SV' 'I' 'I'  '165'
                    i_msgv1 space_msgv space_msgv space_msgv.
      EXIT.
    ELSEIF addr_comp_line-address_not_exist = 'X' AND
           create_address = space.
      <handle_x> = <f1_x>.
*      HANDLE = <F1>.
      create_address = 'X'.
      CLEAR: <address_number>, <vim_total_address_number>.
      REFRESH addr_comp_tab. CLEAR addr_comp_line.
      addr_comp_line = handle.
*      ADDR_COMP_LINE-ADDRHANDLE = <F1>.
      addr_comp_line-remote_addrnumber = vim_upgr_address_number.
      APPEND addr_comp_line TO addr_comp_tab.
      CALL FUNCTION 'ADDR_COMPARE'
        EXPORTING
          rfc_destination = vim_default_rfc_dest-rfcdest
        TABLES
          compare_tab     = addr_comp_tab
        EXCEPTIONS
          rfc_error       = 1
          OTHERS          = 2.
      IF sy-subrc <> 0.
        PERFORM vim_process_message
              USING sy-msgid 'E' 'E'  sy-msgno
                    sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        EXIT.
      ENDIF.
      READ TABLE addr_comp_tab INDEX 1 INTO addr_comp_line.
      IF addr_comp_line-parameter_error = 'X' OR
         addr_comp_line-internal_error = 'X'.
        einfo = addr_comp_line-error_table.
        PERFORM vim_process_message
          USING einfo-msg_id 'E' 'E'  einfo-msg_number
            einfo-msg_var1 einfo-msg_var2 einfo-msg_var3 einfo-msg_var4.
*       Adresse kann nicht abgeglichen werden -> Eintrag verwerfen
        EXIT.
      ENDIF.
*     Überprüfung von REM_ADDRESS_NOT_EXIST, .. hier nicht nötig

    ELSEIF addr_comp_line-address_is_equal = 'X'.
      EXIT.
    ELSEIF create_address = space.
      READ TABLE vim_locked_addresses FROM <address_number>
                                        TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.                "not yet locked
        CALL FUNCTION 'ADDR_ENQUEUE'
             EXPORTING
                  address_number    = <address_number>
*               MODE_ADRC         = 'E'
             EXCEPTIONS
                  address_not_exist = 1
                  foreign_lock      = 2
                  system_failure    = 3
                  internal_error    = 4.
        CASE sy-subrc.
          WHEN 0.
            INSERT <address_number> INTO TABLE vim_locked_addresses.
          WHEN 1.  " würde schon in ADDR_COMPARE auftreten
            PERFORM vim_process_message    "eigentlich überflüssig
                USING 'SV' 'E' 'E' '049'
                      sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          WHEN 2.
            PERFORM vim_process_message
                USING 'SV' 'E' 'E' '049'
                      sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          WHEN OTHERS.
*            i_msgv1 = <table1>.   "HCG Dump when nonchar field in view
            LOOP AT x_namtab.       "HCG write field by field instead
* XB H647964B
              CHECK x_namtab-keyflag NE space.
* Beim Feld f wurden Offset oder Länge angegeben und der Datentyp des
* zuzuweisenden Felds erlaubt keine Teilzugriffe. (Dies ist bei den
* Datentypen I, F und P der Fall.)
              CHECK x_namtab-inttype NE 'I'.
              CHECK x_namtab-inttype NE 'P'.
              CHECK x_namtab-inttype NE 'F'.
* XB H647964E
              ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE <table1>
                                              TO <field_loc>.
              dum = ( x_namtab-position + x_namtab-flength ) /
                            cl_abap_char_utilities=>charsize.
              pos_char = x_namtab-position /
                                      cl_abap_char_utilities=>charsize.
              IF dum <= 50.         "End of field <= Length of sy-msgv1
                WRITE <field_loc> TO i_msgv1+pos_char.
              ELSE.
                dum = 50 - pos_char.
                IF dum GT 0. "Otherwise i_msgv1 just filled up to 50
                  WRITE <field_loc>(dum) TO i_msgv1+pos_char.
                ENDIF.
                EXIT.                               "HCG i_msgv1 filled
              ENDIF.
            ENDLOOP.
            PERFORM vim_process_message
              USING 'SV' 'E' 'E' '050'
                  i_msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDCASE.
      ENDIF.   "SY-SUBRC
    ENDIF.
  ENDIF.     " vim_import_mode_active

  CALL FUNCTION 'ADDR_ADJUST'
    EXPORTING
      addrnumber           = <address_number>
      addrhandle           = handle
      address_group        = 'CA01'
    IMPORTING
      returncode           = retcode
    TABLES
      error_table          = error_info
    EXCEPTIONS
      parameter_error      = 1
      address_not_exist    = 2
      handle_exist         = 3
      internal_error       = 4
      address_not_compared = 5
      OTHERS               = 6.
  IF sy-subrc <> 0.
    PERFORM vim_process_message
           USING sy-msgid 'E' 'E' sy-msgno
                 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF retcode = 'E'.
      READ TABLE error_info INDEX 1.
      PERFORM vim_process_message
             USING error_info-msg_id 'E' 'E' error_info-msg_number
                   error_info-msg_var1 error_info-msg_var2
                   error_info-msg_var3 error_info-msg_var4.
    ELSE.    "ok
      IF create_address = 'X'.
        <address_number> = '@NEW'.
        <address_number>+4(6) = <status>-newadrcnt.
        ADD 1 TO <status>-newadrcnt.
        <status>-upd_flag = 'X'.
      ENDIF.
      <vim_total_address_number> = <address_number>.
      READ TABLE vim_addresses_to_save
                              WITH KEY viewname = x_header-viewname
                                       addrnumber = <address_number>
                              BINARY SEARCH TRANSPORTING NO FIELDS.
      IF sy-subrc NE 0.
        vim_addresses_to_save-viewname = x_header-viewname.
        vim_addresses_to_save-addrnumber = <address_number>.
        <vim_addr_handle_x> = <f1_x>.
*        VIM_ADDRESSES_TO_SAVE-HANDLE = <F1>.
        INSERT vim_addresses_to_save INDEX sy-tabix.
      ENDIF.
      IF vim_client_state EQ vim_log AND
        x_header-flag NE vim_transport_denied and
        vim_actopts-transp_off NE bc_transport_denied.
        <status>-upd_flag = 'X'. "nec. for transport of master entry
      ENDIF.
    ENDIF.                                                  "RETCODE
  ENDIF.            "SY-SUBRC
ENDFORM.                    "vim_address_adjust
