*---------------------------------------------------------------------*
*       FORM NICHT_VORHANDEN                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM nicht_vorhanden USING rc tabind.
  DATA: dum TYPE i VALUE 0.
  FIELD-SYMBOLS <tot_mkey_beforex> TYPE X.

*  MOVE <table1> TO total.
  move <table1> to <vim_total_struc>.
  IF x_header-bastab NE space AND x_header-texttbexst NE space.
    MOVE <table1_xtext> TO <vim_xtotal_text>.
* nec. if special types in texttab
*    MOVE <table1_text> TO <total_text>.
    IF <status>-upd_flag EQ 'X' OR <status>-upd_flag EQ 'T'.
      <action_text> = neuer_eintrag.
    ELSE.
      CLEAR <action_text>.
    ENDIF.
  ENDIF.
  <action>          = neuer_eintrag.
  CLEAR <mark>.                                          "HCG HW785631
  CASE rc.                                                  "aro
    WHEN 0.                                                 "aro
      MODIFY total INDEX tabind.  "#EC *                          "aro
    WHEN 4.
      INSERT total INDEX tabind. "#EC *
    WHEN 8.                                                 "aro
      APPEND total. "#EC *
  ENDCASE.                                                  "aro
  IF vim_special_mode NE vim_upgrade AND                    "aro
     status-action NE kopieren.                             "aro
    IF status-mode EQ list_bild.
      IF vim_single_entry_function EQ space.
        CLEAR <xmark>.
        APPEND extract. "#EC *
      ELSE.
        nbr_of_added_dummy_entries = 0.
      ENDIF.
      extract = total.
      MODIFY extract INDEX nextline. "#EC *
    ELSE.
      IF x_header-delmdtflag NE space.
        PERFORM check_if_entry_is_to_display USING 'L' <vim_xtotal_key>
                                                   'D' <vim_begdate>.
        IF sy-subrc EQ 0.
          PERFORM check_new_mainkey.
          IF sy-subrc EQ 0.
            READ TABLE vim_collapsed_mainkeys WITH KEY <vim_xtotal_key> "#EC *
                                             BINARY SEARCH
                                         TRANSPORTING NO FIELDS.
            <vim_collapsed_keyx> = <vim_xtotal_key>.
*           vim_collapsed_mainkeys-mainkey = <vim_total_key>.
            ASSIGN <vim_tot_mkey_before> TO <tot_mkey_beforex> CASTING.
* "HCG      <vim_collapsed_mkey_bfx> = <vim_tot_mkey_before>. hex=char!
            <vim_collapsed_mkey_bfx> = <tot_mkey_beforex>.
*           vim_collapsed_mainkeys-mkey_bf = <vim_tot_mkey_before>.
            INSERT vim_collapsed_mainkeys INDEX sy-tabix. "#EC *
          ENDIF.
          CLEAR sy-subrc.
        ENDIF.
      ENDIF.
      IF x_header-delmdtflag EQ space OR sy-subrc LT 8.
        extract = total.
        APPEND extract. "#EC *
        exind = sy-tabix.
      ENDIF.
    ENDIF.
  ENDIF.                                                    "aro
  neuer = 'N'.
  DESCRIBE TABLE extract LINES maxlines.
  IF status-mode EQ list_bild.                              "aro
    SUBTRACT nbr_of_added_dummy_entries FROM maxlines.
    dum = maxlines - firstline - sy-loopc + 1.              "aro
    IF dum EQ 0.                                            "aro
      destpage = maxlines.
    ENDIF.                                                  "aro
  ENDIF.                                                    "aro
ENDFORM.
