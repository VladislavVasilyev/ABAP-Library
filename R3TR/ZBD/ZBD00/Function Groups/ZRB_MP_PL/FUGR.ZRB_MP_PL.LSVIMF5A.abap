*----------------------------------------------------------------------*
***INCLUDE LSVIMF5A .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  VIM_BC_LOGS_PUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_BC_ENTRY_LIST  text
*----------------------------------------------------------------------*
FORM vim_bc_logs_put CHANGING p_bc_entry_list LIKE
                              vim_bc_entry_list.

  DATA: corr_keytab_save LIKE TABLE OF e071k, first,        "#EC *
        dummy LIKE sy-subrc, transport_active LIKE t000-cccoractiv,        "#EC NEEDED
        w_tabkey_value TYPE scpractr,
        tabkey_values_n TYPE vim_bc_tab_logs,
        tabkey_values_u TYPE vim_bc_tab_logs,
        tabkey_values_d TYPE vim_bc_tab_logs,
        w_bc_entry TYPE scpr_viewdata, bc_entries TYPE scpr_viewdatas,       "#EC NEEDED
        w_bc_entry_list TYPE vimty_bc_entry_list_type,
        bc_keytab TYPE bc_keytab_type,
        bc_keytab_wa LIKE LINE OF bc_keytab,
        p_msgid, p_msgty, p_msgno, bc_key_needed(1) TYPE c,                    "#EC NEEDED
        foreign_langu TYPE sy-langu,
        rc LIKE sy-subrc, keys_identical TYPE xfeld,
        subrc TYPE sy-subrc, tabix TYPE sy-tabix,
        same_view(1), proceed(1) TYPE c.

  DATA: same_bc_set TYPE c,
  old_bc_set TYPE scpractr-profid,
  new_bc_set TYPE scpractr-profid,
  t_bc_entry_list TYPE vimty_bc_entry_list_type."MPRE/1034145


  STATICS: viewname_old TYPE vimdesc-viewname,
           keylen_real TYPE i.

  CONSTANTS: bc_id_length TYPE i VALUE 32,               "#EC NEEDED
             bc_recno_length TYPE i VALUE 10.                        "#EC NEEDED

  FIELD-SYMBOLS: <bc_entry_keyx> TYPE x,
                 <key> TYPE x,                             "#EC *
                 <vim_bc_keyx> TYPE x, <w_bc_entry_x> TYPE x,
                 <xlangu> TYPE x, <namtab> TYPE vimnamtab.

*-----------"HCG HW686163 Option: Write no Activation links -----------*
  CHECK vim_actopts-actlinks NE 'N'.

  ASSIGN: w_bc_entry_list-keys(x_header-keylen) TO <bc_entry_keyx>.
  ASSIGN: bc_keytab_wa-bc_tabkey TO <vim_bc_keyx> CASTING.
  ASSIGN: w_bc_entry-data TO <w_bc_entry_x> CASTING.

  same_bc_set = 'X'.
  same_view = 'X'.                                          "IG 1034145
  proceed = 'X'.                                            "IG 1034145

  READ TABLE p_bc_entry_list INTO t_bc_entry_list INDEX 1. "MPRE 1034145
  IF sy-subrc = 0.
    new_bc_set = t_bc_entry_list-id.

  ENDIF.
  IF new_bc_set NE old_bc_set.
     same_bc_set = space.
    old_bc_set = new_bc_set.
  ENDIF.

  IF x_header-viewname NE viewname_old. "HCG: has table align gap?
    same_view = space.
    viewname_old = x_header-viewname.
    CLEAR keylen_real.
    LOOP AT x_namtab ASSIGNING <namtab> WHERE keyflag = 'X' AND
                                                texttabfld IS INITIAL.
      keylen_real = keylen_real + <namtab>-flength.
    ENDLOOP.
  ENDIF.
  IF x_header-subsetflag EQ 'X'.                            "IG 1034145
    IF same_view EQ 'X' AND same_bc_set = 'X'.
      LOOP AT p_bc_entry_list INTO w_bc_entry_list WHERE
         viewname = x_header-viewname AND action <> original.
        EXIT.
      ENDLOOP.
      IF vim_first_recnum NE w_bc_entry_list-recnumber.
        vim_first_recnum = w_bc_entry_list-recnumber.
      ELSE.
        proceed = space.
      ENDIF.
    ELSE.
      LOOP AT p_bc_entry_list INTO w_bc_entry_list WHERE
         viewname = x_header-viewname AND action <> original.
        vim_first_recnum = w_bc_entry_list-recnumber.
        EXIT.
      ENDLOOP.
    ENDIF.
  ENDIF.                                                    "IG 1034145
  IF proceed = 'X'.                                         "IG 1034145
    LOOP AT p_bc_entry_list INTO w_bc_entry_list WHERE
     viewname = x_header-viewname AND action <> original.
*    IF w_bc_entry_list-action = neuer_geloescht.   Obsolete, was only
*      DELETE p_bc_entry_list. CONTINUE.            possible at bc-set
*    ENDIF.                              activation in dialog via SM30
      IF first = space.
        first = 'X'.
        INSERT lines of corr_keytab INTO TABLE corr_keytab_save.
        REFRESH corr_keytab.
        CLEAR <table1>.
        transport_active = vim_client_state.
      ENDIF.
* fill corr_keytab
      IF x_header-keylen = keylen_real.
        READ TABLE total WITH KEY <bc_entry_keyx> BINARY SEARCH."#EC *
      ELSE.
        PERFORM vim_read_table_with_gap
                      TABLES   total
                      USING    <bc_entry_keyx>
                               x_namtab[]
                      CHANGING subrc
                               tabix.
        IF subrc = 0.
          READ TABLE total INDEX tabix.
        ENDIF.
      ENDIF.
      IF x_header-bastab EQ space.                            "view
        MOVE <bc_entry_keyx> TO <f1_x>.
        PERFORM (corr_formname) IN PROGRAM (sy-repid) USING
                                              vim_writing_bc_imp_log
                                              dummy.
        REFRESH bc_keytab.
        CLEAR bc_key_needed.
      IF x_header-keylen > vim_max_trsp_keylength. "HCG tabkey up to 255
          bc_key_needed = 'X'.
        ENDIF.
      IF bc_key_needed NE 'X'.           "Look for non-char field in key
          LOOP AT x_namtab WHERE keyflag = 'X'.
            IF 'CNDT' NS x_namtab-inttype. "non charlike field
              bc_key_needed = 'X'.
              EXIT.
            ENDIF.
          ENDLOOP.
        ENDIF.
      IF bc_key_needed NE 'X'.             "Look if viewkey > primtabkey
          CLEAR keys_identical.
          PERFORM vim_comp_roottabkey USING x_header
                                            x_namtab[]
                                   CHANGING keys_identical
                                            rc.
          IF keys_identical EQ space. bc_key_needed = 'X'. ENDIF.
        ENDIF.
      IF bc_key_needed NE space.                 "Tabkeys via new coding
          LOOP AT corr_keytab.
            MOVE-CORRESPONDING corr_keytab TO bc_keytab_wa.
            APPEND bc_keytab_wa TO bc_keytab.
          ENDLOOP.
          PERFORM vim_build_bc_tabkeys USING w_bc_entry_list
                                    CHANGING bc_keytab.
      ELSE.  "Tabkeys as up to now via generated coding (corr_maint_...)
          LOOP AT corr_keytab.
            MOVE-CORRESPONDING corr_keytab TO bc_keytab_wa.
            MOVE corr_keytab-tabkey TO bc_keytab_wa-bc_tabkey.
            APPEND bc_keytab_wa TO bc_keytab.
          ENDLOOP.
*     Look for other languages in bc-set and append to corr_keytab too
          IF x_header-texttbexst NE space.
            READ TABLE bc_keytab INTO bc_keytab_wa
                                 WITH KEY objname = x_header-texttab.
            LOOP AT w_bc_entry_list-forlangu INTO foreign_langu.
              ASSIGN foreign_langu TO <xlangu> CASTING.
              MOVE <xlangu> TO
    <vim_bc_keyx>+x_header-sprasfdpos(cl_abap_char_utilities=>charsize).
              APPEND bc_keytab_wa TO bc_keytab.
            ENDLOOP.
          ENDIF.
        ENDIF.
     ELSE.                                                   "base table
        MOVE <vim_xtotal> TO <table1_x>.
        MOVE-CORRESPONDING e071k TO bc_keytab_wa.
        MOVE e071k-tabkey TO bc_keytab_wa-bc_tabkey.
        bc_keytab_wa-objname = x_header-maintview.
        MOVE <bc_entry_keyx> TO <vim_bc_keyx>(x_header-keylen).
        APPEND bc_keytab_wa TO bc_keytab.
        IF x_header-bastab <> space AND
           x_header-texttbexst NE space AND         "base table with
           <vim_xtotal_text> NE <text_initial_x>.   "text table
          MOVE-CORRESPONDING e071k TO bc_keytab_wa.
          MOVE e071k-tabkey TO bc_keytab_wa-bc_tabkey.
          bc_keytab_wa-objname = x_header-texttab.
          MOVE <vim_xtotal_text> TO <vim_bc_keyx>(x_header-textkeylen).
          APPEND bc_keytab_wa TO bc_keytab.
*       other languages
         READ TABLE x_namtab WITH KEY keyflag = 'X'         "langu field
                                primtabkey = '0000'.    "#EC *
          LOOP AT w_bc_entry_list-forlangu INTO foreign_langu.
            ASSIGN foreign_langu TO <xlangu> CASTING.
            MOVE <xlangu> TO
                 <vim_bc_keyx>+x_namtab-texttabpos(x_namtab-flength).
            APPEND bc_keytab_wa TO bc_keytab.
          ENDLOOP.
        ENDIF.
      ENDIF.                             "base table or view
      CASE w_bc_entry_list-action.
        WHEN neuer_eintrag.
* bc-set imported
          PERFORM bc_entry_log_fill USING     x_header
                                              x_namtab[]
                                              bc_keytab[]
                                              w_bc_entry_list
                                        CHANGING tabkey_values_n.
          CLEAR w_bc_entry_list-action.
        WHEN aendern.
* bc-set entry modified
          PERFORM bc_entry_log_fill USING     x_header
                                              x_namtab[]
                                              bc_keytab[]
                                              w_bc_entry_list
                                        CHANGING tabkey_values_u.
          CLEAR w_bc_entry_list-action.
          MOVE: w_bc_entry_list-id TO w_bc_entry-bcset_id,
                w_bc_entry_list-recnumber TO w_bc_entry-recnumber,
                x_header-viewname TO w_bc_entry-viewname,
                <vim_xtotal> TO <w_bc_entry_x>.
          APPEND w_bc_entry TO bc_entries.
        WHEN geloescht.
* bc-set entry deleted.
          PERFORM bc_entry_log_fill USING     x_header
                                              x_namtab[]
                                              bc_keytab[]
                                              w_bc_entry_list
                                        CHANGING tabkey_values_d.
          DELETE p_bc_entry_list.
      ENDCASE.
      REFRESH corr_keytab.   "weg???
      REFRESH bc_keytab.
    ENDLOOP.
    IF NOT tabkey_values_n IS INITIAL.
      DELETE ADJACENT DUPLICATES FROM tabkey_values_n COMPARING ALL
       FIELDS.
      LOOP AT tabkey_values_n INTO w_tabkey_value.
        CALL FUNCTION 'SCPR_EXT_SCPRACTR_FILL'
          EXPORTING
            tablename         = w_tabkey_value-tablename
            profid            = w_tabkey_value-profid
            recnumber         = w_tabkey_value-recnumber
            viewname          = x_header-maintview
            viewvar           = x_header-viewname
            del_record        = ' '
            new_record        = 'X'
            key               = w_tabkey_value-tabkey
          EXCEPTIONS
            wrong_parameters  = 1
            internal_error    = 2
            key_not_supportet = 3
            fielddescr_error  = 4
            OTHERS            = 5.
        IF sy-subrc <> 0.
          p_msgid = 'SCPR'.
          CASE sy-subrc.
            WHEN 1.
              p_msgty = 'E'.
              p_msgno = '273'.
            WHEN 3.
              p_msgty = 'W'.
              p_msgno = '408'.
            WHEN 4.
              p_msgty = 'E'.
              p_msgno = '395'.
            WHEN OTHERS.
              p_msgty = 'E'.
              p_msgno = '320'.
          ENDCASE.
          PERFORM vim_process_message USING sy-msgid sy-msgty sy-msgty
                                    sy-msgno space space space space.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF NOT tabkey_values_u IS INITIAL.
      DELETE ADJACENT DUPLICATES FROM tabkey_values_u COMPARING ALL
       FIELDS.
      LOOP AT tabkey_values_u INTO w_tabkey_value.
        CALL FUNCTION 'SCPR_EXT_SCPRACTR_FILL'
          EXPORTING
            tablename         = w_tabkey_value-tablename
            profid            = w_tabkey_value-profid
            recnumber         = w_tabkey_value-recnumber
            viewname          = x_header-maintview
            viewvar           = x_header-viewname
            del_record        = ' '
            new_record        = ' '
            key               = w_tabkey_value-tabkey
          EXCEPTIONS
            wrong_parameters  = 1
            internal_error    = 2
            key_not_supportet = 3
            fielddescr_error  = 4
            OTHERS            = 5.
        IF sy-subrc <> 0.
          p_msgid = 'SCPR'.
          CASE sy-subrc.
            WHEN 1.
              p_msgty = 'E'.
              p_msgno = '273'.
            WHEN 3.
              p_msgty = 'W'.
              p_msgno = '408'.
            WHEN 4.
              p_msgty = 'E'.
              p_msgno = '395'.
            WHEN OTHERS.
              p_msgty = 'E'.
              p_msgno = '320'.
          ENDCASE.
          PERFORM vim_process_message USING sy-msgid sy-msgty sy-msgty
                                    sy-msgno space space space space.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF NOT tabkey_values_d IS INITIAL.
      DELETE ADJACENT DUPLICATES FROM tabkey_values_d COMPARING ALL
       FIELDS.
      LOOP AT tabkey_values_d INTO w_tabkey_value.
        CALL FUNCTION 'SCPR_EXT_SCPRACTR_FILL'
          EXPORTING
            tablename         = w_tabkey_value-tablename
            profid            = w_tabkey_value-profid
            recnumber         = w_tabkey_value-recnumber
            viewname          = x_header-maintview
            viewvar           = x_header-viewname
            del_record        = 'X'
            new_record        = ' '
            key               = w_tabkey_value-tabkey
          EXCEPTIONS
            wrong_parameters  = 1
            internal_error    = 2
            key_not_supportet = 3
            fielddescr_error  = 4
            OTHERS            = 5.
        IF sy-subrc <> 0.
          p_msgid = 'SCPR'.
          CASE sy-subrc.
            WHEN 1.
              p_msgty = 'E'.
              p_msgno = '273'.
            WHEN 3.
              p_msgty = 'W'.
              p_msgno = '408'.
            WHEN 4.
              p_msgty = 'E'.
              p_msgno = '395'.
            WHEN OTHERS.
              p_msgty = 'E'.
              p_msgno = '320'.
          ENDCASE.
          PERFORM vim_process_message USING sy-msgid sy-msgty sy-msgty
                                    sy-msgno space space space space.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF NOT corr_keytab_save IS INITIAL.
      INSERT lines of corr_keytab_save INTO TABLE corr_keytab.
    ENDIF.
  ENDIF.
ENDFORM.                               " VIM_BC_LOGS_PUT

*&---------------------------------------------------------------------*
*&      Form  bc_entry_log_fill
*&---------------------------------------------------------------------*
*       fills value table for BC-set activation log for every fix entity
*       field
*----------------------------------------------------------------------*
*      -->P_HEADER  text
*      -->P_NAMTAB  text
*      -->P_CORR_KEYTAB  text
*      -->P_BC_ENTRY  text
*      <--P_TABKEY_VALUE  text
*----------------------------------------------------------------------*
FORM bc_entry_log_fill USING        p_header TYPE vimdesc
                                    p_namtab LIKE x_namtab[]
                                    p_bc_keytab TYPE bc_keytab_type
                               p_bc_entry TYPE vimty_bc_entry_list_type
                          CHANGING p_tabkey_values TYPE vim_bc_tab_logs.

  STATICS: dd28j_tab TYPE TABLE OF dd28j.
  DATA: w_dd28j TYPE dd28j, w_tabkey_value TYPE scpractr,
        w_fields TYPE vimty_fields_type.                   "#EC NEEDED
  FIELD-SYMBOLS: <namtab> TYPE vimnamtab,
                 <dfies> TYPE dfies,                        "#EC *
                 <keytab> TYPE bc_key_type.

  IF p_header-bastab = space.
    READ TABLE dd28j_tab INTO w_dd28j INDEX 1.
    IF sy-subrc <> 0 OR p_header-viewname <> w_dd28j-viewname.
* get join-conditions
      REFRESH dd28j_tab.
      CALL FUNCTION 'DDIF_VIEW_GET'
        EXPORTING
          name          = p_header-viewname
        TABLES
          dd28j_tab     = dd28j_tab
        EXCEPTIONS
          illegal_input = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
    ENDIF.
  ENDIF.
  w_tabkey_value-client = sy-mandt.
  w_tabkey_value-profid = p_bc_entry-id.
  w_tabkey_value-recnumber = p_bc_entry-recnumber.
  w_tabkey_value-viewname = p_header-maintview.             "HCG 6.8.02
  LOOP AT p_namtab ASSIGNING <namtab> WHERE keyflag = space OR
   texttabfld = space.
    READ TABLE p_bc_entry-fields INTO w_fields WITH KEY fieldname =
     <namtab>-viewfield.
    CHECK sy-subrc = 0.
    READ TABLE p_tabkey_values WITH KEY client = sy-mandt
      tablename = <namtab>-bastabname profid = p_bc_entry-id
      recnumber = p_bc_entry-recnumber viewname = p_header-viewname
      TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      LOOP AT p_bc_keytab ASSIGNING <keytab> WHERE
                                pgmid = 'R3TR' AND
                               object = 'TABU' AND
                              objname = <namtab>-bastabname.
        w_tabkey_value-tablename = <namtab>-bastabname.
        w_tabkey_value-tabkey = <keytab>-bc_tabkey.
        APPEND w_tabkey_value TO p_tabkey_values.
      ENDLOOP.
      CHECK sy-subrc = 0.
    ENDIF.
    IF x_header-bastab = space.
* view
      LOOP AT dd28j_tab INTO w_dd28j WHERE viewname = p_header-viewname
       AND ltab = <namtab>-bastabname AND lfield = <namtab>-viewfield.
        READ TABLE p_tabkey_values WITH KEY client = sy-mandt
          tablename = w_dd28j-rtab profid = p_bc_entry-id
          recnumber = p_bc_entry-recnumber viewname = p_header-viewname
          TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
          READ TABLE p_bc_keytab WITH KEY pgmid = 'R3TR'
                            object = 'TABU'
                           objname = w_dd28j-rtab ASSIGNING <keytab>.
          CHECK sy-subrc = 0.
          w_tabkey_value-tablename = w_dd28j-rtab.
          w_tabkey_value-tabkey = <keytab>-bc_tabkey.
          APPEND w_tabkey_value TO p_tabkey_values.
        ENDIF.
      ENDLOOP.
      LOOP AT dd28j_tab INTO w_dd28j WHERE viewname = p_header-viewname
       AND rtab = <namtab>-bastabname AND rfield = <namtab>-viewfield.
        READ TABLE p_tabkey_values WITH KEY client = sy-mandt
          tablename = w_dd28j-ltab profid = p_bc_entry-id
          recnumber = p_bc_entry-recnumber viewname = p_header-viewname
          TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
          LOOP AT p_bc_keytab ASSIGNING <keytab> WHERE
                                pgmid = 'R3TR' AND
                               object = 'TABU' AND
                              objname = w_dd28j-ltab.
            w_tabkey_value-tablename = w_dd28j-ltab.
            w_tabkey_value-tabkey = <keytab>-bc_tabkey.
            APPEND w_tabkey_value TO p_tabkey_values.
          ENDLOOP.
          CHECK sy-subrc = 0.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDLOOP.
ENDFORM.                               " bc_entry_log_fill
*&---------------------------------------------------------------------*
*&      Form  VIM_BC_LOGS_GET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_C_ENTRY_LIST  text
*      -->P_VIEW_NAME  text
*      -->P_HEADER  text
*      -->P_NAMTAB  text
*----------------------------------------------------------------------*
FORM vim_bc_logs_get USING    p_view_name TYPE tabname             "#EC NEEDED
                              p_header TYPE vimdesc
                              p_namtab LIKE x_namtab[]
                CHANGING p_bc_entry_list TYPE vimty_bc_entry_list_ttype.

  STATICS: tablist TYPE TABLE OF scprxtabl, viewname TYPE tabname.

  DATA:    tabkeys TYPE TABLE OF scpractr, w_tablist TYPE scprxtabl,
           bc_entry_list_wa TYPE vimty_bc_entry_list_type, failed(1), "#EC *
           rc LIKE sy-subrc, keys_identical TYPE xfeld,
           x030l_root TYPE x030l,
           x030l_bastab TYPE x030l,
           root_entry TYPE REF TO data,
           bastab_entry TYPE REF TO data,
           tabflags TYPE scpr_actfs, tabflags_wa TYPE scpr_actf,
*           tabflags_quick TYPE HASHED TABLE OF scpr_actf
*            WITH UNIQUE KEY tablename fieldname bcset_id
           tabflags_quick TYPE SORTED TABLE OF scpr_actf
            WITH NON-UNIQUE KEY tablename fieldname bcset_id
            recnumber tabkey INITIAL SIZE 100,
           fields_wa TYPE vimty_fields_type,
           bc_entry_list TYPE STANDARD TABLE OF
            vimty_bc_entry_list_type WITH KEY viewname keys,
            tabkey_wa TYPE scpractr-tabkey,
            tabkeys_wa TYPE scpractr,
            tabix TYPE sy-tabix,
            tabkey_struc(1024) TYPE c,
            flagind TYPE i, data_end TYPE i.
  FIELD-SYMBOLS: <namtab> TYPE vimnamtab, <sektabkey> TYPE scpractr,
                 <tabkeys_main> TYPE scpractr,
                 <bastab> TYPE ANY, <bastab_x> TYPE x,
                 <roottab> TYPE ANY, <roottab_x> TYPE x,
                 <rootfld> TYPE ANY,
                 <tabkey> TYPE x, <viewfld> TYPE ANY,
                 <sektabkeyx> TYPE x,
                 <clnt> TYPE ANY,
                 <tabkey_c> TYPE c.

  DELETE p_bc_entry_list WHERE viewname = p_header-maintview."HCG 6.8.02
  CHECK vim_import_profile = space.
*  CHECK 'TS' NS maint_mode.   "HCG Necessary in show and transport mode
*                    too, e.g. for selection show only data from BC-Sets
  IF viewname <> p_header-viewname.                  "HCG 9/04 HW771997
* make table list
    viewname = p_header-maintview.
    REFRESH tablist.
    w_tablist-sign = 'I'. w_tablist-option = 'EQ'.
    IF p_header-bastab EQ 'X'.                              "S-table
      w_tablist-low = viewname.         "HCG only roottab in tablist
      COLLECT w_tablist INTO tablist.
    ELSE.                                                      "View
      w_tablist-low = p_header-roottab. "HCG only roottab in tablist
      COLLECT w_tablist INTO tablist.
      LOOP AT p_namtab ASSIGNING <namtab>.
        IF <namtab>-keyflag NE space "HCG Field from sektab in Viewkey
           AND <namtab>-bastabname NE w_tablist-low.
          w_tablist-low = <namtab>-bastabname.
          APPEND w_tablist TO tablist.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
* "HCG 9/04: tabkeys does only contain data to the table/view which
* needs to be regarded and tabflags-tablename contains eventually the
* name of a viewvariant, which is in the bcset but not known here.
*  For this reason the content of tabflags-tablename is not known yet.
  CALL FUNCTION 'SCPR_BCSET_PROT_GET_TABKEYS'
    EXPORTING
      viewname = viewname
      clidep   = p_header-clidep                            "824950
    IMPORTING
      actkeys  = tabkeys
      tabflags = tabflags
    TABLES
      tabnames = tablist
    EXCEPTIONS
      no_data  = 1
      OTHERS   = 2.
  CHECK sy-subrc = 0 AND NOT tabkeys IS INITIAL.
* "HCG 04.01.2005 HW806401
* For Perfomance problems with very brad tables (>100 fields)
* delete all lines in tabflags with flag = USE or VAR in SM30 mode
* In BC-Set activation no deletion, due to actopts-no_standrd mode
  IF vim_import_profile EQ space.
    LOOP AT tabflags INTO tabflags_wa.
      IF tabflags_wa-flag EQ vim_profile_use    or
         tabflags_wa-flag EQ vim_profile_fixkey or          "824950
         tabflags_wa-flag EQ vim_profile_key    or          "824950
         tabflags_wa-flag EQ vim_profile_var.               "824950
        DELETE tabflags INDEX sy-tabix.
      ENDIF.
    ENDLOOP.
  ENDIF.
  LOOP AT tabkeys INTO tabkeys_wa.
    tabkey_wa = tabkeys_wa-tabkey.
    tabix = sy-tabix.
    CALL FUNCTION 'SCPR_EXT_ACTKEY_TO_KEY'
      EXPORTING
        tablename        = tabkeys_wa-tablename  "in case: Sektabname
        tablekey         = tabkey_wa
      IMPORTING
        key              = tabkey_struc
      EXCEPTIONS
        wrong_parameters = 1
        key_too_large    = 2
        fielddescr_error = 3
        internal_error   = 4
        OTHERS           = 5.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    ASSIGN tabkey_struc TO <tabkey_c> CASTING.
    tabkeys_wa-tabkey = <tabkey_c>.
    MODIFY tabkeys FROM tabkeys_wa INDEX tabix.
  ENDLOOP.
  bc_entry_list_wa-viewname = p_header-maintview.           "HCG 6.8.02
  IF p_header-clidep <> space.
    READ TABLE p_namtab ASSIGNING <namtab>
     WITH KEY datatype = 'CLNT'.
    ASSIGN COMPONENT <namtab>-viewfield
     OF STRUCTURE <table1_wa> TO <clnt>.
  ENDIF.
  SORT tabflags BY bcset_id recnumber.              "HCG 1.9.03 9/04
  IF p_header-bastab = space.
* build up viewkeys and put'em into entry list
***********************************************************************
* viewkey and roottabkey identical?
    PERFORM vim_comp_roottabkey USING p_header
                                      p_namtab
                                CHANGING keys_identical
                                         rc.
    CHECK rc = 0.
    IF keys_identical = space.
      PERFORM vim_get_x030l USING p_header-roottab
                            CHANGING x030l_root
                                     rc.
      CHECK rc = 0.
      CREATE DATA root_entry TYPE (p_header-roottab).
      ASSIGN: root_entry->* TO <roottab>,
              <roottab> TO <roottab_x> CASTING.
    ENDIF.
    INSERT lines of tabflags INTO TABLE tabflags_quick.
    LOOP AT tabkeys ASSIGNING <tabkeys_main>.               "HCG 9/04
*     tablename = p_header-roottab.
      CLEAR: failed, <table1_wa>.
* get all primary table entries
      bc_entry_list_wa-id = <tabkeys_main>-profid.
      bc_entry_list_wa-recnumber = <tabkeys_main>-recnumber.
      ASSIGN <tabkeys_main>-tabkey TO <tabkey> CASTING.
      IF keys_identical <> space.
* move complete table key to view key
        MOVE <tabkey>(p_header-keylen) TO <f1_wax>.
      ELSE.
* fill view key field by field
        CLEAR: <roottab>.
        MOVE <tabkey>(x030l_root-keylen)
         TO <roottab_x>(x030l_root-keylen).
        LOOP AT p_namtab ASSIGNING <namtab> WHERE keyflag <> space AND
         texttabfld = space.
* build viewkey...
          CHECK <namtab>-datatype <> 'CLNT' OR p_header-clidep = space.
          ASSIGN COMPONENT <namtab>-viewfield
           OF STRUCTURE <table1_wa> TO <viewfld>.
          IF <namtab>-bastabname = p_header-roottab.
* ... from primary table
            ASSIGN COMPONENT <namtab>-bastabfld OF STRUCTURE <roottab>
             TO <rootfld>.
            MOVE <rootfld> TO <viewfld>.
          ELSE.
* ... from secondary table
            failed = 'X'.
            IF NOT <sektabkey> IS ASSIGNED
             OR <sektabkey>-tablename <> <namtab>-bastabname.
              READ TABLE tabkeys ASSIGNING <sektabkey>
               WITH KEY tablename = <namtab>-bastabname
                        recnumber = <tabkeys_main>-recnumber
                        profid = <tabkeys_main>-profid.
              IF sy-subrc <> 0.
                UNASSIGN <sektabkey>.
                EXIT.
              ENDIF.
              PERFORM vim_get_x030l USING <namtab>-bastabname
                                    CHANGING x030l_bastab
                                             rc.
              CHECK rc = 0.
              CREATE DATA bastab_entry TYPE (<namtab>-bastabname).
              ASSIGN: bastab_entry->* TO <bastab>,
                      <bastab> TO <bastab_x> CASTING.
            ENDIF.
            ASSIGN <sektabkey>-tabkey TO <sektabkeyx> CASTING.
            MOVE <sektabkeyx>(x030l_bastab-keylen)
             TO <bastab_x>(x030l_bastab-keylen).
            ASSIGN COMPONENT <namtab>-bastabfld OF STRUCTURE <bastab>
             TO <rootfld>.
            MOVE <rootfld> TO <viewfld>.
            CLEAR failed.
          ENDIF.
        ENDLOOP.
        CHECK failed IS INITIAL.
      ENDIF.
      IF p_header-clidep <> space.
* fill client-field
        MOVE sy-mandt TO <clnt>.
      ENDIF.
      MOVE <f1_wax> TO bc_entry_list_wa-keys.
      REFRESH bc_entry_list_wa-fields.
      LOOP AT p_namtab ASSIGNING <namtab>.
        CHECK <namtab>-datatype <> 'CLNT' OR p_header-clidep = space.
* get bc-set field attributes
        READ TABLE tabflags_quick INTO tabflags_wa WITH KEY                           "#EC CI_SORTSEQ
*         tablename = p_header-viewname               "HCG 9/04
         fieldname = <namtab>-viewfield "HCH 8.8.2002 separat portiert
         bcset_id = bc_entry_list_wa-id
         recnumber = bc_entry_list_wa-recnumber.
        CHECK sy-subrc = 0.
        fields_wa-fieldname = <namtab>-viewfield.
        fields_wa-flag = tabflags_wa-flag.
        APPEND fields_wa TO bc_entry_list_wa-fields.
      ENDLOOP.
      INSERT bc_entry_list_wa INTO TABLE bc_entry_list.
      UNASSIGN <sektabkey>.
    ENDLOOP.
  ELSE.
* move table keys into entry list
***********************************************************************
    LOOP AT tabkeys ASSIGNING <tabkeys_main> WHERE
     tablename = p_header-maintview.
      bc_entry_list_wa-id = <tabkeys_main>-profid.
      bc_entry_list_wa-recnumber = <tabkeys_main>-recnumber.
      ASSIGN <tabkeys_main>-tabkey TO <tabkey> CASTING.
      MOVE <tabkey>(p_header-keylen) TO <table1_wax>(p_header-keylen).
      IF p_header-clidep <> space.
* fill client-field
        MOVE sy-mandt TO <clnt>.
      ENDIF.
      MOVE <f1_wax> TO bc_entry_list_wa-keys.
      REFRESH bc_entry_list_wa-fields.
* get bc-set field attributes                               "HCG 1.9.03
*      LOOP AT tabflags INTO tabflags_wa WHERE ( tablename =
*       p_header-viewname OR tablename = p_header-texttab ) AND
*       bcset_id = bc_entry_list_wa-id
*       AND recnumber = bc_entry_list_wa-recnumber.
*        fields_wa-fieldname = tabflags_wa-fieldname.
*        fields_wa-flag = tabflags_wa-flag.
*        APPEND fields_wa TO bc_entry_list_wa-fields.
*      ENDLOOP.
*------------------get bc-set field attributes (New)----"HCG 1.9.03----*
      READ TABLE tabflags INTO tabflags_wa WITH KEY
*         tablename = p_header-viewname          "HCG 9/04
          bcset_id = bc_entry_list_wa-id
         recnumber = bc_entry_list_wa-recnumber BINARY SEARCH.
      IF sy-subrc = 0.
        flagind = sy-tabix.
        fields_wa-fieldname = tabflags_wa-fieldname.
        fields_wa-flag = tabflags_wa-flag.
        APPEND fields_wa TO bc_entry_list_wa-fields.
        CLEAR data_end.
        WHILE data_end = 0.     "HCG all fields for 1 dataset in a row
          flagind = flagind + 1.
          READ TABLE tabflags INTO tabflags_wa INDEX flagind.
          IF sy-subrc = 0.            "Otherwise end of table tabflags
*           IF tabflags_wa-tablename = p_header-viewname AND "HCG 9/04
            IF tabflags_wa-bcset_id = bc_entry_list_wa-id AND
               tabflags_wa-recnumber = bc_entry_list_wa-recnumber.
              fields_wa-fieldname = tabflags_wa-fieldname.
              fields_wa-flag = tabflags_wa-flag.
              APPEND fields_wa TO bc_entry_list_wa-fields.
            ELSE.
              data_end = 1.
            ENDIF.
          ELSE.
            data_end = 1.               "End of table tabflags reached
          ENDIF.
        ENDWHILE.
*-------------------"HCG 1.9.03-----End of Performance optimization----*
        INSERT bc_entry_list_wa INTO TABLE bc_entry_list.
      ENDIF.
    ENDLOOP.
  ENDIF.
  SORT bc_entry_list.
* should normally not be necessary:
  DELETE ADJACENT DUPLICATES FROM bc_entry_list.
  DESCRIBE TABLE bc_entry_list.
* changing of fix BC-set-entries?
  CLEAR <status>-bcfixnochg.
  IF sy-tfill > 0.
    INSERT lines of bc_entry_list INTO TABLE p_bc_entry_list.
    CALL FUNCTION 'SCPR_AUTHORITY_CHECK'
      EXPORTING
        task             = 'CHGFIXVAL'
      EXCEPTIONS
        wrong_parameters = 1
        no_authority     = 2
        OTHERS           = 3.
    IF sy-subrc <> 0.
      <status>-bcfixnochg = 'N'.
    ELSE.
      <status>-bcfixnochg = 'Y'.
    ENDIF.
  ENDIF.
ENDFORM.                               " VIM_GET_BC_LOGS
*&---------------------------------------------------------------------*
*&      Form  VIM_BC_LOGS_MAINTAIN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_HEADER         Header info of maintenance dialog
*      -->P_BACKGROUND     Flag: 'X' means BC-set import in background
*                                running.
*      <--P_BC_ENTRY_LIST  List of entries coming from BC-set
*----------------------------------------------------------------------*
FORM vim_bc_logs_maintain USING    p_header TYPE vimdesc
                                   p_background TYPE xfeld
                          CHANGING p_bc_entry_list LIKE
                                   vim_bc_entry_list.

  DATA: fields_wa TYPE vimty_fields_type,                  "#EC NEEDED
        subrc TYPE sy-subrc, tabix TYPE sy-tabix.
  STATICS:       viewname_old TYPE vimdesc-viewname,
                 keylen_real TYPE i.
  FIELD-SYMBOLS: <bc_entry> TYPE vimty_bc_entry_list_type,
                 <key> TYPE x, <namtab> TYPE vimnamtab.

  IF p_background = space.
* bc import running in dialogue
    LOOP AT total.
      CHECK ' N' NS <action>.
      READ TABLE p_bc_entry_list ASSIGNING <bc_entry> WITH KEY
       viewname = p_header-viewname keys = <vim_xtotal_key>.
      CHECK sy-subrc = 0.
      CASE <action>.
        WHEN aendern.
* Rel. 4.6 only: does entry contain fix values?
*          LOOP AT <bc_entry>-fields INTO fields_wa
*           WHERE flag = vim_profile_fix.
*            TRANSLATE <bc_entry>-action USING ' U'.
*            EXIT.
*          ENDLOOP.
        WHEN geloescht.
* deleting bc-set-entry
          CASE <bc_entry>-action.
            WHEN neuer_eintrag.
              <bc_entry>-action = neuer_geloescht.
            WHEN OTHERS.
              <bc_entry>-action = geloescht.
          ENDCASE.
*      WHEN zurueckholen.
** undeleting BC-set-entry --> maintain table of BC-Set-entries
*        CASE <bc_entry>-action.
*          WHEN neuer_geloescht.
*            <bc_entry>-action = neuer_eintrag.
*          WHEN OTHERS.
*            <bc_entry>-action = original.
      ENDCASE.
    ENDLOOP.
  ELSE.
* bc import running in background
    DELETE vim_bc_entry_list WHERE viewname = p_header-viewname."#EC *
    PERFORM vim_get_global_table IN PROGRAM saplsvim
                USING 'VIM_BC_ENTRY_LIST'
                       vim_bc_entry_list
                       sy-subrc.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
    IF p_header-viewname NE viewname_old. "HCG: has table align gap?
      viewname_old = p_header-viewname.
      CLEAR keylen_real.
      LOOP AT x_namtab ASSIGNING <namtab> WHERE keyflag = 'X' AND
                                                texttabfld IS INITIAL.
        keylen_real = keylen_real + <namtab>-flength.
      ENDLOOP.
    ENDIF.
    LOOP AT vim_bc_entry_list ASSIGNING <bc_entry> WHERE
     viewname = p_header-viewname.
      ASSIGN <bc_entry>-keys(x_header-keylen) TO <key>.
      IF p_header-keylen = keylen_real.
        READ TABLE total WITH KEY <key> BINARY SEARCH.     "#EC *
        subrc = sy-subrc.
      ELSE.
        PERFORM vim_read_table_with_gap
                    TABLES   total
                    USING    <key>
                             x_namtab[]
                    CHANGING subrc
                             tabix.
        IF subrc = 0.
          READ TABLE total INDEX tabix.
        ENDIF.
      ENDIF.
* bc-set entry really imported?
      IF subrc <> 0 OR 'NUD' NS <action>.
        DELETE vim_bc_entry_list.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                               " VIM_BC_LOGS_MAINTAIN
*&---------------------------------------------------------------------*
*&      Form  VIM_BC_LOGS_USE
*&---------------------------------------------------------------------*
*       delivers field attribute defined in BC-sets
*----------------------------------------------------------------------*
*      -->P_FIELD         text
*      -->P_VIM_BC_ENTRY  text
*      <--P_SCREEN_INPUT  text
*      <--P_MODIFY_SCREEN  text
*----------------------------------------------------------------------*
FORM vim_bc_logs_use USING p_field TYPE fieldname
                           p_vim_bc_entry TYPE vimty_bc_entry_list_type
                     CHANGING p_screen LIKE screen
                              p_modify_screen TYPE xfeld.

  DATA w_field TYPE vimty_fields_type.

  READ TABLE p_vim_bc_entry-fields INTO w_field
   WITH TABLE KEY fieldname = p_field.
  CHECK sy-subrc = 0.
  IF w_field-flag = vim_profile_fix.
    p_screen-input = 0.
    p_modify_screen = 'X'.
  ENDIF.
ENDFORM.                               " VIM_BC_LOGS_USE
*&---------------------------------------------------------------------*
*&      Form  vim_chng_fix_flds
*&---------------------------------------------------------------------*
*       make fix values form bc-sets modifiable
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM vim_chng_fix_flds.
  IF vim_actlinks NE x_header-viewname.
    PERFORM vim_bc_logs_get USING view_name x_header x_namtab[]
                          CHANGING vim_bc_entry_list.
    vim_actlinks = x_header-viewname. "For which actlinks are valid
  ENDIF.
  IF <status>-bcfixnochg = 'Y'.
    vim_bc_chng_allowed = 'X'.
  ELSE.
    MESSAGE e202(sv).
*   Sie haben keine Berechtigung, Felder mit fixen BC-Set-Werten zu ände
  ENDIF.
ENDFORM.                               " vim_chng_fix_flds
*&---------------------------------------------------------------------*
*&      Form  vim_get_x030l
*&---------------------------------------------------------------------*
*       Delivers X030l fron dictionary.
*----------------------------------------------------------------------*
*      -->P_TABNAME     tablename
*      <--P_X030L
*      <--P_RC
*----------------------------------------------------------------------*
FORM vim_get_x030l  USING    p_tabname TYPE tabname
                    CHANGING p_x030l TYPE x030l
                             p_rc LIKE sy-subrc.
  CALL FUNCTION 'DDIF_NAMETAB_GET'
    EXPORTING
      tabname  = p_tabname
    IMPORTING
      x030l_wa = p_x030l
    EXCEPTIONS
      OTHERS   = 1.
  p_rc = sy-subrc.
ENDFORM.                    " vim_get_x030l
*&---------------------------------------------------------------------*
*&      Form  vim_show_fix_flds
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM vim_bc_show_fix_flds.
  DATA: p_tabtype TYPE objh-objecttype,
        p_tabname TYPE scpr_tabl.


  IF vim_actlinks NE x_header-viewname.
    PERFORM vim_bc_logs_get USING view_name x_header x_namtab[]
                          CHANGING vim_bc_entry_list.
    vim_actlinks = x_header-viewname. "For which actlinks are valid
  ENDIF.
  p_tabname = x_header-maintview. "HCG 6.8.02 actlinks for maintview
  IF x_header-bastab = space.
    p_tabtype = 'V'.
  ELSE.
    p_tabtype = 'S'.
  ENDIF.
  LOOP AT extract.
    IF <xmark> NE markiert.
      CONTINUE.
    ELSE.
      MOVE <vim_extract_struc> TO <table1>.
      CALL FUNCTION 'SCPR_ACTIVATION_INFOS_SHOW'
        EXPORTING
          tablename             = p_tabname
          tabletype             = p_tabtype
          record                = <table1>
        EXCEPTIONS
          fielddefinition_error = 1
          no_tvdir_entry        = 2
          table_not_found       = 3
          table_to_large        = 4
          ddif_internal_error   = 5
          wrong_parameters      = 6
          internal_error        = 7
          no_actlinks           = 8
          key_too_large         = 9
          OTHERS                = 10.
      CASE sy-subrc.
        WHEN 0.
        WHEN 1.
          MESSAGE e395(scpr) RAISING fielddefinition_error.                   "#EC *
        WHEN 2.
          MESSAGE e028(scpr) WITH p_tabname RAISING no_tvdir_entry.
        WHEN 3.
          MESSAGE e120(scpr) WITH p_tabname RAISING table_not_found.
        WHEN 4.
          MESSAGE e026(scpr) WITH p_tabname RAISING table_to_large.           "#EC *
        WHEN 5.
          MESSAGE e035(scpr) RAISING ddif_internal_error.                     "#EC *
        WHEN 6.
          MESSAGE e273(scpr) RAISING wrong_parameters.                        "#EC *
        WHEN 8.
          MESSAGE s399(scpr) RAISING no_actlinks.                             "#EC *
        WHEN 9.
          MESSAGE e408(scpr) RAISING key_too_large.                           "#EC *
        WHEN OTHERS.
          MESSAGE e320(scpr) RAISING internal_error.
      ENDCASE.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " vim_show_fix_flds
*&---------------------------------------------------------------------*
*&      Form  vim_build_bc_tabkeys
*&---------------------------------------------------------------------*
*   To build up table keys for views with keylen > 120 up to 256
*   and / or non-character like fields.
*----------------------------------------------------------------------*
*      <--P_BC_KEYTAB  text
*----------------------------------------------------------------------*
FORM vim_build_bc_tabkeys USING bc_entry_list_wa TYPE
                                       vimty_bc_entry_list_type
                       CHANGING p_bc_keytab TYPE bc_keytab_type.

  TYPES: BEGIN OF tablist_type,
           tabname TYPE objs-tabname,
         END OF tablist_type.

  STATICS: cg_dd28j_tab LIKE dd28j OCCURS 30,
           old_viewname LIKE vimdesc-viewname,
           all_dfiestab LIKE dfies OCCURS 40.

  DATA: objstablist TYPE TABLE OF tablist_type, "#EC NEEDED
        namtab_wa TYPE vimnamtab, "#EC NEEDED
        tabname_wa TYPE objs-tabname,
        dd28j_wa LIKE LINE OF cg_dd28j_tab,
        primtab_entry TYPE REF TO data,
        sektab_entry TYPE REF TO data,
        p_bc_keytab_wa LIKE LINE OF p_bc_keytab,
        keytab_index TYPE sy-tabix,
        bc_keylen TYPE i, flag(1) TYPE c,
        cg_langu(1) TYPE c,
        cg_dfiestab LIKE dfies OCCURS 10,
        dfies_wa LIKE LINE OF cg_dfiestab,
        piecelist TYPE TABLE OF objs-tabname,
        foreign_langu LIKE sy-langu,
        langu_fieldname TYPE dfies-fieldname,
        p_bc_keytab_langu TYPE bc_keytab_type,
        w_bc_entry_list TYPE vimty_bc_entry_list_type.  "#EC NEEDED

  FIELD-SYMBOLS: <primtab> TYPE ANY, <sektab> TYPE ANY,
                 <viewfld> TYPE ANY,
                 <primtabfld> TYPE ANY, <sektabfld> TYPE ANY,
                 <bc_tabkey> TYPE bc_key_type-bc_tabkey,    "#EC *
                 <tabkey_x> TYPE x, <tabkey_struc_x> TYPE x.

  IF x_header-viewname NE old_viewname.
    old_viewname = x_header-viewname.
    CALL FUNCTION 'DDIF_VIEW_GET'
      EXPORTING
        name          = x_header-viewname
        state         = 'A'
        langu         = sy-langu
      IMPORTING
        gotstate      = flag
      TABLES
        dd28j_tab     = cg_dd28j_tab
      EXCEPTIONS
        illegal_input = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
      MESSAGE e164(sv) WITH tabname_wa RAISING view_not_found.
    ENDIF.
    IF flag = space.
      MESSAGE e306(sv) WITH tabname_wa RAISING view_not_found.
    ENDIF.
*   Get tables from piecelist
    SELECT tabname FROM objs INTO tabname_wa
                       WHERE objectname = x_header-viewname
                         AND objecttype = 'V'.
      APPEND tabname_wa TO piecelist.
    ENDSELECT.
    REFRESH all_dfiestab.
    LOOP AT piecelist INTO tabname_wa.
      REFRESH cg_dfiestab.
      CALL FUNCTION 'DDIF_NAMETAB_GET'
        EXPORTING
          tabname   = tabname_wa
        TABLES
          dfies_tab = cg_dfiestab[]
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
      IF sy-subrc NE 0.
        MESSAGE e028(sv) WITH tabname_wa RAISING view_not_found.
      ENDIF.
      LOOP AT cg_dfiestab INTO dfies_wa.
        APPEND dfies_wa TO all_dfiestab.
      ENDLOOP.
    ENDLOOP.
  ENDIF.
  LOOP AT p_bc_keytab INTO p_bc_keytab_wa.
    keytab_index = sy-tabix.
    IF p_bc_keytab_wa-objname = x_header-roottab.
*-----Build tabkey for root-table from viewkey-------------------------
      CREATE DATA primtab_entry TYPE (x_header-roottab).
      ASSIGN primtab_entry->* TO <primtab>.
      LOOP AT x_namtab WHERE keyflag = 'X' AND
                           bastabname = x_header-roottab.
        ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE
                   <vim_total_struc> TO <viewfld>.
        ASSIGN COMPONENT x_namtab-bastabfld OF STRUCTURE <primtab>
                   TO <primtabfld>.
        MOVE <viewfld> TO <primtabfld>.
      ENDLOOP.                 " Primtabkey completely in <primtab>
      PERFORM vim_get_bc_keylen    "Analog corr_maint_>>viewname<<
              USING x_header-roottab
           CHANGING bc_keylen.
      ASSIGN <primtab> TO <tabkey_struc_x> CASTING.
      ASSIGN p_bc_keytab_wa-bc_tabkey TO <tabkey_x> CASTING.
      MOVE <tabkey_struc_x>(bc_keylen) TO <tabkey_x>(bc_keylen).
      MODIFY p_bc_keytab INDEX keytab_index FROM p_bc_keytab_wa.
    ELSEIF p_bc_keytab_wa-objname EQ x_header-texttab.
*-----Build tabkeys for textable of view from viewkey field by field---
      REFRESH p_bc_keytab_langu.
      tabname_wa = p_bc_keytab_wa-objname.
      CREATE DATA sektab_entry TYPE (tabname_wa).
      ASSIGN sektab_entry->* TO <sektab>.
      PERFORM vim_get_bc_keylen    "Analog corr_maint_>>viewname<<
                  USING tabname_wa
                  CHANGING bc_keylen.
      LOOP AT all_dfiestab INTO dfies_wa WHERE tabname = tabname_wa
                                          AND keyflag = 'X'.
        CLEAR cg_langu.
        READ TABLE cg_dd28j_tab WITH KEY rtab = tabname_wa
                                       rfield = dfies_wa-fieldname
                                    INTO dd28j_wa.
        IF sy-subrc EQ 0.
          READ TABLE x_namtab WITH KEY bastabname = dd28j_wa-ltab
                                        bastabfld = dd28j_wa-lfield.
        ELSE.       "Field not in join -> additional keyfield in view
          READ TABLE x_namtab WITH KEY bastabname = tabname_wa
                                    bastabfld = dfies_wa-fieldname.
          IF sy-subrc NE 0.    "Then it must be langu field of texttab
            cg_langu = 'X'.
          ENDIF.
        ENDIF.
        IF cg_langu EQ space.                 "Field is not langu field
          ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE
                     <vim_total_struc> TO <viewfld>.
          ASSIGN COMPONENT dfies_wa-fieldname OF STRUCTURE
                                           <sektab> TO <sektabfld>.
          MOVE <viewfld> TO <sektabfld>.
        ELSE.                                     "Field is langu field
          langu_fieldname = dfies_wa-fieldname.
          ASSIGN COMPONENT dfies_wa-fieldname OF STRUCTURE
                                           <sektab> TO <sektabfld>.
          MOVE sy-langu TO <sektabfld>.
        ENDIF.
        ASSIGN <sektab> TO <tabkey_struc_x> CASTING.
        ASSIGN p_bc_keytab_wa-bc_tabkey TO <tabkey_x> CASTING.
        MOVE <tabkey_struc_x>(bc_keylen) TO <tabkey_x>(bc_keylen).
      ENDLOOP.
      MODIFY p_bc_keytab INDEX keytab_index FROM p_bc_keytab_wa.
*     Look for other languages in bc-set and append to p_bc_keytab too
      ASSIGN COMPONENT langu_fieldname OF STRUCTURE
                                           <sektab> TO <sektabfld>.
      LOOP AT bc_entry_list_wa-forlangu INTO foreign_langu.
        MOVE foreign_langu TO <sektabfld>.
        MOVE <tabkey_struc_x>(bc_keylen) TO <tabkey_x>(bc_keylen).
        APPEND p_bc_keytab_wa TO p_bc_keytab_langu.
      ENDLOOP.
    ELSE.
*-----Build tabkeys for secondary tabs from viewkey field by field-----
      tabname_wa = p_bc_keytab_wa-objname.
      CREATE DATA sektab_entry TYPE (tabname_wa).
      ASSIGN sektab_entry->* TO <sektab>.
      PERFORM vim_get_bc_keylen    "Analog corr_maint_>>viewname<<
                  USING tabname_wa
                  CHANGING bc_keylen.
      LOOP AT all_dfiestab INTO dfies_wa WHERE tabname = tabname_wa
                                          AND keyflag = 'X'.
        CLEAR cg_langu.
        READ TABLE cg_dd28j_tab WITH KEY rtab = tabname_wa
                                       rfield = dfies_wa-fieldname
                                    INTO dd28j_wa.
        IF sy-subrc EQ 0.
          READ TABLE x_namtab WITH KEY bastabname = dd28j_wa-ltab
                                        bastabfld = dd28j_wa-lfield.
        ELSE.       "Field not in join -> additional keyfield in view
          READ TABLE x_namtab WITH KEY bastabname = tabname_wa
                                    bastabfld = dfies_wa-fieldname.
          IF sy-subrc NE 0.                 "Then it must be an error
*            error.!!!!
          ENDIF.
        ENDIF.
        ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE
                   <vim_total_struc> TO <viewfld>.
        ASSIGN COMPONENT dfies_wa-fieldname OF STRUCTURE
                                         <sektab> TO <sektabfld>.
        MOVE <viewfld> TO <sektabfld>.
        ASSIGN <sektab> TO <tabkey_struc_x> CASTING.
        ASSIGN p_bc_keytab_wa-bc_tabkey TO <tabkey_x> CASTING.
        MOVE <tabkey_struc_x>(bc_keylen) TO <tabkey_x>(bc_keylen).
      ENDLOOP.
      MODIFY p_bc_keytab INDEX keytab_index FROM p_bc_keytab_wa.
    ENDIF.
  ENDLOOP.
***********************************************************************
  "HCG Look for sektab, which is not in piecelist but has keyfield
  "in viewkey and write actlink anyway "HW664698
  LOOP AT x_namtab WHERE keyflag = 'X'.
*   View Variant may not have all the key fields selected
    IF x_namtab-bastabname NE space.                        "IG 1020971
      READ TABLE p_bc_keytab WITH KEY objname = x_namtab-bastabname
                                             TRANSPORTING NO FIELDS.
      IF sy-subrc NE 0. "bastab of keyfield not in piecelist -> add
        READ TABLE p_bc_keytab INTO p_bc_keytab_wa INDEX 1.
        p_bc_keytab_wa-objname = x_namtab-bastabname.
        CLEAR p_bc_keytab_wa-bc_tabkey.
        REFRESH cg_dfiestab.
        tabname_wa = x_namtab-bastabname.
        CALL FUNCTION 'DDIF_NAMETAB_GET'
          EXPORTING
            tabname   = tabname_wa
          TABLES
            dfies_tab = cg_dfiestab[]
          EXCEPTIONS
            not_found = 1
            OTHERS    = 2.
        IF sy-subrc NE 0.
          MESSAGE e028(sv) WITH tabname_wa RAISING view_not_found.
        ENDIF.
        LOOP AT cg_dfiestab INTO dfies_wa.
          APPEND dfies_wa TO all_dfiestab.
        ENDLOOP.
*-----Build tabkeys for secondary tabs from viewkey field by field-----
        CREATE DATA sektab_entry TYPE (tabname_wa).
        ASSIGN sektab_entry->* TO <sektab>.
        PERFORM vim_get_bc_keylen    "Analog corr_maint_>>viewname<<
                    USING tabname_wa
                    CHANGING bc_keylen.
        LOOP AT all_dfiestab INTO dfies_wa WHERE tabname = tabname_wa
                                            AND keyflag = 'X'.
          CLEAR cg_langu.
          READ TABLE cg_dd28j_tab WITH KEY rtab = tabname_wa
                                         rfield = dfies_wa-fieldname
                                      INTO dd28j_wa.
          IF sy-subrc EQ 0.
            READ TABLE x_namtab WITH KEY bastabname = dd28j_wa-ltab
                                          bastabfld = dd28j_wa-lfield.
          ELSE.       "Field not in join -> additional keyfield in view
            READ TABLE x_namtab WITH KEY bastabname = tabname_wa
                                      bastabfld = dfies_wa-fieldname.
          ENDIF.
          IF sy-subrc NE 0.
            IF dfies_wa-datatype = 'CLNT'.
              ASSIGN COMPONENT dfies_wa-fieldname OF STRUCTURE
                                             <sektab> TO <sektabfld>.
             <sektabfld> = sy-mandt."HCG clnt in namtab with primtabname
            ELSE.
*            error. Field/SEKTAB not in join cond. and not in namtab.
            ENDIF.
          ELSE.
            ASSIGN COMPONENT x_namtab-viewfield OF STRUCTURE
                       <vim_total_struc> TO <viewfld>.
            ASSIGN COMPONENT dfies_wa-fieldname OF STRUCTURE
                                             <sektab> TO <sektabfld>.
            MOVE <viewfld> TO <sektabfld>.
          ENDIF.
          ASSIGN <sektab> TO <tabkey_struc_x> CASTING.
          ASSIGN p_bc_keytab_wa-bc_tabkey TO <tabkey_x> CASTING.
          MOVE <tabkey_struc_x>(bc_keylen) TO <tabkey_x>(bc_keylen).
        ENDLOOP.
        APPEND p_bc_keytab_wa TO p_bc_keytab.
      ENDIF.
    ENDIF.
  ENDLOOP.
***********************************************************************
  APPEND LINES OF p_bc_keytab_langu TO p_bc_keytab.
ENDFORM.                    " vim_build_bc_tabkeys
*&---------------------------------------------------------------------*
*&      Form  vim_read_table_with_gap
*&---------------------------------------------------------------------*
*       Implementierung des
*         READ TABLE <it_data> WITH KEY <key> BINARY SEARCH
*       für Tabellen mit Alignment-Lücken (Nicht-Character-Feld wie
*       z.B. ein INT4-Feld im Schlüssel)
*
*       Voraussetzung zum Aufruf: gap_table ist sortiert
*
*       Rückgabewert: SUBRC = 0    1. Datensatz passend zum KEY
*       (analog                    wurde gefunden (wichtig für
*        BINARY                    BC-Sets mit Schlüsselkonflikt)
*        SEARCH)                   Datensatznummer in TABIX
*
*                     SUBRC = 4    Eintrag wurde nicht gefunden
*                                  Datensatznummer + 1 in TABIX
*
*                     SUBRC = 8    Eintrag wurde nicht gefunden
*                                  Letzte Datensatznummer + 1 in TABIX
*----------------------------------------------------------------------*
*     To use function SCPR_CTRL_CT_COMP_TWO_RECORDS table of field
*     description in SCPR format is created and filled partly.
*----------------------------------------------------------------------*
FORM vim_read_table_with_gap TABLES   gap_table
                         USING    key   TYPE x
                                  namtab LIKE x_namtab[]
                         CHANGING subrc TYPE sy-subrc
                                  tabix TYPE sy-tabix.

  TYPES: scpr_x8192(8192) TYPE x.
  DATA: result  TYPE scpr_txt20,
        tab_i   TYPE sy-tabix,
        tab_j   TYPE sy-tabix,
        tab_k   TYPE sy-tabix,
        tab_len TYPE sy-tabix.

  DATA: align TYPE f, wa_8192 TYPE scpr_x8192,      "#EC NEEDED
        it_fldnames TYPE STANDARD TABLE OF scpr_flddescr,
        fldnames_wa LIKE LINE OF it_fldnames.
*        gap_table_wa(2048) TYPE c.
  FIELD-SYMBOLS: <wa_it_data> TYPE x,
                 <namtab> TYPE vimnamtab.

* Fill necessary fields in it_fieldnames from namtab
  LOOP AT namtab ASSIGNING <namtab> WHERE keyflag = 'X'
                                    AND texttabfld = space.
    fldnames_wa-fieldname = <namtab>-viewfield.
    fldnames_wa-position = <namtab>-position.
    fldnames_wa-intlen = <namtab>-flength.
    fldnames_wa-keyflag = 'X'.
    fldnames_wa-flag = 'FKY'. "KEY would do the same job...
    APPEND fldnames_wa TO it_fldnames.
  ENDLOOP.

  DESCRIBE TABLE gap_table LINES tab_len.
  tab_i = 1.
  tab_j = tab_len.
  subrc = 8.
  tabix = tab_len + 1.
  ASSIGN wa_8192 TO <wa_it_data>.
* sturkturierte oder non-sturkturierte sollte beobachten
  ASSIGN gap_table TO <wa_it_data> CASTING.                 "XB H628871


  DO.
    IF tab_i > tab_j.
*     Datensatz wurde nicht gefunden
      subrc = 4.
      tabix = tab_k + 1.
      EXIT.
    ENDIF.
    tab_k = ( tab_i + tab_j ) / 2.

*    READ TABLE gap_table INTO gap_table_wa INDEX tab_k.
    READ TABLE gap_table INDEX tab_k.                       "XB H628871

    CALL FUNCTION 'SCPR_CTRL_CT_COMP_TWO_RECORDS'
      EXPORTING
        cu_lines      = <wa_it_data>
        bc_lines      = key
        compare_key   = 'X'
        ip_align_data = 'X'
      IMPORTING
        RESULT        = RESULT
      TABLES
        it_fldnames   = it_fldnames.

    IF result = 'LT'.
      tab_j = tab_k - 1.
    ELSEIF result = 'GT'.
      tab_i = tab_k + 1.
    ELSE.
      subrc = 0.
      tabix = tab_k.
      EXIT.
    ENDIF.
  ENDDO.
ENDFORM.                    " read_table_with_gap
