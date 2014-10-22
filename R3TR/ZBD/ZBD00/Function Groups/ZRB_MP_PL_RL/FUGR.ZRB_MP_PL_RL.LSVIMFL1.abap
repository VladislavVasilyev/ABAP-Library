*----------------------------------------------------------------------*
*   INCLUDE LSVIMFL1
**----------------------------------------------------------------------
*
*---------------------------------------------------------------------*
*       FORM VIM_GET_TEXTTAB_DATA                                     *
*---------------------------------------------------------------------*
* Texteinträge von der DB nachlesen für angeg. Sprachen               *
* UFProbl251070/1998: Falls X_NAMTAB-Reihenfolge nicht mit
*                     DBA-SELLIST-Reihenfolge übereinstimmt, werden
*                     ANDs oder ORs verschluckt.
*---------------------------------------------------------------------*
*  --> LANGUS         ausgewählte Sprachen
* <--> TEXTTAB
*---------------------------------------------------------------------*
FORM vim_get_texttab_data TABLES langus STRUCTURE h_t002
                          CHANGING texttab TYPE table.
*                                  Type VIM_LINE_US/../VIM_LINE_UL
  DATA: tgd_sellist LIKE vimsellist OCCURS 10, tgd_sel LIKE vimsellist,
        wheretab_line LIKE vimwheretb,
        spras_value(3) TYPE c,
*        curr_spras(1) TYPE c,
        keylen TYPE i,
        l TYPE i, sellist_l TYPE i, tbx TYPE i,
        and_or_str(6) TYPE c, left_par(1) TYPE c,
        tmp_texttab TYPE REF TO data,
        tmp_texttab_wa TYPE REF TO data,
*        tmp_texttab TYPE vim_tab_ul WITH HEADER LINE,
        texttab_tabix LIKE sy-tabix,
        align1 type f,                                     "#EC NEEDED
        texttab_wa TYPE vim_line_ul,
        align2 type f,                                   "#EC NEEDED
        view_wa TYPE tabl8000, map_error TYPE xfeld.
  FIELD-SYMBOLS: <tmp_texttab> TYPE STANDARD TABLE,
                 <tmp_texttab_wa> TYPE ANY, <tmp_texttab_wax> TYPE x,
                 <view_key> TYPE x, <next_spras> TYPE spras,
                 <curr_spras> TYPE spras,
                 <h_texttab> TYPE x, <h_texttab_wa> TYPE x,
                 <viewkey_in_texttab> TYPE x, <texttab_struc> TYPE ANY.

  CREATE DATA: tmp_texttab TYPE STANDARD TABLE OF (x_header-texttab),
               tmp_texttab_wa TYPE (x_header-texttab).
  ASSIGN: tmp_texttab->* TO <tmp_texttab>,
          tmp_texttab_wa->* TO <tmp_texttab_wa>,
          <tmp_texttab_wa> TO <tmp_texttab_wax> CASTING.

  IF x_header-selection NE space.
    LOOP AT dba_sellist INTO tgd_sel       "UFProbl251070/1998
     WHERE value <> space OR initial = 'X'.
      LOOP AT x_namtab WHERE viewfield EQ tgd_sel-viewfield
                       AND keyflag NE space AND txttabfldn NE space.
        tgd_sel-viewfield = x_namtab-txttabfldn.
        tgd_sel-tabix     = sy-tabix.
        APPEND tgd_sel TO tgd_sellist.
        EXIT.
      ENDLOOP.
    ENDLOOP.                                "UFProbl251070/1998
  ENDIF.                               "X_HEADER-SELECTION

  DESCRIBE TABLE tgd_sellist LINES sellist_l.
  IF sellist_l > 0.
    READ TABLE tgd_sellist INDEX sellist_l INTO tgd_sel.
    IF tgd_sel-and_or NE space.
      CLEAR tgd_sel-and_or.
      MODIFY tgd_sellist INDEX sellist_l FROM tgd_sel.
    ENDIF.
    CALL FUNCTION 'VIEW_FILL_WHERETAB'
         EXPORTING
              tablename               = x_header-texttab
              only_cnds_for_keyflds   = 'X'
              is_texttable            = 'X'
         TABLES
              sellist                 = tgd_sellist
              wheretab                = vim_wheretab
              x_namtab                = x_namtab
         EXCEPTIONS
              no_conditions_for_table = 01.
    IF sy-subrc = 1. sellist_l = 0. ENDIF.
  ELSE.
    REFRESH vim_wheretab.
  ENDIF.

* VIM_WHERETAB um Bedingungen für ausgew. Sprachen ergänzen
  DESCRIBE TABLE langus LINES l.
  IF l > 1.
    and_or_str = 'OR'.
    IF sellist_l > 0.
      left_par = '('.
    ENDIF.
  ENDIF.
  tbx = 1.
  spras_value = ''' '''.
  LOOP AT langus.
    spras_value+1(1) = langus-spras.
    IF tbx = l.      " letzte Zeile für Sprachselektion
      IF l > 1 AND sellist_l > 0.
        and_or_str = ' ) AND'.
      ELSEIF l = 1 AND sellist_l > 0.
        and_or_str = ' AND'.
      ELSE.
        CLEAR and_or_str.
      ENDIF.
    ENDIF.
   CONCATENATE left_par x_header-sprasfield 'EQ' spras_value and_or_str
                            INTO wheretab_line SEPARATED BY space.
    INSERT wheretab_line INTO vim_wheretab INDEX tbx.
    CLEAR left_par.
    tbx = tbx + 1.
  ENDLOOP.

  SELECT * FROM (x_header-texttab) INTO TABLE <tmp_texttab>
                                      WHERE (vim_wheretab).

* Texttabellen-Einträge sortiert in Texttabelle einfügen
  IF x_header-delmdtflag <> space AND  "zeitabh. & part. Fremdschl.
     x_header-ptfrkyexst  = 'X'.       "      -> zeitunabh. Texttab.
    keylen = x_header-after_keyc
              - vim_datum_length * cl_abap_char_utilities=>charsize.
  ELSE.
    keylen = x_header-after_keyc.
  ENDIF.
  ASSIGN: view_wa(keylen) TO <view_key>,
          texttab_wa TO <h_texttab_wa> CASTING,
          <h_texttab_wa>(keylen) TO <viewkey_in_texttab>,
          <h_texttab_wa>+keylen(x_header-texttablen) TO <h_texttab>,
          <h_texttab> TO <texttab_struc>
           CASTING TYPE (x_header-texttab),
          COMPONENT x_header-sprasfield OF STRUCTURE <texttab_struc>
           TO <next_spras>,
          COMPONENT x_header-sprasfield OF STRUCTURE <tmp_texttab_wa>
           TO <curr_spras>.
  LOOP AT <tmp_texttab> INTO <tmp_texttab_wa>.
    PERFORM map_texttabkey_to_viewkey TABLES x_namtab
                                      USING x_header
                                            <tmp_texttab_wax>
                                            x_header-textkeylen
                                            x_header-genertxtrp
                                      CHANGING <view_key>
                                               map_error.
    CHECK map_error = space.
*    PERFORM vim_fill_view_key USING tmp_texttab
*                           CHANGING <view_key> curr_spras.
    CLEAR texttab_wa.
    READ TABLE texttab WITH KEY <view_key> INTO texttab_wa  "#EC *
                                                        BINARY SEARCH.
    texttab_tabix = sy-tabix.
    IF sy-subrc = 0 AND
      <viewkey_in_texttab> = <view_key> AND  "Text ex. in weiteren Spr
      <next_spras> < <curr_spras>. "#EC PORTABLE
      LOOP AT texttab FROM texttab_tabix INTO texttab_wa.
        IF <viewkey_in_texttab> <> <view_key> OR
           <next_spras> >= <curr_spras>. "#EC PORTABLE
          texttab_tabix = sy-tabix.
          EXIT.
* Condition Redundant - Internal Message 0001699060 - ACHACHADI
*        ELSEIF <next_spras> < <curr_spras>.               "#EC BOOL_OK
         ELSE.
          texttab_tabix = sy-tabix + 1.
        ENDIF.
      ENDLOOP.
    ENDIF.   " <next_spras> >= <curr_spras> oder ex. nicht
    IF <next_spras> <> <curr_spras> OR
       <viewkey_in_texttab> <> <view_key>.  "Text ex. nicht in Sprache
      CLEAR texttab_wa.
      <viewkey_in_texttab> = <view_key>.
      <texttab_struc> = <tmp_texttab_wa>.
      INSERT texttab_wa INTO texttab INDEX texttab_tabix.
    ELSE.
      <texttab_struc> = <tmp_texttab_wa>.
      MODIFY texttab FROM texttab_wa INDEX texttab_tabix.
    ENDIF.

  ENDLOOP.                             " tmp_texttab
ENDFORM.                               "VIM_GET_TEXTTAB_DATA

*---------------------------------------------------------------------*
*       FORM VIM_READ_TEXTTAB_ENTRY                                   *
*---------------------------------------------------------------------*
* einzelnen Texttabellen-Eintrag für alle bisher bearbeiteten         *
* Sprachen nachlesen
* Aktueller Eintrag steht in Kopfzeile von EXTRACT
*---------------------------------------------------------------------*
FORM vim_read_texttab_entry.
  DATA: texttab_wa TYPE vim_line_ul,
        texttab_tabix LIKE sy-tabix,
        keylen TYPE i,
        offset TYPE i,
        modify_texttab(1) TYPE c,
        tmp_texttab TYPE ref to data,
        w_tmp_texttab type ref to data.
  FIELD-SYMBOLS: <h_texttab_wa> type x,
                 <viewkey_in_texttab> type x,               "#EC *
                 <texttab_key> type x,
                 <texttab_fields>, <texttab_action> type c,
                 <extract_key> type x,
                 <tmp_texttab> type standard table,
                 <w_tmp_texttab> type any,
                 <w_tmp_texttab_x> type x.

  IF x_header-delmdtflag <> space AND  "zeitabh. & part. Fremdschl.
     x_header-ptfrkyexst  = 'X'.       "      -> zeitunabh. Texttab.
    ASSIGN <vim_ext_mkey_beforex> TO <extract_key>.
*    ASSIGN <vim_ext_mkey_before> TO <extract_key>.
    keylen = x_header-keylen
              - vim_datum_length * cl_abap_char_utilities=>charsize.
  ELSE.
    ASSIGN <vim_xextract_key> TO <extract_key>.
     keylen = x_header-after_keyc.
*    keylen = x_header-keylen.
  ENDIF.

  READ TABLE <vim_texttab> WITH KEY <extract_key>           "#EC *
                           BINARY SEARCH TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    texttab_tabix = sy-tabix.
  ELSE.
    EXIT.     "keine Texte zum Key in anderen Sprachen erfaßt
  ENDIF.

  ASSIGN: texttab_wa TO <h_texttab_wa> casting,
          <h_texttab_wa>+keylen(x_header-textkeylen) TO <texttab_key>,
          <h_texttab_wa>+keylen(x_header-texttablen)
           TO <texttab_fields>.
*  ASSIGN texttab_wa(keylen) TO <viewkey_in_texttab>.
*  ASSIGN texttab_wa+keylen(x_header-textkeylen) TO <texttab_key>.
*  ASSIGN texttab_wa+keylen(x_header-texttablen) TO <texttab_fields>.
  offset = ( keylen + x_header-texttablen )
           / cl_abap_char_utilities=>charsize.
*  offset = keylen + x_header-texttablen.
  ASSIGN texttab_wa+offset(1) TO <texttab_action>.

  create data tmp_texttab type standard table of (x_header-texttab).
  create data w_tmp_texttab type (x_header-texttab).
  assign: tmp_texttab->* to <tmp_texttab>,
          w_tmp_texttab->* to <w_tmp_texttab>,
          <w_tmp_texttab> to <w_tmp_texttab_x> casting.
  LOOP AT <vim_texttab> FROM texttab_tabix INTO texttab_wa.
*    IF <viewkey_in_texttab> <> <extract_key>. EXIT. ENDIF. "Commented ACHACHADI 0001352850
    IF <texttab_action> = neuer_eintrag.
      DELETE <vim_texttab>.
      modify_texttab = 'X'.
    ELSEIF <texttab_action> <> original.
      refresh <tmp_texttab>.
*      REFRESH tmp_texttab.
      CALL FUNCTION 'DB_SELECT_GENERIC_TABLE'
           EXPORTING
                genkey      = <texttab_key>
                genkey_ln   = x_header-textkeylen
                tablename   = x_header-texttab
           TABLES
                inttab      = <tmp_texttab>
*                inttab      = tmp_texttab
           EXCEPTIONS
                db_error    = 12
                not_found   = 04
                wrong_param = 08.
      IF sy-subrc > 4. RAISE get_table_error. ENDIF.        "#EC *

      READ TABLE <tmp_texttab> into <w_tmp_texttab> INDEX 1.
*      READ TABLE tmp_texttab INDEX 1.
      IF sy-subrc = 0.
        <texttab_fields> = <w_tmp_texttab_x>(x_header-texttablen).
*        <texttab_fields> = tmp_texttab(x_header-texttablen).
        <texttab_action> = original.
        MODIFY <vim_texttab> FROM texttab_wa.
        modify_texttab = 'X'.
      ELSE.                            "NOT_FOUND
        DELETE <vim_texttab>.
        modify_texttab = 'X'.
      ENDIF.
    ENDIF.
  ENDLOOP.
  IF modify_texttab = 'X'.
    MODIFY vim_texttab_container INDEX vim_texttab_container_index.
    CLEAR sy-subrc.
  ELSE.
    sy-subrc = 4.
  ENDIF.
ENDFORM.                               "VIM_READ_TEXTTAB_ENTRY

*---------------------------------------------------------------------*
*       FORM VIM_TEXTTAB_DB_UPD                                       *
*---------------------------------------------------------------------*
* Datenbank-Änderungen für Texttabelle (für spras <> SY-LANGU)        *
* Action_Flag in <VIM_TEXTTAB> für modif. Einträge zurücksetzen
* gelöschte Einträge aus interner Text-Tabelle löschen
*---------------------------------------------------------------------*
FORM vim_texttab_db_update.
  DATA: modified_entries TYPE i,
        texttab_modified(1) TYPE c,
        keylen TYPE i,
        offset TYPE i,
        align type f, texttab_wa TYPE vim_line_ul,                   "#EC NEEDED "HCG never separate
        tmp_texttab TYPE REF TO data,
        w_tmp_texttab TYPE REF TO data.
*        tmp_texttab TYPE vim_tab_ul WITH HEADER LINE.
  FIELD-SYMBOLS: <tmp_texttab> TYPE STANDARD TABLE,
                 <w_tmp_texttab> TYPE ANY,
                 <h_texttab_wa> TYPE x, <h_texttab_fields> TYPE x,
                 <texttab_fields> TYPE ANY, <texttab_action>.

  CLEAR texttab_modified.
  CHECK x_header-texttbexst <> space.
  IF x_header-delmdtflag <> space AND  "zeitabh. & part. Fremdschl.
     x_header-ptfrkyexst  = 'X'.       "      -> zeitunabh. Texttab.
    keylen = x_header-after_keyc
             - vim_datum_length * cl_abap_char_utilities=>charsize.
  ELSE.
    keylen = x_header-after_keyc.
  ENDIF.

  CREATE DATA: tmp_texttab TYPE STANDARD TABLE OF (x_header-texttab),
               w_tmp_texttab TYPE (x_header-texttab).
  ASSIGN: tmp_texttab->* TO <tmp_texttab>,
          w_tmp_texttab->* TO <w_tmp_texttab>,
          texttab_wa TO <h_texttab_wa> CASTING,
          <h_texttab_wa>+keylen(x_header-texttablen)
           TO <h_texttab_fields>,
          <h_texttab_fields> TO <texttab_fields>
           CASTING TYPE (x_header-texttab).
  offset = ( keylen + x_header-aft_txttbc )
           / cl_abap_char_utilities=>charsize.
  ASSIGN texttab_wa+offset(1) TO <texttab_action>.

* DELETE: nur in interner Texttabelle, in DB schon bisher für alle Spr.
  LOOP AT <vim_texttab> INTO texttab_wa.
    CHECK <texttab_action> EQ geloescht OR
          <texttab_action> EQ neuer_geloescht OR
          <texttab_action> EQ update_geloescht.
    DELETE <vim_texttab>.
    texttab_modified = 'X'.
  ENDLOOP.                             "<VIM_TEXTTAB>

* UPDATE
  CLEAR modified_entries. REFRESH <tmp_texttab>.
  LOOP AT <vim_texttab> INTO texttab_wa.
    CHECK <texttab_action> EQ aendern.
    APPEND <texttab_fields> TO <tmp_texttab>.
*    tmp_texttab  = <texttab_fields>.
*    APPEND tmp_texttab.
    modified_entries = modified_entries + 1.
    <texttab_action> = original.
    MODIFY <vim_texttab> FROM texttab_wa.
  ENDLOOP.                             "<VIM_TEXTTAB>
  IF modified_entries > 0.
    UPDATE (x_header-texttab) FROM TABLE <tmp_texttab>.
    texttab_modified = 'X'.
  ENDIF.

* INSERT
  CLEAR modified_entries. REFRESH <tmp_texttab>.
  LOOP AT <vim_texttab> INTO texttab_wa.
    CHECK <texttab_action> EQ neuer_eintrag.
    APPEND <texttab_fields> TO <tmp_texttab>.
*    tmp_texttab = <texttab_fields>.
*    APPEND tmp_texttab.
    modified_entries = modified_entries + 1.
    <texttab_action> = original.
    MODIFY <vim_texttab> FROM texttab_wa.
  ENDLOOP.                             "<VIM_TEXTTAB>
  IF modified_entries > 0.
    INSERT (x_header-texttab) FROM TABLE <tmp_texttab>
           ACCEPTING DUPLICATE KEYS. "um RABAX bei unzulässigem
    "Texttab-Aufbau zu vermeiden
    texttab_modified = 'X'.
  ENDIF.

  IF texttab_modified = 'X'.
    MODIFY vim_texttab_container INDEX vim_texttab_container_index.
  ENDIF.
ENDFORM.                               "VIM_TEXTTAB_DB_UPDATE

* Import für Texte in anderen Sprachen                      "Textimp ...
*---------------------------------------------------------------------*
*       FORM VIM_READ_TEXTTAB_ALL_LANGUS                              *
*---------------------------------------------------------------------*
* Texteinträge von der DB für alle Sprachen einlesen.                 *
*---------------------------------------------------------------------*
FORM vim_read_texttab_all_langus.
  DATA: langus_selected(1) TYPE c,             "#EC NEEDED
        curr_sptxt LIKE t002t-sptxt,               "#EC NEEDED
        sel_langus LIKE h_t002 OCCURS 0 WITH HEADER LINE.

  CALL FUNCTION 'VIEW_GET_LANGUAGES'
       EXPORTING
            all_without_selection = 'X'
       IMPORTING
            languages_selected    = langus_selected
            curr_sptxt            = curr_sptxt
       TABLES
            languages             = sel_langus.
  IF x_header-frm_tl_get NE space.
    PERFORM (x_header-frm_tl_get) IN PROGRAM (x_header-fpoolname)
                                  TABLES sel_langus.
  ELSE.
    PERFORM vim_read_texttab_for_langus TABLES sel_langus USING ' '.
  ENDIF.
ENDFORM.                               "VIM_READ_TEXTTAB_ALL_LANGUS

************************************************************************
* SW Langtext
*    Absprung in Langtextpflege über Userexit vom Übersetzungsscreen aus
*    ermöglichen
*---------------------------------------------------------------------*
*       FORM VIM_CALL_LTEXT_EXIT                                      *
*---------------------------------------------------------------------*
* ->  MAINT_MODE      'U'/'R' (Update/Read)
* ->  EXITFORM        Name der Userexit-Routine für Langtextpflege
* <-> TEXTTABLE_ENTRY Zeile, für die Langtextpflege aufgerufen wurde
* <-  MODIFIED        'X' -> Zeile wurde modifiziert
*---------------------------------------------------------------------*
* Aufruf des Userexits für Langtextpflege                             *
*---------------------------------------------------------------------*
FORM vim_call_ltext_exit
             USING    maint_mode TYPE c
                      exitform TYPE vimfrmname
             CHANGING texttable_entry TYPE vimty_textmaint_record
                      modified TYPE c.
  DATA: text_wa TYPE vim_line_ul,
        textmaint_field TYPE vimty_textfield,
        pgm_name LIKE sy-repid,                        "#EC NEEDED
        offset LIKE sy-fdpos.                              "#EC NEEDED

  FIELD-SYMBOLS: <text_wa> TYPE x, <text_wa_struc> TYPE ANY,
                 <texttabkey> TYPE x, <txtfld> TYPE ANY.

  CLEAR modified.
  IF vim_internal_ltext_call = space.
    PERFORM (exitform) IN PROGRAM (sy-repid).
  ELSE.
    READ TABLE x_header INDEX 1.
    ASSIGN: text_wa TO <text_wa> CASTING,
            <text_wa> TO <text_wa_struc>
             CASTING TYPE (x_header-texttab),
            texttable_entry-keys TO <texttabkey> CASTING.

    PERFORM map_viewkey_to_texttabkey TABLES x_namtab
                                USING x_header
                                      texttable_entry-spras
                                      <texttabkey>
                             CHANGING <text_wa>.
*    PERFORM VIM_FILL_TEXTTAB_KEY USING TEXTTABLE_ENTRY-KEYS
*                                       TEXTTABLE_ENTRY-SPRAS
*                                       X_HEADER-SPRASFDPOS
*                              CHANGING TEXT_WA.
    LOOP AT texttable_entry-texttab INTO textmaint_field.
      READ TABLE x_namtab INDEX textmaint_field-namtab_idx.
*      offset = x_namtab-texttabpos.
      IF x_namtab-lowercase = space.
        TRANSLATE textmaint_field-text TO UPPER CASE.
      ENDIF.
      IF x_namtab-txttabfldn = space.
* tab + texttab
        ASSIGN COMPONENT x_namtab-bastabfld
         OF STRUCTURE <text_wa_struc> TO <txtfld>.
      ELSE.
* view
        ASSIGN COMPONENT x_namtab-txttabfldn
         OF STRUCTURE <text_wa_struc> TO <txtfld>.
      ENDIF.
      <txtfld> = textmaint_field-text.
*      text_wa+offset(x_namtab-flength) =
*         textmaint_field-text(x_namtab-flength).
    ENDLOOP.
    PERFORM (exitform) IN PROGRAM (x_header-fpoolname)
                          USING maint_mode
                          CHANGING text_wa modified.
    IF modified = 'X'.
      IF maint_mode = 'U'.
        LOOP AT texttable_entry-texttab INTO textmaint_field.
          READ TABLE x_namtab INDEX textmaint_field-namtab_idx.
          ASSIGN COMPONENT x_namtab-txttabfldn
           OF STRUCTURE <text_wa_struc> TO <txtfld>.
          textmaint_field-text = <txtfld>.
*          offset = x_namtab-texttabpos.
*          textmaint_field-text(x_namtab-flength) =
*            text_wa+offset(x_namtab-flength).
          MODIFY texttable_entry-texttab FROM textmaint_field.
        ENDLOOP.
        texttable_entry-action = 'X'.
      ELSE.
        CLEAR modified.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                               " VIM_CALL_LTEXT_EXIT
