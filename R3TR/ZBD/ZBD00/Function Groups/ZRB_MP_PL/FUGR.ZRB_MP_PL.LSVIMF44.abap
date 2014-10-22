*---------------------------------------------------------------------*
*       FORM VIM_PROCESS_ASSIGNS                                      *
*---------------------------------------------------------------------*
* process assigns                                                     *
*---------------------------------------------------------------------*
FORM vim_process_assigns.
  DATA: length TYPE i, keydate_alr_assigned(1) TYPE c,
        tablength TYPE i, texttablength TYPE i, keylen_bef_date TYPE i,
        xlength type i.

  TRANSLATE vim_prtfky_assigned USING 'XY'.
  ASSIGN: <initial> TO <initial_x> CASTING,
          total TO <vim_ctotal> CASTING TYPE c,
          total TO <vim_total_struc> CASTING TYPE (x_header-maintview),
          total to <vim_xtotal> casting,
          extract TO <vim_cextract> CASTING TYPE c,
          extract TO <vim_extract_struc>
           CASTING TYPE (x_header-maintview),
          extract to <vim_xextract> casting,
          corr_keytab-tabkey to <vim_corr_keyx> casting.
  tablength = x_header-after_tabc / cl_abap_char_utilities=>charsize.
  texttablength =
   x_header-aft_txttbc / cl_abap_char_utilities=>charsize.

  IF x_header-bastab NE space AND x_header-texttbexst NE space.
    length = tablength + texttablength.
    xlength = x_header-texttablen + x_header-tablen.
    ASSIGN: <vim_ctotal>+tablength(texttablength) TO <total_text>,
            <vim_xtotal>+x_header-after_tabc(x_header-texttablen)
             to <vim_xtotal_text>,
            <vim_xtotal_text> to <vim_tot_txt_struc>
             casting type (x_header-texttab),
            <vim_cextract>(tablength) TO <extract_enti>,
            <vim_cextract>+tablength(texttablength) TO <extract_text>,
            <vim_xextract>+x_header-after_tabc(x_header-texttablen)
             to <vim_xextract_text>,
            <vim_xextract_text> to <vim_ext_txt_struc>
             casting type (x_header-texttab).
ELSE.
    length = tablength.
    xlength = x_header-tablen.
  ENDIF.
  ASSIGN: <vim_ctotal>+length(1) TO <action>,
          <action>+1(1) TO <mark>,
          <vim_cextract>(length) TO <table2>,
          <vim_xextract>(xlength) to <table2_x>,
          <vim_xextract>(x_header-tablen) to <vim_xextract_enti>,
          <vim_cextract>+length(1) TO <xact>,
          <xact>+1(1)  TO <xmark>,
          <vim_ctotal>(vim_ctabkeylen) TO <vim_total_key>,
          <vim_cextract>(vim_ctabkeylen) TO <vim_extract_key>,
          <vim_xtotal>(x_header-keylen) TO <vim_xtotal_key>,
          <vim_xextract>(x_header-keylen) TO <vim_xextract_key>.

  IF x_header-bastab NE space AND x_header-texttbexst NE space.
    ASSIGN: <mark>+1(1) TO <action_text>,
            <xmark>+1(1) TO <xact_text>.
  ENDIF.
  IF x_header-adrnbrflag NE space.
    assign vim_addresses_to_save-handle to <vim_addr_handle_x> casting.
    LOOP AT x_namtab WHERE domname IN adrnbr_domain.
      ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE
       <vim_total_struc> TO <vim_total_address_number>.
      EXIT.
    ENDLOOP.
  ENDIF.
  IF x_header-delmdtflag NE space.
    LOOP AT x_namtab WHERE domname EQ vim_delim_date_domain
                       AND ( rollname in vim_begda_types or
                             rollname in vim_endda_types ).
      IF x_namtab-rollname in vim_begda_types.
* begin date
        IF x_header-delmdtflag EQ 'E'.
* end date is key field
          IF x_namtab-texttabfld EQ space.
            ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE
             <vim_total_struc> TO <vim_begdate>.
*            ASSIGN total+x_namtab-position(x_namtab-flength)
*                                   TO <vim_begdate> TYPE 'D'.
          ENDIF.
        ELSE.                          "begin date is key field
          CHECK keydate_alr_assigned EQ space OR
                keydate_alr_assigned EQ 'E' AND
                x_namtab-texttabfld NE space OR
                keydate_alr_assigned EQ 'T' AND
                x_namtab-texttabfld EQ space.
          IF x_namtab-texttabfld EQ space.
            TRANSLATE keydate_alr_assigned USING ' ETX'.
            ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE
             <vim_total_struc> TO <vim_enddate>.
*            ASSIGN total+x_namtab-position(x_namtab-flength)
*                                  TO <vim_enddate> TYPE 'D'.
            IF x_namtab-position GT 0.
              ASSIGN: <vim_xtotal>(x_namtab-position)
                       TO <vim_tot_mkey_beforex> casting,
                      <vim_xextract>(x_namtab-position)
                       TO <vim_ext_mkey_beforex> casting.
* for downward compatibility only:
              keylen_bef_date =
               x_namtab-position DIV cl_abap_char_utilities=>charsize.
              ASSIGN: <vim_ctotal>(keylen_bef_date)
                                     TO <vim_tot_mkey_before> TYPE 'C',
                      <vim_cextract>(keylen_bef_date)
                                     TO <vim_ext_mkey_before> TYPE 'C'.
            ELSE.
              ASSIGN:
*      begin correction if position <= 0, should be fitted to unicode.
                      vim_dummy_mainkey TO <vim_tot_mkey_beforex>
                                                              casting ,
                      vim_dummy_mainkey TO <vim_tot_mkey_beforex>
                                                              casting ,
*      end correction von XB am 22.03.02 for csn int1332679 2002
                      vim_dummy_mainkey TO <vim_tot_mkey_before>
                                                              TYPE 'C',
                      <vim_tot_mkey_before> TO <vim_ext_mkey_before>
                                                              TYPE 'C'.
            ENDIF.
            IF vim_mkey_after_exists NE space.
              PERFORM vim_assign_mkey_after_2 USING sy-tabix.
            ENDIF.
          ELSE.
            TRANSLATE keydate_alr_assigned USING ' TEX'.
            ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE
             <vim_tot_txt_struc> TO <vim_text_enddate>.
*            ASSIGN total+x_namtab-position(x_namtab-flength)
*                                  TO <vim_text_enddate> TYPE 'D'.
          ENDIF.
        ENDIF.                         "x_header-delmdtflag eq 'E'
      ELSE.
* end date
        IF x_header-delmdtflag EQ 'E'.
* end date is key field
          CHECK keydate_alr_assigned EQ space OR
                keydate_alr_assigned EQ 'E' AND
                x_namtab-texttabfld NE space OR
                keydate_alr_assigned EQ 'T' AND
                x_namtab-texttabfld EQ space.
          IF x_namtab-texttabfld EQ space.
            TRANSLATE keydate_alr_assigned USING ' ETX'.
            ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE
             <vim_total_struc> TO <vim_enddate>.
*            ASSIGN total+x_namtab-position(x_namtab-flength)
*                                  TO <vim_enddate> TYPE 'D'.
            IF x_namtab-position GT 0.
              ASSIGN: <vim_xtotal>(x_namtab-position)
                       TO <vim_tot_mkey_beforex> casting,
                      <vim_xextract>(x_namtab-position)
                       TO <vim_ext_mkey_beforex> casting.
* for downward compatibility only:
              keylen_bef_date =
               x_namtab-position DIV cl_abap_char_utilities=>charsize.
              ASSIGN:
                      <vim_ctotal>(keylen_bef_date)
                                     TO <vim_tot_mkey_before> TYPE 'C',
                      <vim_cextract>(keylen_bef_date)
                                     TO <vim_ext_mkey_before> TYPE 'C'.
*              ASSIGN: total(x_namtab-position)
*                                     TO <vim_tot_mkey_before> TYPE 'C',
*                      extract(x_namtab-position)
*                                     TO <vim_ext_mkey_before> TYPE 'C'.
            ELSE.
              ASSIGN:
*      begin correction if position <= 0, should be fitted to unicode.
                      vim_dummy_mainkey TO <vim_tot_mkey_beforex>
                                                              casting ,
                      vim_dummy_mainkey TO <vim_ext_mkey_beforex>
                                                              casting ,
*      end correction von XB am 22.03.02 for csn int1332679 2002
                      vim_dummy_mainkey TO <vim_tot_mkey_before>
                                                              TYPE 'C',
                      <vim_tot_mkey_before> TO <vim_ext_mkey_before>
                                                              TYPE 'C'.
            ENDIF.
            IF vim_mkey_after_exists NE space.
              PERFORM vim_assign_mkey_after_2 USING sy-tabix.
            ENDIF.
          ELSE.
            TRANSLATE keydate_alr_assigned USING ' TEX'.
            ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE
             <vim_tot_txt_struc> TO <vim_text_enddate>.
*            ASSIGN total+x_namtab-position(x_namtab-flength)
*                                  TO <vim_text_enddate> TYPE 'D'.
          ENDIF.
        ELSE.                          "begin date is key field
          IF x_namtab-texttabfld EQ space.
            ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE
             <vim_total_struc> TO <vim_begdate>.
*            ASSIGN total+x_namtab-position(x_namtab-flength)
*                                   TO <vim_begdate> TYPE 'D'.
          ENDIF.
        ENDIF.                         "x_header-delmdtflag eq 'E'
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                               "vim_process_assigns
