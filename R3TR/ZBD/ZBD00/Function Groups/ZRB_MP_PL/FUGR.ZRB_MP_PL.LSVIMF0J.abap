*&--------------------------------------------------------------------*
*&      FORM COLLAPSE                                                 *
*&--------------------------------------------------------------------*
* collapse                                                            *
*&--------------------------------------------------------------------*
FORM collapse USING value(c_begin_ix) TYPE i value(c_end_ix) TYPE i.
  LOCAL: extract.
  DATA: first(1) TYPE c VALUE 'X', hf_ind TYPE i, hf_ind2 TYPE i,
        act_ix TYPE i.

  LOOP AT total.
    act_ix = sy-tabix.
    PERFORM select USING <status>-selected.
    CHECK sy-subrc EQ 0.
    CHECK <vim_tot_mkey_beforeX> EQ <vim_mkey_beforeX> AND
          ( vim_mkey_after_exists EQ space OR
            <vim_tot_mkey_afterx> EQ <vim_mkey_afterx> ).
*    CHECK <vim_tot_mkey_before> EQ <vim_mkey_before> AND
*          ( vim_mkey_after_exists EQ space OR
*            <vim_tot_mkey_after> EQ <vim_mkey_after> ).
    IF first NE space.
* Changed from XB. 12.06.02 BCEK060520/BCEK060521
      <vim_collapsed_keyx> = <vim_xtotal_key>.
*      vim_collapsed_mainkeys-mainkey = <vim_total_key>.
      if <vim_collapsed_mkey_bfx> ne <vim_tot_mkey_beforex>.
        <vim_collapsed_mkey_bfx> = <vim_tot_mkey_beforex>.
*      vim_collapsed_mainkeys-mkey_bf = <vim_tot_mkey_before>.
      endif.
      hf_ind = act_ix.
      CLEAR first.
    ENDIF.
* Changed from XB. 12.06.02 End.

    IF x_header-delmdtflag EQ 'E'.
      CHECK <vim_begdate> LE sy-datum AND
            <vim_enddate> GE sy-datum.
    ELSE.
      CHECK <vim_begdate> GE sy-datum AND
            <vim_enddate> LE sy-datum.
    ENDIF.
    <vim_collapsed_keyx> = <vim_xtotal_key>.
* changed from Xue. End.
    if <vim_collapsed_mkey_bfx> ne <vim_tot_mkey_beforex>.
      <vim_collapsed_mkey_bfx> = <vim_tot_mkey_beforex>.
    endif.
*    vim_collapsed_mainkeys-mainkey = <vim_total_key>.
*    <vim_collapsed_mkey_bfx> = <vim_tot_mkey_beforex>.
*    vim_collapsed_mainkeys-mkey_bf = <vim_tot_mkey_before>.

* Change from Xue. End.
    hf_ind = act_ix.
    EXIT.
  ENDLOOP.
  READ TABLE vim_collapsed_mainkeys                         "#EC *
                                with key <vim_collapsed_keyx>
*                                WITH KEY vim_collapsed_mainkeys-mainkey
                                BINARY SEARCH
                                TRANSPORTING NO FIELDS.
  INSERT vim_collapsed_mainkeys INDEX sy-tabix.
  vim_delim_entries-index1 = hf_ind.
  vim_delim_entries-index2 = c_begin_ix.
  vim_delim_entries-index3 = c_begin_ix.
  vim_delim_entries-index_corr = 'X'.
  APPEND vim_delim_entries.
  hf_ind2 = c_begin_ix + 1.
  CLEAR vim_delim_entries.
  LOOP AT extract FROM hf_ind2 TO c_end_ix.
    vim_delim_entries-index3 = sy-tabix.
    APPEND vim_delim_entries.
  ENDLOOP.
  CLEAR vim_old_viewkey.
  TRANSLATE vim_no_mainkey_exists USING vim_no_mkey_not_procsd_patt.
ENDFORM.                               "collapse
