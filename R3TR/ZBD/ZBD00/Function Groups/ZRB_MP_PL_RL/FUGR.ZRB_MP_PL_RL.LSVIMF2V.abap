*---------------------------------------------------------------------*
*       FORM CHECK_KEY                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM check_key.
  DATA: s LIKE sy-tabix, mess_type(1) TYPE c VALUE 'E', ck_tabix TYPE i,   "#EC NEEDED
        ck_check_tab LIKE vimdesc-viewname, ck_slcnds_nokey(1) TYPE c,     "#EC NEEDED
        ck_clause TYPE vim_ck_selcond, ck_wa TYPE REF TO data,
        ck_wheretab LIKE vimwheretb OCCURS 10, ck_rc LIKE sy-subrc,
        oc_keys TYPE occheckkeyflds, n(1) TYPE n, ocmes TYPE fieldname,
        field1 TYPE fieldname, field2 TYPE fieldname,
        field3 TYPE fieldname, field4 TYPE fieldname,
        w_oc_keys TYPE occheckkey, fieldname TYPE fnam_____4.
  FIELD-SYMBOLS: <ck_1> TYPE ANY, <noauth> TYPE fieldname,
                 <namtab> TYPE vimnamtab, <ck_wa> TYPE ANY,
                 <table1_txt_loc> type any.

  CHECK neuer CO 'JX'.
  IF vim_key_alr_checked NE space.
    READ TABLE total WITH KEY <f1_x> BINARY SEARCH.          "#EC *
    EXIT.
  ELSE.
    vim_key_alr_checked = 'X'.
  ENDIF.
* first check namespace
  IF x_header-customauth CO sap_cust_classes OR
     vim_ale_keyspec_check NE space OR
     vim_sync_keyspec_check NE space.
    PERFORM check_allowed_keyranges.
  ENDIF.
* check if user is authorised for this key
  IF NOT vim_oc_inst IS INITIAL.
    CALL METHOD vim_oc_inst->build_key_value_tab
      EXPORTING
        entry     = <table1>
      IMPORTING
        keyvalues = oc_keys.
    CALL METHOD vim_oc_inst->check_oc_authority
      EXPORTING
        activity        = '02'
      CHANGING
        key_values      = oc_keys
      EXCEPTIONS
        no_auth         = 1
*        key_incomplete  = 2
        wrong_parameter = 3
        OTHERS          = 4.
    CASE sy-subrc.
      WHEN 1.
        PERFORM set_pf_status USING 'ERROR'.
        CLEAR vim_key_alr_checked.
        LOOP AT oc_keys INTO w_oc_keys WHERE noauth = 'X'.    "#EC CI_SORTSEQ
          n = n + 1.
          CONCATENATE 'FIELD' n INTO ocmes.
          IF n <= '4'.
            ASSIGN (ocmes) TO <noauth>.
            READ TABLE x_namtab ASSIGNING <namtab> WITH KEY
             viewfield = w_oc_keys-keyname.
            CHECK sy-subrc = 0.
            IF <namtab>-scrtext_s <> space.
              <noauth> = <namtab>-scrtext_s.
            ELSE.
              <noauth> = w_oc_keys-keyname.
            ENDIF.
          ELSE.
*            ocmiss4 = text-001.
          ENDIF.
        ENDLOOP.
        MESSAGE e757(sv) WITH field1 field2 field3 field4.
      WHEN OTHERS.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDCASE.
  ENDIF.
* second check if entry fits selection conditions
  IF x_header-selection NE space.
    if x_header-bastab <> space and x_header-texttbexst <> space.
      assign <table1_text> to <table1_txt_loc>.
    else.
      assign <table1> to <table1_txt_loc>.
    endif.
    CALL FUNCTION 'TABLE_RANGE_CHECK'
         EXPORTING
              tabname                   = x_header-maintview
              entry                     = <table1>
              entry_text                = <table1_txt_loc>
              ddic                      = 'J'
              key                       = 'J'
              ignore_blank_subsetfields = 'N'
         TABLES
              x_namtab                  = x_namtab
              x_header                  = x_header
              sellist                   = <vim_ck_sellist>
         EXCEPTIONS
              entry_not_fits            = 1.
    IF sy-subrc EQ 1.
      PERFORM set_pf_status USING 'ERROR'.
      CLEAR vim_key_alr_checked.
      MESSAGE e033(sv).
    ENDIF.
  ENDIF.                               "x_header-selection ne space.
* Forkey-Check for subset fields in import mode
  IF vim_called_by_cluster = space AND
   ( vim_import_mode_active <> space OR
     vim_special_mode = vim_upgrade ).
    CALL FUNCTION 'VIEW_FORKEY_CHECK'
         EXPORTING
              viewname     = view_name
              entry        = <table1>
         TABLES
              namtab       = x_namtab
         EXCEPTIONS
              forkey_error = 1.
    IF sy-subrc EQ 1.
      PERFORM set_pf_status USING 'ERROR'.
      CLEAR vim_key_alr_checked.
      MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
* third check against TOTAL anyway
  READ TABLE total WITH KEY <f1_x> BINARY SEARCH.            "#EC *
  ck_tabix = sy-tabix.
* fourth check against db if not found and nokey-selconds exist
  IF sy-subrc NE 0 AND                 "entry not found in TOTAL and
     x_header-selection NE space AND   "selconds exist and
   <status>-nokeyslcds NE space.       "nokey-selconds: check against db
    IF x_header-bastab EQ space.
      ck_check_tab = x_header-roottab.
    ELSE.
      ck_check_tab = x_header-maintview.
    ENDIF.
    LOOP AT x_namtab WHERE keyflag NE space. "all keyfields
      IF x_header-bastab NE space AND x_header-texttbexst NE space.
        CHECK x_namtab-texttabfld EQ space. "ignore texttab-keyfields
      ELSEIF x_header-bastab EQ space. "view -> safety check langu key
        CHECK x_namtab-bastabname EQ x_header-roottab.
      ENDIF.
      PERFORM vim_ck_append_wheretab TABLES ck_wheretab
                                     USING ck_clause.
      IF x_header-bastab EQ space.
        ck_clause-field = x_namtab-bastabfld.
      ELSE.
        ck_clause-field = x_namtab-viewfield.
      ENDIF.
      ck_clause-operator = 'EQ'.
      ck_clause-hk1 = ''''.
      ck_clause-hk2 = ''''.
      ck_clause-and = 'AND'.
      IF x_namtab-inttype CO 'DTN'.
        ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE <table1>
         TO <ck_1> CASTING TYPE c.
*        ASSIGN <f1>+x_namtab-position(x_namtab-flength) TO <ck_1>
*                                                        TYPE 'C'.
*      ELSEIF x_namtab-inttype CO 'IPX'.
      ELSE.
       CONCATENATE x_header-maintview x_namtab-viewfield INTO fieldname
           SEPARATED BY '-'.
        ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE <table1>
         TO <ck_1> CASTING TYPE (fieldname).
*        ASSIGN <f1>+x_namtab-position(x_namtab-flength) TO <ck_1>
*                                            TYPE x_namtab-inttype.
*      ELSE.
*        ASSIGN <f1>+x_namtab-position(x_namtab-flength) TO <ck_1>.
      ENDIF.
      ck_clause-value = <ck_1>.
      CONDENSE ck_clause-value.             "IG CM 446319 2005.
    ENDLOOP.
    CLEAR ck_clause-and.
    PERFORM vim_ck_append_wheretab TABLES ck_wheretab
                                   USING ck_clause.
    CREATE DATA ck_wa TYPE (ck_check_tab).
    ASSIGN ck_wa->* TO <ck_wa>.
    SELECT SINGLE * INTO <ck_wa> FROM (ck_check_tab)
                                 WHERE (ck_wheretab).
    IF sy-subrc EQ 8.                  "key not qualified
      RAISE impossible_error.                               "#EC *
    ENDIF.
    ck_rc = sy-subrc.
  ELSE. "entry found in TOTAL or no nokey-selconds
    ck_rc = sy-subrc.
  ENDIF.                               "x_header-selection ne space.
  IF ck_rc NE 0 AND vim_called_by_cluster NE space.
    CALL FUNCTION 'VIEWCLUSTER_CHECK_MASTER_ENTRY'
         EXPORTING
              check_entry   = <table1>
              view_name     = x_header-viewname
         EXCEPTIONS
              invalid_key   = 1
              invalid_value = 2.
    IF sy-subrc NE 0.
      IF status-mode EQ list_bild.
        SET CURSOR FIELD sy-msgv1 LINE l.
      ELSE.
        SET CURSOR FIELD sy-msgv1.
      ENDIF.
      CLEAR vim_key_alr_checked.
      PERFORM set_pf_status USING 'ERROR'.
      MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
  sy-subrc = ck_rc. sy-tabix = ck_tabix.
  CHECK ck_rc EQ 0.
  IF x_header-delmdtflag NE space AND status-mode EQ detail_bild.
    mess_type = 'S'.
  ENDIF.
  PERFORM set_pf_status USING 'ERROR'.
  CLEAR vim_key_alr_checked.
  IF <action> EQ geloescht
  OR <action> EQ neuer_geloescht
  OR <action> EQ update_geloescht.
    MESSAGE ID 'SV' TYPE mess_type NUMBER '010'.
  ELSE.
    MESSAGE ID 'SV' TYPE mess_type NUMBER '009'.
  ENDIF.
  IF x_header-delmdtflag NE space AND status-mode EQ detail_bild.
    <vim_h_old_mkey>(x_header-keylen) = <f1_x>.
*    vim_old_viewkey = <f1>.
    TRANSLATE neuer USING 'JX'.
    CLEAR: function, ok_code. LEAVE SCREEN.
  ENDIF.
ENDFORM.
