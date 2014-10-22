*&--------------------------------------------------------------------*
*&      Form CHECK_ALLOWED_KEYRANGES                                  *
*&--------------------------------------------------------------------*
* check new entries fitting allowed keyranges                         *
*---------------------------------------------------------------------*
*                                                                     *
*&--------------------------------------------------------------------*
FORM check_allowed_keyranges.
  DATA: roottab_key LIKE e071k-tabkey,
        tablename LIKE vimdesc-viewname,
        allowed,
        mess_type(1) TYPE c VALUE 'W',
        ale_msgty(1) TYPE c VALUE 'E', ale_msgno LIKE sy-msgno,
        ale_msgid LIKE sy-msgid, ale_msgv1 LIKE sy-msgv1,
        ale_msgv2 LIKE sy-msgv2, ale_msgv3 LIKE sy-msgv3,
        ale_msgv4 LIKE sy-msgv4,
        roottab_row TYPE REF TO data,
        keytab_loc TYPE TABLE OF tbl8096,
        keytab_wa LIKE LINE OF keytab_loc,
        keytab_wa2 LIKE LINE OF keytab_loc,
        allowed_keys TYPE TABLE OF tbl8096,
        sctm_fill_cache, viewtype,
        p_roottab_keylen TYPE i.                            "XB H651706


  FIELD-SYMBOLS: <key_x> TYPE x, <h_old_mkey2> TYPE x,
                 <roottab_row_x> TYPE x,
                 <f_field1> TYPE ANY,
                 <f_field2> TYPE ANY,
                 <roottab_row> TYPE ANY.

  CHECK vim_keyrange_alr_checked EQ space.
* check synchronizer keyspecific stuff
  IF vim_sync_keyspec_check NE space.
    sctm_fill_cache = 'X'.
    IF x_header-bastab EQ space.
      viewtype = 'V'.
    ELSE.
      viewtype = 'S'.
    ENDIF.
    REFRESH keytab_loc.
    REFRESH allowed_keys.
    keytab_wa-line =  <f1_x>.
    APPEND keytab_wa TO keytab_loc.             "Table with 1 line only
    CALL FUNCTION 'SCTM_CHECK_VIEW_KEY'
      EXPORTING
        viewname              = x_header-viewname
        viewtype              = viewtype
        bcset                 = vim_bcset_id  "if NE space: BC-set act
        fill_cache            = sctm_fill_cache
*     IMPORTING               "HCG: Already set in justify_action_mode
*       EDIT_FLAG           = vim_sync_edit_lock
*       KESPEC_FLAG         = vim_sync_keyspec_check
      TABLES
        query_tab             = keytab_loc
        allowed_tab           = allowed_keys
      EXCEPTIONS
        no_sync_present       = 1
        old_sync_system       = 2
        OTHERS                = 3.
    IF sy-subrc <> 0.     "Ignore check_result but no message to user
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      allowed = 'X'.
      CLEAR vim_sync_key_lock_del.     "If no connection: open all
    ELSE.
      CLEAR keytab_wa2-line.
      READ TABLE allowed_keys INTO keytab_wa2 INDEX 1.
      IF keytab_wa-line(x_header-keylen) NE
         keytab_wa2-line(x_header-keylen).  "Key is not changeable
        allowed = 'A'. ale_msgno = '182'. ale_msgid = 'SV'.
        MOVE vim_sctm_sourcesys TO ale_msgv1.
        vim_sync_key_lock_del = 'X'.
      ELSE.
        allowed = 'X'.
        CLEAR vim_sync_key_lock_del.
      ENDIF.
    ENDIF.
  ENDIF.
* check ALE keyspecific stuff
  IF vim_ale_keyspec_check NE space AND allowed NE 'A'. "HCG HW 718225
    ASSIGN roottab_key TO <key_x> CASTING.
    <key_x> = <f1_x>. allowed = 'X'.
    LOOP AT vim_ale_keyspec_objtab.
      CALL FUNCTION 'ALE_EDIT_KEY_CHECK'
        EXPORTING
          objecttype          = vim_ale_keyspec_objtab-otype
          objectname          = vim_ale_keyspec_objtab-oname
          objectkey           = roottab_key
        EXCEPTIONS
          key_no_maintainance = 1.
      IF sy-subrc NE 0.
        allowed = 'A'. ale_msgno = sy-msgno. ale_msgid = sy-msgid.
        ale_msgv1 = sy-msgv1. ale_msgv2 = sy-msgv2.
        ale_msgv3 = sy-msgv3. ale_msgv4 = sy-msgv4.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.
  IF allowed <> 'A'.                               "329818/2001
    vim_keyrange_alr_checked = 'X'.                "329818/2001
  ENDIF.
* check namespace
  IF ( vim_ale_keyspec_check EQ space AND
       vim_sync_keyspec_check EQ space ) OR
     ( x_header-customauth CO sap_cust_ctrl_classes AND
       allowed CO ' X' ).
    IF vim_import_profile EQ space. "Skip namespace check in BC-Set Akt
      IF x_header-bastab EQ space.       "view
        MOVE x_header-roottab TO tablename.
      ELSE.                              "base table
        MOVE x_header-viewname TO tablename.
      ENDIF.
      ASSIGN roottab_key TO <key_x> CASTING.
* XB H617717B
* rerange the roottab content from view (<table1>).
      IF x_header-bastab EQ space.       "view
        CREATE DATA roottab_row TYPE (x_header-roottab).
        ASSIGN roottab_row->* TO <roottab_row>.
        ASSIGN <roottab_row> TO <roottab_row_x> CASTING.
        LOOP AT x_namtab.
          CHECK x_namtab-primtabkey <> 0.
          ASSIGN COMPONENT x_namtab-viewfield
              OF STRUCTURE <table1> TO <f_field1>.
          ASSIGN COMPONENT x_namtab-primtabkey
              OF STRUCTURE <roottab_row> TO <f_field2>.
          <f_field2> = <f_field1>.
        ENDLOOP.
*XB H651706B
        PERFORM vim_get_trspkeylen
                 USING x_header-roottab
                 CHANGING p_roottab_keylen.
        IF x_header-generictrp <> space.
          MOVE <roottab_row_x>(x_header-maxtrkeyln) TO <key_x>.
        ELSE.
          MOVE <roottab_row_x>(p_roottab_keylen) TO <key_x>.
*XB H651706E
        ENDIF.
      ELSE.                     "base table no change the sequence
        IF x_header-generictrp <> space.
          MOVE <f1_x>(x_header-maxtrkeyln) TO <key_x>.
        ELSE.
          MOVE <f1_x>(x_header-keylen) TO <key_x>.
        ENDIF.
      ENDIF.
* XB H617717E
*    IF x_header-generictrp <> space.
*      MOVE <f1_x>(x_header-maxtrkeyln) TO <key_x>.
*    ELSE.
*      MOVE <f1_x>(x_header-keylen) TO <key_x>.
*    ENDIF.
      CALL FUNCTION 'CHECK_CUSTOMER_NAMES'
        EXPORTING
          tablename   = tablename
          tablekey    = roottab_key
        IMPORTING
          key_allowed = allowed.
    ENDIF.                   "No BC-Set activation       "HCG HW 718225
  ENDIF.

  IF allowed CO ' A'.
    EXPORT vimviewname FROM x_header-viewname TO MEMORY ID sy-uname.
    IF x_header-delmdtflag NE space AND status-mode EQ detail_bild.
      mess_type = 'S'.
    ELSEIF allowed EQ 'A'.
      mess_type = ale_msgty.
      PERFORM set_pf_status USING 'ERROR'.
    ENDIF.
    IF neuer EQ 'J'.                   "add mode
      IF x_header-delmdtflag <> space.
        ASSIGN <vim_h_old_mkey>(x_header-keylen) TO <h_old_mkey2>.
        IF <h_old_mkey2> = <f1_x>.
*      IF x_header-delmdtflag NE space AND <f1> EQ vim_old_viewkey.
          CHECK check_all_keyr_scnd_time EQ space. "simul. of warning
        ENDIF.
      ENDIF.
*     MESSAGE E019(SV). "Bitte den Schlüssel aus dem zulässigen Namensra
      CLEAR: vim_keyrange_alr_checked, vim_key_alr_checked.
      IF allowed NE 'A'.
        MESSAGE ID 'SV' TYPE mess_type NUMBER '019'.
      ELSE.
        MESSAGE ID ale_msgid TYPE mess_type NUMBER ale_msgno WITH
          ale_msgv1 ale_msgv2 ale_msgv3 ale_msgv4.
      ENDIF.
      IF x_header-delmdtflag NE space.
        IF status-mode EQ detail_bild.
          <h_old_mkey2> = <f1_x>.
*          vim_old_viewkey = <f1>.
          check_all_keyr_scnd_time = allowed.    "simulation of warning
          TRANSLATE check_all_keyr_scnd_time USING ' XA '.
          TRANSLATE neuer USING 'JX'.
          CLEAR: function, ok_code. LEAVE SCREEN.
        ENDIF.
        <h_old_mkey2> = <f1_x>.
*        vim_old_viewkey = <f1_x>.
        check_all_keyr_scnd_time = 'X'."simulation of warning
      ENDIF.
    ELSE.                              "update mode.
      IF allowed NE 'A'.
        IF vim_special_mode EQ vim_delete.
          mess_type = 'S'.
        ELSE.
          mess_type = 'W'.
        ENDIF.
        IF vim_system_type NE 'SAP'.
          MESSAGE ID 'SV' TYPE mess_type NUMBER '117'.
        ELSE.
*       MESSAGE W136(SV). "Vorsicht bei Änderungen, Eintrag gehört dem K
          MESSAGE ID 'SV' TYPE mess_type NUMBER '136'.
        ENDIF.
      ELSE.
        IF vim_special_mode EQ vim_delete.
          mess_type = 'S'.
        ELSE.
          mess_type = ale_msgty.
        ENDIF.
        MESSAGE ID ale_msgid TYPE mess_type NUMBER ale_msgno WITH
          ale_msgv1 ale_msgv2 ale_msgv3 ale_msgv4.
      ENDIF.
    ENDIF.
    sy-subrc = 8.
  ELSE.
    CLEAR sy-subrc.
  ENDIF.
ENDFORM.                    "check_allowed_keyranges
