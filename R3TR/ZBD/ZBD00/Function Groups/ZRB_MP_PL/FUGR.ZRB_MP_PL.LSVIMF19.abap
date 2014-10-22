*&--------------------------------------------------------------------*
*&      Form  VIM_MODIFY_VIEW_ENTRY                                   *
*&--------------------------------------------------------------------*
* update/insert entry, process all checks                             *
*&--------------------------------------------------------------------*
FORM vim_modify_view_entry USING value(vmve_exix) TYPE i
                                 vmve_rc TYPE i.
  DATA: h_ix TYPE i, h_act(1) TYPE c, hact2(1) TYPE c,                 "#EC NEEDED
        fieldname TYPE fnam_____4.
  FIELD-SYMBOLS: <guid> TYPE ANY, <old_guid> TYPE ANY,
                 <guid_wa> TYPE ANY,
                 <extract_val> TYPE ANY, <total_val> TYPE ANY.
  CLEAR vmve_rc.
  nextline = exind = vmve_exix.
* new: transfer of changed entries from EXTRACT into TOTAL via dynps
* ... first: handle read-only fields and subset fields
  IF x_header-subsetflag NE space OR
     x_header-rdonlyflag NE space OR
     x_header-adrnbrflag NE space.
    IF <xact> NE neuer_eintrag.
      READ TABLE total WITH KEY <vim_xextract_key>          "#EC *
                       BINARY SEARCH.
      h_act = <action>.
    ELSE.
      h_act = <xact>.
    ENDIF.
    LOOP AT x_namtab WHERE readonly EQ rdonly
                       OR  ( readonly EQ subset AND
                             keyflag EQ space ).
      ASSIGN COMPONENT x_namtab-viewfield
       OF STRUCTURE <vim_extract_struc> TO <extract_val>.
      CHECK sy-subrc = 0.
      IF <xact> NE neuer_eintrag.
        ASSIGN COMPONENT x_namtab-viewfield
         OF STRUCTURE <vim_total_struc> TO <total_val>.
        IF sy-subrc = 0.
          <extract_val> = <total_val>.
        ENDIF.
*        extract+x_namtab-position(x_namtab-flength) =
*            total+x_namtab-position(x_namtab-flength).
      ELSE.
        ASSIGN COMPONENT x_namtab-viewfield
         OF STRUCTURE <initial> TO <total_val>.
        IF sy-subrc = 0.
          <extract_val> = <total_val>.
        ENDIF.
*        extract+x_namtab-position(x_namtab-flength) =
*            <initial>+x_namtab-position(x_namtab-flength).
      ENDIF.
    ENDLOOP.
    IF sy-subrc EQ 0.
      hact2 = <xact>. <xact> = h_act.
      MODIFY extract INDEX vmve_exix.
      <xact> = hact2.
    ENDIF.
  ENDIF.
  PERFORM move_extract_to_view_wa.
* ... second: handle address number and GUID
  CLEAR vim_upgr_address_number.
  IF x_header-adrnbrflag NE space.
    IF x_header-adrnbrflag = 'N'.
      vim_upgr_address_number = <address_number>.
    ENDIF.
    IF <xact> NE neuer_eintrag.
      <address_number> = <vim_total_address_number>.
    ELSE.
      CLEAR <address_number>.
    ENDIF.
  ENDIF.
  IF x_header-guidflag <> space AND <xact> <> neuer_eintrag.
* update only, GUID will be set in UPDATE_TAB for new entries
    LOOP AT x_namtab WHERE domname IN vim_guid_domain.
      CONCATENATE x_header-maintview x_namtab-viewfield
       INTO fieldname SEPARATED BY '-'.
      ASSIGN COMPONENT x_namtab-viewfield
       OF STRUCTURE <vim_extract_struc> TO <guid>.
      ASSIGN COMPONENT x_namtab-viewfield
       OF STRUCTURE <vim_total_struc> TO <old_guid>.
*      ASSIGN extract+x_namtab-position(x_namtab-flength) TO <guid>
*       CASTING TYPE (fieldname).
*      ASSIGN total+x_namtab-position(x_namtab-flength) TO <old_guid>
*       CASTING TYPE (fieldname).
      IF <guid> IS INITIAL AND <old_guid> IS INITIAL.
* no GUID-value imported from remote system and GUID not yet set in
* current entry
        PERFORM vim_make_guid USING x_namtab-viewfield.
        ASSIGN (fieldname) TO <guid_wa> CASTING TYPE (fieldname).
        <guid> = <guid_wa>.
* (including event 27)
      ELSEIF <guid> IS INITIAL.
* use old GUID
        <guid> = <old_guid>.
        IF x_header-frm_af_uid <> space.
          PERFORM (x_header-frm_af_uid) IN PROGRAM (x_header-fpoolname)
                                    USING <old_guid>
                                    CHANGING <guid>
                                             <vim_extract_struc>.
* Condition always FALSE - Internal Message 0001699060 - ACHACHADI
*        ELSEIF x_header-frm_af_uid <> space.                        "#EC BOOL_OK
** overwrite old GUID with GUID from remote client... or not?
*          PERFORM (x_header-frm_af_uid) IN PROGRAM (x_header-fpoolname)
*                                    USING <old_guid>
*                                    CHANGING <guid>
*                                             <vim_extract_struc>.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
  IF <xact> EQ neuer_eintrag.
    status-action = hinzufuegen.
    <vim_extract_struc> = <initial>.
    IF x_header-bastab NE space AND
       x_header-texttbexst NE space.
      <vim_xextract_text> = <text_initial_x>.
    ENDIF.
    <xact> = leer.
  ELSE.
    status-action = aendern. <xact> = h_act.
  ENDIF.
  MODIFY extract INDEX vmve_exix.
* ...third: call screen a la replace
  CASE status-type.
    WHEN einstufig.
      PERFORM vim_imp_call_screen USING liste.
    WHEN zweistufig.
      IF <xact> EQ leer.
        neuer = 'J'.
      ENDIF.
      PERFORM process_detail_screen USING 'C'.
  ENDCASE.
  status-action = <status>-st_action = aendern.
  IF ok_code EQ 'IGN '. vmve_rc = 4. CLEAR ok_code. EXIT. ENDIF.
  IF function EQ 'ABR '. vmve_rc = 8. CLEAR function. EXIT. ENDIF.
ENDFORM.                               "vim_modify_view_entry
