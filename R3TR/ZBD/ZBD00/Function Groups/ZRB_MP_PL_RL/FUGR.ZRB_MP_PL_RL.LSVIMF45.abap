*---------------------------------------------------------------------*
*       FORM INITIALISIEREN                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM initialisieren.
  LOCAL: counter.                                           "#EC *
  TYPES: BEGIN OF i_fnamecnt,
           name LIKE vimsellist-viewfield,                  "#EC *
           cnt TYPE i,
         END OF i_fnamecnt.
  DATA: keydate_alr_assigned(1) TYPE c,
        program LIKE d020s-prog,                            "#EC NEEDED
        namlen TYPE i,                                      "#EC NEEDED
        length TYPE i,
        name(25) TYPE c,
        fname(50) TYPE c,
        dynnr LIKE liste,                                    "#EC NEEDED
        i_fnametb TYPE SORTED TABLE OF i_fnamecnt WITH UNIQUE KEY name,
        i_fnameln TYPE i_fnamecnt, initexclfldtabs(1) TYPE c,
        i_objtype LIKE objh-objecttype,
        f_fieldname(50) TYPE c.
  DATA: h_f1(70) TYPE c, h_f2(8)  TYPE c, h_f3(20) TYPE c.                         "#EC NEEDED
  FIELD-SYMBOLS: <m1>, <mili> TYPE ANY, <x_namtab> TYPE vimnamtab,"#EC *
                 <f_fld_value> TYPE ANY.

  IF nbrd_texts_alr_read EQ space.
    CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'transport/systemtype'                "#EC CI_CCALL
                       ID 'VALUE' FIELD vim_system_type.
    PERFORM set_numbered_texts.
    length = vim_position_info_lg1 + 2 + vim_position_info_lg3.
** XB 585898B - remove the unused characters ';;'.
*    IF sy-langu = 'J'.
*      REPLACE ';;' IN svim_text_027 WITH '  '.
*    ENDIF.
** XB 585898E
*   HW804856 remove disturbing ';'or ';;..' from translated texts
    REPLACE ALL OCCURRENCES OF ';' IN svim_text_027 WITH '    '.
    REPLACE ALL OCCURRENCES OF ';' IN svim_text_028 WITH '    '.
    REPLACE ALL OCCURRENCES OF ';' IN svim_text_029 WITH '    '.
    WRITE: svim_text_027 TO
             vim_position_info_mask(vim_position_info_lg1),
           svim_text_028 TO
             vim_position_info_mask+length(vim_position_info_lg2).
    vim_posi_push = '@3Y@'. vim_posi_push+4 = svim_text_029.
    MOVE: 'I'   TO mark_functions-sign,
          'I'   TO adrnbr_domain-sign,
          'I'   TO exted_functions-sign,
          'EQ'  TO mark_functions-option,
          'EQ'  TO adrnbr_domain-option,
          'EQ'  TO exted_functions-option,
          space TO mark_functions-high,
          space TO adrnbr_domain-high,
          space TO exted_functions-high.
    MOVE 'ADDR' TO mark_functions-low. APPEND mark_functions."#EC *
    MOVE 'ALMK' TO mark_functions-low. APPEND mark_functions."#EC *
    MOVE 'DELE' TO mark_functions-low. APPEND mark_functions."#EC *
    MOVE 'DELM' TO mark_functions-low. APPEND mark_functions."#EC *
    MOVE 'EXPA' TO mark_functions-low. APPEND mark_functions."#EC *
    MOVE 'KOPE' TO mark_functions-low. APPEND mark_functions."#EC *
    MOVE 'MKLO' TO mark_functions-low. APPEND mark_functions."#EC *
    MOVE 'ORGI' TO mark_functions-low. APPEND mark_functions."#EC *
    MOVE 'REPL' TO mark_functions-low. APPEND mark_functions."#EC *
    MOVE 'TEXT' TO mark_functions-low. APPEND mark_functions."#EC *
    MOVE 'TREX' TO mark_functions-low. APPEND mark_functions."#EC *
    MOVE 'TRIN' TO mark_functions-low. APPEND mark_functions."#EC *
    MOVE 'UNDO' TO mark_functions-low. APPEND mark_functions."#EC *
    MOVE 'BCSH' TO mark_functions-low. APPEND mark_functions."#EC *
    MOVE 'UNDO' TO exted_functions-low. APPEND exted_functions."#EC *
    MOVE 'DELE' TO exted_functions-low. APPEND exted_functions."#EC *
    MOVE 'TRIN' TO exted_functions-low. APPEND exted_functions."#EC *
    MOVE 'TREX' TO exted_functions-low. APPEND exted_functions."#EC *
    PERFORM vim_fill_vim_guid_domain.
    PERFORM vim_fill_date_type.
    DO.
      ASSIGN COMPONENT sy-index OF STRUCTURE vim_adrnbr_domains TO <m1>.
      IF sy-subrc NE 0. EXIT. ENDIF.
      MOVE <m1> TO adrnbr_domain-low. APPEND adrnbr_domain. "#EC *
    ENDDO.
    PERFORM vim_initialize_d0100.      " SW Texttransl
    MOVE 'X' TO nbrd_texts_alr_read.
  ENDIF.
  READ TABLE x_header INDEX 1.                              "#EC *
  IF x_header-existency NE 'R'.
* SOBJ-Eintrag da?
    IF x_header-bastab EQ space OR
     ( x_header-maintview NE x_header-viewname AND          "UF160998
       x_header-bastab NE space ).                          "#EC BOOL_OK
      i_objtype = 'V'.
    ELSE.
      i_objtype = 'S'.
    ENDIF.
    SELECT SINGLE * FROM objh WHERE objectname EQ x_header-viewname
                                AND objecttype EQ i_objtype."#EC *
    IF sy-subrc NE 0.                  "no obj.descr. -> run RSVIM30A
      MESSAGE a138(sv) WITH x_header-viewname x_header-area.
    ENDIF.
  ENDIF.
  CLEAR: vim_nbr_of_scrfrm_pointers.
  vim_view_name = vim_addresses_to_save-viewname = x_header-viewname.
  MOVE: x_header-liste TO liste,
        x_header-detail TO detail.
  CASE x_header-type.
    WHEN '1'. MOVE einstufig TO status-type.
    WHEN '2'. MOVE zweistufig TO status-type.
  ENDCASE.
  counter = STRLEN( x_header-ddtext ).
  IF counter EQ 0. counter = 1. x_header-ddtext(1) = '?'. ENDIF.
  vim_title_name = x_header-ddtext.
  ASSIGN: vim_title_name(counter) TO <name>.
  MOVE <name> TO vim_frame_field.
* set up status vector
  IF x_header-bastab NE space.
    MOVE: 'STATUS_' TO name,
          x_header-maintview TO name+7.                     "Subviews
    ASSIGN (name) TO <status>.
    MOVE: '*' TO name,
          x_header-maintview TO name+1.
    ASSIGN (x_header-maintview) TO <table1>.
    IF sy-subrc = 4.
      MESSAGE a173(sv) WITH x_header-maintview x_header-area.  "#EC *
    ENDIF.
    ASSIGN (name) TO <initial> CASTING TYPE (x_header-maintview).
* XB H606530B
* check if the time-field exists: Yes, then reset initial value.
    LOOP AT x_namtab WHERE datatype = 'TIMS' AND
                       texttabfld EQ space.         "HCG HW681596
      CONCATENATE '<initial>' x_namtab-viewfield INTO f_fieldname
              SEPARATED BY '-'.
      ASSIGN (f_fieldname) TO <f_fld_value>.
      CLEAR <f_fld_value> WITH space.
    ENDLOOP.
* XB H606530B
    IF x_header-texttbexst NE space.
      MOVE x_header-texttab TO name+1.
      ASSIGN: (x_header-texttab)  TO <table1_text>,
              (name)              TO <text_initial>,
              <table1_text>       TO <table1_xtext> CASTING,
              <table1_xtext>(x_header-textkeylen)  TO <textkey_x>,
              <text_initial>      TO <text_initial_x> CASTING,
              <text_initial_x>(x_header-textkeylen)
               TO <initial_textkey_x>.
      IF x_header-generictrp <> 'X'
       AND cl_abap_char_utilities=>charsize = 1.
* charlike key and non-unicode-system (FS only assigned for
* downward compatibility).
        ASSIGN: <table1_text>(x_header-textkeylen) TO <textkey>,
           <text_initial>(x_header-textkeylen) TO <initial_textkey>.
      ELSE.
        ASSIGN: <table1_xtext> TO <textkey>,
               <initial_textkey_x> TO <initial_textkey>.
      ENDIF.
    ENDIF.
    IF x_header-viewname = x_header-maintview.              "Subviews
      CLEAR e071k-viewname.
      master_type = transp_object.
    ELSE.      "View auf Tab.                              "Subviews ..
      e071k-viewname = view_name.
      master_type = vim_view_type.
    ENDIF.                             ".. Subviews
  ELSE.                                                     "view
* XB H606530B
* check if the time-field exists: Yes, then reset initial value.
    LOOP AT x_namtab WHERE datatype = 'TIMS'.               "#EC *
      CONCATENATE '<initial>' x_namtab-viewfield INTO f_fieldname
              SEPARATED BY '-'.
      ASSIGN (f_fieldname) TO <f_fld_value>.
      CLEAR <f_fld_value> WITH space.
    ENDLOOP.
* XB H606530B
    WRITE: x_header-maintview TO compl_formname+compl_form_offs,
           x_header-maintview TO corr_formname+corr_form_offs.
    MOVE: view_name     TO e071k-viewname,
          vim_view_type TO master_type.
  ENDIF.
* set up screens
  MOVE: 'TCTRL_' TO name,
        x_header-maintview TO name+6.
* Übergangslösung Tablecontrol Anfang
  DATA: h LIKE d020s, f LIKE d021s OCCURS 10, e LIKE d022s OCCURS 10,"#EC *
        m LIKE d023s OCCURS 10, e_h LIKE d022s,             "#EC NEEDED
        i_dynid(44) TYPE c.            "VALUE 'SAPL'.
  i_dynid  = x_header-fpoolname.                            "4.0B
  i_dynid+40(4) = x_header-liste.
  IMPORT DYNPRO h f e m ID i_dynid.
  IF sy-subrc EQ 0.
    LOOP AT e INTO e_h WHERE LINE CS name.
      EXIT.
    ENDLOOP.
    IF sy-subrc EQ 0.
      vim_tabctrl_active = 'X'.
    ELSE.
      CLEAR vim_tabctrl_active.
    ENDIF.
    ASSIGN h-mili TO <mili> CASTING TYPE x.
    IF <mili> O vim_template_dynpro.   "SW: gen. Dynpros sind evtl.
      h-mili = h-mili - vim_template_dynpro.   "fälschlicherweise als
      EXPORT DYNPRO h f e m ID i_dynid."Vorlagedynpros gekennzeichnet
      GENERATE DYNPRO h f e m ID i_dynid
                              MESSAGE h_f1 LINE h_f2 WORD h_f3.
    ENDIF.
  ELSE.
    CLEAR vim_tabctrl_active.
  ENDIF.
  IF x_header-type = '2'.
    i_dynid+40(4) = x_header-detail.
    IMPORT DYNPRO h f e m ID i_dynid.
    ASSIGN h-mili TO <mili> CASTING TYPE x.                         "#EC RC_READ
    IF sy-subrc = 0
     AND <mili> O vim_template_dynpro. "UF: Auch Einzelbilder sind
      h-mili = h-mili - vim_template_dynpro.   "evtl. fälschlicherweise
      EXPORT DYNPRO h f e m ID i_dynid."als Vorlagedynpros
      GENERATE DYNPRO h f e m ID i_dynid       "gekennzeichnet
       MESSAGE h_f1 LINE h_f2 WORD h_f3.
    ENDIF.
  ENDIF.
  IF vim_tabctrl_active NE space.
* Übergangslösung Tablecontrol Ende
    ASSIGN (name) TO <vim_tctrl>.
    IF sy-subrc EQ 0.
      vim_tabctrl_active = 'X'.
      IF last_view_info <> space.      "Subviews ..
        REFRESH CONTROL name FROM SCREEN x_header-liste.
      ENDIF.                           ".. Subviews
      IF vim_restore_mode EQ space.
        <status>-l_sel_mode = <vim_tctrl>-line_sel_mode.
      ENDIF.
*     IF x_header-maintview <> x_header-viewname. "Subviews or Switch-ID
      LOOP AT x_namtab WHERE readonly = vim_hidden.         "#EC *
        CONCATENATE x_header-maintview '-' x_namtab-viewfield
                                                           INTO fname.
        LOOP AT <vim_tctrl>-cols INTO vim_tc_cols
                                 WHERE screen-name = fname.
          vim_tc_cols-vislength = 0.
          vim_tc_cols-invisible = '1'.
          MODIFY <vim_tctrl>-cols FROM vim_tc_cols.
          EXIT.
        ENDLOOP.
      ENDLOOP.
*     ENDIF.                                   ".. Subviews or Switch-ID
    ELSE.
      CLEAR vim_tabctrl_active.
    ENDIF.
  ENDIF.
* process assigns to structure
  vim_ctabkeylen =
   x_header-after_keyc / cl_abap_char_utilities=>charsize.
  IF x_header-clidep NE space.
    READ TABLE x_namtab ASSIGNING <x_namtab>
     WITH KEY datatype = 'CLNT'.
    ASSIGN COMPONENT <x_namtab>-viewfield OF STRUCTURE <table1>
     TO <client>.
    ASSIGN COMPONENT <x_namtab>-viewfield OF STRUCTURE <initial>
     TO <vim_client_initial>.
    <vim_client_initial> = sy-mandt.
  ELSE.
    ASSIGN mandant TO <vim_client_initial>.
  ENDIF.
  master_name = view_name.
  ASSIGN: (x_header-maintview) TO <table1_x> CASTING,
          <table1_x>(x_header-keylen) TO <f1_x>,
          vim_view_wax TO <table1_wa>
           CASTING TYPE (x_header-maintview),
          vim_view_wax TO <table1_wax> CASTING,
          <table1_wax>(x_header-keylen) TO <f1_wax> CASTING.
  IF x_header-generictrp <> 'X'
   AND cl_abap_char_utilities=>charsize = 1.
* charlike key or non-unicode-system (<f1> is only assigned for
* downward compatibility).
    ASSIGN <table1>(vim_ctabkeylen) TO <f1>.
  ELSE.
    ASSIGN <f1_x> TO <f1>.
  ENDIF.
  PERFORM vim_set_init_from_sellist USING x_header-maintview
                                          x_namtab[]
                                          dba_sellist[]
                                          vim_hidden
                                    CHANGING <initial>.
  IF last_view_info NE space.          "store old exclfldtabs
    MOVE: last_view_info TO vim_excl_xxx_tab_safe-viewname,
          excl_pos_tab[] TO vim_excl_xxx_tab_safe-excl_pos_tab,
          excl_rpl_tab[] TO vim_excl_xxx_tab_safe-excl_rpl_tab,
          excl_que_tab[] TO vim_excl_xxx_tab_safe-excl_que_tab.
    MODIFY TABLE vim_excl_xxx_tab_safe.                     "#EC *
    IF sy-subrc NE 0.
      INSERT TABLE vim_excl_xxx_tab_safe.                   "#EC *
    ENDIF.
  ENDIF.
  READ TABLE vim_excl_xxx_tab_safe WITH TABLE KEY
                                   viewname = x_header-viewname."#EC *
  IF sy-subrc EQ 0.
    excl_pos_tab[] = vim_excl_xxx_tab_safe-excl_pos_tab.
    excl_rpl_tab[] = vim_excl_xxx_tab_safe-excl_rpl_tab.
    excl_que_tab[] = vim_excl_xxx_tab_safe-excl_que_tab.
  ELSE.
    REFRESH: excl_rpl_tab, excl_que_tab, excl_pos_tab, exclude_tab.
    CLEAR: excl_rpl_tab, excl_que_tab, excl_pos_tab, exclude_tab.
    initexclfldtabs = 'X'.
  ENDIF.
  IF x_header-subsetflag NE space OR x_header-adrnbrflag NE space OR
     x_header-rdonlyflag NE space OR x_header-usrexiflag NE space OR
     x_header-hiddenflag NE space OR x_header-scrfrmflag NE space OR
     x_header-guidflag NE space.
* no positioning or replacing for certain kinds of fields
    LOOP AT x_namtab WHERE readonly NE space
                        OR domname IN adrnbr_domain
                        OR domname EQ vim_scrform_domain
                        OR domname IN vim_guid_domain.      "#EC *
      IF x_namtab-domname IN adrnbr_domain.
*        ASSIGN <table1>+x_namtab-position(x_namtab-flength)
*                    TO <address_number>.
        ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE <table1>
         TO <address_number>.
        MOVE x_namtab-readonly TO adrnbr_roflag.
        vim_addr_basetable = x_namtab-bastabname.
        vim_addr_bastab_field = x_namtab-bastabfld.
        CHECK initexclfldtabs NE space.
        MOVE x_namtab-viewfield TO excl_rpl_tab-fieldname.
        MOVE x_namtab-viewfield TO excl_que_tab-fieldname.
        MOVE x_namtab-viewfield TO excl_pos_tab-fieldname.
        COLLECT excl_rpl_tab.                               "#EC *
        COLLECT excl_que_tab.                               "#EC *
        COLLECT excl_pos_tab.                               "#EC *
        CONTINUE.
      ELSEIF x_namtab-domname EQ vim_scrform_domain.
*        ASSIGN <table1>+x_namtab-position(x_namtab-flength)
*                    TO <vim_scrform_name>.
        ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE <table1>
         TO <vim_scrform_name>.
        ADD 1 TO vim_nbr_of_scrfrm_pointers.
      ELSEIF x_namtab-domname IN vim_guid_domain.
        MOVE x_namtab-viewfield TO excl_rpl_tab-fieldname.
        MOVE x_namtab-viewfield TO excl_que_tab-fieldname.
        MOVE x_namtab-viewfield TO excl_pos_tab-fieldname.
        COLLECT excl_rpl_tab.                               "#EC *
        COLLECT excl_que_tab.                               "#EC *
        COLLECT excl_pos_tab.                               "#EC *
        CONTINUE.
      ENDIF.
      CHECK initexclfldtabs NE space.
      CASE x_namtab-readonly.
        WHEN subset.
          MOVE x_namtab-viewfield TO excl_rpl_tab-fieldname.
          MOVE x_namtab-viewfield TO excl_que_tab-fieldname.
          APPEND excl_rpl_tab.                              "#EC *
          APPEND excl_que_tab.                              "#EC *
        WHEN usrexi.
*         check initexclfldtabs ne space.
          MOVE x_namtab-viewfield TO excl_rpl_tab-fieldname.
          MOVE x_namtab-viewfield TO excl_que_tab-fieldname.
          MOVE x_namtab-viewfield TO excl_pos_tab-fieldname.
          APPEND excl_rpl_tab.                              "#EC *
          APPEND excl_que_tab.                              "#EC *
          APPEND excl_pos_tab.                              "#EC *
        WHEN vim_hidden.
          MOVE x_namtab-viewfield TO excl_rpl_tab-fieldname.
          MOVE x_namtab-viewfield TO excl_que_tab-fieldname.
          MOVE x_namtab-viewfield TO excl_pos_tab-fieldname.
          APPEND excl_rpl_tab.                              "#EC *
          APPEND excl_que_tab.                              "#EC *
          APPEND excl_pos_tab.                              "#EC *
        WHEN rdonly.
          MOVE x_namtab-viewfield TO excl_rpl_tab-fieldname.
          APPEND excl_rpl_tab.                              "#EC *
      ENDCASE.
    ENDLOOP.
  ENDIF.
  IF x_header-scrfrmflag NE space AND vim_nbr_of_scrfrm_pointers EQ 1.
    mark_functions-low = 'SCRF'. APPEND mark_functions.     "#EC *
  ELSE.
    DELETE mark_functions WHERE low EQ 'SCRF'.
  ENDIF.
  IF x_header-selection NE space AND initexclfldtabs NE space.
    i_fnameln-cnt = 1.
    LOOP AT dba_sellist WHERE ddic CO ddic_marks
                        AND ( negation EQ space AND operator EQ 'EQ' OR
                              negation EQ 'NOT' AND operator EQ 'NE' )."#EC *
      i_fnameln-name = dba_sellist-viewfield.
      COLLECT i_fnameln INTO i_fnametb.
    ENDLOOP.
    LOOP AT i_fnametb INTO i_fnameln WHERE cnt EQ 1.        "#EC CI_SORTSEQ
      excl_rpl_tab-fieldname = i_fnameln-name.
      COLLECT excl_rpl_tab.                                 "#EC *
      excl_que_tab-fieldname = i_fnameln-name.
      COLLECT excl_que_tab.                                 "#EC *
    ENDLOOP.
  ENDIF.
  IF x_header-delmdtflag NE space.
    vim_tdep_title = svim_text_104.
    CLEAR: vim_old_viewkey, vim_old_st_selected.          "SW wegen Vcl
    REFRESH vim_sval_tab. CLEAR vim_sval_tab.
    MOVE: x_header-viewname TO vim_sval_tab-tabname,
          x_header-maintview TO vim_begdate_name-tabname,
          x_header-maintview TO vim_enddate_name-tabname,
          'X' TO vim_sval_tab-field_obl,
          sy-datum TO vim_sval_tab-value.
    vim_begdate_name-dash = vim_enddate_name-dash = '-'.
    IF x_header-delmdtflag EQ 'E'.
      ASSIGN d0001_field_tab-end TO <key_date>.
    ELSE.
      ASSIGN d0001_field_tab-begin TO <key_date>.
    ENDIF.
    ASSIGN: vim_mainkey TO <vim_h_mkey> CASTING,
            vim_old_viewkey TO <vim_h_old_mkey> CASTING,
            vim_collapsed_mainkeys-mainkey TO <vim_h_coll_mkey> CASTING,
            vim_collapsed_mainkeys-log_key TO <vim_h_coll_logkey>
             CASTING,
            vim_collapsed_mainkeys-mkey_bf TO <vim_h_coll_bfkey>
             CASTING,
            vim_merged_entries-merged_key TO <vim_h_merged_key> CASTING.
    LOOP AT x_namtab WHERE domname EQ vim_delim_date_domain
                       AND ( rollname IN vim_begda_types OR
                             rollname IN vim_endda_types ). "#EC *
      IF x_namtab-rollname IN vim_begda_types.
* begin date
        IF x_header-delmdtflag EQ 'E'.
* end date is key field
          IF x_namtab-texttabfld EQ space.
*            ASSIGN: <table1>+x_namtab-position(x_namtab-flength)
*                                   TO <vim_new_begdate> TYPE 'D',
*                    <table1>+x_namtab-position(x_namtab-flength)
*                                   TO <vim_begdate_mask> TYPE 'C'.
            ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE <table1>
             TO <vim_new_begdate>.
            ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE <table1>
             TO <vim_begdate_mask> CASTING TYPE c.
            MOVE: x_namtab-viewfield TO vim_sval_tab-fieldname,
                  x_namtab-viewfield TO vim_begdate_name-fieldname.
            vim_begdate_is_ro = x_namtab-readonly.
          ENDIF.
        ELSE.
* begin date is key field
          CHECK keydate_alr_assigned EQ space.
          keydate_alr_assigned = 'X'.
          IF x_namtab-texttabfld EQ space.
*            ASSIGN: <table1>+x_namtab-position(x_namtab-flength)
*                                   TO <vim_enddate_mask> TYPE 'C'.
            ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE <table1>
             TO <vim_enddate_mask> CASTING TYPE c.
            IF x_namtab-position GT 0.
              IF x_header-generictrp <> 'X'.
** charlike key or non-unicode-system (FS is only assigned for
** downward compatibility).
                length = x_namtab-position
                          DIV cl_abap_char_utilities=>charsize.
                ASSIGN: <table1>(length)
                         TO <vim_f1_before> CASTING TYPE c,
                        vim_mainkey(length)
                          TO <vim_mkey_before> CASTING TYPE c,
                        vim_old_viewkey(length)
                          TO <vim_old_mkey_before> CASTING TYPE c.
              ENDIF.
              IF NOT ( <vim_f1_before> IS ASSIGNED
                       OR <vim_mkey_before> IS ASSIGNED
                       OR <vim_old_mkey_before> IS ASSIGNED ).
** could not be assigned because unicode flag is set in function
** group and key is non charlike
                ASSIGN: <table1_x>(x_namtab-position)
                         TO <vim_f1_before> CASTING TYPE x,
                        <vim_h_mkey>(x_namtab-position)
                          TO <vim_mkey_before> CASTING TYPE x,
                        <vim_h_old_mkey>(x_namtab-position)
                          TO <vim_old_mkey_before> CASTING TYPE x.
              ENDIF.
              ASSIGN: <table1_x>(x_namtab-position)
                       TO <vim_f1_beforex>,
                      <vim_h_mkey>(x_namtab-position)
                        TO <vim_mkey_beforex>,
                      <vim_h_old_mkey>(x_namtab-position)
                        TO <vim_old_mkey_beforex>,
                      <vim_h_coll_bfkey>(x_namtab-position)
                        TO <vim_collapsed_mkey_bfx>.
              CLEAR vim_no_mainkey_exists.
            ELSE.
              ASSIGN: vim_dummy_mainkey TO <vim_mkey_before> TYPE 'C',"#EC *
                      <vim_mkey_before> TO <vim_old_mkey_before>,
                      <vim_mkey_before> TO <vim_f1_before>,
                      vim_dummy_mainkey TO <vim_mkey_beforex> CASTING,
                      <vim_mkey_beforex> TO <vim_old_mkey_beforex>,
                      <vim_mkey_beforex> TO <vim_f1_beforex>,
                      <vim_mkey_beforex> TO <vim_collapsed_mkey_bfx>.
              vim_no_mainkey_exists = 'X'.
            ENDIF.
            MOVE x_namtab-viewfield TO vim_enddate_name-fieldname.
            PERFORM vim_assign_mainkey_after USING sy-tabix.
          ENDIF.
        ENDIF.                         "x_header-delmdtflag eq 'E'
      ELSE.
* end date
        IF x_header-delmdtflag EQ 'E'.
* end date is key field
          CHECK keydate_alr_assigned EQ space.
          keydate_alr_assigned = 'X'.
          IF x_namtab-texttabfld EQ space.
*            ASSIGN: <table1>+x_namtab-position(x_namtab-flength)
*                                   TO <vim_enddate_mask> TYPE 'C'.
            ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE <table1>
             TO <vim_enddate_mask> CASTING TYPE c.
            IF x_namtab-position GT 0.
              IF x_header-generictrp <> 'X'.
** charlike key or non-unicode-system (FS is only assigned for
** downward compatibility).
                length = x_namtab-position
                          DIV cl_abap_char_utilities=>charsize.
                ASSIGN: <table1>(length)
                         TO <vim_f1_before> CASTING TYPE c,
                        vim_mainkey(length)
                          TO <vim_mkey_before> CASTING TYPE c,
                        vim_old_viewkey(length)
                          TO <vim_old_mkey_before> CASTING TYPE c.
              ENDIF.
              IF NOT ( <vim_f1_before> IS ASSIGNED
                       OR <vim_mkey_before> IS ASSIGNED
                       OR <vim_old_mkey_before> IS ASSIGNED ).
** could not be assigned because unicode flag is set in function
** group and key is non charlike
                ASSIGN: <table1_x>(x_namtab-position)
                         TO <vim_f1_before> CASTING TYPE x,
                        vim_mainkey(x_namtab-position)
                          TO <vim_mkey_before> CASTING TYPE x,
                        vim_old_viewkey(x_namtab-position)
                          TO <vim_old_mkey_before> CASTING TYPE x.
              ENDIF.
              ASSIGN: <table1_x>(x_namtab-position)
                       TO <vim_f1_beforex>,
                      <vim_h_mkey>(x_namtab-position)
                        TO <vim_mkey_beforex>,
                      <vim_h_old_mkey>(x_namtab-position)
                        TO <vim_old_mkey_beforex>,
                      <vim_h_coll_bfkey>(x_namtab-position)
                        TO <vim_collapsed_mkey_bfx>.
*              ASSIGN: <table1>(x_namtab-position)
*                                     TO <vim_f1_before> TYPE 'C',
*                      vim_mainkey(x_namtab-position)
*                                     TO <vim_mkey_before> TYPE 'C',
*                      vim_old_viewkey(x_namtab-position)
*                                     TO <vim_old_mkey_before> TYPE 'C'.
              CLEAR vim_no_mainkey_exists.
            ELSE.
              ASSIGN: vim_dummy_mainkey TO <vim_mkey_before> TYPE 'C',"#EC *
                      <vim_mkey_before> TO <vim_old_mkey_before>,
                      <vim_mkey_before> TO <vim_f1_before>,
                      vim_dummy_mainkey TO <vim_mkey_beforex> CASTING,
                      <vim_mkey_beforex> TO <vim_old_mkey_beforex>,
                      <vim_mkey_beforex> TO <vim_f1_beforex>,
                      <vim_mkey_beforex> TO <vim_collapsed_mkey_bfx>.
              vim_no_mainkey_exists = 'X'.
            ENDIF.
            MOVE x_namtab-viewfield TO vim_enddate_name-fieldname.
            PERFORM vim_assign_mainkey_after USING sy-tabix.
          ENDIF.
        ELSE.
* begin date is key field
          IF x_namtab-texttabfld EQ space.
*            ASSIGN: <table1>+x_namtab-position(x_namtab-flength)
*                                   TO <vim_new_begdate> TYPE 'D',
*                    <table1>+x_namtab-position(x_namtab-flength)
*                                   TO <vim_begdate_mask> TYPE 'C'.
            ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE <table1>
             TO <vim_new_begdate>.
            ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE <table1>
             TO <vim_begdate_mask> CASTING TYPE c.
            MOVE: x_namtab-viewfield TO vim_sval_tab-fieldname,
                  x_namtab-viewfield TO vim_begdate_name-fieldname.
            vim_begdate_is_ro = x_namtab-readonly.
          ENDIF.
        ENDIF.                         "x_header-delmdtflag eq 'E'
      ENDIF.
    ENDLOOP.
    APPEND vim_sval_tab.                                    "#EC *
    CONDENSE: vim_begdate_name NO-GAPS, vim_enddate_name NO-GAPS.
    MOVE: x_header-viewname TO vim_memory_id_1-viewname,
          sy-uname          TO vim_memory_id_1-user.
    IMPORT vim_collapsed_mainkeys FROM MEMORY ID vim_memory_id_1."#EC *
    IF sy-subrc NE 0.
      REFRESH vim_collapsed_mainkeys.
    ENDIF.
    ASSIGN: <vim_h_coll_mkey>(x_header-keylen)
                              TO <vim_collapsed_keyx>,
            <vim_h_coll_logkey>(x_header-keylen)
                              TO <vim_collapsed_logkeyx>,
            <vim_h_merged_key>(x_header-keylen)
                              TO <vim_merged_keyx>.
    IF x_header-generictrp <> 'X'.
      ASSIGN: vim_collapsed_mainkeys-mainkey(x_header-keylen)
                                    TO <vim_collapsed_key>,
              vim_collapsed_mainkeys-log_key(x_header-keylen)
                                    TO <vim_collapsed_logkey>,
              vim_merged_entries-merged_key(x_header-keylen)
                                    TO <vim_merged_key>.
    ELSE.
      ASSIGN: <vim_collapsed_keyx> TO <vim_collapsed_key>,
              <vim_collapsed_logkeyx> TO <vim_collapsed_logkey>,
              <vim_merged_keyx> TO <vim_merged_key>.
    ENDIF.
  ENDIF.                               "x_header-delmdtflag ne space
* if necessary. -> how to decide this ? X_HEADER-PTFRKYEXST, later
  ASSIGN vim_mainkey(x_header-keylen) TO <vim_mainkey_mask>.
  CLEAR vim_prtfky_assigned.
* endif.
* consider clusters in transport defaults
  IF vim_called_by_cluster NE space.
    master_type = vim_clus_type.
    master_name = vim_calling_cluster.
  ENDIF.
* set transport defaults.....
  MOVE: transporter   TO e071-pgmid,
        master_type   TO e071-object,
        master_name   TO e071-obj_name,
        e071_objfunc  TO e071-objfunc,
        transporter   TO e071k-pgmid,
        transp_object TO e071k-object,
        space         TO e071k-as4pos,
        master_type   TO e071k-mastertype,
        master_name   TO e071k-mastername,
        space         TO e071k-objfunc,
        space         TO e071k-flag.
  PERFORM vim_get_img_activity
   CHANGING e071k-activity.           "UF738595/2001
  IF x_header-existency EQ space OR x_header-existency EQ 'M'.
    MOVE sortflag_with_existency TO e071k-sortflag.
  ELSE.
    MOVE sortflag_without_existency TO e071k-sortflag.
  ENDIF.
  REFRESH vim_corr_objtab. CLEAR vim_corr_obj_viewname.
  IF x_header-texttbexst <> space.     "SW Texttransl
    PERFORM vim_initialize_texttab.
    vim_texttab_is_ro = 'X'.
    LOOP AT x_namtab WHERE keyflag EQ space
                       AND bastabname EQ x_header-texttab
                       AND readonly NE rdonly.              "#EC *
      CLEAR vim_texttab_is_ro.
      EXIT.
    ENDLOOP.
  ENDIF.
  CLEAR looplines.
* possible to select profiles?
  vim_coming_from_img = 'N'.
  IF vim_called_by_cluster = space.
*    IF x_header-adrnbrflag = space.
*      CALL FUNCTION 'SCPR_MEMORY_FLAG'
*        IMPORTING
*          coming_from_img = vim_coming_from_img.
*    ENDIF.
  ELSE.
    CALL FUNCTION 'VIEWCLUSTER_PR_IMPORT_CTRL'
      EXPORTING
        viewname        = x_header-viewname
        action          = 'P'
      CHANGING
        coming_from_img = vim_coming_from_img
      EXCEPTIONS                                            "#EC *
        wrong_parameter = 1
        OTHERS          = 2.
  ENDIF.
  last_view_info = view_name.
  PERFORM vim_maint_selflag USING    'I'
                            CHANGING x_header-selection.
ENDFORM.                    "initialisieren

*---------------------------------------------------------------------*
*       FORM VIM_INITIALIZE_TEXTTAB                                   *
*---------------------------------------------------------------------*
* Initialisierung vin <VIM_TEXTTAB> und <VIM_READ_LANGUS>
*---------------------------------------------------------------------*
FORM vim_initialize_texttab.
  DATA: idx LIKE sy-tabix,
        texttab_l TYPE i.

  READ TABLE vim_texttab_container WITH KEY viewname = view_name
                                   BINARY SEARCH.           "#EC *
  vim_texttab_container_index = sy-tabix.
  IF sy-subrc <> 0.
    CLEAR vim_texttab_container-tabdata-valid_idx.
    REFRESH vim_texttab_container-tabdata-tab_us.
    REFRESH vim_texttab_container-tabdata-tab_vs.
    REFRESH vim_texttab_container-tabdata-tab_s.
    REFRESH vim_texttab_container-tabdata-tab_m.
    REFRESH vim_texttab_container-tabdata-tab_l.
    REFRESH vim_texttab_container-tabdata-tab_vl.
    REFRESH vim_texttab_container-tabdata-tab_ul.
    REFRESH vim_texttab_container-sel_langus.
    CLEAR vim_texttab_container.

    vim_texttab_container-viewname = view_name.
*   Texttabellenbreite bestimmen
    texttab_l = ( x_header-after_keyc + x_header-aft_txttbc )
                 / cl_abap_char_utilities=>charsize + 1.
*    texttab_l = x_header-keylen + x_header-texttablen + 1.
    IF texttab_l LE ultra_short_tab.
      vim_texttab_container-tabdata-valid_idx = 2.
    ELSEIF texttab_l LE very_short_tab.
      vim_texttab_container-tabdata-valid_idx = 3.
    ELSEIF texttab_l LE short_tab.
      vim_texttab_container-tabdata-valid_idx = 4.
    ELSEIF texttab_l LE middle_tab.
      vim_texttab_container-tabdata-valid_idx = 5.
    ELSEIF texttab_l LE long_tab.
      vim_texttab_container-tabdata-valid_idx = 6.
    ELSEIF texttab_l LE very_long_tab.
      vim_texttab_container-tabdata-valid_idx = 7.
    ELSEIF texttab_l LE ultra_long_tab.
      vim_texttab_container-tabdata-valid_idx = 8.
    ENDIF.
    INSERT vim_texttab_container INDEX vim_texttab_container_index."#EC *
  ENDIF.
  idx = vim_texttab_container-tabdata-valid_idx.
  ASSIGN COMPONENT idx OF STRUCTURE
         vim_texttab_container-tabdata TO <vim_texttab>.
  ASSIGN vim_texttab_container-sel_langus TO <vim_read_langus>.
ENDFORM.                               "VIM_INITIALIZE_TEXTTAB
*&---------------------------------------------------------------------*
*&      Form  vim_fill_vim_guid_domain
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM vim_fill_vim_guid_domain.
  MOVE: 'I'   TO vim_guid_domain-sign,
        'EQ'  TO vim_guid_domain-option.
  MOVE 'SYSUUID' TO vim_guid_domain-low. APPEND vim_guid_domain."#EC *
  MOVE 'SYSUUID_C' TO vim_guid_domain-low. APPEND vim_guid_domain."#EC *
  MOVE 'SYSUUID_22' TO vim_guid_domain-low. APPEND vim_guid_domain."#EC *
  MOVE 'SYSUUID_25' TO vim_guid_domain-low. APPEND vim_guid_domain."#EC *
ENDFORM.                    " vim_fill_vim_guid_domain
*&---------------------------------------------------------------------*
*&      Form  vim_set_init_from_sellist
*&---------------------------------------------------------------------*
*       If sellist defines values unambiguously, set them into initial
*       WA.
*----------------------------------------------------------------------*
*      -->P_TABNAME   tabname
*      -->P_NAMTAB[]  nametab info
*      -->P_SELLIST   selection
*      <--P_INIT      initial view-wa
*----------------------------------------------------------------------*
FORM vim_set_init_from_sellist USING    p_tabname TYPE tabname
                                        p_namtab LIKE x_namtab[]
                                        p_sellist LIKE dba_sellist[]
                                        p_maintdesc TYPE vfldroflag
                               CHANGING p_init TYPE any.

  DATA: count TYPE i, h_ix TYPE i, rcode TYPE xfeld,                     "#EC NEEDED
        tabfld TYPE tabfield.
  FIELD-SYMBOLS: <namtab> TYPE vimnamtab, <sel_wa> TYPE vimsellist,
                 <value> TYPE ANY.

  LOOP AT p_namtab ASSIGNING <namtab> WHERE readonly = p_maintdesc.
    CLEAR: rcode, count, h_ix.
    LOOP AT p_sellist ASSIGNING <sel_wa>
     WHERE viewfield EQ <namtab>-viewfield
           AND ( negation EQ space AND operator EQ 'EQ' OR
                 negation EQ 'NOT' AND operator EQ 'NE' )
           AND ( ddic      CO 'XB' OR
                 ddic      CO 'SB' ).
      ADD 1 TO count.
      CHECK <sel_wa>-and_or EQ space OR <sel_wa>-and_or EQ 'AND'.
      rcode = 'X'. h_ix = sy-tabix.
    ENDLOOP.
    IF rcode = space OR count > 1.
      CLEAR: rcode, count.
      LOOP AT p_sellist ASSIGNING <sel_wa>
       WHERE viewfield EQ <namtab>-viewfield
        AND ( negation EQ space AND operator EQ 'EQ' OR
                   negation EQ 'NOT' AND operator EQ 'NE' )
             AND ( ddic EQ 'A' ).
        ADD 1 TO count.
        CHECK <sel_wa>-and_or EQ space OR <sel_wa>-and_or EQ 'AND'.
        rcode = 'X'. h_ix = sy-tabix.
      ENDLOOP.
    ENDIF.
    IF rcode <> space AND count = 1.
      ASSIGN COMPONENT <namtab>-viewfield OF STRUCTURE p_init TO <value>.
      CHECK sy-subrc = 0.
      tabfld-tabname = p_tabname.
      tabfld-fieldname = tabfld-lfieldname = <namtab>-viewfield.
      CALL FUNCTION 'RS_CONV_EX_2_IN'
        EXPORTING
          input_external  = <sel_wa>-value
          table_field     = tabfld
        IMPORTING
          output_internal = <value>
        EXCEPTIONS
          OTHERS          = 1.
      IF sy-subrc <> 0.
        CLEAR <value>.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " vim_set_init_from_sellist
*&---------------------------------------------------------------------*
*&      Form  vim_fill_date_type
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM vim_fill_date_type.

  MOVE: 'I'   TO vim_begda_types-sign,
        'EQ'  TO vim_begda_types-option.
  MOVE vim_begdate_dtel1 TO vim_begda_types-low. APPEND vim_begda_types."#EC *
  MOVE vim_begdate_dtel2 TO vim_begda_types-low. APPEND vim_begda_types."#EC *
  MOVE vim_begdate_dtel3 TO vim_begda_types-low. APPEND vim_begda_types."#EC *
  MOVE vim_begdate_dtel4 TO vim_begda_types-low. APPEND vim_begda_types."#EC *
  MOVE vim_enddate_dtel1 TO vim_begda_types-low.
  APPEND vim_begda_types TO vim_endda_types.
  MOVE vim_enddate_dtel2 TO vim_begda_types-low.
  APPEND vim_begda_types TO vim_endda_types.
  MOVE vim_enddate_dtel3 TO vim_begda_types-low.
  APPEND vim_begda_types TO vim_endda_types.
  MOVE vim_enddate_dtel4 TO vim_begda_types-low.
  APPEND vim_begda_types TO vim_endda_types.
ENDFORM.                    " vim_fill_date_type
