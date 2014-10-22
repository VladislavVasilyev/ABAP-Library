*----------------------------------------------------------------------*
*   INCLUDE LSVIMFXP  form routines to activate profiles               *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_PROFILES
*&---------------------------------------------------------------------*
*  NOT IN USE ANYMOREW BUT STILL CALLED IN APPLICATION FUNCTION GROUPS
*       Get customizing profiles using Function
*       SCPR_SHOW_CUT_OF_VIEW
*----------------------------------------------------------------------*
*  <--  p_selected  Flag X: Profil wurde bereits ausgewählt und
*                           importiert ==> nur anzeigen
*----------------------------------------------------------------------*
FORM get_profiles USING p_selected TYPE c.             "#EC NEEDED

*  DATA: cobj_type VALUE 'V'.           "customizing-objecttype
*
*  IF x_header-bastab NE space.               "HCG FuBa gelöscht zu 700
*    cobj_type = vim_tabl.
*  ENDIF.
*  CLEAR vim_pr_activating.
*  CALL FUNCTION 'SCPR_SHOW_OUT_OF_VIEW'
*    EXPORTING
*      tabname            = x_header-viewname
*      tabtype            = cobj_type
*      preselection       = p_selected
*      cluster            = vim_called_by_cluster
*    TABLES
*      header             = x_header
*      namtab             = x_namtab
*      sellist            = <vim_ck_sellist>
*    EXCEPTIONS
*      user_abort         = 1
*      no_profile_found   = 2
*      profile_dont_exist = 3
*      no_data            = 4
*      OTHERS             = 5.
*  CASE sy-subrc.
*    WHEN 2.
*      MESSAGE s820(sv).
**   Kein Profil gefunden.
*    WHEN 3.
*      IF cobj_type = 'S'.
*        MESSAGE s822(sv) WITH x_header-viewname.
**   Zur Tabelle & existiert kein Profil.
*      ELSE.
*        MESSAGE s821(sv) WITH x_header-viewname.
**   Zur View & existiert kein Profil.
*      ENDIF.
*  ENDCASE.
ENDFORM.                               " GET_PROFILES
*&---------------------------------------------------------------------*
*&      Form  IMPORT_PROFILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*----------------------------------------------------------------------*
FORM import_profile USING actopts TYPE scpractopt.

  DATA:          ext_field(1000),                          "#EC NEEDED
                 pr_field(1000),                               "#EC NEEDED
                 next,                                     "#EC NEEDED
                 i TYPE i VALUE 1,
                 extr_lin TYPE i,
                 len_text TYPE i, profile_used,                   "#EC *
                 imported_to_all VALUE 'X'.                        "#EC NEEDED
  FIELD-SYMBOLS: <pr_field>, <bc_total_key>,                "#EC *
                 <bc_total>, <bc_total_action>, <bc_total_mark>,"#EC *
                 <w_record> TYPE vim_pr_tab_type.

  len_text = x_header-texttablen - x_header-textkeylen.
  CASE status-action.
    WHEN aendern.
* import in update mode
      IF status-mode = list_bild.
* import in list screen
        LOOP AT vim_pr_tab ASSIGNING <w_record>.
          IF <w_record>-action = aendern.
* update existing entry
            LOOP AT extract.
              CHECK <w_record>-keys = <vim_xextract_key>.
              PERFORM bcset_force_into_entry USING    <w_record>
                                                      aendern actopts.
              MODIFY extract.
              EXIT.
            ENDLOOP.
          ELSE.
* new entry
            MOVE <initial_x> TO <vim_xextract>.
            <vim_xextract_key> = <w_record>-keys.
            PERFORM bcset_force_into_entry USING    <w_record>
                                                  neuer_eintrag actopts.
            APPEND extract.
            ADD 1 TO maxlines.
          ENDIF.
        ENDLOOP.
        SORT extract BY <vim_xextract_key>.
      ELSE.
* import in detail mode
        LOOP AT vim_pr_tab ASSIGNING <w_record> WHERE
         action = neuer_eintrag.
          MOVE <initial_x> TO <vim_xextract>.
          <vim_xextract_key> = <w_record>-keys.
          PERFORM bcset_force_into_entry USING    <w_record>
                                               neuer_eintrag actopts.
          APPEND extract.
          ADD 1 TO maxlines.
        ENDLOOP.
* update existing entries
        LOOP AT vim_pr_tab ASSIGNING <w_record> WHERE action = aendern.
          CLEAR profile_used.
          LOOP AT extract.
            CHECK <w_record>-keys = <vim_xextract_key>.
            PERFORM bcset_force_into_entry USING    <w_record>
                                                    aendern actopts.
            MODIFY extract.
            profile_used = 'X'.
            EXIT.
          ENDLOOP.
          IF profile_used = space.
            LOOP AT total INTO extract.
              CHECK <w_record>-keys = <vim_xextract_key>.
              PERFORM bcset_force_into_entry USING    <w_record>
                                                      aendern actopts.
              APPEND extract.
              ADD 1 TO maxlines.
              EXIT.
            ENDLOOP.
          ENDIF.
        ENDLOOP.
        SORT extract BY <vim_xextract_key>.
      ENDIF.
    WHEN hinzufuegen.
* import from append status
      IF status-mode = list_bild.
* import in list mode
        DESCRIBE TABLE extract LINES extr_lin.
        LOOP AT vim_pr_tab ASSIGNING <w_record> WHERE
         action = neuer_eintrag.
          IF extr_lin LE i.
* add blank line to extract
            CLEAR extract. MOVE leer TO <xact>.
            APPEND extract.
          ENDIF.
* new entry
          LOOP AT extract FROM i.
            CHECK <xact> = leer.
            i = sy-tabix + 1.
            ADD 1 TO maxlines.
            <vim_xextract_key> = <w_record>-keys.
            PERFORM bcset_force_into_entry USING    <w_record>
                                                 neuer_eintrag actopts.
            MODIFY extract.
            EXIT.
          ENDLOOP.
        ENDLOOP.
      ELSE.
* import in detail mode
        MOVE <initial_x> TO <vim_xextract>.
        LOOP AT vim_pr_tab ASSIGNING <w_record> WHERE
         action = neuer_eintrag.
          <vim_xextract_key> = <w_record>-keys.
          PERFORM bcset_force_into_entry USING    <w_record>
                                               neuer_eintrag actopts.
          APPEND extract.
          ADD 1 TO maxlines.
        ENDLOOP.
      ENDIF.
* update existing entries
      LOOP AT vim_pr_tab ASSIGNING <w_record> WHERE action = aendern.
        LOOP AT total INTO extract.
          CHECK <w_record>-keys = <vim_xextract_key>.
          PERFORM bcset_force_into_entry USING    <w_record>
                                                  aendern actopts.
          APPEND extract.
          EXIT.
        ENDLOOP.
      ENDLOOP.
      SORT extract BY <vim_xextract_key>.
  ENDCASE.
ENDFORM.                               " IMPORT_PROFILE
*&---------------------------------------------------------------------*
*&      Form  GET_PROFILE_STATUS
*&---------------------------------------------------------------------*
*       Checks key fields of the profile whether they're fixed or not
*       and concatenates profile keys into the lines of vim_pr_tab
*       according to their nametab-position.
*       Table & Texttable: Fills textfield value and initial text key
*       into VIM_PR_TAB.
*----------------------------------------------------------------------*
*  <--  VIM_PR_TAB     contains for every record key status, key values
*                      and textfields
*  <--  VIM_PR_FIELDS  Contains all profile fields filled with
*                      values. Used to set the request-flag in PBO.
*----------------------------------------------------------------------*
FORM get_profile_status CHANGING vim_pr_tab LIKE vim_pr_tab
                                 vim_pr_fields LIKE vim_pr_fields[].

  DATA:          w_profile TYPE scpr_vals,
                 w_vim_pr_tab TYPE vim_pr_tab_type,
                 w_vim_pr_fields TYPE vim_pr_fields_type,
                 recnumber LIKE scprvals-recnumber,
                 text(1000), value LIKE vimsellist-value,   "#EC NEEDED
                 gottext, first, rc LIKE sy-subrc,           "#EC NEEDED
                 fieldname TYPE fnam_____4.
  FIELD-SYMBOLS: <pr_key>,                                  "#EC *
                 <x_keys> TYPE x, <x_text> TYPE x,
                 <bc_val> TYPE ANY, <imp_val> TYPE ANY,
                 <keys_struc> TYPE ANY, <text_struc> TYPE ANY.

  ASSIGN: w_vim_pr_tab-keys TO <x_keys> CASTING,
          <x_keys> TO <keys_struc> CASTING TYPE (x_header-maintview).
  IF x_header-bastab <> space AND x_header-texttbexst <> space.
    ASSIGN: w_vim_pr_tab-textrecord TO <x_text> CASTING,
            <x_text> TO <text_struc> CASTING TYPE (x_header-texttab).
  ENDIF.
  RANGES dont_use FOR scprvals-recnumber.
  dont_use-sign = 'E'. dont_use-option = 'EQ'.

  LOOP AT vim_pr_tab INTO w_vim_pr_tab.
    READ TABLE vim_pr_fields INTO w_vim_pr_fields WITH KEY
     recnumber = w_vim_pr_tab-recnumber.
    <x_keys> = <initial_x>(x_header-keylen).
*    w_vim_pr_tab-keys = <initial>(x_header-keylen).
    IF x_header-bastab <> space AND x_header-texttbexst <> space.
      <x_text> = <initial_textkey_x>.
*      w_vim_pr_tab-textrecord = <initial_textkey>.
    ENDIF.
* Fill key fields
    LOOP AT x_namtab WHERE keyflag = 'X' AND texttabfld IS INITIAL.
      IF x_namtab-datatype = 'CLNT' AND x_header-clidep <> space.
*        MOVE sy-mandt TO
*             w_vim_pr_tab-keys+x_namtab-position(x_namtab-flength).
        DELETE TABLE w_vim_pr_fields-fields WITH TABLE KEY
         fieldname = x_namtab-viewfield.
        MODIFY TABLE vim_pr_fields FROM w_vim_pr_fields.
*        IF x_header-bastab <> space AND x_header-texttbexst <> space.
*          MOVE sy-mandt TO
*         w_vim_pr_tab-textrecord+x_namtab-texttabpos(x_namtab-flength).
*        ENDIF.
      ELSE.
        CLEAR w_profile.
        READ TABLE vim_profile_values INTO w_profile WITH KEY
                   tablename = x_header-viewname
                   fieldname = x_namtab-viewfield
                   recnumber = w_vim_pr_tab-recnumber.
        IF w_profile-flag = vim_profile_fixkey.
          CASE w_vim_pr_tab-keys_fix.
            WHEN space.
              w_vim_pr_tab-keys_fix = vim_pr_all_fix.
            WHEN vim_pr_open.
              w_vim_pr_tab-keys_fix = vim_pr_some_fix.
          ENDCASE.
        ELSE.
          CASE w_vim_pr_tab-keys_fix.
            WHEN space.
              w_vim_pr_tab-keys_fix = vim_pr_open.
            WHEN vim_pr_all_fix.
              w_vim_pr_tab-keys_fix = vim_pr_some_fix.
          ENDCASE.
        ENDIF.
        IF x_namtab-readonly <> subset."subsetf. already in <initial>
* use profile keyfield
          CONCATENATE x_header-maintview x_namtab-viewfield
           INTO fieldname SEPARATED BY '-'.
          ASSIGN: w_profile-value TO <bc_val> CASTING TYPE (fieldname),
                      COMPONENT x_namtab-viewfield
                       OF STRUCTURE <keys_struc> TO <imp_val>.
          <imp_val> = <bc_val>.
*          MOVE w_profile-value(x_namtab-flength) TO
*          w_vim_pr_tab-keys+x_namtab-position(x_namtab-flength).
          IF x_header-bastab <> space AND x_header-texttbexst <> space.
* make text table key (for finding the suitable text value only)
            ASSIGN COMPONENT x_namtab-txttabfldn
                   OF STRUCTURE <text_struc> TO <imp_val>.
            <imp_val> = <bc_val>.
*            MOVE w_profile-value(x_namtab-flength) TO
*         w_vim_pr_tab-textrecord+x_namtab-texttabpos(x_namtab-flength).
          ENDIF.
        ENDIF.                         "x_namtab-readonly <> subset
        w_vim_pr_fields-keys_fix = w_vim_pr_tab-keys_fix.
        MODIFY vim_pr_fields FROM w_vim_pr_fields TRANSPORTING keys_fix
                 WHERE recnumber = w_vim_pr_fields-recnumber.
      ENDIF.                           "x_namtab-datatype = 'CLNT'
    ENDLOOP.
    IF x_header-bastab <> space AND x_header-texttbexst <> space AND
       w_vim_pr_tab-keys_fix <> vim_pr_error.
* get record for text table
      CLEAR recnumber.
      IF vim_pr_records > 1.
        WHILE gottext = space.
          gottext = 'X'.
          first = 'X'.
          LOOP AT vim_profile_values INTO w_profile WHERE
                          tablename = x_header-texttab
                          AND recnumber IN dont_use[].
            IF first = 'X'.
              recnumber = w_profile-recnumber.
              CLEAR first.
            ELSE.
              IF recnumber <> w_profile-recnumber.
                IF gottext <> space. EXIT. ENDIF.
                recnumber = w_profile-recnumber.
              ENDIF.
            ENDIF.
            IF w_profile-flag+2 = 'Y'. "keY, ukY or fkY -> Key fields!
* check key-value
              IF w_profile-fieldname = x_header-sprasfield.
                IF w_profile-value(1) <> sy-langu.
                  dont_use-low = recnumber.
                  APPEND dont_use.
                  CLEAR: text, gottext.
                  CONTINUE.
                ENDIF.
              ELSE.
                READ TABLE x_namtab WITH KEY
                                    viewfield = w_profile-fieldname
                                    keyflag = 'X' texttabfld = 'X'.
                CONCATENATE x_header-texttab x_namtab-txttabfldn
                         INTO fieldname SEPARATED BY '-'.
                ASSIGN: w_profile-value TO <bc_val>
                         CASTING TYPE (fieldname),
                        COMPONENT x_namtab-txttabfldn
                         OF STRUCTURE <text_struc> TO <imp_val>.
*                ASSIGN w_profile-value(x_namtab-flength) TO <vgl1>.
*   ASSIGN w_vim_pr_tab-textrecord+x_namtab-texttabpos(x_namtab-flength)
*                                                          TO <vgl2>.
*                IF <vgl1> <> <vgl2>.
                IF <imp_val> <> <bc_val>.
                  CLEAR gottext.
                  dont_use-low = recnumber.
                  APPEND dont_use.
*                    CLEAR text.
                  CONTINUE.
                ENDIF.
              ENDIF.
*              ELSE.
** store textfield.
*                text = w_profile-value.
*                APPEND w_profile-fieldname TO w_vim_pr_fields-fields.
            ENDIF.                                          "key field
          ENDLOOP.
        ENDWHILE.
        IF gottext <> space.
          recnumber = w_profile-recnumber.
        ENDIF.
*          IF NOT text IS INITIAL.
*            READ TABLE x_namtab WITH KEY keyflag = space
*                                         texttabfld = 'X'.
*            MOVE text TO
*         w_vim_pr_tab-textrecord+x_namtab-texttabpos(x_namtab-flength).
*            CLEAR: text, gottext.
*          ENDIF.
      ELSEIF vim_pr_records = 1.
* insert language into text table key
*           READ TABLE x_namtab WITH KEY viewfield = x_header-sprasfield
*                                        keyflag = 'X' texttabfld = 'X'.
        ASSIGN COMPONENT x_header-sprasfield
                      OF STRUCTURE <text_struc> TO <imp_val>.
        <imp_val> = sy-langu.
*            MOVE sy-langu TO
*         w_vim_pr_tab-textrecord+x_namtab-texttabpos(x_namtab-flength).
        READ TABLE vim_profile_values INTO w_profile WITH KEY
                   tablename = x_header-texttab
                   fieldname = x_header-sprasfield
                   value = sy-langu.
        IF sy-subrc = 0.
* textfield value found
          recnumber = w_profile-recnumber.
        ENDIF.
      ENDIF.                                                "lines = 1
      IF NOT recnumber IS INITIAL.
*textvalue in bc-set found
        LOOP AT x_namtab WHERE keyflag = space AND
                                     texttabfld = 'X'.
          CONCATENATE x_header-texttab x_namtab-viewfield
                   INTO fieldname SEPARATED BY '-'.
          READ TABLE vim_profile_values INTO w_profile WITH KEY
                           tablename = x_header-texttab
                           recnumber = recnumber
                           fieldname = x_namtab-viewfield.
          ASSIGN: w_profile-value TO <bc_val>
                   CASTING TYPE (fieldname),
                  COMPONENT x_namtab-viewfield
                   OF STRUCTURE <text_struc> TO <imp_val>.
          <imp_val> = <bc_val>.
*                MOVE w_profile-value
*      TO w_vim_pr_tab-textrecord+x_namtab-texttabpos(x_namtab-flength).
          APPEND w_profile-fieldname TO w_vim_pr_fields-fields.
        ENDLOOP.
      ELSE.
* no text value in bc-set
        MOVE <text_initial_x> TO <x_text>.
      ENDIF.
    ENDIF.                             "text table exists
    MODIFY vim_pr_tab FROM w_vim_pr_tab.
    MODIFY TABLE vim_pr_fields FROM w_vim_pr_fields.
  ENDLOOP.
ENDFORM.                    "get_profile_status
*&---------------------------------------------------------------------*
*&      Form  ACTIVATE_PROFILE
*&---------------------------------------------------------------------*
*     No longer in use: For 6.20 the funcionality of BC set activation
*     via SM30 was abolished
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM activate_profile CHANGING p_selected
TYPE c.

  DATA: pr_rc TYPE i, pr_funcsafe(4), pr_counter TYPE i,    "#EC *
        pr_mark_entries VALUE 'X', hf1  TYPE i, hf  TYPE i,  "#EC NEEDED
        cobj_type VALUE 'V', pr_key_da, pr_recnumber TYPE scpr_recnr,"#EC *
        bc_id TYPE scpr_id, bc_rec_found(1) TYPE c,
        actopts TYPE scpractopt."HCG always empty, only nec. 46C 610
  STATICS: viewname LIKE vimdesc-viewname.
  FIELD-SYMBOLS: <pr_f1> TYPE x, <w_record> TYPE vim_pr_tab_type,
                 <bc_key> TYPE x.

  CHECK status-action NE anzeigen AND  "ignore wrong setted requestflags
        status-action NE transportieren. "due to individual F4 modules
  CLEAR vim_pr_activating.
  IF p_selected IS INITIAL.
* read profile
    REFRESH: vim_profile_values, vim_pr_tab.
*    CALL FUNCTION 'SCPR_ACTIVATE'     // Ast stillgelegt, der Baustein
*                                      // existiert nicht mehr
*        EXPORTING
*             tabname          = x_header-viewname
*             initial          = <initial>
*       IMPORTING
*            PROFID           =
*        TABLES
*             values           = vim_profile_values
*             sellist          = dpl_sellist
*        EXCEPTIONS
*             user_abort       = 1
*             no_profile_found = 2
*             OTHERS           = 3.
*    CASE sy-subrc.
*      WHEN 0.
*        p_selected = 'X'. viewname = x_header-viewname.
*        SORT vim_profile_values BY id version tablename recnumber.
*        IF 'AU' CA status-action.
* get records the profile contains
*          PERFORM get_pr_nbr_records USING vim_profile_values
*                                           x_header
*                                     CHANGING pr_rc
*                                              bc_id
*                                              vim_pr_records
*                                              vim_pr_tab
*                                              vim_pr_fields.
* check key-status
*          PERFORM get_profile_status CHANGING vim_pr_tab
*                                              vim_pr_fields.
*        ENDIF.
*      WHEN 1.
*        EXIT.
*      WHEN 2.
*        IF x_header-bastab NE space.
*          cobj_type = vim_tabl.
*        ENDIF.
*        IF cobj_type = 'S'.
*          MESSAGE e822(sv) WITH x_header-viewname.
*   Zur Tabelle & existiert kein Profil.
*        ELSE.
*          MESSAGE e821(sv) WITH x_header-viewname.
*   Zur View & existiert kein Profil.
*        ENDIF.
*    ENDCASE.
  ELSE.
    IF vim_called_by_cluster <> space AND
     viewname <> x_header-viewname.
* update key values according to current view and selection
      viewname = x_header-viewname.
      IF 'AU' CA status-action.
* get records the profile contains
        PERFORM get_pr_nbr_records USING vim_profile_values
                                         x_header
                                   CHANGING pr_rc
                                            bc_id
                                            vim_pr_records
                                            vim_pr_tab
                                            vim_pr_fields.
* check key-status
        PERFORM get_profile_status CHANGING vim_pr_tab
                                            vim_pr_fields.
      ENDIF.
    ENDIF.
  ENDIF.
* check, if bc-set-records refer to existing datasets
  PERFORM bcset_key_check_in_total.
  PERFORM markiere_alle USING nicht_markiert.
  PERFORM import_profile USING actopts.
* viewcluster: show list of views to work on
  IF vim_called_by_cluster <> space.
    CALL FUNCTION 'VIEWCLUSTER_PR_IMPORT_CTRL'
      EXPORTING
        viewname        = x_header-viewname
        action          = 'M'
      TABLES
        profile_values  = vim_profile_values
      EXCEPTIONS                                           "#EC *
        wrong_parameter = 1
        OTHERS          = 2.
  ENDIF.
  replace_mode = 'X'.
  vim_special_mode = vim_upgrade.
* handle changed entries
  ASSIGN <vim_xtotal>(x_header-tablen) TO <pr_f1> CASTING.
  LOOP AT extract.
    CHECK <xact> = aendern OR <xact> = neuer_eintrag.
    CLEAR vim_bc_entry_list_wa.
    vim_bc_entry_list_wa-id = bc_id.
    vim_bc_entry_list_wa-viewname = x_header-viewname.
    hf = sy-tabix.
    READ TABLE total WITH KEY <vim_xextract_key> BINARY SEARCH."#EC *
    IF sy-subrc EQ 0.                  "entry exists in current client
      hf1 = sy-tabix.
      IF <xact> EQ neuer_eintrag AND
      <action> EQ geloescht OR <action> EQ neuer_geloescht OR
      <action> EQ update_geloescht.
        status-delete = geloescht.
* entry deleted in cur clnt -> first undelete it
        <xact> = <action>.
        MODIFY extract.
        pr_funcsafe = function.
        CLEAR pr_rc.
        PERFORM vim_mark_and_process USING hf 'UNDO' hf1
                                           pr_rc.
        CLEAR status-delete. function = pr_funcsafe.
        CHECK pr_rc NE 4.
        IF pr_rc EQ 8.
          EXIT.
        ENDIF.
        READ TABLE extract INDEX hf.
        READ TABLE total WITH KEY <vim_xextract_key> BINARY SEARCH."#EC *
        hf1 = sy-tabix.
        <xact> = aendern. MODIFY extract.
      ENDIF.
      IF <vim_xtotal_key> = <vim_xextract_key>.
* record already exists: do not import but save
        <action> = aendern.
        MODIFY total INDEX hf1.
        IF x_header-bastab NE space AND x_header-texttbexst NE space.
          TRANSLATE <status>-upd_flag USING ' ETX'.
        ELSE.
          <status>-upd_flag = 'X'.
        ENDIF.
      ENDIF.
    ENDIF.                             "sy-subrc eq 0.
    CLEAR vim_pr_fields_wa.
    CLEAR bc_rec_found.
    LOOP AT vim_pr_tab ASSIGNING <w_record>.
      ASSIGN <w_record>-keys(x_header-keylen) TO <bc_key>.
      CHECK <bc_key> = <vim_xextract_key>.
      bc_rec_found = 'X'.
      READ TABLE vim_pr_fields INTO vim_pr_fields_wa WITH KEY
       recnumber = <w_record>-recnumber.
      vim_bc_entry_list_wa-id = bc_id.
      vim_bc_entry_list_wa-recnumber = <w_record>-recnumber.
      vim_bc_entry_list_wa-keys = <bc_key>.
*      if x_header-bastab <> space and x_header-texttbexst <> space.
** table with text table
*        vim_bc_entry_list_wa-keys + x_header-keylen =
*         <w_record>-textrecord(x_header-textkeylen).
*      endif.
      vim_bc_entry_list_wa-action = neuer_eintrag.
      INSERT LINES OF vim_pr_fields_wa-fields INTO TABLE
       vim_bc_entry_list_wa-fields.
      EXIT.
    ENDLOOP.
    CHECK NOT bc_rec_found IS INITIAL.
    IF <xact> <> aendern OR <pr_f1> <> <table2_x>.
* import bc-set record
      CHECK NOT vim_pr_fields_wa IS INITIAL.
      <status>-prof_found = vim_pr_into_view.
      PERFORM vim_modify_view_entry USING hf pr_rc.
      <status>-prof_found = vim_profile_found.
      CHECK pr_rc NE 4.
      IF pr_rc EQ 8.
        EXIT.
      ENDIF.
    ENDIF.
    READ TABLE total WITH KEY <vim_xtotal_key> BINARY SEARCH "#EC *
                     TRANSPORTING NO FIELDS.
    IF <mark> EQ nicht_markiert.
      <mark> = markiert. ADD 1 TO mark_total.
      MODIFY total INDEX sy-tabix.
    ENDIF.
    extract = total.
    MODIFY extract.
    INSERT vim_bc_entry_list_wa INTO TABLE vim_bc_entry_list.
    IF sy-subrc = 4.
      MODIFY TABLE vim_bc_entry_list FROM vim_bc_entry_list_wa.
    ENDIF.
    ADD 1 TO pr_counter.
  ENDLOOP.
  IF pr_counter < vim_pr_records.
    MESSAGE s818(sv) WITH pr_counter vim_pr_records.
*   Es wurden &1 von &2 Einträgen des Business-Configuration-Sets import
  ELSE.
    MESSAGE s819(sv).
*   Das Business-Configuration-Set wurde vollständig importiert.
  ENDIF.
  nextline = 1.
  CLEAR: vim_special_mode, replace_mode.
  PERFORM fill_extract.
  IF status-action EQ hinzufuegen.
    status-action = aendern.
    title-action  = aendern.
    CLEAR <status>-selected.
  ENDIF.
  IF status-mode = detail_bild.
* return to list screen
    vim_next_screen = liste. vim_leave_screen = 'X'.
  ENDIF.
ENDFORM.                               " ACTIVATE_PROFILE
*&---------------------------------------------------------------------*
*&      Form  SET_PROFILE_KEY_ATTRIBUTES
*&---------------------------------------------------------------------*
*       sets screen input attribute according to profile attributes
*       of key field p_name
*----------------------------------------------------------------------*
*      <--P_SCREEN_INPUT  text
*      <--P_VIM_MODIFY_SCREEN  text
*----------------------------------------------------------------------*
FORM set_profile_key_attributes
                    USING p_name LIKE vim_objfield
                    CHANGING p_screen_input LIKE screen-input
                             p_modify_screen LIKE vim_modify_screen.

  DATA: w_field TYPE vimty_fields_type.

  p_screen_input = '0'.
  CASE vim_pr_fields_wa-keys_fix.
    WHEN vim_pr_open.
      p_screen_input = '1'. p_modify_screen = 'X'.
    WHEN vim_pr_all_fix.
      p_screen_input = '0'.
    WHEN vim_pr_some_fix.
      READ TABLE vim_pr_fields_wa-fields INTO w_field
          WITH KEY fieldname = p_name.
      IF w_field-flag <> vim_profile_fixkey.
        p_screen_input = '1'. p_modify_screen = 'X'.
      ENDIF.
  ENDCASE.
ENDFORM.                               " SET_PROFILE_KEY_ATTRIBUTES
*&---------------------------------------------------------------------*
*&      Form  PROFILE_PUT_INTO_WA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p_record  bc-set
*  -->  p_subset  flag: put "initial" value into subsetfield
*  -->  p_action  action-flag from EXTRACT
*  <--  p_field   view-maintenance dataset
*----------------------------------------------------------------------*
FORM profile_put_into_wa USING p_bc_set LIKE vim_profile_values
                               p_record TYPE vim_pr_tab_type
                               p_header TYPE vimdesc
                               p_namtab LIKE x_namtab[]
                               p_subset TYPE xfeld
                               p_action TYPE char1
                               actopts TYPE scpractopt
                         CHANGING p_field.
  DATA:          w_profile TYPE scpr_vals,
                 fieldname TYPE fnam_____4,
                 old_guid TYPE REF TO data,
                 tabname_wa TYPE objs-tabname,
                 objecttype TYPE objs-objecttype VALUE 'S'.
  STATICS:       loc_viewname TYPE objs-objectname,
                 piecelist TYPE TABLE OF objs-tabname.
  FIELD-SYMBOLS: <namtab> TYPE vimnamtab, <field> TYPE ANY,
                 <old_guid> TYPE ANY, <work_area> TYPE ANY,
                 <bc_value> TYPE ANY.

  CONSTANTS: no_standard(1) TYPE c VALUE 'F',
             stan(3) TYPE c VALUE 'USE',
             new_entry(1) TYPE c VALUE 'N'.                 "IG 1036876

  ASSIGN p_field TO <work_area> CASTING TYPE (p_header-maintview).
  LOOP AT p_namtab ASSIGNING <namtab> WHERE keyflag = space
   AND texttabfld = space.
    ASSIGN COMPONENT <namtab>-viewfield OF STRUCTURE <work_area>
     TO <field>.
    CONCATENATE p_header-maintview <namtab>-viewfield
     INTO fieldname SEPARATED BY '-'.
    IF <namtab>-domname IN vim_guid_domain.
* GUID field
      IF p_action = neuer.
*     Overtake GUID from BC-Set for new entries.
      ELSE.
        IF p_record-keys_fix = vim_pr_all_fix.
          IF p_header-frm_af_uid <> space.
* prepare event 27
            CREATE DATA old_guid TYPE (fieldname).
*          ASSIGN p_field+<namtab>-position(<namtab>-flength)
*           TO <guid> CASTING TYPE (fieldname).
            ASSIGN: old_guid->* TO <old_guid>.
            <old_guid> = <field>.
          ENDIF.
        ELSE.
          CONTINUE.
* Use GUID from BC-Set only if complete key is given fix
        ENDIF.
      ENDIF.
    ENDIF.
    CASE <namtab>-readonly.
      WHEN space.
        READ TABLE p_bc_set INTO w_profile WITH KEY
          tablename = p_header-viewname
          recnumber = p_record-recnumber
          fieldname = <namtab>-viewfield BINARY SEARCH
          TRANSPORTING flag value.
        CHECK sy-subrc = 0.
        ASSIGN w_profile-value TO <bc_value> CASTING TYPE (fieldname).
*       Do not overwrite field of existing dataset with BC-Set value
*       if standard field (flag = USE) and actopts-no_standard = Y.
        IF actopts-no_standrd NE no_standard OR w_profile-flag NE stan
           OR p_action EQ new_entry.                        "IG 1036876
          <field> = <bc_value>.
        ENDIF.
*        MOVE w_profile-value(<namtab>-flength)
*             TO p_field+<namtab>-position(<namtab>-flength).
      WHEN rdonly OR vim_hidden.       "HCG Check if table in piece list
        IF p_header-viewname NE loc_viewname.
          loc_viewname = p_header-viewname.
          REFRESH piecelist.
          IF p_header-bastab EQ space. objecttype = 'V'. ENDIF.
          SELECT tabname FROM objs INTO tabname_wa   "Get info from OBJS
                       WHERE objectname = p_header-viewname
                       AND   objecttype = objecttype.
            APPEND tabname_wa TO piecelist.
          ENDSELECT.
        ENDIF.
        READ TABLE p_bc_set INTO w_profile WITH KEY
          tablename = p_header-viewname
          recnumber = p_record-recnumber
          fieldname = <namtab>-viewfield BINARY SEARCH
          TRANSPORTING flag value.
        CHECK sy-subrc = 0.
        READ TABLE piecelist INTO tabname_wa WITH KEY      "#EC *
                                               <namtab>-bastabname.
        IF sy-subrc EQ 0. "HCG If table is not in piecelist: skip field
          ASSIGN w_profile-value TO <bc_value> CASTING TYPE (fieldname).
*         Do not overwrite field of existing dataset with BC-Set value
*         if standard field (flag = USE) and actopts-no_standard = Y.
          IF actopts-no_standrd NE no_standard OR
             w_profile-flag NE stan OR p_action EQ new_entry."IG 1036876
            <field> = <bc_value>.
          ENDIF.
        ENDIF.
      WHEN subset.
        CHECK p_subset <> space.
        ASSIGN COMPONENT <namtab>-viewfield OF STRUCTURE <initial>
         TO <bc_value>.
*        MOVE <initial>+<namtab>-position(<namtab>-flength)
*         TO p_field+<namtab>-position(<namtab>-flength).
    ENDCASE.
    IF <namtab>-domname IN vim_guid_domain
     AND p_record-keys_fix = vim_pr_all_fix
     AND  p_header-frm_af_uid <> space.
* event 27 for GUID field
      PERFORM (p_header-frm_af_uid) IN PROGRAM (p_header-fpoolname)
                                    USING <old_guid>
                                    CHANGING <field>
                                             <work_area>.
    ENDIF.
  ENDLOOP.
ENDFORM.                               " PROFILE_PUT_INTO_WA
*&---------------------------------------------------------------------*
*&      Form  GET_PR_NBR_RECORDS
*&---------------------------------------------------------------------*
*       Get the number of records the chosen profile contains and get
*       the fields every record contains.
*----------------------------------------------------------------------*
*      -->VIM_PROFILE_VALUES  contains bc-set
*      -->X_HEADER
*      -->P_RC                = 4: no record found
*      <--VIM_PR_RECORDS      number of records in bc-set
*      <--VIM_PR_TAB          table of bc-set-records, initialized
*      <--VIM_PR_FIELDS       lists of matched fields for every record
*----------------------------------------------------------------------*
FORM get_pr_nbr_records USING vim_profile_values
                               LIKE vim_profile_values
                              x_header TYPE vimdesc
                        CHANGING p_rc LIKE sy-subrc
                                 p_bc_id TYPE scpr_id
                                 vim_pr_records TYPE i
                                 vim_pr_tab LIKE vim_pr_tab
                                 vim_pr_fields LIKE vim_pr_fields.

  DATA: w_vim_pr_tab TYPE vim_pr_tab_type, first VALUE 'X',
        w_vim_pr_fields TYPE vim_pr_fields_type,
        w_fields TYPE vimty_fields_type, recnumber TYPE scpr_recnr.
  FIELD-SYMBOLS: <profile_value> LIKE LINE OF vim_profile_values.

  REFRESH: vim_pr_tab, vim_pr_fields.
  CLEAR: vim_pr_records, p_rc.

  LOOP AT vim_profile_values ASSIGNING <profile_value>
       WHERE tablename = x_header-viewname.
    IF <profile_value>-recnumber <> recnumber.
      recnumber = <profile_value>-recnumber.
      IF first = space.
        APPEND w_vim_pr_tab TO vim_pr_tab.
        APPEND w_vim_pr_fields TO vim_pr_fields. CLEAR w_vim_pr_fields.
      ENDIF.
      CLEAR first.
      w_vim_pr_fields-recnumber = w_vim_pr_tab-recnumber
       = <profile_value>-recnumber.
      ADD 1 TO vim_pr_records.
    ENDIF.
    w_fields-fieldname = <profile_value>-fieldname.
    w_fields-flag = <profile_value>-flag.
    APPEND w_fields TO w_vim_pr_fields-fields.
  ENDLOOP.
  p_rc = sy-subrc.
  CHECK sy-subrc = 0.
  APPEND w_vim_pr_tab TO vim_pr_tab.
  APPEND w_vim_pr_fields TO vim_pr_fields.
  p_bc_id = <profile_value>-id.
*  IF w_vim_pr_tab-recnumber IS INITIAL.
*    w_vim_pr_tab-recnumber = 1. APPEND w_vim_pr_tab TO vim_pr_tab.
*    ADD 1 TO vim_pr_records.
*  ENDIF.
ENDFORM.                               " GET_PR_NBR_RECORDS
*&---------------------------------------------------------------------*
*&      Form  GET_PR_FIELD_FROM_SEL
*&---------------------------------------------------------------------*
*       extracts value for field P_PR_NAMTAB-VIEWFIELD from P_PR_SELLIST
*       into P_VIM_SEL_VALUE.
*----------------------------------------------------------------------*
*      <--P_SEL_VALUE   extracted value, P_SEL_VALUE remain sunchanged
*      <--P_RC          0: o.k.  1: no selection defined, P_SEL_VALUE
*                       remains unchanged  2: no unambiguous
*                       extraction possible, P_SEL_VALUE cleared
*      -->P_PR_SELLIST  text
*      -->P_PR_NAMTAB   text
*      -->P_PR_CLUSTER  Flag: View maintenance called by cluster
*----------------------------------------------------------------------*
FORM get_pr_field_from_sel
       USING    p_pr_sellist TYPE vimsellist_type
                p_pr_namtab LIKE vimnamtab
       CHANGING p_sel_value LIKE dpl_sellist-value
                p_rc LIKE sy-subrc.

  DATA: w_sellist LIKE vimsellist, first.                   "#EC *

  p_rc = 1. first = 'X'.
  LOOP AT p_pr_sellist INTO w_sellist.
    CHECK w_sellist-viewfield = p_pr_namtab-viewfield.
    IF first = space OR w_sellist-operator <> 'EQ'.
      CLEAR p_sel_value. p_rc = 2. EXIT.
    ELSE.
      MOVE w_sellist-value(p_pr_namtab-flength) TO
       p_sel_value(p_pr_namtab-flength).
      p_rc = 0.
    ENDIF.
    CLEAR first.
  ENDLOOP.
ENDFORM.                               " GET_PR_FIELD_FROM_SEL
*&---------------------------------------------------------------------*
*&      Form  VIM_PR_mand_fields
*&---------------------------------------------------------------------*
*       Appending profiles in detail mode: Leaves screen to reset
*       mandatory attribute and to process sreen in background if
*       at least one dynpro-field is mandatory.
*----------------------------------------------------------------------*
FORM vim_pr_mand_fields.
  LOOP AT SCREEN.
    CHECK screen-required <> '0'.
    vim_pr_activating = 'X'.
    SET SCREEN detail. LEAVE SCREEN.
  ENDLOOP.
ENDFORM.                               " VIM_PR_AT_EXIT_COM
*&---------------------------------------------------------------------*
*&      Form  bcset_key_check_in_total
*&---------------------------------------------------------------------*
*       check, if bc-set-key already exists
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM bcset_key_check_in_total.

  DATA: w_record TYPE vim_pr_tab_type.
  FIELD-SYMBOLS: <bc_key> TYPE x.

  ASSIGN w_record-keys(x_header-keylen) TO <bc_key>.
  LOOP AT vim_pr_tab INTO w_record.
    CLEAR w_record-action.
    READ TABLE total WITH KEY <bc_key> BINARY SEARCH        "#EC *
     TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      w_record-action = aendern.
    ELSE.
      w_record-action = neuer_eintrag.
    ENDIF.
    MODIFY vim_pr_tab FROM w_record.
  ENDLOOP.
ENDFORM.                               " bcset_key_check_in_total
*&---------------------------------------------------------------------*
*&      Form  bcset_force_into_entry
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<W_RECORD>  text
*      <--P_AENDERN  text
*----------------------------------------------------------------------*
FORM bcset_force_into_entry USING    p_record TYPE vim_pr_tab_type
                                     p_action TYPE char1
                                     actopts TYPE scpractopt.

  FIELD-SYMBOLS: <textrec_x> TYPE x.

  IF <xmark> = nicht_markiert.
    <xmark> = markiert. ADD 1 TO mark_extract.
  ENDIF.
  <xact> = p_action.
  PERFORM profile_put_into_wa USING vim_profile_values
                                    p_record
                                    x_header
                                    x_namtab[]
                                    'X'
                                    p_action
                                    actopts
                              CHANGING <vim_xextract>.
*                              CHANGING <table2>.
  IF x_header-texttbexst <> space AND x_header-bastab <> space.
    ASSIGN p_record-textrecord(x_header-texttablen)
     TO <textrec_x> CASTING.
    MOVE <textrec_x> TO <vim_xextract_text>.
*    MOVE p_record-textrecord+x_header-textkeylen(len_text)
*             TO <extract_text>+x_header-textkeylen(len_text).
  ENDIF.
ENDFORM.                               " bcset_force_into_entry
