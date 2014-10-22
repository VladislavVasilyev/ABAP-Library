*&--------------------------------------------------------------------*
*&      Form  TEMP_DELIM_DEL_OVERLED_ENTRIES                          *
*&--------------------------------------------------------------------*
* delete entries with overlaying time ranges                          *
*---------------------------------------------------------------------*
* BEGDATE ---> E: new begin date /B: new end date                     *
* ENDDATE ---> E: end date /B: begin date                             *
*&--------------------------------------------------------------------*
FORM temp_delim_del_overld_entries USING value(begdate) TYPE d
                                         value(enddate) TYPE d.
  LOCAL: extract, <table1>.
  DATA: first(1) TYPE c VALUE 'X', overlayed(1) TYPE c, cur_ix TYPE i,
        date_increment TYPE i, enddate_safe(8) TYPE c, new_ix TYPE i,
        trans_pattern(6) TYPE c, act_safe, mark_safe, act_txt_safe, "#EC *
        enddate_safe2(8) TYPE c, act, act_txt, hf TYPE i,   "#EC *
        key_safe LIKE vim_merged_entries-new_key, date_safe TYPE d, "#EC NEEDED
*        old_key TYPE vim_line_ul,
        old_keyx TYPE vrsdat1000.

  IF vim_temp_delim_alr_checked NE space.
    CLEAR first.
  ENDIF.
  LOOP AT total.
    CHECK <vim_tot_mkey_beforex> EQ <vim_f1_beforex> AND
          ( vim_mkey_after_exists EQ space OR
            <vim_tot_mkey_afterx> EQ <vim_f1_afterx> ).
    IF vim_special_mode NE vim_upgrade AND
       vim_special_mode NE vim_reset AND
       vim_special_mode NE vim_replace.
      CHECK <vim_enddate> NE enddate.
    ENDIF.
    CHECK <action> NE geloescht AND
          <action> NE neuer_geloescht AND
          <action> NE update_geloescht.
    CLEAR overlayed.
    IF x_header-delmdtflag EQ 'E'.     "end date is key field
      CHECK <vim_enddate> GE begdate AND <vim_begdate> LE enddate.
      IF <vim_begdate> GE begdate AND <vim_enddate> LT enddate.
        MOVE 'F' TO overlayed. "whole old entry is overlayed by new one
      ELSEIF <vim_begdate> LT begdate AND <vim_enddate> GT enddate.
        MOVE 'M' TO overlayed. "middle of old entry is overl. by new one
      ELSEIF <vim_begdate> LE enddate AND <vim_enddate> GT enddate.
        MOVE 'P' TO overlayed. "part of old entry is overlayed by new on
      ELSEIF <vim_begdate> EQ begdate AND <vim_enddate> EQ enddate.
        temporal_delimitation_happened = 'N'. EXIT. "no delim required
      ELSEIF <vim_enddate> EQ enddate.
        MOVE 'E' TO overlayed. "end of old entry is overlayed by new one
      ENDIF.
      MOVE -1 TO date_increment.
    ELSE.                              "begin date is key field
      CHECK <vim_enddate> LE begdate AND <vim_begdate> GE enddate. "entr
      IF <vim_begdate> LE begdate AND <vim_enddate> GT enddate.
        MOVE 'F' TO overlayed. "whole old entry is overlayed by new one
      ELSEIF <vim_enddate> LT enddate AND <vim_begdate> GT begdate.
        MOVE 'M' TO overlayed. "middle of old entry is overl. by new one
      ELSEIF <vim_enddate> LE enddate AND <vim_begdate> GT enddate.
        MOVE 'P' TO overlayed. "part of old entry is overlayed by new on
      ELSEIF <vim_begdate> EQ begdate AND <vim_enddate> EQ enddate.
        temporal_delimitation_happened = 'N'. EXIT. "no delim required
      ELSEIF <vim_enddate> EQ enddate.
        MOVE 'E' TO overlayed. "begin of old entry is overlayed by new o
      ENDIF.
      MOVE 1 TO date_increment.
    ENDIF.                             "x_header-delmdtflag eq 'E'
    IF first NE space.
      IF vim_special_mode NE vim_reset.
        MESSAGE w047(sv). "Überlagerte Sätze werden gelöscht
      ELSE.
        MESSAGE i047(sv). "Überlagerte Sätze werden gelöscht
      ENDIF.
      CLEAR first.
    ENDIF.
    cur_ix = sy-tabix.
    CLEAR vim_delim_entries.
    READ TABLE extract WITH KEY <vim_xtotal_key>.           "#EC *
*    READ TABLE extract WITH KEY total.
    IF sy-subrc EQ 0.
      MOVE sy-tabix TO vim_delim_entries-index3.
      IF overlayed NE 'P' AND overlayed NE 'M' AND overlayed NE 'E'.
        APPEND vim_delim_entries.
      ENDIF.
    ENDIF.
    IF overlayed EQ space OR overlayed EQ 'F'.
* delete old entry which is overlayed
      MOVE: original TO trans_pattern, geloescht TO trans_pattern+1(1),
            aendern  TO trans_pattern+2(1), update_geloescht
                                                 TO trans_pattern+3(1),
            neuer_eintrag TO trans_pattern+4(1), neuer_geloescht
                                                 TO trans_pattern+5(1).
      TRANSLATE <action> USING trans_pattern.
      IF x_header-bastab NE space AND x_header-texttbexst NE space AND
         x_header-ptfrkyexst EQ space.
        TRANSLATE <action_text> USING trans_pattern.
      ENDIF.
      IF <mark> EQ markiert.
        <mark> = nicht_markiert.
        SUBTRACT 1 FROM mark_total.
      ENDIF.
      MODIFY total.
    ENDIF. "overlayed eq space or overlayed eq 'F'
    IF overlayed EQ space OR overlayed EQ 'M' OR overlayed EQ 'E'.
* create new entry due to delimitation
      IF overlayed EQ 'M'.
        MOVE: <vim_enddate> TO enddate_safe, <action> TO act_safe,
              <mark> TO mark_safe.
        IF x_header-bastab NE space AND x_header-texttbexst NE space.
          MOVE <action_text> TO act_txt_safe.
        ENDIF.
      ENDIF.
      CLEAR hf.
      old_keyx = <vim_xtotal_key>.                 "SW Texttransl
*      old_key = total.
      <vim_enddate> = begdate + date_increment.
      IF x_header-delmdtflag EQ 'E'.                        "ACHACHADI 1317455
        CHECK <vim_enddate> GE <vim_begdate>.               "aro 070798
      ELSEIF x_header-delmdtflag EQ 'B'.
        CHECK <vim_enddate> LE <vim_begdate>.               "ACHACHADI 1317455
      ENDIF.
      CHECK <vim_enddate> LE <vim_begdate>.
      <action> = neuer_eintrag.
      <mark> = nicht_markiert.
      IF x_header-texttbexst NE space AND
         x_header-ptfrkyexst EQ space.
        PERFORM vim_temp_delim_texttab
                 USING enddate old_keyx.  "SW Texttransl
        IF x_header-bastab NE space.
          MOVE: <vim_enddate> TO <vim_text_enddate>,
                neuer_eintrag TO <action_text>.
        ENDIF.
      ENDIF.
      IF vim_special_mode NE space.    "special mode
        PERFORM temp_delim_undelete USING <vim_enddate_mask>
                                          <vim_begdate>
                                          act act_txt new_ix.
        IF new_ix NE 0.
          MOVE act TO <action>.
          IF x_header-bastab NE space AND x_header-texttbexst NE space.
            MOVE act_txt TO <action_text>.
          ENDIF.
          MODIFY total INDEX new_ix.
        ENDIF.
      ENDIF.                           "special mode
      IF vim_special_mode EQ space OR sy-subrc NE 0.
        IF x_header-delmdtflag EQ 'E'. "end date is key field
          new_ix = cur_ix. INSERT total.
        ELSE.                          "begin date is key field
          new_ix = cur_ix + 1. INSERT total INDEX new_ix.
        ENDIF.                         "x_header-delmdtflag eq 'E'
      ENDIF.
      IF vim_special_mode NE vim_undelete AND
         vim_delim_entries-index3 NE 0.
        vim_delim_entries-index1 = new_ix.
        vim_delim_entries-index2 = vim_delim_entries-index3.
        sy-fdpos = vim_delim_entries-index3.
        CLEAR vim_delim_entries-index3.
        APPEND vim_delim_entries.
        vim_delim_entries-index3 = sy-fdpos.
      ENDIF.                           "no undelete mode
    ENDIF. "overlayed eq space or overlayed eq 'M'
    IF overlayed EQ 'P' OR overlayed EQ 'M'.
      IF overlayed EQ 'M'.
        MOVE: enddate_safe TO <vim_enddate>, act_safe TO <action>,
              mark_safe TO <mark>.
        IF x_header-bastab NE space AND x_header-texttbexst NE space.
          MOVE act_txt_safe TO <action_text>.
        ENDIF.
      ENDIF.
      CLEAR hf.
      <vim_begdate> = enddate - date_increment.
      MOVE: original TO trans_pattern, aendern TO trans_pattern+1(1).
      TRANSLATE <action> USING trans_pattern.
      IF <mark> EQ markiert.
        <mark> = nicht_markiert.
        SUBTRACT 1 FROM mark_total.
      ENDIF.
      MODIFY total.
      IF vim_delim_entries-index3 NE 0.
        vim_delim_entries-index1 = cur_ix.
        vim_delim_entries-index2 = vim_delim_entries-index3.
        APPEND vim_delim_entries.
      ENDIF.
    ENDIF. "overlayed eq 'P' or overlayed eq 'M'
  ENDLOOP.
  MOVE 'G' TO temporal_delimitation_happened.
ENDFORM.                               "temp_delim_del_overled_entries
