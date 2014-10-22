*----------------------------------------------------------------------*
***INCLUDE LSVIMF64 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  vim_synchronizer_call
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CU_KO200_TAB[]  text
*      -->P_CORR_KEYTAB[]  text
*      -->P_SPACE  text
*----------------------------------------------------------------------*
FORM vim_synchronizer_call  USING
                                 p_cu_ko200_tab TYPE vim_ko200_tab_type
                                 p_corr_keytab TYPE tr_keys
                                 p_synchronizer_flag TYPE xfeld.

  STATICS: e071k_loc TYPE TABLE OF e071k,
          e071_loc TYPE TABLE OF e071.
  STATICS: sv_trkorr     TYPE trkorr,       "VG 31 Mar 2004
           sv_at_tr_change,
           sv_project_id TYPE project_id,
           sv_strkorr    TYPE trkorr.
  DATA: e071k_loc_wa TYPE e071k,
        e071_loc_wa TYPE e071.

  IF p_synchronizer_flag = space.
    CLEAR: e071k_loc, e071_loc.
    REFRESH: e071k_loc, e071_loc.
    LOOP AT p_corr_keytab INTO e071k_loc_wa.
      APPEND e071k_loc_wa TO e071k_loc.
    ENDLOOP.
    LOOP AT p_cu_ko200_tab INTO e071_loc_wa.
      APPEND e071_loc_wa TO e071_loc.
    ENDLOOP.
  ELSE.
    READ TABLE e071k_loc INDEX 1 INTO e071k_loc_wa.
*----------------------------------------------------------------------
* Signal for Wulf Kruempelmann's Synchronizer (data written)
    IF e071k_loc_wa-trkorr = space.
      READ TABLE p_corr_keytab INDEX 1 INTO e071k_loc_wa.
    ENDIF.    "HCG p_corr_keytab-trkorr could be empty in VCL HW658985

    IF e071k_loc_wa-trkorr <> sv_trkorr.    "VG 31 Mar 2004
      sv_trkorr = e071k_loc_wa-trkorr.
      CALL FUNCTION 'SCTM_CHECK_TRIGGER_METHOD_TRK'
        EXPORTING
          iv_trkorr              = e071k_loc_wa-trkorr
        IMPORTING
*         EV_AT_TR_RELEASE       =
          ev_at_tr_change        = sv_at_tr_change
*         EV_POLLING             =
*         EV_NO_SYNC             =
*         EV_IS_TARGET           =
          ev_project_id          = sv_project_id
          ev_strkorr             = sv_strkorr.
    ENDIF.
    CHECK sv_at_tr_change = 'X'.

    CALL FUNCTION 'SCDC_DISTRIBUTE_TABLE_KEYS'
      EXPORTING
        project_id = sv_project_id
        trkorr     = sv_strkorr
      TABLES
        e071_tab   = e071_loc
        e071k_tab  = e071k_loc
      EXCEPTIONS
        no_project = 1
        OTHERS     = 2.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
*----------------------------------------------------------------------
  ENDIF.
ENDFORM.                    " vim_synchronizer_call
*&---------------------------------------------------------------------*
*&      Form  check_sync_key_lock
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_VIM_SYNC_KEY_LOCK  text
*----------------------------------------------------------------------*
FORM check_sync_key_lock USING p_check_all
                         CHANGING p_vim_sync_key_lock.

  DATA:    keytab_loc TYPE TABLE OF tbl8096,
           keytab_wa LIKE LINE OF keytab_loc,
           allowed_keys TYPE TABLE OF tbl8096,
           n TYPE i, viewtype.                              "#EC *
  DATA:    sctm_fill_cache TYPE oax.
  STATICS: old_viewname TYPE vimdesc-viewname.

  CHECK <xact> NE 'L'. "Avoids empty checks on add new entry in list
  IF x_header-bastab EQ space.
    viewtype = 'V'.
  ELSE.
    viewtype = 'S'.
  ENDIF.
  IF p_check_all EQ space.                           "check entry
    REFRESH keytab_loc.
    REFRESH allowed_keys.
    keytab_wa-line = <vim_xextract>.
    CLEAR sctm_fill_cache.
    IF <xact> NE space.
      sctm_fill_cache = 'X'.
    ENDIF.
    APPEND keytab_wa TO keytab_loc.          "Table with 1 line only to
    CALL FUNCTION 'SCTM_CHECK_VIEW_KEY' "grey out locked data in screen
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
      CLEAR p_vim_sync_key_lock.          "If no connection: open all
    ELSE.
      DESCRIBE TABLE allowed_keys LINES n.
      IF n EQ 0.
        p_vim_sync_key_lock = 'X'.
      ELSE.
        CLEAR p_vim_sync_key_lock.
      ENDIF.
    ENDIF.
  ELSEIF old_viewname NE x_header-viewname.
    old_viewname = x_header-viewname."Just fill cache in sync, no check
    REFRESH keytab_loc.
    REFRESH allowed_keys.
    LOOP AT total.                                          "#EC *
      keytab_wa-line = <vim_xtotal>.
      APPEND keytab_wa TO keytab_loc.                "Provide all data
    ENDLOOP.
    CALL FUNCTION 'SCTM_CHECK_VIEW_KEY'
      EXPORTING
        viewname              = x_header-viewname
        viewtype              = viewtype
        bcset                 = vim_bcset_id  "if NE space: BC-set act
        fill_cache            = 'X'    "fill cache for first call
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
    ENDIF.
  ENDIF.
ENDFORM.                    " check_sync_key_lock
