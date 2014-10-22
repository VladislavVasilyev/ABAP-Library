*---------------------------------------------------------------------*
*       FORM CHECK_IF_ENTRY_IS_TO_DISPLAY                             *
*---------------------------------------------------------------------*
* <--- SY_SUBRC - 0: display entry, expanded mode or new entry        *
*               - 4: display entry, collapsed mode and actual entry   *
*               - 8: don't display entry, collapsed mode              *
*---------------------------------------------------------------------*
FORM check_if_entry_is_to_display USING value(key_local) TYPE char01
                                        value(key_in)    TYPE any
                                        value(mod_flag)  TYPE char01
                                        value(begdate)   TYPE d.
  DATA: rec TYPE i, act_entry_flag(1) TYPE c.
  LOCAL: total, extract.
  FIELD-SYMBOLS: <key_x> TYPE x, <key_h> TYPE x.


  CLEAR: <table1_wa>.
  <f1_wax> = <f1_x>.
  ASSIGN: key_in TO <key_h> CASTING,
          <key_h>(x_header-keylen) TO <key_x>.
  MOVE <key_x> TO <f1_x>.
  IF mod_flag NE space AND
     x_header-delmdtflag EQ 'E' AND begdate LE sy-datum AND
     <vim_enddate_mask> GE sy-datum OR x_header-delmdtflag EQ 'B' AND
     begdate GE sy-datum AND <vim_enddate_mask> LE sy-datum.
    act_entry_flag = 'X'.
  ENDIF.
  LOOP AT vim_collapsed_mainkeys FROM vim_coll_mainkeys_beg_ix.
    CHECK <vim_collapsed_mkey_bfx> = <vim_f1_beforex>.
*                                 WHERE mkey_bf EQ <vim_f1_before>.
    IF vim_mkey_after_exists NE space.
      CHECK <vim_collapsed_key_afx> EQ <vim_f1_afterx>.
*      CHECK <vim_collapsed_key_af> EQ <vim_f1_after>.
    ENDIF.
    vim_last_coll_mainkeys_ix = sy-tabix.
    IF act_entry_flag NE space.
      IF mod_flag EQ 'D'.
        READ TABLE extract WITH KEY <vim_collapsed_keyx>    "#EC *
                           TRANSPORTING NO FIELDS.
        IF sy-subrc EQ 0.
          DELETE extract INDEX sy-tabix.
        ENDIF.
      ENDIF.
      IF <key_x> NE <vim_collapsed_keyx>.
*      IF key_in NE vim_collapsed_mainkeys-mainkey.
        <vim_collapsed_keyx> = <key_x>.
*        vim_collapsed_mainkeys-mainkey = key_in.
        <vim_xtotal_key> = <key_x>.
        if <vim_collapsed_mkey_bfx> ne <vim_tot_mkey_beforex>.
          <vim_collapsed_mkey_bfx> = <vim_tot_mkey_beforex>.
        endif.
*        vim_collapsed_mainkeys-mkey_bf = <vim_tot_mkey_before>.
        MODIFY vim_collapsed_mainkeys.
      ENDIF.
      rec = 4.
    ELSE.
      IF <key_x> NE <vim_collapsed_keyx>.
*      IF key_in NE vim_collapsed_mainkeys-mainkey.
        rec = 8.
      ELSE.
        rec = 4.
      ENDIF.
    ENDIF.
    EXIT.
  ENDLOOP.
  IF sy-subrc NE 0.
    CLEAR rec.
  ENDIF.
  IF key_local NE space.
    <f1_x> = <f1_wax>.
  ENDIF.
  sy-subrc = rec.
ENDFORM.                               "check_if_entry_is_to_display
