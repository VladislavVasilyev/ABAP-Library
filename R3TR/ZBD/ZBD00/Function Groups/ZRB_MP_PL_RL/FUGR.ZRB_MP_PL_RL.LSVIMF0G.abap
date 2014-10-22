*&--------------------------------------------------------------------*
*&      Form  BUILD_MAINKEY_TAB_1                                     *
*&--------------------------------------------------------------------*
* build mainkey tab for display modification - part one               *
* merge identical entries for same mainkey into one entry
* assumptions: TOTAL is sorted ascending by <VIM_TOTAL_KEY>
*              Now, with unicode: sorted by <VIM_TOTAL_KEYX>
*&--------------------------------------------------------------------*
FORM build_mainkey_tab_1.
  DATA: date_safe TYPE d, date_safe_1 TYPE d, date_safe_2 TYPE d,
        date_safe_3 TYPE d.

  date_safe = <vim_begdate>.           "TOTAL
  date_safe_1 = <vim_enddate>.         "TOTAL
  date_safe_2 = <vim_new_begdate>.                          "<TABLE1>
  date_safe_3 = <vim_enddate_mask>.                         "<TABLE1>
  <vim_begdate> = <vim_enddate> = <vim_new_begdate> =
                  <vim_enddate_mask> = '99999999'.
  IF <vim_xtotal> NE <table1_x>.
    MOVE: date_safe   TO <vim_begdate>,
          date_safe_1 TO <vim_enddate>,
          date_safe_2 TO <vim_new_begdate>,
          date_safe_3 TO <vim_enddate_mask>.
    IF vim_no_mainkey_exists EQ vim_no_mkey_not_procsd OR
       <vim_tot_mkey_beforex> NE <vim_f1_beforex>.
*       <vim_tot_mkey_before> NE <vim_f1_before> OR
*       ( vim_mkey_after_exists NE space AND
*         <vim_tot_mkey_after> NE <vim_f1_after> ).
      IF vim_coll_mkeys_first EQ space.
        APPEND vim_collapsed_mainkeys.
        CLEAR vim_collapsed_mainkeys-log_key.
      ELSE.
        CLEAR vim_coll_mkeys_first.
      ENDIF.
      <vim_collapsed_keyx> = <vim_xtotal_key>.
      <vim_collapsed_mkey_bfx> = <vim_tot_mkey_beforex>.
*      vim_collapsed_mainkeys-mainkey = <vim_total_key>.
*      vim_collapsed_mainkeys-mkey_bf = <vim_tot_mkey_before>.
* If the position <= 0, the <vim_collapsed_mkey_bfx> shouldn't be
* assigned. XB am 27.03.2002 CSN int1332679 2002
    ELSEIF vim_mkey_after_exists NE space AND
         <vim_tot_mkey_afterx> NE <vim_f1_afterx>.
      IF vim_coll_mkeys_first EQ space.
        APPEND vim_collapsed_mainkeys.
        CLEAR vim_collapsed_mainkeys-log_key.
      ELSE.
        CLEAR vim_coll_mkeys_first.
      ENDIF.
      <vim_collapsed_keyx> = <vim_xtotal_key>.
*      <vim_collapsed_mkey_bfx> = <vim_tot_mkey_beforex>.
*      vim_collapsed_mainkeys-mainkey = <vim_total_key>.
*      vim_collapsed_mainkeys-mkey_bf = <vim_tot_mkey_before>.
    ELSE.
      IF x_header-delmdtflag EQ 'E' AND <vim_begdate> LE sy-datum AND
       <vim_enddate> GE sy-datum OR x_header-delmdtflag EQ 'B' AND
       <vim_begdate> GE sy-datum AND <vim_enddate> LE sy-datum.
        <vim_collapsed_keyx> = <vim_xtotal_key>.
* change xb 12.06.02 begin--------------------------------------------
        if <vim_collapsed_mkey_bfx> NE <vim_tot_mkey_beforex>.
          <vim_collapsed_mkey_bfx> = <vim_tot_mkey_beforex>.
        endif.
* change xb 12.06.02 ***********************************************
*        vim_collapsed_mainkeys-mainkey = <vim_total_key>.
*        vim_collapsed_mainkeys-mkey_bf = <vim_tot_mkey_before>.
      ENDIF.
    ENDIF.
* end correction XB am 27.03.2002 CSN int1332679 2002
    <table1_x> = <vim_xtotal>.
    TRANSLATE vim_no_mainkey_exists USING vim_no_mkey_procsd_patt.
  ELSE.
    MOVE: date_safe   TO <vim_begdate>,
          date_safe_1 TO <vim_enddate>,
          date_safe_2 TO <vim_new_begdate>,
          date_safe_3 TO <vim_enddate_mask>.
    IF x_header-delmdtflag EQ 'E' AND <vim_begdate> LE sy-datum AND
      <vim_enddate> GE sy-datum OR x_header-delmdtflag EQ 'B' AND
      <vim_begdate> GE sy-datum AND <vim_enddate> LE sy-datum.
      <vim_collapsed_keyx> = <vim_xtotal_key>.
* change xb 12.06.02 begin--------------------------------------------
      if <vim_collapsed_mkey_bfx> NE <vim_tot_mkey_beforex>.
        <vim_collapsed_mkey_bfx> = <vim_tot_mkey_beforex>.
      endif.
* change xb 12.06.02 ***********************************************

*      vim_collapsed_mainkeys-mainkey = <vim_total_key>.
*      vim_collapsed_mainkeys-mkey_bf = <vim_tot_mkey_before>.
    ENDIF.
  ENDIF.

ENDFORM.                               "build_mainkey_tab_1
