*---------------------------------------------------------------------*
*       FORM CORR_UPD.                                                *
*---------------------------------------------------------------------*
*       Behandlung des FCODES 'SAVE' im Transportmodus                *
*       logging of changes                                            *
*---------------------------------------------------------------------*
FORM corr_upd.
  DATA: ko200 LIKE ko200,
        cu_e071k_tab LIKE e071k OCCURS 100,
        cu_e071_tab LIKE e071 OCCURS 10,
        cu_trpar LIKE trpar_int OCCURS 1,
        cu_trmess LIKE trmess_int OCCURS 1,
        cu_tadir LIKE tadir,
        cu_e071_htb LIKE e071 OCCURS 10,
        cu_dderr LIKE dderr,                                             "#EC NEEDED
        cu_corr_keytab_safe LIKE corr_keytab OCCURS 50,
        cu_corr_keyhtb LIKE corr_keytab OCCURS 50,
        lockable_objects_exist(1) TYPE c, e071_safe LIKE e071,
        cu_ko200_tab LIKE ko200 OCCURS 10,
        cu_last_corr LIKE e071-trkorr,
        w_cu_ko200 LIKE ko200,
        cu_ko200_sec LIKE ko200 OCCURS 10,
        corr_for_insert LIKE e071-trkorr, rc LIKE sy-subrc,
        cu_new_locks LIKE strlocktab OCCURS 10,                        "#EC NEEDED
        cu_begix TYPE i,
        cu_hobjfunc(1) TYPE c, cu_tdevc LIKE tdevc,
        cu_order_type LIKE e070-trfunction, cu_obj_not_chkd(1) TYPE c,
        cu_task_type LIKE e070-trfunction, cu_appendable(1) TYPE c,
        cu_request TYPE trwbo_request, cu_category LIKE vim_syst,
        cu_corr_objtab LIKE LINE OF vim_corr_objtab OCCURS 0,
        cu_last_cat LIKE vim_syst, cu_h_flag(1) TYPE c,
        cu_h_e071 LIKE e071, cuiorder LIKE e071-trkorr,
        cuitask LIKE e071-trkorr.

  DATA: lt_edt_objects       TYPE tredt_objects,
        ls_edt_object        TYPE LINE OF tredt_objects.
  DATA: corr_keyhtb_wa LIKE LINE OF cu_corr_keyhtb.
  FIELD-SYMBOLS: <ls_e071>   TYPE e071.

  FIELD-SYMBOLS: <vim_corr_objtab> LIKE vim_corr_objtab,
                 <e071> LIKE e071.

  CHECK maint_mode EQ transportieren OR vim_client_state EQ vim_log.
  CHECK x_header-flag NE vim_transport_denied.
  CHECK vim_actopts-transp_off NE bc_transport_denied.
  cu_h_flag = x_header-flag.
  IF vim_corr_obj_viewname NE x_header-viewname.
    REFRESH vim_corr_objtab.
  ELSE.
    cu_corr_objtab = vim_corr_objtab[].
  ENDIF.
  e071_safe = e071.
  CLEAR e071.
  LOOP AT corr_keytab WHERE mastername EQ x_header-viewname
                        AND ( mastertype EQ vim_unlockable_object
                              OR mastertype EQ vim_lockable_object ).
    MOVE: corr_keytab-trkorr  TO e071-trkorr,    "fill object tab
          corr_keytab-pgmid   TO e071-pgmid,
          corr_keytab-object  TO e071-object,
*         CORR_KEYTAB-OBJNAME TO E071-OBJ_NAME,
          corr_keytab-objfunc TO e071-objfunc,
          corr_keytab-activity TO e071-activity. "UF738595/2001
    IF corr_keytab-objname EQ vim_long_objname.
      e071-obj_name = corr_keytab-tabkey.
    ELSE.
      e071-obj_name = corr_keytab-objname.
    ENDIF.
    APPEND e071 TO cu_e071_tab.
    READ TABLE vim_corr_objtab WITH KEY pgmid = e071-pgmid
                                        object = e071-object
                                        obj_name = e071-obj_name
                               TRANSPORTING NO FIELDS.
    IF sy-subrc NE 0.                  "entry not found...
*      vim_corr_objtab = e071.
      MOVE-CORRESPONDING e071 TO vim_corr_objtab.     "UNICODE
      IF corr_keytab-mastertype EQ vim_unlockable_object.
*       APPEND E071 TO VIM_ULO_TRSP_OBJS.
        vim_corr_objtab-lockable = space.
      ELSE.
*       APPEND E071 TO VIM_LCK_TRSP_OBJS.
        vim_corr_objtab-lockable = lockable_objects_exist = 'X'.
      ENDIF.
      APPEND vim_corr_objtab.
      IF corr_keytab-flag EQ 'V'.
        IF vim_corr_obj_viewname NE x_header-viewname.
          APPEND vim_corr_objtab TO cu_corr_objtab.
        ENDIF.
      ELSE.
        cu_obj_not_chkd = 'X'.
      ENDIF.
    ELSEIF corr_keytab-mastertype EQ vim_lockable_object.
      lockable_objects_exist = 'X'.
    ENDIF.
  ENDLOOP.
  LOOP AT cu_e071_tab INTO e071.
    LOOP AT corr_keytab WHERE mastertype EQ e071-object
                          AND mastername EQ e071-obj_name
                          AND pgmid EQ vim_deleted_key.
      corr_keytab-pgmid = transporter. "collect all keys to
      APPEND corr_keytab TO cu_e071k_tab. "delete for all objects
      DELETE corr_keytab.
    ENDLOOP.
  ENDLOOP.
  vim_corr_obj_viewname = x_header-viewname.
* save keytab entries related to objects not in e071 tab
  LOOP AT corr_keytab.
    IF x_header-flag NE space AND x_header-frm_e071 EQ space AND
       ( x_header-frm_e071ka NE space OR x_header-frm_e071ks NE space ).
      IF corr_keytab-objname EQ vim_long_objname.
        READ TABLE cu_e071_tab WITH KEY
         object = corr_keytab-object
         obj_name = corr_keytab-tabkey
         TRANSPORTING NO FIELDS.
      ELSE.
        READ TABLE cu_e071_tab WITH KEY
         object = corr_keytab-object
         obj_name = corr_keytab-objname
         TRANSPORTING NO FIELDS.
      ENDIF.
      IF sy-subrc EQ 0.                "delete corr_keytab anyway
        DELETE corr_keytab.
      ENDIF.
    ELSE.
      READ TABLE cu_e071_tab WITH KEY
       object = corr_keytab-mastertype
       obj_name = corr_keytab-mastername
       TRANSPORTING NO FIELDS.
    ENDIF.
    CHECK sy-subrc NE 0.
    APPEND corr_keytab TO cu_corr_keytab_safe.
    DELETE corr_keytab.
  ENDLOOP.
  IF maint_mode EQ aendern AND lockable_objects_exist EQ space AND
     cu_obj_not_chkd NE space.
* may be objects are not yet checked
    LOOP AT cu_e071_tab ASSIGNING <e071>.        "UNICODE
      MOVE-CORRESPONDING <e071> TO w_cu_ko200.   "UNICODE
      APPEND w_cu_ko200 TO cu_ko200_tab.         "UNICODE
*    cu_ko200_tab = cu_e071_tab.
    ENDLOOP.                                     "UNICODE
    CALL FUNCTION 'TR_OBJECTS_CHECK'
*       exporting
*            IV_NO_SHOW_OPTION              = 'X'
       IMPORTING
            we_order                       = cuiorder
            we_task                        = cuitask
            we_objects_appendable          = cu_appendable
         TABLES
              wt_ko200                     = cu_ko200_tab
              wt_e071k                     = corr_keytab
       EXCEPTIONS
       cancel_edit_other_error       = 1
       show_only_other_error         = 2
       OTHERS                        = 3.
    IF sy-subrc NE 0 OR cu_appendable EQ space.
      rc = sy-subrc.
      LOOP AT cu_corr_keytab_safe INTO corr_keytab.
        APPEND corr_keytab.
      ENDLOOP.
      e071 = e071_safe. vim_corr_objtab[] = cu_corr_objtab.
      IF rc NE 0.
        MESSAGE ID     sy-msgid
                TYPE   'I'
                NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2  sy-msgv3 sy-msgv4.
        RAISE saving_correction_failed.
      ELSE.
        sy-subrc = rc.
        EXIT.
      ENDIF.
    ELSEIF cuiorder NE space OR cuitask NE space.
      <status>-order_nbr = cuiorder.
      <status>-corr_nbr = cuitask.
    ENDIF.
    REFRESH cu_ko200_tab.
  ENDIF. "may be objects are not yet checked
  IF maint_mode EQ aendern AND lockable_objects_exist NE space OR
     maint_mode EQ transportieren AND cu_obj_not_chkd NE space.
    IF cu_obj_not_chkd NE space.
* first check previously unchecked lockable objects
      CLEAR vim_last_source_system.
      LOOP AT vim_corr_objtab WHERE lockable NE space.
        READ TABLE cu_corr_objtab
                         WITH KEY pgmid  = vim_corr_objtab-pgmid
                                 object  = vim_corr_objtab-object
                                 obj_name = vim_corr_objtab-obj_name
                         TRANSPORTING NO FIELDS.
        CHECK sy-subrc NE 0.
        e071 = vim_corr_objtab.
        PERFORM check_lockable_object USING e071 rc.
        IF rc NE 0 OR x_header-flag EQ vim_transport_denied.
          x_header-flag = cu_h_flag. MODIFY x_header INDEX 1.
          MESSAGE i162(sv) WITH vim_corr_objtab-pgmid
                                vim_corr_objtab-object
                                vim_corr_objtab-obj_name.
          IF maint_mode EQ aendern.
            rc = 9. EXIT.
          ELSE.
            DELETE vim_corr_objtab.
          ENDIF.
        ENDIF.
      ENDLOOP.
      DESCRIBE TABLE vim_corr_objtab.
      IF maint_mode EQ aendern AND rc NE 0 OR sy-tfill EQ 0.
* restore saved keytab entries and corr_objtab
        LOOP AT cu_corr_keytab_safe INTO corr_keytab.
          APPEND corr_keytab.
        ENDLOOP.
        e071 = e071_safe.
        RAISE saving_correction_failed.
      ENDIF.
    ENDIF.                             "cu_obj_not_chckd ne space
    IF <status>-corr_nbr EQ space.
      LOOP AT vim_corr_objtab INTO e071.
        CALL FUNCTION 'TR_CHECK_TYPE'
          EXPORTING
            wi_e071     = e071
          IMPORTING
            we_tadir    = cu_tadir
            we_category = cu_category.
       CHECK cu_category EQ vim_syst OR cu_category EQ vim_cust_syst OR
                     cu_category EQ vim_appl.
        cu_last_cat = vim_syst. cu_h_e071 = e071.
      ENDLOOP.
      IF cu_last_cat EQ space.
        cu_category = vim_cust.
      ELSE.
        cu_category = cu_last_cat. e071 = cu_h_e071.
      ENDIF.
      CALL FUNCTION 'TRINT_GET_REQUEST_TYPE'
* UF041099 inserted instead of TRINT_CHECK_ORDER_TYPE
           EXPORTING
                iv_pgmid                   = e071-pgmid
                iv_object                  = e071-object
                iv_obj_name                = e071-obj_name
                iv_category                = cu_category
                is_tadir                   = cu_tadir
                is_tdevc                   = cu_tdevc
*                IV_USE_MEMORY              = 'X'
           IMPORTING
                ev_request_type            = cu_order_type
                ev_task_type               = cu_task_type
*                EV_TARGET                  =
           EXCEPTIONS
                internal_error             = 1
                no_request_needed          = 2
                cts_initialization_failure = 3
                OTHERS                     = 4.
      CASE sy-subrc.
        WHEN 0.
        WHEN 2.
          cu_order_type = 'K'.
          cu_task_type = 'S'.
        WHEN OTHERS.
          LOOP AT cu_corr_keytab_safe INTO corr_keytab.
            APPEND corr_keytab.
          ENDLOOP.
          e071 = e071_safe. vim_corr_objtab[] = cu_corr_objtab.
          MESSAGE ID     sy-msgid
                  TYPE   'I'
                  NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2  sy-msgv3 sy-msgv4.
          RAISE saving_correction_failed.
      ENDCASE.
      DO.
        CALL FUNCTION 'TRINT_ORDER_CHOICE'
          EXPORTING
            wi_order_type          = cu_order_type
            wi_task_type           = cu_task_type
            wi_category            = cu_category
            wi_cli_dep             = space
          IMPORTING
            we_order               = <status>-order_nbr
            we_task                = <status>-corr_nbr
          TABLES
            wt_e071                = cu_e071_tab
            wt_e071k               = corr_keytab
          EXCEPTIONS
            no_correction_selected = 1
            display_mode           = 2
            object_append_error    = 3
            recursive_call         = 4
            OTHERS                 = 5.
        IF sy-subrc NE 0.
* restore saved keytab entries and corr_objtab
          LOOP AT cu_corr_keytab_safe INTO corr_keytab.
            APPEND corr_keytab.
          ENDLOOP.
          e071 = e071_safe. vim_corr_objtab[] = cu_corr_objtab.
          IF sy-subrc NE 1.
            MESSAGE ID     sy-msgid
                    TYPE   'I'
                    NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2  sy-msgv3 sy-msgv4.
          ENDIF.
          RAISE saving_correction_failed.
        ENDIF.                         "sy-subrc ne 0
        IF maint_mode EQ transportieren.
* enqueue corr
          CALL FUNCTION 'ENQUEUE_E_TRKORR'
               EXPORTING
                    trkorr = <status>-corr_nbr
*               X_TRKORR = E02
               EXCEPTIONS
                    foreign_lock = 01
                    system_failure = 02.
          CASE sy-subrc.
            WHEN 0.
            WHEN 1.
          MESSAGE s092(sv) WITH <status>-corr_nbr. "Korr. wirdger.bearb.
              CONTINUE.
            WHEN 2.
              MESSAGE a095(sv) WITH <status>-corr_nbr. "Systemfehler
              CONTINUE.
          ENDCASE.
          <status>-corr_enqud = 'X'.
          EXIT.
        ELSE.                          "change mode
          EXIT.
        ENDIF.                         "maint_mode eq transportieren
      ENDDO.
    ENDIF.                             "<status>-corr_nbr eq space.
* store corr number into tables
    LOOP AT cu_e071_tab INTO e071 WHERE trkorr EQ space.
      e071-trkorr = <status>-corr_nbr.
      MODIFY cu_e071_tab FROM e071.
      LOOP AT vim_corr_objtab WHERE pgmid = e071-pgmid
                                AND object = e071-object
                                AND obj_name = e071-obj_name.
        vim_corr_objtab-trkorr = <status>-corr_nbr.
        MODIFY vim_corr_objtab.
        EXIT.
      ENDLOOP.
      sy-fdpos = strlen( e071-obj_name ).
      IF sy-fdpos GT vim_71k_name_length.
        READ TABLE corr_keytab WITH KEY pgmid = e071-pgmid
                                        object = e071-object
                                        objname = vim_long_objname
                                        tabkey  = e071-obj_name.
      ELSE.
        READ TABLE corr_keytab WITH KEY pgmid = e071-pgmid
                                        object = e071-object
                                        objname = e071-obj_name."#EC *
      ENDIF.
      IF sy-subrc EQ 0.
        corr_keytab-trkorr = <status>-corr_nbr.
        MODIFY corr_keytab INDEX sy-tabix.
      ENDIF.
    ENDLOOP.
  ENDIF.
  IF maint_mode EQ transportieren OR lockable_objects_exist NE space.
    SORT cu_e071_tab BY trkorr.
    LOOP AT cu_e071_tab INTO e071 WHERE objfunc NE 'D'.
      cu_begix = sy-tabix + 1.
      EXIT.
    ENDLOOP.
    IF sy-subrc EQ 0.
      APPEND e071 TO cu_e071_htb.
      LOOP AT corr_keytab WHERE mastertype EQ e071-object
                            AND mastername EQ e071-obj_name.
        APPEND corr_keytab TO cu_corr_keyhtb.
      ENDLOOP.
      cu_last_corr = e071-trkorr.
      LOOP AT cu_e071_tab INTO e071 FROM cu_begix WHERE objfunc NE 'D'.
        IF e071-trkorr NE cu_last_corr.
*___________________________________________________________________
          LOOP AT cu_e071_htb ASSIGNING <ls_e071>.
            MOVE-CORRESPONDING <ls_e071> TO ls_edt_object.
            APPEND ls_edt_object TO lt_edt_objects.
          ENDLOOP.
          CALL FUNCTION 'TR_EC_CUST_ORIG_LANG'
            EXPORTING
              it_objects   = lt_edt_objects
              iv_checkmode = ' '
              iv_dialog    = 'X'
            CHANGING
              ct_keys      = cu_corr_keyhtb
            EXCEPTIONS
              cancel       = 1
              display_only = 2
              OTHERS       = 3.
          IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF.
*--------------------------------------------------------------------
          CALL FUNCTION 'TRINT_APPEND_TO_COMM_ARRAYS'
            EXPORTING
              wi_trkorr     = cu_last_corr
            TABLES
              wt_e071       = cu_e071_htb
              wt_e071k      = cu_corr_keyhtb
              wt_trmess_int = cu_trmess
              wt_trpar_int  = cu_trpar
            EXCEPTIONS
              OTHERS        = 08.
          IF sy-subrc NE 0.
* restore saved keytab entries and corr_objtab
            LOOP AT cu_corr_keytab_safe INTO corr_keytab.
              APPEND corr_keytab.
            ENDLOOP.
            e071 = e071_safe. vim_corr_objtab[] = cu_corr_objtab.
            MESSAGE ID     sy-msgid
                    TYPE   'I'
                    NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2  sy-msgv3 sy-msgv4.
            RAISE saving_correction_failed.
          ENDIF.
          REFRESH: cu_e071_htb, cu_corr_keyhtb.
          cu_last_corr = e071-trkorr.
        ENDIF.
        APPEND e071 TO cu_e071_htb.
        LOOP AT corr_keytab WHERE mastertype EQ e071-object
                              AND mastername EQ e071-obj_name.
          APPEND corr_keytab TO cu_corr_keyhtb.
        ENDLOOP.
      ENDLOOP.
    ENDIF.                             "sy-subrc of loop at e071_tab
    DESCRIBE TABLE cu_e071_htb.
    IF sy-tfill NE 0.
*      CALL FUNCTION 'TR_APPEND_TO_COMM_OBJS_KEYS'
*        EXPORTING
**         WI_SIMULATION                        = ' '
**         WI_SUPPRESS_KEY_CHECK                = ' '
*          wi_trkorr                            = e071-trkorr
*        tables
*          wt_e071                              = cu_e071_htb
*          wt_e071k                             = cu_corr_keyhtb
*       EXCEPTIONS
*         KEY_CHAR_IN_NON_CHAR_FIELD           = 1
*         KEY_CHECK_KEYSYNTAX_ERROR            = 2
*         KEY_INTTAB_TABLE                     = 3
*         KEY_LONGER_FIELD_BUT_NO_GENERC       = 4
*         KEY_MISSING_KEY_MASTER_FIELDS        = 5
*         KEY_MISSING_KEY_TABLEKEY             = 6
*         KEY_NON_CHAR_BUT_NO_GENERIC          = 7
*         KEY_NO_KEY_FIELDS                    = 8
*         KEY_STRING_LONGER_CHAR_KEY           = 9
*         KEY_TABLE_HAS_NO_FIELDS              = 10
*         KEY_TABLE_NOT_ACTIV                  = 11
*         KEY_UNALLOWED_KEY_FUNCTION           = 12
*         KEY_UNALLOWED_KEY_OBJECT             = 13
*         KEY_UNALLOWED_KEY_OBJNAME            = 14
*         KEY_UNALLOWED_KEY_PGMID              = 15
*         KEY_WITHOUT_HEADER                   = 16
*         OB_CHECK_OBJ_ERROR                   = 17
*         OB_DEVCLASS_NO_EXIST                 = 18
*         OB_EMPTY_KEY                         = 19
*         OB_GENERIC_OBJECTNAME                = 20
*         OB_ILL_DELIVERY_TRANSPORT            = 21
*         OB_ILL_LOCK                          = 22
*         OB_ILL_PARTS_TRANSPORT               = 23
*         OB_ILL_SOURCE_SYSTEM                 = 24
*         OB_ILL_SYSTEM_OBJECT                 = 25
*         OB_ILL_TARGET                        = 26
*         OB_INTTAB_TABLE                      = 27
*         OB_LOCAL_OBJECT                      = 28
*         OB_LOCKED_BY_OTHER                   = 29
*         OB_MODIF_ONLY_IN_MODIF_ORDER         = 30
*         OB_NAME_TOO_LONG                     = 31
*         OB_NO_APPEND_OF_CORR_ENTRY           = 32
*         OB_NO_APPEND_OF_C_MEMBER             = 33
*         OB_NO_CONSOLIDATION_TRANSPORT        = 34
*         OB_NO_ORIGINAL                       = 35
*         OB_NO_SHARED_REPAIRS                 = 36
*         OB_NO_SYSTEMNAME                     = 37
*         OB_NO_SYSTEMTYPE                     = 38
*         OB_NO_TADIR                          = 39
*         OB_NO_TADIR_NOT_LOCKABLE             = 40
*         OB_PRIVAT_OBJECT                     = 41
*         OB_REPAIR_ONLY_IN_REPAIR_ORDER       = 42
*         OB_RESERVED_NAME                     = 43
*         OB_SYNTAX_ERROR                      = 44
*         OB_TABLE_HAS_NO_FIELDS               = 45
*         OB_TABLE_NOT_ACTIV                   = 46
*         TR_ENQUEUE_FAILED                    = 47
*         TR_ERRORS_IN_ERROR_TABLE             = 48
*         TR_ILL_KORRNUM                       = 49
*         TR_LOCKMOD_FAILED                    = 50
*         TR_LOCK_ENQUEUE_FAILED               = 51
*         TR_NOT_OWNER                         = 52
*         TR_NO_SYSTEMNAME                     = 53
*         TR_NO_SYSTEMTYPE                     = 54
*         TR_ORDER_NOT_EXIST                   = 55
*         TR_ORDER_RELEASED                    = 56
*         TR_ORDER_UPDATE_ERROR                = 57
*         TR_WRONG_ORDER_TYPE                  = 58
*         OB_INVALID_TARGET_SYSTEM             = 59
*         TR_NO_AUTHORIZATION                  = 60
*         OB_WRONG_TABLETYP                    = 61
*         OB_WRONG_CATEGORY                    = 62
*         OB_SYSTEM_ERROR                      = 63
*         OB_UNLOCAL_OBJEKT_IN_LOCAL_ORD       = 64
*         TR_WRONG_CLIENT                      = 65
*         OB_WRONG_CLIENT                      = 66
*         KEY_WRONG_CLIENT                     = 67
*         OTHERS                               = 68
*                .
*___________________________________________________________________
      LOOP AT cu_e071_htb ASSIGNING <ls_e071>.
        MOVE-CORRESPONDING <ls_e071> TO ls_edt_object.
        APPEND ls_edt_object TO lt_edt_objects.
      ENDLOOP.
      CALL FUNCTION 'TR_EC_CUST_ORIG_LANG'
        EXPORTING
          it_objects   = lt_edt_objects
          iv_checkmode = ' '
          iv_dialog    = 'X'
        CHANGING
          ct_keys      = cu_corr_keyhtb
        EXCEPTIONS
          cancel       = 1
          display_only = 2
          OTHERS       = 3.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
*--------------------------------------------------------------------
      IF e071-trkorr EQ space.                        "HCG HW 707466
        READ TABLE cu_corr_keyhtb into corr_keyhtb_wa INDEX 1.
        e071-trkorr = corr_keyhtb_wa-trkorr.
      ENDIF.
      CALL FUNCTION 'TRINT_APPEND_TO_COMM_ARRAYS'
           EXPORTING
                wi_trkorr     = e071-trkorr
           TABLES
                wt_e071       = cu_e071_htb
                wt_e071k      = cu_corr_keyhtb
                wt_trmess_int = cu_trmess
                wt_trpar_int  = cu_trpar
*           EXCEPTIONS
*                OTHERS        = 08.
       EXCEPTIONS
         key_check_keysyntax_error          = 1
         ob_check_obj_error                 = 2
         tr_lockmod_failed                  = 3
         tr_lock_enqueue_failed             = 4
         tr_wrong_order_type                = 5
         tr_order_update_error              = 6
         file_access_error                  = 7
         ob_no_systemname                   = 8
         OTHERS                             = 9.
      IF sy-subrc NE 0.
* restore saved keytab entries and corr_objtab
        LOOP AT cu_corr_keytab_safe INTO corr_keytab.
          APPEND corr_keytab.
        ENDLOOP.
        e071 = e071_safe. vim_corr_objtab[] = cu_corr_objtab.
        MESSAGE ID     sy-msgid
                TYPE   'I'
                NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2  sy-msgv3 sy-msgv4.
        RAISE saving_correction_failed.
      ENDIF.
    ENDIF.
    IF maint_mode EQ transportieren.
* process deletion
      LOOP AT cu_e071_tab INTO e071 WHERE objfunc NE space.
        IF e071-objfunc EQ 'K'.
          CALL FUNCTION 'TRINT_DELETE_COMM_KEYS'
            EXPORTING
              wi_e071                = e071
              wi_trkorr              = <status>-corr_nbr
            TABLES
              wt_e071k               = cu_e071k_tab
            EXCEPTIONS
              e070_update_error      = 01
              keys_protected         = 02
              order_already_released = 03
              unallowed_ordertyp     = 04
              user_not_owner         = 05
              wrong_client           = 06.
          IF sy-subrc NE 0.
* restore saved keytab entries and corr_objtab
            LOOP AT cu_corr_keytab_safe INTO corr_keytab.
              APPEND corr_keytab.
            ENDLOOP.
            e071 = e071_safe. vim_corr_objtab[] = cu_corr_objtab.
*         MESSAGE S097(SV) WITH <STATUS>-CORR_NBR.
            MESSAGE ID     sy-msgid
                    TYPE   'I'
                    NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2  sy-msgv3 sy-msgv4.
            RAISE saving_correction_failed.
          ELSE.
* check if object is to be deleted and delete it if necessary
            LOOP AT corr_keytab WHERE mastertype EQ e071-object
                                  AND mastername EQ e071-obj_name.
              EXIT.
            ENDLOOP.
          ENDIF.                       "sy-subrc of function call
        ELSEIF e071-objfunc EQ 'D'.
          sy-subrc = 8.
        ELSE.
          CLEAR sy-subrc.
        ENDIF.                         "e071-objfunc
        IF sy-subrc NE 0.
* delete object
          cu_hobjfunc = e071-objfunc.
          cu_request-objects = cu_e071_tab.
          cu_request-objects_filled = 'X'.
          CALL FUNCTION 'TRINT_DELETE_COMM_OBJECT_KEYS'
               EXPORTING
                    is_e071_delete              = e071
                    iv_dialog_flag              = ' '
*                IMPORTING
*                     ET_NEW_LOCKS                =
               CHANGING
                    cs_request                  = cu_request
               EXCEPTIONS
                    OTHERS = 8.

          IF sy-subrc NE 0.
* restore saved keytab entries and corr_objtab
            LOOP AT cu_corr_keytab_safe INTO corr_keytab.
              APPEND corr_keytab.
            ENDLOOP.
            e071 = e071_safe. vim_corr_objtab[] = cu_corr_objtab.
            MESSAGE ID     sy-msgid
                    TYPE   'I'
                    NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2  sy-msgv3 sy-msgv4.
            RAISE saving_correction_failed.
          ENDIF. "sy-subrc of function call corr_delete_entry.
          IF sy-subrc EQ 0 AND "del. was successful or entry didn't ex.
             cu_hobjfunc EQ 'D'.       "and no table entry
            DELETE cu_corr_keytab_safe
              WHERE pgmid EQ e071-pgmid AND object EQ e071-object
                AND ( objname EQ e071-obj_name OR
                      objname EQ vim_long_objname AND
                      tabkey EQ e071-obj_name )
                AND objfunc EQ e071-objfunc.
          ENDIF.
        ENDIF.                         "sy-subrc for deletion
      ENDLOOP.
      CLEAR: <status>-keytbmodfd, <status>-upd_flag.
      MESSAGE s096(sv) WITH <status>-corr_nbr.
    ENDIF.                             "maint_mode eq transportieren.
* call synchronizer also for transp mode "HCG int. message 1832131/2003
    cu_ko200_sec = cu_ko200_tab.
    ASSIGN vim_corr_objtab TO <vim_corr_objtab>.
    LOOP AT vim_corr_objtab.            "Fill cu_ko200_tab for sync-call
      MOVE-CORRESPONDING <vim_corr_objtab> TO w_cu_ko200. "UNICODE
      APPEND w_cu_ko200 TO cu_ko200_tab.                  "UNICODE
    ENDLOOP.
    PERFORM vim_synchronizer_call
                             USING
                                  cu_ko200_tab[]
                                  corr_keytab[]
                                  space.
    cu_ko200_tab = cu_ko200_sec.              "Reset cu_ko200_tab again
  ELSE.
* change mode and no lockable objects
    ASSIGN vim_corr_objtab TO <vim_corr_objtab>.
    LOOP AT vim_corr_objtab.
      MOVE-CORRESPONDING <vim_corr_objtab> TO w_cu_ko200. "UNICODE
      APPEND w_cu_ko200 TO cu_ko200_tab.                  "UNICODE
    ENDLOOP.
    IF <status>-order_nbr NE space.
      corr_for_insert = <status>-order_nbr.
    ELSE.
      corr_for_insert = <status>-corr_nbr.
    ENDIF.

    CALL FUNCTION 'TR_OBJECTS_INSERT'
         EXPORTING
*             WI_ORDER                       = <STATUS>-ORDER_NBR
              wi_order                       = corr_for_insert
         IMPORTING
              we_order                       = <status>-order_nbr
              we_task                        = <status>-corr_nbr
         TABLES
              wt_ko200                       = cu_ko200_tab
              wt_e071k                       = corr_keytab
         EXCEPTIONS
              cancel_edit_other_error        = 4
              show_only_other_error          = 6
              OTHERS                         = 8.

    IF sy-subrc NE 0.
      rc = sy-subrc.
* restore saved keytab entries and corr_objtab
      LOOP AT cu_corr_keytab_safe INTO corr_keytab.
        APPEND corr_keytab.
      ENDLOOP.
      e071 = e071_safe. vim_corr_objtab[] = cu_corr_objtab.
      IF rc GT 4.
*       MESSAGE I097(SV) WITH <STATUS>-CORR_NBR.
        MESSAGE ID     sy-msgid
                TYPE   'I'
                NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2  sy-msgv3 sy-msgv4.
      ENDIF.
      RAISE saving_correction_failed.
    ENDIF.
    PERFORM vim_synchronizer_call
                             USING
                                  cu_ko200_tab[]
                                  corr_keytab[]
                                  space.
  ENDIF. "maint_mode eq transportieren or lockable_objects_exist ne spac
* delete saved keytab entries - but not in transport mode
  IF maint_mode EQ aendern.
    IF x_header-flag NE space AND x_header-frm_e071 EQ space AND
       ( x_header-frm_e071ks NE space OR x_header-frm_e071ka NE space ).
      REFRESH corr_keytab.
    ELSE.
      DELETE corr_keytab WHERE mastertype NE vim_unlockable_object
                           AND mastertype NE vim_lockable_object.
    ENDIF.
  ENDIF.
* restore saved keytab entries and set used task number
  LOOP AT cu_corr_keytab_safe INTO corr_keytab.
    IF corr_keytab-mastername EQ x_header-viewname AND
       ( corr_keytab-mastertype EQ vim_unlockable_object OR
         corr_keytab-mastertype EQ vim_lockable_object ).
      corr_keytab-trkorr = <status>-corr_nbr.
    ENDIF.
    APPEND corr_keytab.
  ENDLOOP.
  SUBTRACT sy-subrc FROM sy-subrc.
  e071 = e071_safe.
  LOOP AT vim_corr_objtab.
    READ TABLE cu_corr_objtab WITH KEY pgmid = vim_corr_objtab-pgmid
                                       object = vim_corr_objtab-object
                                     obj_name = vim_corr_objtab-obj_name
                              TRANSPORTING NO FIELDS.
    CHECK sy-subrc NE 0.               "delete added entries
    DELETE vim_corr_objtab.
  ENDLOOP.
  e071-trkorr = <status>-corr_nbr.
  last_corr_number = <status>-l_corr_nbr = <status>-corr_nbr.
  CLEAR <status>-keytbmodfd.
  FREE: cu_e071k_tab, cu_trmess, cu_trpar, cu_e071_tab,
        cu_corr_keytab_safe, cu_ko200_tab, cu_e071_htb, cu_new_locks.
ENDFORM.                    "corr_upd
