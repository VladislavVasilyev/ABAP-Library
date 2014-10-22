*---------------------------------------------------------------------*
*       FORM BEENDEN                                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM beenden.
  DATA: line1(30) TYPE c,
        handle TYPE ad_handle,
        adrnum TYPE ad_addrnum.

  CASE function.
    WHEN 'ANZG'.
      line1 = svim_text_001.
    WHEN 'ATAB'.
      line1 = svim_text_008.
    WHEN 'ENDE'.
      line1 = svim_text_003.
  ENDCASE.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
       EXPORTING
            titel     = line1
            textline1 = svim_text_018  "Daten wurden verändert.
            textline2 = svim_text_019  "Änderungen vorher sichern ?
       IMPORTING
            answer    = answer.
  CASE answer.
    WHEN 'J'.
      sy-subrc = 0.
    WHEN 'N'.
      CLEAR <status>-upd_flag.
      IF maint_mode EQ transportieren.
        <status>-keytbinvld = 'X'.
      ELSEIF maint_mode EQ aendern. "AND x_header-adrnbrflag EQ 'N'.
* reset unsaved addresses                          UF557286/2000b
        LOOP AT vim_addresses_to_save.
          IF vim_addresses_to_save-addrnumber CP '@NEW*'.
            CLEAR adrnum.
            handle = vim_addresses_to_save-handle.
          ELSE.
            CLEAR handle.
            adrnum = vim_addresses_to_save-addrnumber.
          ENDIF.
          CALL FUNCTION 'ADDR_SINGLE_RESET'
               EXPORTING
                    address_number = adrnum
                    address_handle = handle
               EXCEPTIONS
                    OTHERS         = 1.
          IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF.
        ENDLOOP.
        REFRESH vim_addresses_to_save.
      ENDIF.                                            "UF557286/2000e
      sy-subrc = 8.
    WHEN 'A'.
      sy-subrc = 12.
  ENDCASE.
ENDFORM.
