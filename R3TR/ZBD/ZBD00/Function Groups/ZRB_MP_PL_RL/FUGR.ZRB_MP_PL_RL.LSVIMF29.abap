*----------------------------------------------------------------------*
***INCLUDE LSVIMF29 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  VIM_MULTI_LANGU_TEXT_ALS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VIM_MULTI_LANGU_TEXT_ALS .

  DATA: sel_langus TYPE ALS_T002,
        texttab_for_output TYPE vimty_multilangu_texttab,
        lb_als TYPE REF TO IF_EX_VIM_ALS_BADI,
        curr_sptxt LIKE t002t-sptxt,
        maint_mode(1) TYPE c,                            "#EC NEEDED
        textmodif(1) TYPE c,                             "#EC NEEDED
        f_called_by_viewmaint TYPE c,                    "#EC NEEDED
        als_text TYPE vimty_max_textline,
        wa1_texttab_for_output LIKE LINE OF texttab_for_output,
        wa2_texttab_for_output LIKE LINE OF texttab_for_output,
        wa1_texttab TYPE vimty_textfield,
        wa2_texttab TYPE vimty_textfield,
        index TYPE sy-tabix.


  CALL METHOD cl_exithandler=>get_instance
    EXPORTING
      null_instance_accepted        = seex_false
      exit_name                     = 'VIM_ALS_BADI'
    CHANGING
      instance                      = lb_als
    EXCEPTIONS
      no_reference                  = 1
      no_interface_reference        = 2
      no_exit_interface             = 3
      class_not_implement_interface = 4
      single_exit_multiply_active   = 5
      cast_error                    = 6
      exit_not_existing             = 7
      data_incons_in_exit_managem   = 8
      OTHERS                        = 9.
  IF sy-subrc NE 0.
    EXIT.
  ELSE.
    IF als_active <> 'X' AND als_langus_selected <> 'X'.
      CALL METHOD lb_als->get_als_languages
        EXPORTING
          view_name  = x_header-viewname
        IMPORTING
          als_active = als_active
        CHANGING
          als_langus = sel_langus.
      als_langus_selected = 'X'.
      als_sel_langus[] = sel_langus[].
    ENDIF.

    sel_langus[] = als_sel_langus[].
    CALL FUNCTION 'VIEW_SET_ALS_LANGUAGES'
      IMPORTING
        curr_sptxt = curr_sptxt
      TABLES
        languages  = sel_langus.

    PERFORM vim_read_texttab_for_langus TABLES sel_langus USING ' '.
    REFRESH texttab_for_output.
    PERFORM vim_fill_texttab_for_als TABLES sel_langus
                                       USING curr_sptxt
                                       CHANGING texttab_for_output.

    CLEAR als_text.
    CLEAR index.

    LOOP AT texttab_for_output INTO wa1_texttab_for_output.
      IF sy-tabix EQ 1.
        LOOP AT wa1_texttab_for_output-texttab INTO wa1_texttab.
          index = sy-tabix.
          als_text = wa1_texttab-text.
          LOOP AT texttab_for_output INTO wa2_texttab_for_output.
            IF sy-tabix EQ 1.
              wa2_texttab_for_output-ACTION = 'X'.
              MODIFY texttab_for_output FROM wa2_texttab_for_output.
            ELSE.
              LOOP AT wa2_texttab_for_output-texttab INTO wa2_texttab.
                IF sy-tabix = index.
                  wa2_texttab-text = als_text.
                 MODIFY wa2_texttab_for_output-texttab FROM wa2_texttab.
                  MODIFY texttab_for_output FROM wa2_texttab_for_output.
                ENDIF.
              ENDLOOP.
            ENDIF.
          ENDLOOP.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

    PERFORM als_update_texttab USING texttab_for_output.
    MODIFY vim_texttab_container INDEX vim_texttab_container_index.
  ENDIF.


ENDFORM.                    " VIM_MULTI_LANGU_TEXT_ALS
*&---------------------------------------------------------------------*
*&      Form  vim_fill_texttab_for_als
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SEL_LANGUS  text
*      -->P_CURR_SPTXT  text
*      <--P_TEXTTAB_FOR_OUTPUT  text
*----------------------------------------------------------------------*
FORM vim_fill_texttab_for_als TABLES sel_langus STRUCTURE h_t002
               USING curr_sptxt LIKE t002t-sptxt
               CHANGING texttab_for_maint TYPE vimty_multilangu_texttab.
  DATA: textmaint_record TYPE vimty_textmaint_record,
        textmaint_field TYPE vimty_textfield,
        align1 TYPE f,                                                 "#EC NEEDED
        texttab_wa TYPE vim_line_ul,
        align2 TYPE f,                                                 "#EC NEEDED
        tmp_wa TYPE tabl8000,
        condense(1) TYPE c,                                            "#EC NEEDED
        texttab_tabix LIKE sy-tabix,
        extract_index LIKE sy-tabix,                                   "#EC NEEDED
        keylen TYPE i,
        rc LIKE sy-subrc,
        keys_identical TYPE xfeld.
  DATA: primkeylen TYPE i.
  FIELD-SYMBOLS: <extract_key> TYPE x,
                 <next_spras> TYPE spras,
                 <text_rec_key> TYPE x, <h_texttab_wa> TYPE x,
                 <viewkey_in_texttab> TYPE x, <txtfld> TYPE ANY,
                 <h_tmp> TYPE x, <tmp_struc> TYPE ANY,
                 <h_texttab> TYPE x, <texttab_struc> TYPE ANY.
  FIELD-SYMBOLS: <extract_primkey> TYPE x.

  ASSIGN <f1_x> TO <extract_key>.
  keylen = x_header-after_keyc.
  keylen = x_header-keylen.

* In case of viewkey > primtabkey -> additional key fields are filled
* in <extract_key> but not existent in <vim_texttab> "HCG 09/02/2005
*  primkeylen = x_header-textkeylen - cl_abap_char_utilities=>charsize.
  IF x_header-bastab EQ space.                              "IG 875536
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
  ENDIF.                                                    "IG 875536
  ASSIGN: texttab_wa TO <h_texttab_wa> CASTING,
          <h_texttab_wa>(primkeylen) TO <viewkey_in_texttab>,
          <h_texttab_wa>+keylen(x_header-texttablen) TO <h_texttab>,
          tmp_wa+keylen(x_header-texttablen)
           TO <h_tmp>,
          <h_texttab> TO <texttab_struc>
           CASTING TYPE (x_header-texttab),
          <h_tmp> TO <tmp_struc> CASTING TYPE (x_header-texttab),
          COMPONENT x_header-sprasfield OF STRUCTURE <texttab_struc>
           TO <next_spras>,
           textmaint_record-keys TO <text_rec_key> CASTING.

  CLEAR textmaint_record.
  <text_rec_key> = <extract_key>.
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
       <table1> TO <txtfld>.
      textmaint_field-text = <txtfld>.
      APPEND textmaint_field TO textmaint_record-texttab.
    ENDLOOP.
  ELSE.
* tab + texttab
    LOOP AT x_namtab WHERE textfldsel = 'X'.
      textmaint_field-namtab_idx = sy-tabix.
      textmaint_field-outplen = x_namtab-flength.
      ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE
       <table1_text> TO <txtfld>.
      textmaint_field-text = <txtfld>.
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
  ASSIGN <extract_key>(primkeylen) TO <extract_primkey>.
  READ TABLE <vim_texttab> WITH KEY <extract_primkey>     "#EC *
                             INTO texttab_wa. " BINARY SEARCH.
  texttab_tabix = sy-tabix.
  LOOP AT sel_langus.
    CLEAR textmaint_record.
    <text_rec_key> = <extract_key>.
    textmaint_record-spras = sel_langus-spras.
    textmaint_record-sptxt = sel_langus-sptxt.
    textmaint_record-action = 'X'.

    IF <viewkey_in_texttab> = <extract_primkey> AND         "817790
       <next_spras> < sel_langus-spras.                   "#EC PORTABLE
      LOOP AT <vim_texttab> FROM texttab_tabix INTO texttab_wa.
        IF <viewkey_in_texttab> <> <extract_primkey> OR     "817790
           <next_spras> >= sel_langus-spras.              "#EC PORTABLE
          texttab_tabix = sy-tabix.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.   " <next_spras> >= sel_langus-spras oder ex. nicht
    IF <next_spras> <> sel_langus-spras OR
        <viewkey_in_texttab> <> <extract_primkey>."langu:text not ex
      CLEAR <tmp_struc>.
    ELSE.
      tmp_wa = <h_texttab_wa>.
    ENDIF.
    LOOP AT x_namtab WHERE textfldsel = 'X'.
      textmaint_field-namtab_idx = sy-tabix.
      textmaint_field-outplen = x_namtab-flength.
      ASSIGN COMPONENT x_namtab-bastabfld OF STRUCTURE     "HCG wrong
       <tmp_struc> TO <txtfld>.   "HCG for txtfldname in view differs
      textmaint_field-text = <txtfld>.
      APPEND textmaint_field TO textmaint_record-texttab.
    ENDLOOP.
    APPEND textmaint_record TO texttab_for_maint.
  ENDLOOP.                           " SEL_LANGUS

ENDFORM.                    " vim_fill_texttab_for_als
*&---------------------------------------------------------------------*
*&      Form  set_als_update_flag
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_als_update_flag .

  DATA: als_flag(1) TYPE c.
  FIELD-SYMBOLS: <h1>,
                 <h2>.
  CLEAR als_flag.
  LOOP AT x_namtab WHERE keyflag EQ space
      AND bastabname EQ x_header-texttab.
    assign component x_namtab-viewfield of structure <table1> to <h1>.
    assign component x_namtab-viewfield of structure
                     <vim_extract_struc> to <h2>.
    IF <h1> NE <h2>.
      als_flag ='X'.
    ENDIF.
  ENDLOOP.

  IF als_flag EQ 'X'.
    PERFORM VIM_MULTI_LANGU_TEXT_ALS.
  ENDIF.

ENDFORM.                    " set_als_update_flag
*&---------------------------------------------------------------------*
*&      Form  ALS_UPDATE_TEXTTAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM als_update_texttab
                USING texttab_for_maint TYPE vimty_multilangu_texttab.
  DATA: textmaint_record TYPE vimty_textmaint_record,
        textmaint_field TYPE vimty_textfield,
        align TYPE f,                                       "#EC NEEDED
        texttab_wa TYPE vim_line_ul,
        search_key TYPE tabl8000,
        offset LIKE sy-fdpos,
        keylen LIKE sy-fdpos,
        extract_index LIKE sy-tabix,                     "#EC NEEDED
        total_index   LIKE sy-tabix,                             "#EC NEEDED
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
        <h_texttab> TYPE x, <tot_fld> TYPE ANY, <ext_fld> TYPE ANY,    "#EC *
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
  IF x_header-bastab EQ space.                              "IG 875536
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
  ENDIF.                                                    "IG 875536

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
  ASSIGN: search_key(primkeylen) TO <search_txtkey>.        "817790

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
      READ TABLE extract WITH KEY <search_key> BINARY SEARCH."#EC *
      extract_index = sy-tabix.
    ENDIF.
    CHECK textmaint_record-action = 'X'.      " Texte wurden modifiziert

    IF textmaint_record-spras = sy-langu.
      READ TABLE total WITH KEY <search_key> BINARY SEARCH. "#EC *
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

        <e_action> = neuer_eintrag.
        <t_action> = neuer_eintrag.
      ELSEIF <e_action> = original.
        <e_action> = aendern.
        <t_action> = aendern.
*     Else.                     " neuer_eintrag / aendern => ok
      ENDIF.

    ELSE.
* different language: Update in texttable
      CLEAR: <h_texttab_wa>, <texttab_struc>.
      READ TABLE <vim_texttab> WITH KEY <search_txtkey>      "#EC *
                               INTO texttab_wa BINARY SEARCH."817790

      texttab_tabix = sy-tabix.
      IF <viewkey_in_texttab>(primkeylen) = <search_txtkey> AND"817790
         <curr_spras> < textmaint_record-spras.
        LOOP AT <vim_texttab> FROM texttab_tabix INTO texttab_wa.
        IF <viewkey_in_texttab>(primkeylen) <> <search_txtkey> OR"817790
             <curr_spras> >= textmaint_record-spras.
            texttab_tabix = sy-tabix.
            EXIT.
* Condition redundant - Internal Message 0001699060 - ACHACHADI
*          ELSEIF <curr_spras> < textmaint_record-spras.                     "#EC BOOL_OK
           ELSE.
            texttab_tabix = sy-tabix + 1.
          ENDIF.
        ENDLOOP.
      ENDIF.   " <next_spras> >= sel_langus-spras oder ex. nicht
      IF <viewkey_in_texttab>(primkeylen) <> <search_txtkey> OR "817790
        <curr_spras> <> textmaint_record-spras.
        CLEAR: <texttab_struc>.
        new_entry = 'X'.
        <viewkey_in_texttab> = <search_key>.
        <texttab_action> = neuer_eintrag.
        PERFORM map_viewkey_to_texttabkey TABLES x_namtab
                                          USING x_header
                                                textmaint_record-spras
                                                <viewkey_in_texttab>
                                          CHANGING <texttab_key>.
      ELSE.
        CLEAR new_entry.
      ENDIF.
*     Text-Values übernehmen
      LOOP AT textmaint_record-texttab INTO textmaint_field.
        READ TABLE x_namtab INDEX textmaint_field-namtab_idx.
        IF x_namtab-lowercase = space.
          TRANSLATE textmaint_field-text TO UPPER CASE.
        ENDIF.
        IF x_header-bastab = 'X'."HCG Custmessage 282684/02------------
* tab + texttab
          ASSIGN: COMPONENT x_namtab-viewfield OF STRUCTURE
                   <texttab_struc> TO <ext_fld>. "XB int.40684/02
        ELSE.
* view, basis table field name.
          ASSIGN: COMPONENT x_namtab-bastabfld OF STRUCTURE
                   <texttab_struc> TO <ext_fld>. "XB int.. 40684
        ENDIF.
        <ext_fld> = textmaint_field-text.
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


ENDFORM.                    " ALS_UPDATE_TEXTTAB
