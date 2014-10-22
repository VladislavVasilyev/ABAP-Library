***INCLUDE LSVIMFXL.
* SW 25.3.1997
*    Readonly-Felder in Texttabelle berücksichtigen

* SW 14.7.1998
*    Import für Texte in anderen Sprachen    "Textimp

* SW 17.9.1998
*    beim Kopieren Texte in anderen Sprachen berücksichtigen   "Textcopy
* UF 19.10.1998: DB-Zugriffe in Include LSVIMFL1 verlagert
INCLUDE lsvimfl1.
*---------------------------------------------------------------------*
*       FORM VIM_SET_LANGUAGES                                        *
*---------------------------------------------------------------------*
* Sprachauswahl expl. über Menue
*---------------------------------------------------------------------*
FORM vim_set_languages.
  DATA: dummy_langus LIKE h_t002 OCCURS 0.
  CALL FUNCTION 'VIEW_GET_LANGUAGES'
    EXPORTING
      new_selection         = 'X'
*      called_by_viewmaint   = 'X'
    TABLES
      languages             = dummy_langus
    EXCEPTIONS
      no_languages_possible = 1.
  IF sy-subrc = 1.
    MESSAGE s160(sv).
  ENDIF.
ENDFORM.                    "vim_set_languages

*---------------------------------------------------------------------*
*       FORM VIM_RESET_TEXTTAB                                        *
*---------------------------------------------------------------------*
* Rücksetzen der internen Texttabelle
*---------------------------------------------------------------------*
* --> VIEWNAME   Rücksetzen der Texttab für Tab/View VIEWNAME
*---------------------------------------------------------------------*
FORM vim_reset_texttab USING viewname LIKE tvdir-tabname.

  READ TABLE vim_texttab_container WITH KEY viewname = viewname
                         BINARY SEARCH.
  IF sy-subrc = 0.
    FREE vim_texttab_container-tabdata-tab_us.
    FREE vim_texttab_container-tabdata-tab_vs.
    FREE vim_texttab_container-tabdata-tab_s.
    FREE vim_texttab_container-tabdata-tab_m.
    FREE vim_texttab_container-tabdata-tab_l.
    FREE vim_texttab_container-tabdata-tab_vl.
    FREE vim_texttab_container-tabdata-tab_ul.
    FREE vim_texttab_container-sel_langus.
    CLEAR vim_texttab_container-all_langus.
    MODIFY vim_texttab_container INDEX sy-tabix.
*     DELETE VIM_TEXTTAB_CONTAINER INDEX SY-TABIX.
  ENDIF.
ENDFORM.                               "VIM_RESET_TEXTTAB

*---------------------------------------------------------------------*
*       FORM VIM_MULTI_LANGU_TEXT_MAINT                               *
*---------------------------------------------------------------------*
* Routine zur Behandlung der Funktion:                                *
*   "Texterfassung in weiteren Sprachen"                              *
*---------------------------------------------------------------------*
FORM vim_multi_langu_text_maint.
  DATA: langus_selected(1) TYPE c,
        curr_sptxt LIKE t002t-sptxt,
        sel_langus LIKE h_t002 OCCURS 0 WITH HEADER LINE,
        texttab_for_output TYPE vimty_multilangu_texttab,
        maint_mode(1) TYPE c,
        textmodif(1) TYPE c,
        f_called_by_viewmaint TYPE c.  "XB H611377 BCEK070683


  CALL FUNCTION 'VIEW_GET_LANGUAGES'
    IMPORTING
      languages_selected    = langus_selected
      curr_sptxt            = curr_sptxt
    TABLES
      languages             = sel_langus
    EXCEPTIONS
      no_languages_possible = 1.
  IF sy-subrc = 1.
    MESSAGE s160(sv).
    EXIT.
  ELSEIF langus_selected = ' '.
    MESSAGE s153(sv).
    EXIT.
  ENDIF.
  IF x_header-frm_tl_get NE space.
    PERFORM (x_header-frm_tl_get) IN PROGRAM (x_header-fpoolname)
                                  TABLES sel_langus.
  ELSE.
    PERFORM vim_read_texttab_for_langus TABLES sel_langus USING ' '.
  ENDIF.

* Falls mehr als 8 Textfelder (noch nicht realisiert)
*    -> Popup zur Feldselektion und Dynproattribute aktualisieren
* PERFORM VIM_ACTUALIZE_D0100.

  REFRESH texttab_for_output.
  PERFORM vim_fill_texttab_for_maint TABLES sel_langus
                                     USING curr_sptxt
                                     CHANGING texttab_for_output.
  IF status-action EQ anzeigen OR status-action EQ transportieren.
    maint_mode = 'R'.
  ELSE.
    maint_mode = 'U'.
  ENDIF.
* XB H611377B BCEK070683
* check if it is called by view maintenance.
  IF x_namtab IS NOT INITIAL AND x_header IS NOT INITIAL.
    f_called_by_viewmaint = 'X'.
  ENDIF.
  CALL FUNCTION 'VIEW_MULTI_LANGU_TEXT_MAINT'
    EXPORTING
      mode                   = maint_mode
      ltext_exit_form        = x_header-frm_tltext
      called_by_viewmaint    = f_called_by_viewmaint
    IMPORTING
      vim_texttable_modified = textmodif
    TABLES
      vim_d0100_fielddescr   = vim_d0100_fdescr_ini
      vim_texttable          = texttab_for_output
      x_header               = x_header
      x_namtab               = x_namtab.
* XB H611377E BCE070683
  IF maint_mode = 'U' AND textmodif = 'X'.
    PERFORM vim_update_texttab USING texttab_for_output.
    MODIFY vim_texttab_container INDEX vim_texttab_container_index.
  ENDIF.

  IF status-mode = list_bild.          "Entmarkieren
    LOOP AT extract.
      CHECK <xmark> = markiert.
      CLEAR <xmark>.
      MODIFY extract.
      mark_extract = mark_extract - 1.
      READ TABLE total WITH KEY <vim_xextract_key> BINARY SEARCH. "#EC *
      IF sy-subrc = 0 AND <mark> = markiert.
        CLEAR <mark>.
        MODIFY total INDEX sy-tabix.
        mark_total = mark_total - 1.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                               " VIM_MULTI_LANGU_TEXT_MAINT

*---------------------------------------------------------------------*
*       FORM VIM_SELECT_TEXTFIELDS                                    *
*---------------------------------------------------------------------*
* Falls mehr als 8 Textfelder existieren -> Benutzerauswahl
*---------------------------------------------------------------------*
FORM vim_select_textfields.
  DATA: nr_of_fields TYPE i.

  nr_of_fields = 0.
  LOOP AT x_namtab WHERE keyflag <> 'X' AND
                         ( texttabfld = 'X' OR txttabfldn <> space ) AND
                     ( readonly = space OR readonly = 'R' )."SW 25.3.97
    "   Textfeld in Tabelle or Textfeld in View
    x_namtab-textfldsel = 'X'.
    nr_of_fields = nr_of_fields + 1.
    MODIFY x_namtab.
    IF nr_of_fields >= vim_max_textfields.   " Auswahl über Popup !!!
      EXIT.
    ENDIF.
  ENDLOOP.
ENDFORM.                               "VIM_SELECT_TEXTFIELDS

*---------------------------------------------------------------------*
*       FORM VIM_INITIALIZE_D0100                                     *
*---------------------------------------------------------------------*
* Initialierung der Attribute für Dynprofelder des Texterfassungs-    *
* Dynpros D0100 (View-unabhängig)                                     *
*---------------------------------------------------------------------*
FORM vim_initialize_d0100.
  DATA: fdescr_wa TYPE vimty_screen_fdescr.

  REFRESH vim_d0100_fdescr_ini.
* Keys
  CLEAR fdescr_wa.
  fdescr_wa-active = 'X'.
  fdescr_wa-name = 'VIM_D0100_WORKAREA-KEY1'.
  APPEND fdescr_wa TO vim_d0100_fdescr_ini.
  CLEAR fdescr_wa-active.
  fdescr_wa-name = 'VIM_D0100_WORKAREA-KEY2'.
  APPEND fdescr_wa TO vim_d0100_fdescr_ini.
  fdescr_wa-name = 'VIM_D0100_WORKAREA-KEY3'.
  APPEND fdescr_wa TO vim_d0100_fdescr_ini.
  fdescr_wa-name = 'VIM_D0100_WORKAREA-KEY4'.
  APPEND fdescr_wa TO vim_d0100_fdescr_ini.
  fdescr_wa-name = 'VIM_D0100_WORKAREA-KEY5'.
  APPEND fdescr_wa TO vim_d0100_fdescr_ini.
  fdescr_wa-name = 'VIM_D0100_WORKAREA-KEY6'.
  APPEND fdescr_wa TO vim_d0100_fdescr_ini.
  fdescr_wa-name = 'VIM_D0100_WORKAREA-KEY7'.
  APPEND fdescr_wa TO vim_d0100_fdescr_ini.
  fdescr_wa-name = 'VIM_D0100_WORKAREA-KEY8'.
  APPEND fdescr_wa TO vim_d0100_fdescr_ini.
  fdescr_wa-name = 'VIM_D0100_WORKAREA-KEY9'.
  APPEND fdescr_wa TO vim_d0100_fdescr_ini.
  fdescr_wa-name = 'VIM_D0100_WORKAREA-KEY10'.
  APPEND fdescr_wa TO vim_d0100_fdescr_ini.
* Sprache
  fdescr_wa-vislength = 10.
  fdescr_wa-active = 'X'.
  fdescr_wa-name = 'VIM_D0100_WORKAREA-SPTXT'.
  APPEND fdescr_wa TO vim_d0100_fdescr_ini.
* Texte
  fdescr_wa-name = 'VIM_D0100_WORKAREA-TEXT1'.
  fdescr_wa-textfld = 'X'.
  APPEND fdescr_wa TO vim_d0100_fdescr_ini.
  CLEAR fdescr_wa-active.
  fdescr_wa-textfld = 'X'.
  fdescr_wa-name = 'VIM_D0100_WORKAREA-TEXT2'.
  APPEND fdescr_wa TO vim_d0100_fdescr_ini.
  fdescr_wa-name = 'VIM_D0100_WORKAREA-TEXT3'.
  APPEND fdescr_wa TO vim_d0100_fdescr_ini.
  fdescr_wa-name = 'VIM_D0100_WORKAREA-TEXT4'.
  APPEND fdescr_wa TO vim_d0100_fdescr_ini.
  fdescr_wa-name = 'VIM_D0100_WORKAREA-TEXT5'.
  APPEND fdescr_wa TO vim_d0100_fdescr_ini.
  fdescr_wa-name = 'VIM_D0100_WORKAREA-TEXT6'.
  APPEND fdescr_wa TO vim_d0100_fdescr_ini.
  fdescr_wa-name = 'VIM_D0100_WORKAREA-TEXT7'.
  APPEND fdescr_wa TO vim_d0100_fdescr_ini.
  fdescr_wa-name = 'VIM_D0100_WORKAREA-TEXT8'.
  APPEND fdescr_wa TO vim_d0100_fdescr_ini.
ENDFORM.                               " VIM_INITIALIZE_D0100

*---------------------------------------------------------------------*
*       FORM VIM_ACTUALIZE_D0100                                      *
*---------------------------------------------------------------------*
* Attribute für Dynprofelder für aktuellen View aktualisieren         *
* (bzw. der ausgewählten Textfelder, falls mehr als 8 ex.             *
*          !!! noch nicht unterstützt  !!!                )           *
*---------------------------------------------------------------------*
FORM vim_actualize_d0100.
  DATA: fdescr_wa TYPE vimty_screen_fdescr,
        next_tabix LIKE sy-tabix,
        nr_of_field TYPE i,
        tot_keylen TYPE i,
        vislen_0(1) TYPE c,
        max_textlen TYPE i,
        tmp_len TYPE i,
        nr_of_text TYPE i.
  FIELD-SYMBOLS: <title> LIKE vimnamtab-scrtext.            "#EC *

  PERFORM vim_select_textfields.
  CLEAR: max_textlen, nr_of_text.
  LOOP AT x_namtab WHERE textfldsel = 'X'.
    nr_of_text = nr_of_text + 1.
    IF max_textlen < x_namtab-outputlen.
      max_textlen = x_namtab-outputlen.
    ENDIF.
  ENDLOOP.
  IF max_textlen > 30. max_textlen = 30. ENDIF.

  CLEAR: tot_keylen, nr_of_field, vislen_0.
  LOOP AT x_namtab WHERE keyflag = 'X' AND texttabfld <> 'X'.
    CHECK x_namtab-datatype <> 'CLNT' OR x_namtab-position > 0.
    CHECK x_namtab-readonly <> 'S' AND x_namtab-readonly <> 'H'.
    CHECK x_header-delmdtflag = space OR x_header-ptfrkyexst = space OR
          x_namtab-domname <> vim_delim_date_domain OR
          ( x_namtab-rollname NOT IN vim_begda_types AND
            x_namtab-rollname NOT IN vim_endda_types ).
    nr_of_field = nr_of_field + 1.
    tot_keylen = tot_keylen + x_namtab-outputlen.
    IF nr_of_field <= vim_max_keyfields.
      READ TABLE vim_d0100_fdescr_ini INDEX nr_of_field INTO fdescr_wa.
      fdescr_wa-title = x_namtab-scrtext.
      fdescr_wa-active = 'X'.
      fdescr_wa-fixlength = x_namtab-outputlen.
      tmp_len = tot_keylen + max_textlen.
      IF vislen_0 = 'X'.
        fdescr_wa-vislength = 0.
      ELSEIF tmp_len  > 70.            "???
        fdescr_wa-vislength = 70 - max_textlen -
                                 ( tot_keylen - x_namtab-outputlen ).
        vislen_0 = 'X'.
        IF fdescr_wa-vislength < 0.
          fdescr_wa-vislength = 0.
        ENDIF.
      ELSE.
        fdescr_wa-vislength = fdescr_wa-fixlength.
      ENDIF.
      IF nr_of_field < vim_max_keyfields.
        MODIFY vim_d0100_fdescr_ini FROM fdescr_wa INDEX nr_of_field.
      ENDIF.
    ELSE.
      fdescr_wa-fixlength = fdescr_wa-fixlength + x_namtab-outputlen + 1.
    ENDIF.
  ENDLOOP.
  IF nr_of_field >= vim_max_keyfields.
    fdescr_wa-title = '...'.
    fdescr_wa-active = 'X'.
    fdescr_wa-vislength = 0.
    MODIFY vim_d0100_fdescr_ini FROM fdescr_wa INDEX vim_max_keyfields.
  ELSE.
    next_tabix = nr_of_field + 1.
    LOOP AT vim_d0100_fdescr_ini INTO fdescr_wa
            FROM next_tabix TO vim_max_keyfields.
      CLEAR fdescr_wa-active.
      fdescr_wa-fixlength = 0.
      fdescr_wa-vislength = 0.
      CLEAR fdescr_wa-title.
      MODIFY vim_d0100_fdescr_ini FROM fdescr_wa.
    ENDLOOP.
  ENDIF.
  next_tabix = vim_max_keyfields + 1.                       "Sprachfeld

  LOOP AT x_namtab WHERE textfldsel = 'X'.
    IF x_namtab-readonly = space OR x_namtab-readonly = 'R'."SW 25.3.97
      next_tabix = next_tabix + 1.
      READ TABLE vim_d0100_fdescr_ini INDEX next_tabix INTO fdescr_wa.
      IF x_namtab-readonly = space.    "SW 25.3.1997
        fdescr_wa-active = 'X'.
      ELSEIF x_namtab-readonly = 'R'.  "SW 25.3.1997 ..
        fdescr_wa-active = 'R'.
      ENDIF.                           ".. SW 25.3.1997
      fdescr_wa-title = x_namtab-scrtext.
      fdescr_wa-fixlength = x_namtab-outputlen.
      fdescr_wa-vislength = x_namtab-outputlen.
      MODIFY vim_d0100_fdescr_ini FROM fdescr_wa INDEX next_tabix.
    ENDIF.
  ENDLOOP.

  next_tabix = next_tabix + 1.
  LOOP AT vim_d0100_fdescr_ini INTO fdescr_wa FROM next_tabix.
    CLEAR fdescr_wa-active.
    fdescr_wa-fixlength = 0.
    fdescr_wa-vislength = 0.
    CLEAR fdescr_wa-title.
    MODIFY vim_d0100_fdescr_ini FROM fdescr_wa.
  ENDLOOP.
ENDFORM.                               "VIM_ACTUALIZE_D0100

*---------------------------------------------------------------------*
*       FORM VIM_READ_TEXTTAB_FOR_LANGUS                              *
*---------------------------------------------------------------------*
* Texteinträge von der DB nachlesen für alle Sprachen, für die noch   *
* nicht eingelesen wurde                                              *
*---------------------------------------------------------------------*
* --> SEL_LANGUS         ausgewählte Sprachen
* --> ALL_LANGUS         'X' alle Sprachen wurden ausgewählt
*---------------------------------------------------------------------*
FORM vim_read_texttab_for_langus TABLES sel_langus STRUCTURE h_t002
                                 USING all_langus TYPE c.
  DATA: diff_langus_exist(1) TYPE c,
        diff_langus LIKE h_t002 OCCURS 0 WITH HEADER LINE.

  IF vim_texttab_container-all_langus = 'X'. EXIT. ENDIF. "alles eingel.

  vim_texttab_container-all_langus = all_langus.
  REFRESH diff_langus. CLEAR diff_langus_exist.
  LOOP AT sel_langus.
    READ TABLE <vim_read_langus> WITH KEY sel_langus-spras              "#EC *
                            TRANSPORTING NO FIELDS BINARY SEARCH.
    IF sy-subrc <> 0.
      INSERT sel_langus-spras INTO <vim_read_langus> INDEX sy-tabix.
      diff_langus = sel_langus-spras.
      APPEND diff_langus.
      diff_langus_exist = 'X'.
    ENDIF.
  ENDLOOP.

  IF diff_langus_exist = 'X' OR all_langus = 'X'.
    IF diff_langus_exist = 'X'.
      PERFORM vim_get_texttab_data TABLES diff_langus
                                 CHANGING <vim_texttab>.
    ENDIF.
    MODIFY vim_texttab_container INDEX vim_texttab_container_index.
*                        wegen <vim_read_langus> und <vim_texttab>
  ENDIF.
ENDFORM.                               " VIM_READ_TEXTTAB_FOR_LANGUS

*---------------------------------------------------------------------*
*       FORM VIM_FILL_TEXTTAB_FOR_MAINT                               *
*---------------------------------------------------------------------*
* Die zur Texterfassung in anderen Sprachen ausgewählten Texte werden *
* (anhand der markierten Einträge sowie der ausgewählten Sprachen)    *
* in die Tabelle zur Verarbeitung auf dem Dynpro übernommen.          *
*---------------------------------------------------------------------*
* --> SEL_LANGUS         ausgewählte Sprachen
* --> CURR_SPTXT         SPTXT von Sy-Langu
* <-- TEXTTAB_FOR_MAINT  Verarbeitungstabelle der ausgewählten Texte
*                        auf dem Dynpro
*---------------------------------------------------------------------*
FORM vim_fill_texttab_for_maint TABLES sel_langus STRUCTURE h_t002
               USING curr_sptxt LIKE t002t-sptxt
               CHANGING texttab_for_maint TYPE vimty_multilangu_texttab.

  DATA: textmaint_record TYPE vimty_textmaint_record,
        textmaint_field TYPE vimty_textfield,
        align1 TYPE f,
        texttab_wa TYPE vim_line_ul,
        align2 TYPE f,
        tmp_wa TYPE tabl8000,
        condense(1) TYPE c,
        texttab_tabix LIKE sy-tabix,
        extract_index LIKE sy-tabix,
        keylen TYPE i,
        rc LIKE sy-subrc,                                   "875536
        keys_identical TYPE xfeld.
  DATA: primkeylen TYPE i.
  FIELD-SYMBOLS: <extract_key> TYPE x,
                 <next_spras> TYPE spras,
                 <text_rec_key> TYPE x, <h_texttab_wa> TYPE x,
                 <viewkey_in_texttab> TYPE x, <txtfld> TYPE ANY,
                 <h_tmp> TYPE x, <tmp_struc> TYPE ANY,
                 <h_texttab> TYPE x, <texttab_struc> TYPE ANY.
  FIELD-SYMBOLS: <extract_primkey> TYPE x.

  IF x_header-delmdtflag <> space AND  "zeitabh. & part. Fremdschl.
     x_header-ptfrkyexst  = 'X'.       "      -> zeitunabh. Texttab.
    condense = 'X'.
    ASSIGN <vim_ext_mkey_beforex> TO <extract_key>.
*    ASSIGN <vim_ext_mkey_before> TO <extract_key>.
    keylen = x_header-after_keyc
     - vim_datum_length * cl_abap_char_utilities=>charsize.
*    keylen = x_header-keylen - vim_datum_length.
    CLEAR <vim_old_mkey_beforex>.
  ELSE.
    ASSIGN <vim_xextract_key> TO <extract_key>.
    keylen = x_header-after_keyc.
*    keylen = x_header-keylen.
    CLEAR condense.
  ENDIF.
* In case of viewkey > primtabkey -> additional key fields are filled
* in <extract_key> but not existent in <vim_texttab> "HCG 09/02/2005
*  primkeylen = x_header-textkeylen - cl_abap_char_utilities=>charsize.
  IF x_header-bastab EQ space.                              "875536
    CLEAR keys_identical.
    PERFORM vim_comp_roottabkey USING x_header
                                      x_namtab[]
                             CHANGING keys_identical
                                      rc.
* CUST. MSG.104177 2008 CHG.DT.31/07/2008.
* START OF CHANGE
*   IF keys_identical EQ SPACE.
    IF keys_identical EQ 'X'.
* END OF CHANGE
      primkeylen = keylen.
    ELSE.
      clear primkeylen.
      LOOP AT x_namtab WHERE keyflag = 'X' AND
                           bastabname = x_header-roottab.
        IF x_namtab-DATATYPE NE 'DATS'.
          primkeylen = primkeylen + x_namtab-FLENGTH.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ELSE.
    primkeylen = x_header-keylen.
  ENDIF.                                                    "875536
  ASSIGN: texttab_wa TO <h_texttab_wa> CASTING.
  IF keylen < primkeylen.
    ASSIGN <h_texttab_wa>(keylen) TO <viewkey_in_texttab>.
  ELSE.
    ASSIGN <h_texttab_wa>(primkeylen) TO <viewkey_in_texttab>.
  ENDIF.
*          texttab_wa+keylen(x_header-textkeylen) TO <texttab_key>,
  ASSIGN: <h_texttab_wa>+keylen(x_header-texttablen) TO <h_texttab>,
          tmp_wa+keylen(x_header-texttablen)
           TO <h_tmp>,
          <h_texttab> TO <texttab_struc>
           CASTING TYPE (x_header-texttab),
          <h_tmp> TO <tmp_struc> CASTING TYPE (x_header-texttab),
          COMPONENT x_header-sprasfield OF STRUCTURE <texttab_struc>
           TO <next_spras>,
           textmaint_record-keys TO <text_rec_key> CASTING.
*  ASSIGN texttab_wa+offset(vim_spras_length) TO <next_spras>.
  IF status-mode = list_bild.
    extract_index = 1.
  ELSE.
    extract_index = nextline.
  ENDIF.

  LOOP AT extract FROM extract_index.  "Loop für Detail nicht nötig
    CHECK status-mode = detail_bild OR <xmark> = markiert.
    CHECK condense = ' ' OR
          <vim_old_mkey_beforex> <> <vim_ext_mkey_beforex>.
    IF condense = 'X'.
      <vim_old_mkey_beforex> = <vim_ext_mkey_beforex>.
    ENDIF.
*   Texte in Sy-Langu
    CLEAR textmaint_record.
    <text_rec_key> = <extract_key>.
*    textmaint_record-keys = <extract_key>.
    PERFORM vim_external_repr_for_key TABLES textmaint_record-keytab
                                      USING <vim_xextract_key>.
    textmaint_record-spras = sy-langu.
    textmaint_record-sptxt = curr_sptxt.
    IF x_header-bastab = space.
* view
      LOOP AT x_namtab WHERE textfldsel = 'X'.
        textmaint_field-namtab_idx = sy-tabix.
        textmaint_field-outplen = x_namtab-flength.
        ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE
         <vim_extract_struc> TO <txtfld>.
        textmaint_field-text = <txtfld>.
*      textmaint_field-text(x_namtab-flength) =
*                          extract+x_namtab-position(x_namtab-flength).
        APPEND textmaint_field TO textmaint_record-texttab.
      ENDLOOP.
    ELSE.
* tab + texttab
      LOOP AT x_namtab WHERE textfldsel = 'X'.
        textmaint_field-namtab_idx = sy-tabix.
        textmaint_field-outplen = x_namtab-flength.
        ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE
         <vim_ext_txt_struc> TO <txtfld>.
        textmaint_field-text = <txtfld>.
*      textmaint_field-text(x_namtab-flength) =
*                          extract+x_namtab-position(x_namtab-flength).
        APPEND textmaint_field TO textmaint_record-texttab.
      ENDLOOP.
    ENDIF.
    APPEND textmaint_record TO texttab_for_maint.

*   Texte in ausgewählten Sprachen
************************************************************************
    CLEAR: <viewkey_in_texttab>, <texttab_struc>.
*    CLEAR texttab_wa.
*   In case of viewkey > primtabkey -> additional key fields are filled
*   in <extract_key> but not existent in <vim_texttab>  "HCG 09/02/2005
    IF keylen < primkeylen.
      ASSIGN <extract_key>(keylen) TO <extract_primkey>.
    ELSE.
      ASSIGN <extract_key>(primkeylen) TO <extract_primkey>.
    ENDIF.
*    READ TABLE <vim_texttab> WITH KEY <extract_key>
*                               INTO texttab_wa. " BINARY SEARCH.
    READ TABLE <vim_texttab> WITH KEY <extract_primkey>                       "#EC *
                               INTO texttab_wa. " BINARY SEARCH.
    texttab_tabix = sy-tabix.
    LOOP AT sel_langus.
      CLEAR textmaint_record.
      <text_rec_key> = <extract_key>.
*      textmaint_record-keys = <extract_key>.             "SW Langtext
      textmaint_record-spras = sel_langus-spras.
      textmaint_record-sptxt = sel_langus-sptxt.

*      IF <viewkey_in_texttab> = <extract_key> AND             "817790
      IF <viewkey_in_texttab> = <extract_primkey> AND       "817790
         <next_spras> < sel_langus-spras.                 "#EC PORTABLE
        LOOP AT <vim_texttab> FROM texttab_tabix INTO texttab_wa.
*          IF <viewkey_in_texttab> <> <extract_key> OR         "817790
          IF <viewkey_in_texttab> <> <extract_primkey> OR   "817790
             <next_spras> >= sel_langus-spras.            "#EC PORTABLE
            texttab_tabix = sy-tabix.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.   " <next_spras> >= sel_langus-spras oder ex. nicht
      IF <next_spras> <> sel_langus-spras OR
*         <viewkey_in_texttab> <> <extract_key>.    "HCG 09/02/2005
          <viewkey_in_texttab> <> <extract_primkey>."langu:text not ex
        CLEAR <tmp_struc>.
*        CLEAR tmp_wa.
      ELSE.
        tmp_wa = <h_texttab_wa>.
      ENDIF.
      LOOP AT x_namtab WHERE textfldsel = 'X'.
        textmaint_field-namtab_idx = sy-tabix.
        textmaint_field-outplen = x_namtab-flength.
*        ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE
        ASSIGN COMPONENT x_namtab-bastabfld OF STRUCTURE     "HCG wrong
         <tmp_struc> TO <txtfld>.   "HCG for txtfldname in view differs
        textmaint_field-text = <txtfld>.
*        offset = keylen + x_namtab-texttabpos.
*        textmaint_field-text(x_namtab-flength) =
*                   tmp_wa+offset(x_namtab-flength).
        APPEND textmaint_field TO textmaint_record-texttab.
      ENDLOOP.
      APPEND textmaint_record TO texttab_for_maint.
    ENDLOOP.                           " SEL_LANGUS

    IF status-mode = detail_bild. EXIT. ENDIF.
  ENDLOOP.                                                  " EXTRACT
ENDFORM.                               " VIM_FILL_TEXTTAB_FOR_MAINT

*&--------------------------------------------------------------------*
*&      Form  VIM_EXTERNAL_REPR_FOR_KEY                               *
*&--------------------------------------------------------------------*
* --> INT_KEY    Interne Darstellung der Schlüsselfelder
* <-- KEYTAB     Tabelle, externe      "
*&--------------------------------------------------------------------*
FORM vim_external_repr_for_key TABLES keytab "TYPE VIMTY_TEXTFIELD
                               USING int_key TYPE x.
  DATA: keynr TYPE i,
        keyfield TYPE vimty_textfield,
        namtab_idx LIKE sy-tabix.
  FIELD-SYMBOLS: <i_value> TYPE ANY, <e_value> TYPE c.

  CLEAR: keynr, keyfield. REFRESH keytab.
  MOVE int_key TO <table1_wax>.
  LOOP AT x_namtab WHERE keyflag = 'X' AND texttabfld <> 'X'.
    namtab_idx = sy-tabix.
*   Mandant nicht anzeigen
    CHECK x_namtab-datatype <> 'CLNT' OR x_header-clidep = space.
*   Subset- und Readonly-Felder nicht anzeigen
    CHECK x_namtab-readonly <> 'S' AND x_namtab-readonly <> 'H'.
*   Datum bei zeitunabh. Texttabelle nicht anzeigen
    CHECK x_header-delmdtflag = space OR x_header-ptfrkyexst = space OR
          x_namtab-domname <> vim_delim_date_domain OR
          ( x_namtab-rollname NOT IN vim_begda_types AND
            x_namtab-rollname NOT IN vim_endda_types ).
    keynr = keynr + 1.
    IF keynr > vim_max_keyfields.
      keyfield-text+keyfield-outplen(1) = '|'.
      keyfield-outplen = keyfield-outplen + 1.
    ENDIF.
    ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE <table1_wa>
     TO <i_value>.
*    ASSIGN int_key+x_namtab-position(x_namtab-flength) TO <i_value>.
    ASSIGN keyfield-text+keyfield-outplen(x_namtab-outputlen)
                                                       TO <e_value>.
    CALL FUNCTION 'VIEW_CONVERSION_OUTPUT'
      EXPORTING
        value_intern = <i_value>
        tabname      = x_header-maintview
        fieldname    = x_namtab-viewfield
        outputlen    = x_namtab-outputlen
        intlen       = x_namtab-flength
      IMPORTING
        value_extern = <e_value>.

    IF keynr < vim_max_keyfields.
      keyfield-namtab_idx = namtab_idx.
      keyfield-outplen = x_namtab-outputlen.
      APPEND keyfield TO keytab.
      CLEAR keyfield.
    ELSE.
      keyfield-outplen = keyfield-outplen + x_namtab-outputlen.
    ENDIF.
  ENDLOOP.

  IF keynr >= vim_max_keyfields.
    APPEND keyfield TO keytab.
  ENDIF.
ENDFORM.                               "VIM_EXTERNAL_REPR_FOR_KEY

*&--------------------------------------------------------------------*
*&      Form  VIM_FILL_TEXTTAB_KEY                                    *
*&--------------------------------------------------------------------*
* UF210800: Not unicode-compatible: Please use form
* MAP_VIEWKEY_TO_TEXTTABKEY instead
*
*&--------------------------------------------------------------------*
* --> VIEW_WA  WA of view                                             *
* --> SPRAS    Sprachschlüssel                                        *
* --> SPRAS_POS Position des Sprachschlüssel in VIEW_WA
* <-- TEXT_WA  Key of text table                                      *
*&--------------------------------------------------------------------*
*FORM vim_fill_texttab_key USING view_wa
*                                spras LIKE t002-spras
*                                spras_pos LIKE vimdesc-sprasfdpos
*                       CHANGING text_wa.
*
** Sprachschlüssel
** TEXT_WA+X_HEADER-SPRASFDPOS(VIM_SPRAS_LENGTH) = SPRAS.
*  text_wa+spras_pos(vim_spras_length) = spras.
** Schlüsselfelder der Text-Tabelle
*  LOOP AT x_namtab WHERE txttabfldn <> space AND keyflag <> space.
*    text_wa+x_namtab-texttabpos(x_namtab-flength) =
*         view_wa+x_namtab-position(x_namtab-flength).
*  ENDLOOP.
*ENDFORM.                               "VIM_FILL_TEXTTAB_KEY
*
*&--------------------------------------------------------------------*
*&      Form  VIM_FILL_VIEW_KEY                                       *
*&--------------------------------------------------------------------*
* Not usable in unicode-systems!!!!
* Please use form MAP_TEXTTABKEY_TO_VIEWKEY instead!
*&--------------------------------------------------------------------*
* --> TEXTTAB_WA  WA of text table                                    *
* <-- VIEW_KEY    KEY of view / table                                 *
* <-- SPRAS                                                           *
*&--------------------------------------------------------------------*
FORM vim_fill_view_key USING texttab_wa TYPE vim_line_ul
                   CHANGING view_key
                            spras LIKE t002-spras.

  LOOP AT x_namtab WHERE txttabfldn <> space AND keyflag <> space.
*   alle Schlüsselfelder, zu denen es Felder in der Texttabelle gibt
    view_key+x_namtab-position(x_namtab-flength) =
         texttab_wa+x_namtab-texttabpos(x_namtab-flength).
  ENDLOOP.
  spras = texttab_wa+x_header-sprasfdpos(vim_spras_length).
ENDFORM.                               "VIM_FILL_VIEW_KEY

*---------------------------------------------------------------------*
*       FORM VIM_UPDATE_TEXTTAB                                       *
*---------------------------------------------------------------------*
* Die vom Benutzer erfaßten/geänderten Texte  werden in die interne   *
* Texttabelle <VIM_TEXTTAB> übernommen                                *
*---------------------------------------------------------------------*
FORM vim_update_texttab
                USING texttab_for_maint TYPE vimty_multilangu_texttab.
  DATA: textmaint_record TYPE vimty_textmaint_record,
        textmaint_field TYPE vimty_textfield,
        align TYPE f,
        texttab_wa TYPE vim_line_ul,
        search_key TYPE tabl8000,
        offset LIKE sy-fdpos,
        keylen LIKE sy-fdpos,
        extract_index LIKE sy-tabix,
        total_index   LIKE sy-tabix,
        texttab_tabix LIKE sy-tabix,
        new_entry(1)  TYPE c,
        keylen_char TYPE i,
        primkeylen type i,                                  "817790
        rc LIKE sy-subrc,                                   "875536
        keys_identical TYPE xfeld.
  FIELD-SYMBOLS:
        <search_key> TYPE x, <rec_key> TYPE x, <curr_spras> TYPE ANY,
        <h_texttab_wa> TYPE x,
        <viewkey_in_texttab> TYPE x, "Key aus View/Tab in Texttab
        <texttab_key> TYPE x, <texttab_struc> TYPE ANY,
        <h_texttab> TYPE x, <tot_fld> TYPE ANY, <ext_fld> TYPE ANY,
        <texttab_action> TYPE c,
        <t_action>, <e_action>,
        <search_txtkey> type x.                             "817790

  IF x_header-delmdtflag <> space AND     "zeitabh. & part. Fremdschl.
     x_header-ptfrkyexst  = 'X'.          "      -> zeitunabh. Texttab.
    keylen = x_header-after_keyc
     - vim_datum_length * cl_abap_char_utilities=>charsize.
  ELSE.
    keylen = x_header-after_keyc.
  ENDIF.
  keylen_char = keylen / cl_abap_char_utilities=>charsize.
*  primkeylen = x_header-textkeylen - cl_abap_char_utilities=>charsize."817790
  IF x_header-bastab EQ space.                              "875536
    CLEAR keys_identical.
    PERFORM vim_comp_roottabkey USING x_header
                                      x_namtab[]
                             CHANGING keys_identical
                                      rc.
    IF keys_identical EQ space.
      primkeylen = keylen.
    ELSE.
      clear primkeylen.
      LOOP AT x_namtab WHERE keyflag = 'X' AND
                           bastabname = x_header-roottab.
        IF x_namtab-DATATYPE NE 'DATS'.
          primkeylen = primkeylen + x_namtab-FLENGTH.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ELSE.
    primkeylen = x_header-keylen.
  ENDIF.                                                    "875536

  ASSIGN: search_key(keylen) TO <search_key>,
          textmaint_record-keys(keylen_char) TO <rec_key> CASTING,
          texttab_wa TO <h_texttab_wa> CASTING,
          <h_texttab_wa>(keylen) TO <viewkey_in_texttab>,
          <h_texttab_wa>+keylen(x_header-textkeylen) TO <texttab_key>,
          <h_texttab_wa>+keylen(x_header-texttablen) TO <h_texttab>,
          <h_texttab> TO <texttab_struc>
           CASTING TYPE (x_header-texttab),
          COMPONENT x_header-sprasfield OF STRUCTURE <texttab_struc>
           TO <curr_spras>.
  IF keylen < primkeylen.                                   "875536
    ASSIGN search_key(keylen) TO <search_txtkey>.
  ELSE.
    ASSIGN search_key(primkeylen) TO <search_txtkey>.       "817790
  ENDIF.

  offset = keylen + x_header-aft_txttbc.
  ASSIGN <h_texttab_wa>+offset(cl_abap_char_utilities=>charsize)
   TO <texttab_action> CASTING.
  IF x_header-bastab = 'X'.
* tab+texttab
    ASSIGN <action_text> TO <t_action>.
    ASSIGN <xact_text> TO <e_action>.
  ELSE.
    ASSIGN <action> TO <t_action>.
    ASSIGN <xact> TO <e_action>.
  ENDIF.

  LOOP AT texttab_for_maint INTO textmaint_record.
    IF textmaint_record-spras = sy-langu.
      <search_key> = <rec_key>.
      READ TABLE extract WITH KEY <search_key> BINARY SEARCH.   "#EC *
      extract_index = sy-tabix.
    ENDIF.
    CHECK textmaint_record-action = 'X'.      " Texte wurden modifiziert

    IF textmaint_record-spras = sy-langu.
*     Texte in Sy-Langu  => Update in Total und Extract
*      READ TABLE EXTRACT WITH KEY <SEARCH_KEY> BINARY SEARCH.
*      EXTRACT_INDEX = SY-TABIX.
      READ TABLE total WITH KEY <search_key> BINARY SEARCH.   "#EC *
      total_index = sy-tabix.
      IF x_header-bastab = 'X'
       AND <vim_xextract_text> = <text_initial_x>.
        PERFORM map_viewkey_to_texttabkey TABLES x_namtab
                                          USING x_header
                                                sy-langu
                                                <vim_xtotal>
                                          CHANGING <vim_xextract_text>.
        PERFORM map_viewkey_to_texttabkey TABLES x_namtab
                                          USING x_header
                                                sy-langu
                                                <vim_xtotal>
                                          CHANGING <vim_xtotal_text>.
*        PERFORM vim_fill_texttab_key USING <search_key> sy-langu
*                                           x_header-sprasfdpos
*                                  CHANGING <extract_text>.
*        PERFORM vim_fill_texttab_key USING <search_key> sy-langu
*                                           x_header-sprasfdpos
*                                  CHANGING <total_text>.
        <e_action> = neuer_eintrag.
        <t_action> = neuer_eintrag.
      ELSEIF <e_action> = original.
        <e_action> = aendern.
        <t_action> = aendern.
*     Else.                     " neuer_eintrag / aendern => ok
      ENDIF.
      LOOP AT textmaint_record-texttab INTO textmaint_field.
        READ TABLE x_namtab INDEX textmaint_field-namtab_idx.
        IF x_namtab-lowercase = space.
          TRANSLATE textmaint_field-text TO UPPER CASE.
        ENDIF.
        IF x_header-bastab = 'X'.
* tab + texttab
          ASSIGN: COMPONENT x_namtab-viewfield OF STRUCTURE
                   <vim_ext_txt_struc> TO <ext_fld>,
                  COMPONENT x_namtab-viewfield OF STRUCTURE
                   <vim_tot_txt_struc> TO <tot_fld>.
        ELSE.
* view
          ASSIGN: COMPONENT x_namtab-viewfield OF STRUCTURE
                   <vim_extract_struc> TO <ext_fld>,
                  COMPONENT x_namtab-viewfield OF STRUCTURE
                   <vim_total_struc> TO <tot_fld>.
        ENDIF.
        <tot_fld> = textmaint_field-text.
        <ext_fld> = textmaint_field-text.
*        extract+x_namtab-position(x_namtab-flength) =
*           textmaint_field-text(x_namtab-flength).
*        total+x_namtab-position(x_namtab-flength) =
*           textmaint_field-text(x_namtab-flength).
      ENDLOOP.                         "TEXTMAINT_RECORD-TEXTTAB
      MODIFY extract INDEX extract_index.
      MODIFY total INDEX total_index.

    ELSE.
* different language: Update in texttable
      CLEAR: <h_texttab_wa>, <texttab_struc>.
*      READ TABLE <vim_texttab> WITH KEY <search_key>            "817790
*                               INTO texttab_wa BINARY SEARCH.   "817790
      READ TABLE <vim_texttab> WITH KEY <search_txtkey>           "#EC * "817790
                               INTO texttab_wa BINARY SEARCH."817790

      texttab_tabix = sy-tabix.
*     IF <viewkey_in_texttab> = <search_key> AND   "Text ex. in and. Spr "817790
      IF keylen < primkeylen.                               "875536
        primkeylen = keylen.                                "875536
      ENDIF.                                                "875536
      IF <viewkey_in_texttab>(primkeylen) = <search_txtkey> AND"817790
         <curr_spras> < textmaint_record-spras.
        LOOP AT <vim_texttab> FROM texttab_tabix INTO texttab_wa.
*          IF <viewkey_in_texttab> <> <search_key> OR                         "817790
          IF <viewkey_in_texttab>(primkeylen) <> <search_txtkey> OR"817790
             <curr_spras> >= textmaint_record-spras.
            texttab_tabix = sy-tabix.
            EXIT.
* Condition redundant - Internal Message 0001699060 - ACHACHADI
*          ELSEIF <curr_spras> < textmaint_record-spras.
            ELSE.
            texttab_tabix = sy-tabix + 1.
          ENDIF.
        ENDLOOP.
      ENDIF.   " <next_spras> >= sel_langus-spras oder ex. nicht
*      IF <viewkey_in_texttab> <> <search_key> OR                            "817790
      IF <viewkey_in_texttab>(primkeylen) <> <search_txtkey> OR"817790
        <curr_spras> <> textmaint_record-spras.
        CLEAR: <texttab_struc>.
*        CLEAR texttab_wa.
        new_entry = 'X'.
        <viewkey_in_texttab> = <search_key>.
*        texttab_wa = <search_key>.
        <texttab_action> = neuer_eintrag.
        PERFORM map_viewkey_to_texttabkey TABLES x_namtab
                                          USING x_header
                                                textmaint_record-spras
                                                <viewkey_in_texttab>
                                          CHANGING <texttab_key>.
**        PERFORM vim_fill_texttab_key
*                            USING <search_key> textmaint_record-spras
*                                  x_header-sprasfdpos
*                            CHANGING <texttab_key>.
      ELSE.
        CLEAR new_entry.
      ENDIF.
*     Text-Values übernehmen
      LOOP AT textmaint_record-texttab INTO textmaint_field.
        READ TABLE x_namtab INDEX textmaint_field-namtab_idx.
*        offset = keylen + x_namtab-texttabpos.
        IF x_namtab-lowercase = space.
          TRANSLATE textmaint_field-text TO UPPER CASE.
        ENDIF.
        IF x_header-bastab = 'X'."HCG Custmessage 282684/02------------
* tab + texttab
          ASSIGN: COMPONENT x_namtab-viewfield OF STRUCTURE
*                   <vim_ext_txt_struc> TO <ext_fld>.
                   <texttab_struc> TO <ext_fld>. "XB int.40684/02
        ELSE.
* view, basis table field name.
          ASSIGN: COMPONENT x_namtab-bastabfld OF STRUCTURE
*                   <vim_extract_struc> TO <ext_fld>.
                   <texttab_struc> TO <ext_fld>. "XB int.. 40684
        ENDIF.
*        ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE
*---------      <texttab_struc> TO <ext_fld>."HCG Custmessage 282684/02
        <ext_fld> = textmaint_field-text.
*        texttab_wa+offset(x_namtab-flength) =
*           textmaint_field-text(x_namtab-flength).
      ENDLOOP.
      IF <texttab_action> = original.
        <texttab_action> = aendern.
      ENDIF.
      IF new_entry = 'X'.
        INSERT texttab_wa INTO <vim_texttab> INDEX texttab_tabix.
      ELSE.
        MODIFY <vim_texttab> FROM texttab_wa INDEX texttab_tabix.
      ENDIF.

    ENDIF.                             " Sy-Langu
  ENDLOOP.                             " TEXTTAB_FOR_MAINT

ENDFORM.                               " VIM_UPDATE_TEXTTAB

*---------------------------------------------------------------------*
*       FORM VIM_TEMP_DELIM_TEXTTAB                                   *
*---------------------------------------------------------------------*
* Abgrenzen für zeitabh. Texttabelle :                                *
*    neuen Eintrag für <vim_xtotal_key> für alle Sprachen in
*      Texttabelle erzeugen, bzw. -falls schon ex.- Texte darin ersetzen
*      Texte werden aus Originaleintrag ORIG_KEY übernommen
*    im Eintrag ENDDATE Texte löschen;
*      falls dieser neu ist -> gesammten Eintrag löschen
*---------------------------------------------------------------------*
* <vim_xtotal_key> = aktuell bearb. Intervall, entstanden durch
*                    Abgrenzen
* --> ENDDATE   Endedatum des neuen Intervalls
* --> ORIG_KEY  altes Endedatum des aktuellen Intervalls vor Abgrenzen
*---------------------------------------------------------------------*
FORM vim_temp_delim_texttab USING value(enddate)
                                  value(orig_key) TYPE x.
  DATA: texttab_orig TYPE vim_line_ul,
        texttab_new  TYPE vim_line_ul,
        align        TYPE f,
        old_key      TYPE tabl8000,
        orig_tabix LIKE sy-tabix,
        new_tabix  LIKE sy-tabix,
        len TYPE i,
        offset TYPE i,
        langus_selected(1) TYPE c,
        curr_sptxt LIKE t002t-sptxt,
        sel_langus LIKE h_t002 OCCURS 0 WITH HEADER LINE.
  FIELD-SYMBOLS: <texttab_orig_x> TYPE x,
                 <txttb_orig_struc> TYPE ANY,
                 <viewkey_in_orig> TYPE x,    "-> texttab_orig
                 <texttab_new_x> TYPE x,
                 <txttb_new_struc> TYPE ANY,
                 <viewkey_in_new> TYPE x,     "-> texttab_new
                 <spras_in_orig> TYPE spras,
                 <spras_in_new> TYPE spras,
                 <date_in_textkey_new> LIKE sy-datum,
                 <action_in_orig>,
                 <action_in_new>,
                 <textfields_in_new> TYPE x,
                 <textfields_in_orig> TYPE x,
                 <h_old_key> TYPE x, <old_key_enddate> LIKE sy-datum,
                 <old_keyx> TYPE x, <old_key_struc> TYPE ANY.

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
    PERFORM vim_read_texttab_for_langus TABLES sel_langus USING 'X'.
  ENDIF.

  READ TABLE <vim_texttab> WITH KEY orig_key                          "#EC *
                           BINARY SEARCH TRANSPORTING NO FIELDS.
  CHECK sy-subrc = 0.
  orig_tabix = sy-tabix.
  ASSIGN: texttab_orig TO <texttab_orig_x> CASTING,
          <texttab_orig_x>(x_header-keylen) TO <viewkey_in_orig>,
          <texttab_orig_x>+x_header-after_keyc
           TO <txttb_orig_struc> CASTING TYPE (x_header-texttab),
          COMPONENT x_header-sprasfield OF STRUCTURE <txttb_orig_struc>
           TO <spras_in_orig>.
  ASSIGN: texttab_new TO <texttab_new_x> CASTING,
          <texttab_new_x>(x_header-keylen) TO <viewkey_in_new>,
          <texttab_new_x>+x_header-after_keyc
           TO <txttb_new_struc> CASTING TYPE (x_header-texttab),
          COMPONENT x_header-sprasfield OF STRUCTURE <txttb_new_struc>
           TO <spras_in_new>.
  offset = x_header-after_keyc + x_header-textkeylen.
  len = x_header-aft_txttbc - x_header-textkeylen.
  ASSIGN: <texttab_new_x>+offset(len) TO <textfields_in_new>,
          <texttab_orig_x>+offset(len) TO <textfields_in_orig>.
  ASSIGN: old_key TO <h_old_key> CASTING,
          <h_old_key>(x_header-keylen) TO <old_keyx>,
          old_key TO <old_key_struc> CASTING TYPE (x_header-maintview).
*  ASSIGN texttab_orig(x_header-keylen) TO <viewkey_in_orig>.
*  ASSIGN texttab_new(x_header-keylen) TO <viewkey_in_new>.
*  offset = x_header-keylen + x_header-sprasfdpos.
*  ASSIGN texttab_orig+offset(vim_spras_length) TO <spras_in_orig>.
*  ASSIGN texttab_new+offset(vim_spras_length) TO <spras_in_new>.
  LOOP AT x_namtab WHERE keyflag = 'X' AND
    ( texttabfld = 'X' OR txttabfldn <> space ) AND
      domname EQ vim_delim_date_domain AND
    ( rollname IN vim_begda_types OR rollname IN vim_endda_types ).
*      offset = x_header-keylen + x_namtab-texttabpos.
*      len = x_namtab-flength.
    EXIT.
  ENDLOOP.
  ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE <txttb_new_struc>
   TO <date_in_textkey_new>.
*    ASSIGN texttab_new+offset(len) TO <date_in_textkey_new> TYPE 'D'.
  offset = ( x_header-after_keyc + x_header-aft_txttbc )
           / cl_abap_char_utilities=>charsize.
*  offset = x_header-keylen + x_header-texttablen.
  ASSIGN texttab_orig+offset(1) TO <action_in_orig>.
  ASSIGN texttab_new+offset(1) TO <action_in_new>.
*  ASSIGN texttab_new+offset(len) TO <textfields_in_new>.
*  ASSIGN texttab_orig+offset(len) TO <textfields_in_orig>.

  LOOP AT <vim_texttab> INTO texttab_orig FROM orig_tabix.
    IF <viewkey_in_orig> <> orig_key. EXIT. ENDIF.
    READ TABLE <vim_texttab> WITH KEY <vim_xtotal_key>      "#EC *
                     INTO texttab_new BINARY SEARCH.
    new_tabix = sy-tabix.
    IF <viewkey_in_new> = <vim_xtotal_key> AND
       <spras_in_new> < <spras_in_orig>.                  "#EC PORTABLE
      LOOP AT <vim_texttab> FROM new_tabix INTO texttab_new.
        IF <viewkey_in_new> <> <vim_xtotal_key> OR
           <spras_in_new> >= <spras_in_orig>.             "#EC PORTABLE
          new_tabix = sy-tabix.
          EXIT.
* Condition Redundant - Internal Message 0001699060 - ACHACHADI
*        ELSEIF <spras_in_new> < <spras_in_orig>.          "#EC PORTABLE
        ELSE.
          new_tabix = sy-tabix + 1.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF <viewkey_in_new> <> <vim_xtotal_key> OR
       <spras_in_new> <> <spras_in_orig>.
*    es gibt noch keinen Eintrag mit neuem Schlüssel
      texttab_new = texttab_orig.
      <viewkey_in_new> = <vim_xtotal_key>.
      <date_in_textkey_new> = <vim_enddate>.
      <action_in_new> = neuer_eintrag.
      INSERT texttab_new INTO <vim_texttab> INDEX new_tabix.
    ELSE.
      IF <action_in_new> = original.
        <action_in_new> = aendern.
      ENDIF.
      <textfields_in_new> = <textfields_in_orig>.
      MODIFY <vim_texttab> FROM texttab_new INDEX new_tabix.
    ENDIF.
  ENDLOOP.

* Text in neuen Eintrag löschen
  <old_keyx> = <vim_xtotal_key>.
*  ASSIGN old_key(x_header-keylen) TO <old_key>.
  LOOP AT x_namtab WHERE keyflag = 'X' AND
    ( texttabfld = 'X' OR txttabfldn <> space ) AND
    domname EQ vim_delim_date_domain AND
    ( rollname IN vim_begda_types OR rollname IN vim_endda_types ).
    EXIT.
  ENDLOOP.
  ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE <old_key_struc>
   TO <old_key_enddate>.
  <old_key_enddate> = enddate.
*  old_key+x_namtab-position(x_namtab-flength) = enddate.
  READ TABLE <vim_texttab> WITH KEY <old_keyx>                      "#EC *
                           BINARY SEARCH TRANSPORTING NO FIELDS.
*  READ TABLE <vim_texttab> WITH KEY <old_key>
*                           BINARY SEARCH TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    LOOP AT <vim_texttab> INTO texttab_orig FROM sy-tabix.
      IF <viewkey_in_orig> <> <old_keyx>. EXIT. ENDIF.
      IF <action_in_orig> = neuer_eintrag.
        DELETE <vim_texttab>.
      ELSE.
        CLEAR <textfields_in_orig>.
        IF <action_in_orig> = original.
          <action_in_orig> = aendern.
        ENDIF.
        MODIFY <vim_texttab> FROM texttab_orig.
      ENDIF.
    ENDLOOP.
  ENDIF.
  MODIFY vim_texttab_container INDEX vim_texttab_container_index.
ENDFORM.                               " VIM_TEMP_DELIM_TEXTTAB

*---------------------------------------------------------------------*
*       FORM VIM_CHECK_UPD_TEXTTAB                                    *
*---------------------------------------------------------------------*
* Setzen von <STATUS>-UPD_FLAG, falls Änderungen in Texttabelle       *
*---------------------------------------------------------------------*
FORM vim_check_upd_texttab.
  DATA: texttab_wa TYPE vim_line_ul,
        offset TYPE i.
  FIELD-SYMBOLS: <texttab_action>.

  IF x_header-delmdtflag <> space AND  "zeitabh. & part. Fremdschl.
     x_header-ptfrkyexst  = 'X'.       "      -> zeitunabh. Texttab.
    offset = x_header-after_keyc
     - vim_datum_length * cl_abap_char_utilities=>charsize.
  ELSE.
    offset = x_header-after_keyc.
  ENDIF.
  offset = ( offset + x_header-aft_txttbc )
           / cl_abap_char_utilities=>charsize.
  ASSIGN texttab_wa+offset(1) TO <texttab_action>.
  LOOP AT <vim_texttab> INTO texttab_wa.
    CHECK <texttab_action> <> original.
    MOVE 'X' TO <status>-upd_flag.
    EXIT.
  ENDLOOP.

ENDFORM.                               "VIM_CHECK_UPD_TEXTTAB

*---------------------------------------------------------------------*
*       FORM VIM_SET_TEXTTAB_ACTION_DELETE                            *
*---------------------------------------------------------------------*
* Für alle als 'GELOESCHT' gekennzeichneten Einträge in TOTAL         *
* entsprechende Einträge in der Texttabelle als 'GELOESCHT' kennz.    *
*---------------------------------------------------------------------*
FORM vim_set_texttab_action_delete.
  DATA: texttab_tabix LIKE sy-tabix,
        offset TYPE i,
        texttab_wa TYPE vim_line_ul.
  FIELD-SYMBOLS: <h_texttab_wa> TYPE x,
                 <texttab_action> TYPE char01,
                 <viewkey_in_texttab> TYPE x,
                 <total_key> TYPE x.

  IF x_header-delmdtflag <> space AND  "zeitabh. & part. Fremdschl.
     x_header-ptfrkyexst  = 'X'.       "      -> zeitunabh. Texttab.
    offset = x_header-after_keyc
             - vim_datum_length * cl_abap_char_utilities=>charsize.
    ASSIGN <vim_tot_mkey_beforex> TO <total_key>.
  ELSE.
    offset = x_header-after_keyc.
    ASSIGN <vim_xtotal_key> TO <total_key>.
  ENDIF.
  ASSIGN: texttab_wa TO <h_texttab_wa> CASTING,
          <h_texttab_wa>(offset) TO <viewkey_in_texttab>.
  offset = ( offset + x_header-aft_txttbc )
           / cl_abap_char_utilities=>charsize.
  ASSIGN texttab_wa+offset(1) TO <texttab_action>.

* Text-Einträge werden nur in dieser Routine, also in PREPARE_SAVING,
* als gelöscht gekennzeichnet, und nach dem eigentlichen Sichern,
* in AFTER_SAVING, aus der internen Texttabelle gelöscht.
* Hier sollten daher keine Einträge als gelöscht gekennzeichnet sein,
* außer wenn im User_exit vor dem Sichern das Sichern abgebrochen wurde.
  LOOP AT <vim_texttab> INTO texttab_wa.
    CHECK <texttab_action> = geloescht OR
          <texttab_action> = update_geloescht OR
          <texttab_action> = neuer_geloescht.
    TRANSLATE <texttab_action> USING 'D XNYU'.
    MODIFY <vim_texttab> FROM texttab_wa.
  ENDLOOP.

  LOOP AT total.
    CHECK <action> = update_geloescht OR
          <action> = geloescht OR
          <action> = neuer_geloescht.
    READ TABLE <vim_texttab> WITH KEY <total_key>                 "#EC *
                               BINARY SEARCH TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      texttab_tabix = sy-tabix.
      LOOP AT <vim_texttab> FROM texttab_tabix INTO texttab_wa.
        IF <viewkey_in_texttab> <> <total_key>.
          EXIT.
        ENDIF.
        TRANSLATE <texttab_action> USING ' DNXUY'.
        MODIFY <vim_texttab> FROM texttab_wa.
      ENDLOOP.
    ENDIF.
  ENDLOOP.
ENDFORM.                               "VIM_SET_TEXTTAB_ACTION_DELETE

*---------------------------------------------------------------------*
*    VIM_TEXTTAB_MODIF_FOR_KEY
*---------------------------------------------------------------------*
* <-- MODIF       'X' -> es gibt mind. einen modifizierten Eintrag
*                        in anderer Sprache
*---------------------------------------------------------------------*
* aktueller Eintrag steht in Kopfzeile von EXTRACT
*---------------------------------------------------------------------*
FORM vim_texttab_modif_for_key CHANGING modif.
  DATA: texttab_wa TYPE vim_line_ul,
        texttab_tabix LIKE sy-tabix,
        keylen TYPE i,
        offset TYPE i.
  FIELD-SYMBOLS: <h_texttab_wa> TYPE x,
                 <texttab_action> TYPE xfeld,
                 <viewkey_in_texttab> TYPE x,
                 <extract_key> TYPE x.

  IF x_header-delmdtflag <> space AND  "zeitabh. & part. Fremdschl.
     x_header-ptfrkyexst  = 'X'.       "      -> zeitunabh. Texttab.
    ASSIGN <vim_ext_mkey_beforex> TO <extract_key>.
    keylen = x_header-after_keyc
     - vim_datum_length * cl_abap_char_utilities=>charsize.
  ELSE.
    ASSIGN <vim_xextract_key> TO <extract_key>.
    keylen = x_header-after_keyc.
  ENDIF.

  CLEAR modif.
  READ TABLE <vim_texttab> WITH KEY <vim_xextract_key>                "#EC *
                           BINARY SEARCH TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    texttab_tabix = sy-tabix.
  ELSE.
    EXIT.     "keine Texte zum Key in anderen Sprachen erfaßt
  ENDIF.

  ASSIGN: texttab_wa TO <h_texttab_wa> CASTING,
          <h_texttab_wa>(keylen) TO <viewkey_in_texttab>.
  offset = ( keylen + x_header-aft_txttbc )
           / cl_abap_char_utilities=>charsize.
  ASSIGN texttab_wa+offset(1) TO <texttab_action>.
  LOOP AT <vim_texttab> FROM texttab_tabix INTO texttab_wa.
    IF <viewkey_in_texttab> <> <extract_key>.
      EXIT.
    ELSEIF <texttab_action> <> original.
      modif = 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.
ENDFORM.                               "VIM_TEXTTAB_MODIF_FOR_KEY

*---------------------------------------------------------------------*
*       FORM VIM_TEXT_KEYTAB_ENTRIES
*---------------------------------------------------------------------*
* Korrektureinträge für Texttabellenänderungen
* UF170200 Dump DATA_LENGTH_TOO_LARGE: Keylen not changed anymore in
* header line of X_HEADER but received in CORR_UPD and added to
* interface (P_KEYLEN).
*---------------------------------------------------------------------*
FORM vim_text_keytab_entries USING value(vake_action) TYPE c
                                   vake_rc TYPE i
                                   value(p_keylen) TYPE syfleng
                                   value(p_txtkeylen) TYPE syfleng.
  DATA: rc1 LIKE sy-subrc,
        offset TYPE i,
        texttab_wa TYPE vim_line_ul,
        max_trsp_keylength_in_byte TYPE i,
        text_keylen TYPE i.                                 " MN 904720
  FIELD-SYMBOLS: <h_texttab_wa> TYPE x,
                 <texttab_action> TYPE c, <texttab_key> TYPE x,
                 <x_header2> TYPE vimdesc.                  "#EC *

  text_keylen = x_header-keylen.                            "MN 904720
  IF x_header-delmdtflag <> space AND  "zeitabh. & part. Fremdschl.
     x_header-ptfrkyexst  = 'X'.       "      -> zeitunabh. Texttab.
    p_keylen = p_keylen
     - vim_datum_length * cl_abap_char_utilities=>charsize. "UF170200
    text_keylen = x_header-keylen
      - vim_datum_length * cl_abap_char_utilities=>charsize."MN 904720
  ENDIF.
*  ASSIGN: texttab_wa TO <h_texttab_wa> CASTING,
*          <h_texttab_wa>+x_header-keylen(x_header-textkeylen) TO <texttab_key>.
  ASSIGN: texttab_wa TO <h_texttab_wa> CASTING,
          <h_texttab_wa>+text_keylen(x_header-textkeylen) TO <texttab_key>." MN 904720
  max_trsp_keylength_in_byte = vim_max_trsp_keylength
   * cl_abap_char_utilities=>charsize.
  IF x_header-keylen GT max_trsp_keylength_in_byte.
*       "HCG                  same as in corr_upd -> p_keylen unchanged
  ELSE.                     "HCG if keylen not an even number char must
    p_keylen = x_header-after_keyc.  "begin on even memory adress in UC
  ENDIF.           "e.g. int1 in key -> keylen = 2n+1 aft_keyc = 2n+1+1
  offset = x_header-after_keyc + x_header-aft_txttbc.       "IG 924398
  IF x_header-delmdtflag <> space AND  "zeitabh. & part. Fremdschl.
     x_header-ptfrkyexst  = 'X'.       "      -> zeitunabh. Texttab.
    offset = offset
     - vim_datum_length * cl_abap_char_utilities=>charsize. "HCG774471
  ENDIF.
  ASSIGN <h_texttab_wa>+offset(cl_abap_char_utilities=>charsize)
          TO <texttab_action> CASTING.

  corr_keytab =  e071k.
  corr_keytab-objname = x_header-texttab.

  vake_rc = 8.
  LOOP AT <vim_texttab> INTO texttab_wa.
    CHECK <texttab_action> <> original AND
          <texttab_action> <> neuer_geloescht.
    MOVE <texttab_key> TO <vim_corr_keyx>(p_txtkeylen).
*    MOVE <texttab_key> TO corr_keytab-tabkey(p_txtkeylen).
    PERFORM update_corr_keytab USING vake_action rc1.
    IF rc1 = 0.
      CLEAR vake_rc.
    ELSE.
      IF vake_action EQ pruefen. vake_rc = 8. EXIT. ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                               "VIM_TEXT_KEYTAB_ENTRIES

*---------------------------------------------------------------------*
*       FORM VIM_TEXT_KEYTAB_ENTRY
*---------------------------------------------------------------------*
* Korrektureintrag für Entry in allen vorhandenen Sprachen
*---------------------------------------------------------------------*
FORM vim_text_keytab_entry USING value(viewkey) TYPE x
                                 value(vake_action) TYPE c
                                 vake_rc TYPE i.
  DATA: rc1 LIKE sy-subrc,
        sys_type(10) TYPE c,
        keylen TYPE i,
        offset TYPE i,
        tbx LIKE sy-tabix,
        align TYPE f,
        texttab_wa TYPE vim_line_ul,
        key_wa TYPE vim_line_ul,
        wheretab LIKE vimwheretb OCCURS 0 WITH HEADER LINE,
        tmp_sellist LIKE vimsellist OCCURS 0 WITH HEADER LINE,
        tmp_texttab TYPE REF TO data, w_tmp_texttab TYPE REF TO data.
  FIELD-SYMBOLS: <tmp_texttab> TYPE STANDARD TABLE,
                 <texttab_wax> TYPE x,
                 <texttab_x> TYPE x, <texttab_struc> TYPE ANY,
                 <texttab_key> TYPE x, <texttab_action> TYPE c,
                 <keyvalue> TYPE ANY, <lang> TYPE spras,
                 <viewkey_in_texttab>, <viewkey> TYPE x.

  vake_rc = 8.
  corr_keytab =  e071k.
  corr_keytab-objname = x_header-texttab.

  IF x_header-generictrp <> space OR x_header-genertxtrp <> space.
    keylen = x_header-maxtrkeyln.
  ELSE.
    keylen = x_header-keylen.
  ENDIF.
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'transport/systemtype'                  "#EC CI_CCALL
                     ID 'VALUE' FIELD sys_type.

  ASSIGN: viewkey(keylen) TO <viewkey> CASTING.
  IF vim_texttab_container-all_langus = 'X'.
* texts have already been read
    ASSIGN: texttab_wa TO <texttab_wax> CASTING,
            <texttab_wax>+keylen(x_header-texttablen) TO <texttab_x>,
            <texttab_x>(x_header-textkeylen) TO <texttab_key>,
            <texttab_x> TO <texttab_struc>
             CASTING TYPE (x_header-texttab),
            COMPONENT x_header-sprasfield OF STRUCTURE
             <texttab_struc> TO <lang>.
    IF x_header-delmdtflag <> space AND"zeitabh. & part. Fremdschl.
       x_header-ptfrkyexst  = 'X'.     "      -> zeitunabh. Texttab.
      keylen = keylen
                - vim_datum_length * cl_abap_char_utilities=>charsize.
    ENDIF.
    ASSIGN <texttab_wax>(keylen) TO <viewkey_in_texttab>.
    offset = keylen + x_header-aft_txttbc.
    ASSIGN <texttab_wax>+offset(cl_abap_char_utilities=>charsize)
     TO <texttab_action> CASTING.

    READ TABLE <vim_texttab> WITH KEY <viewkey>                     "#EC *
             BINARY SEARCH TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      LOOP AT <vim_texttab> INTO texttab_wa FROM sy-tabix.
        CHECK <texttab_action> <> neuer_eintrag.
        IF <viewkey_in_texttab> <> <viewkey>. EXIT. ENDIF.
        MOVE <texttab_key> TO <vim_corr_keyx>(x_header-textkeylen).
*        WRITE <texttab_key> TO corr_keytab-tabkey(x_header-textkeylen).
        PERFORM update_corr_keytab USING vake_action rc1.
        IF rc1 = 0.
          CLEAR vake_rc.
        ELSE.
          IF vake_action EQ pruefen. vake_rc = 8. EXIT. ENDIF.
        ENDIF.
      ENDLOOP.
    ELSE.
      CLEAR vake_rc.
    ENDIF.
  ELSE.
* Texte direkt von DB lesen
    REFRESH wheretab.
    tmp_sellist-operator = 'EQ'.
    tmp_sellist-and_or = 'AND'.
    MOVE <viewkey> TO <f1_wax>.
    LOOP AT x_namtab WHERE keyflag NE space    "fill sellist for
                       AND txttabfldn <> space.             "texttab
      tmp_sellist-tabix = sy-tabix.
*      ASSIGN viewkey+x_namtab-position(x_namtab-flength) TO <keyvalue>.
*      ASSIGN COMPONENT x_namtab-viewfield
*       OF STRUCTURE <table1_wa> TO <keyvalue>.
* XB 11062002, int2023251/03. choos the right key into texttabkey.
      ASSIGN COMPONENT x_namtab-viewfield
       OF STRUCTURE <table1> TO <keyvalue>.           " XB H631231
      tmp_sellist-viewfield = x_namtab-txttabfldn.
      IF x_namtab-inttype = 'C' AND x_namtab-convexit = space.
        tmp_sellist-value = <keyvalue>.
      ELSE.
        CALL FUNCTION 'VIEW_CONVERSION_OUTPUT'
          EXPORTING
            value_intern = <keyvalue>
            tabname      = x_header-maintview
            fieldname    = x_namtab-viewfield
            inttype      = x_namtab-inttype
            datatype     = x_namtab-datatype
            decimals     = x_namtab-decimals
            convexit     = x_namtab-convexit
            sign         = x_namtab-sign
            outputlen    = x_namtab-outputlen
            intlen       = x_namtab-flength
          IMPORTING
            value_extern = tmp_sellist-value
          EXCEPTIONS                                    "#EC *
            OTHERS       = 1.
      ENDIF.
      APPEND tmp_sellist.
      tbx   = sy-tabix.
    ENDLOOP.
    IF tbx > 0.
      CLEAR tmp_sellist-and_or.
      MODIFY tmp_sellist INDEX tbx.
      CALL FUNCTION 'VIEW_FILL_WHERETAB'
        EXPORTING
          tablename               = x_header-texttab
          only_cnds_for_keyflds   = 'X'
          is_texttable            = 'X'
        TABLES
          sellist                 = tmp_sellist
          wheretab                = wheretab
          x_namtab                = x_namtab
        EXCEPTIONS                                      "#EC *
          no_conditions_for_table = 01.
      CREATE DATA tmp_texttab TYPE STANDARD TABLE OF (x_header-texttab).
      CREATE DATA w_tmp_texttab TYPE (x_header-texttab).
      ASSIGN: tmp_texttab->* TO <tmp_texttab>,
              w_tmp_texttab->* TO <texttab_struc>,
              <texttab_struc> TO <texttab_wax> CASTING,
              <texttab_wax>(x_header-textkeylen) TO <texttab_key>,
              COMPONENT x_header-sprasfield OF STRUCTURE
               <texttab_struc> TO <lang>.
      SELECT * FROM (x_header-texttab) INTO TABLE <tmp_texttab>
                                      WHERE (wheretab).
      IF sy-subrc = 0.
*        ASSIGN texttab_wa(x_header-textkeylen) TO <texttab_key>.
        LOOP AT <tmp_texttab> INTO <texttab_struc>.
*          MOVE <texttab_key> TO <vim_corr_keyx>(x_header-textkeylen).
* txttabkeyLen > 120, use x_hader-maxtrtxkln.
* XB H631231B
          IF x_header-textkeylen > x_header-maxtrtxkln
            AND x_header-maxtrtxkln <> 0.
            MOVE <texttab_key> TO <vim_corr_keyx>(x_header-maxtrtxkln).
          ELSE.
            MOVE <texttab_key> TO <vim_corr_keyx>(x_header-textkeylen).
          ENDIF.
* XB H631231E
          PERFORM update_corr_keytab USING vake_action rc1.
          IF rc1 = 0.
            CLEAR vake_rc.
          ELSE.
            IF vake_action EQ pruefen. vake_rc = 8. EXIT. ENDIF.
          ENDIF.
        ENDLOOP.
      ELSE.
        CLEAR vake_rc.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                               "VIM_TEXT_KEYTAB_ENTRY

* "SW Textcopy
*---------------------------------------------------------------------*
*       FORM VIM_COPY_TEXTTAB_ENTRY                                   *
*---------------------------------------------------------------------*
* Kopieren für Texttabelle :                                          *
*    neuen Eintrag für NEW_KEY für alle Sprachen in Texttabelle erzeugen
*       ?? bzw. -falls schon ex.- Texte darin ersetzen ??
*    Texte werden aus Originaleintrag ORIG_KEY übernommen
*---------------------------------------------------------------------*
* --> NEW_KEY   Schlüssel des neuen Eintrags
* --> ORIG_KEY  Schlüssel des zu kopierenden Eintrags
*---------------------------------------------------------------------*
FORM vim_copy_texttab_entry USING value(new_key) TYPE x
                                  value(orig_key) TYPE x.
  DATA: texttab_orig TYPE vim_line_ul,
        texttab_new  TYPE vim_line_ul,
        orig_tabix LIKE sy-tabix,
        new_tabix  LIKE sy-tabix,
        len TYPE i,
        offset TYPE i,
        langus_selected(1) TYPE c,
        curr_sptxt LIKE t002t-sptxt,
        sel_langus LIKE h_t002 OCCURS 0 WITH HEADER LINE.
  FIELD-SYMBOLS: <texttab_orig_x> TYPE x,
                 <h_texttab_orig_x> TYPE x,
                 <txttb_orig_struc> TYPE ANY,
                 <viewkey_in_orig> TYPE x,    "-> texttab_orig
                 <texttab_new_x> TYPE x,
                 <h_texttab_new_x> TYPE x,
                 <txttb_new_struc> TYPE ANY,
                 <viewkey_in_new> TYPE x,     "-> texttab_new
                 <spras_in_orig> TYPE spras,
                 <spras_in_new> TYPE spras,
                 <action_in_orig>,
                 <action_in_new>,
                 <textfields_in_new> TYPE x,
                 <textfields_in_orig> TYPE x,
                 <textkey_in_new> TYPE x.

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
    PERFORM vim_read_texttab_for_langus TABLES sel_langus USING 'X'.
  ENDIF.

  READ TABLE <vim_texttab> WITH KEY orig_key                                "#EC *
                           BINARY SEARCH TRANSPORTING NO FIELDS.
  CHECK sy-subrc = 0.
  orig_tabix = sy-tabix.
  ASSIGN: texttab_orig TO <texttab_orig_x> CASTING,
          <texttab_orig_x>(x_header-keylen) TO <viewkey_in_orig>,
          <texttab_orig_x>+x_header-after_keyc(x_header-texttablen)
           TO <h_texttab_orig_x>,
          <h_texttab_orig_x>
           TO <txttb_orig_struc> CASTING TYPE (x_header-texttab),
          COMPONENT x_header-sprasfield OF STRUCTURE <txttb_orig_struc>
           TO <spras_in_orig>.
  ASSIGN: texttab_new TO <texttab_new_x> CASTING,
          <texttab_new_x>(x_header-keylen) TO <viewkey_in_new>,
          <texttab_new_x>+x_header-after_keyc(x_header-textkeylen)
           TO <textkey_in_new>,
          <texttab_new_x>+x_header-after_keyc(x_header-texttablen)
           TO <h_texttab_new_x>,
          <h_texttab_new_x>
           TO <txttb_new_struc> CASTING TYPE (x_header-texttab),
          COMPONENT x_header-sprasfield OF STRUCTURE <txttb_new_struc>
           TO <spras_in_new>.
  offset = x_header-after_keyc + x_header-textkeylen.
  len = x_header-aft_txttbc - x_header-textkeylen.
  ASSIGN: <texttab_new_x>+offset(len) TO <textfields_in_new>,
          <texttab_orig_x>+offset(len) TO <textfields_in_orig>.
  offset = ( x_header-after_keyc + x_header-aft_txttbc )
           / cl_abap_char_utilities=>charsize.
  ASSIGN texttab_orig+offset(1) TO <action_in_orig>.
  ASSIGN texttab_new+offset(1) TO <action_in_new>.
*  ASSIGN texttab_orig(x_header-keylen) TO <viewkey_in_orig>.
*  ASSIGN texttab_new(x_header-keylen) TO <viewkey_in_new>.
*  ASSIGN texttab_new+x_header-keylen(x_header-textkeylen)
*                                       TO <textkey_in_new>.
*  offset = x_header-keylen + x_header-sprasfdpos.
*  ASSIGN texttab_orig+offset(vim_spras_length) TO <spras_in_orig>.
*  ASSIGN texttab_new+offset(vim_spras_length) TO <spras_in_new>.
*  offset = x_header-keylen + x_header-texttablen.
*  ASSIGN texttab_new+offset(1) TO <action_in_new>.
*  offset = x_header-keylen + x_header-textkeylen.
*  len = x_header-texttablen - x_header-textkeylen.
*  ASSIGN texttab_new+offset(len) TO <textfields_in_new>.
*  ASSIGN texttab_orig+offset(len) TO <textfields_in_orig>.

  LOOP AT <vim_texttab> INTO texttab_orig FROM orig_tabix.
    IF <viewkey_in_orig> <> orig_key. EXIT. ENDIF.
    READ TABLE <vim_texttab> WITH KEY new_key                     "#EC *
                     INTO texttab_new BINARY SEARCH.
    new_tabix = sy-tabix.
    IF <viewkey_in_new> = new_key AND
       <spras_in_new> < <spras_in_orig>.                  "#EC PORTABLE
      LOOP AT <vim_texttab> FROM new_tabix INTO texttab_new.
        IF <viewkey_in_new> <> new_key OR                 "#EC PORTABLE
           <spras_in_new> >= <spras_in_orig>.
          new_tabix = sy-tabix.
          EXIT.
* Condition redundant - Internal Message 0001699060 - ACHACHADI
*        ELSEIF <spras_in_new> < <spras_in_orig>.          "#EC PORTABLE
         ELSE.
          new_tabix = sy-tabix + 1.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF <viewkey_in_new> <> new_key OR
       <spras_in_new> <> <spras_in_orig>.
*    es gibt noch keinen Eintrag mit neuem Schlüssel
      texttab_new = texttab_orig.
      <viewkey_in_new> = new_key.
      PERFORM map_viewkey_to_texttabkey TABLES x_namtab
                                        USING x_header
                                              <spras_in_orig>
                                              new_key
                                        CHANGING <textkey_in_new>.
*      PERFORM vim_fill_texttab_key USING new_key
*                          <spras_in_orig> x_header-sprasfdpos
*                                   CHANGING <textkey_in_new>.
      <action_in_new> = neuer_eintrag.
      INSERT texttab_new INTO <vim_texttab> INDEX new_tabix.
    ELSE.
      IF <action_in_new> = original.
        <action_in_new> = aendern.
      ENDIF.
      <textfields_in_new> = <textfields_in_orig>.
      MODIFY <vim_texttab> FROM texttab_new INDEX new_tabix.
    ENDIF.
  ENDLOOP.
  MODIFY vim_texttab_container INDEX vim_texttab_container_index.
ENDFORM.                               " VIM_COPY_TEXTTAB_ENTRY
