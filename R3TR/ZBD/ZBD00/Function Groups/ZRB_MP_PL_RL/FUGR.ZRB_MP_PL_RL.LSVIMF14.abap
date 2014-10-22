*&--------------------------------------------------------------------*
*&      Form PREPARE_SAVING                                           *
*&--------------------------------------------------------------------*
* prepare saving of changed data in data base                         *
*&--------------------------------------------------------------------*
* <-- SY-SUBRC: 0 - ok, save, others: - don't save                    *
* SY-SUBRC soll abgelöst werden durch:
* <-- VIM_ABORT_SAVING: space -> save, others -> don't save
*&--------------------------------------------------------------------*
FORM prepare_saving.
  DATA: rc LIKE sy-subrc,
        ps_addr_ref LIKE addr_ref,
        ps_transp_addrs(1) TYPE c,
        ps_e071k_tab LIKE e071k OCCURS 0,
        ps_tot_ix TYPE i,
        ps_ko200 LIKE ko200,
        ps_addrrc LIKE szad_field-returncode,                      "#EC NEEDED
        ps_ko200_tab LIKE ko200 OCCURS 0, addr_e071 LIKE e071,
        addr_e071k LIKE e071k, dummy TYPE char1,                   "#EC NEEDED
        ps_addr_errtab LIKE addr_error OCCURS 0 WITH HEADER LINE,  "#EC NEEDED
        new_addr_group TYPE ad_group, object_key TYPE ad_objkey.
  DATA  e071_loctab TYPE vim_ko200_tab_type.

  FIELD-SYMBOLS: <object_key_x> TYPE x, <addr_key> TYPE x.

  IF vim_adjust_middle_level_mode EQ subset.
    x_header[] = vim_adj_header.
    READ TABLE x_header INDEX 1.
    x_namtab[] = vim_adj_namtab.
  ENDIF.
  CLEAR vim_abort_saving.
  IF <status>-upd_checkd EQ space.
    PERFORM check_upd.
  ENDIF.
  IF <status>-upd_flag NE space.
    IF maint_mode EQ aendern.
      CLEAR sy-subrc.
      IF x_header-frm_bf_sav NE space.
        PERFORM (x_header-frm_bf_sav) IN PROGRAM.
*       CHECK SY-SUBRC EQ 0. "if sy-subrc ne 0 don't save -> exit
        IF sy-subrc <> 0 OR vim_abort_saving NE space.
          vim_abort_saving = 'X'. sy-subrc = 8.
          EXIT.
        ENDIF.
      ENDIF.
      IF x_header-texttbexst <> space.
        PERFORM vim_set_texttab_action_delete.          "SW Texttransl
      ENDIF.
      IF vim_client_state IS INITIAL OR
       ( vim_called_by_cluster <> space AND       "SW  CSS 80009987/1998
          vim_client_state = vim_noact ).
        CALL FUNCTION 'VIEW_GET_CLIENT_STATE'
          IMPORTING
            transp_state = vim_client_state.
      ENDIF.
    ENDIF.
    PERFORM vim_bc_logs_maintain USING x_header
                                       vim_import_profile
                                 CHANGING vim_bc_entry_list.
   IF ( vim_no_dialog EQ space OR vim_import_mode_active NE space ) AND
        ( vim_client_state EQ vim_log OR maint_mode EQ transportieren ).
      IF corr_nbr NE space AND corr_nbr NE <status>-corr_nbr.
        <status>-corr_nbr = corr_nbr.
      ENDIF.
      IF maint_mode EQ transportieren.
        IF <status>-corr_nbr EQ space.
          PERFORM request_corr_number.
          IF x_header-flag NE vim_transport_denied AND
             vim_actopts-transp_off NE bc_transport_denied AND
             <status>-l_corr_nbr NE <status>-corr_nbr.
            PERFORM prepare_corr.
          ENDIF.
        ENDIF.
      ELSE.
        PERFORM check_transp_objs_for_maint USING rc.
        IF rc NE 0.
          RAISE missing_corr_number.
        ENDIF.
        IF x_header-flag NE vim_transport_denied AND
           vim_actopts-transp_off NE bc_transport_denied.
          PERFORM prepare_corr.
          PERFORM update_corr.
        ENDIF.
      ENDIF.
      PERFORM corr_upd.
*    elseif not VIM_BC_ENTRY_LIST is initial.
* fill corr_keytab for bc-set import log
*      perform vim_bc_fill_corr_keytab.
    ENDIF.
    IF vim_import_testmode NE space.   "testrun for import
      CLEAR <status>-upd_flag.         "do not save if testrun happens
      vim_import_no_message = 'X'.
      PERFORM vim_process_message USING 'SV' 'I' 'I' '154'
                                        space space space space.
      CLEAR vim_import_no_message.
    ELSE.
* log begin of database changes
      CALL FUNCTION 'VIEW_WRITE_CHANGELOG_HEADER'
        EXPORTING
          viewname = x_header-viewname
          bastab   = x_header-bastab
          begin    = 'X'
          clidep   = x_header-clidep.
* save addresses.
      IF x_header-adrnbrflag EQ 'N'.   "only new technique
        ASSIGN: object_key TO <object_key_x> CASTING,
                ps_addr_ref-appl_key TO <addr_key> CASTING.
        IF ( maint_mode EQ transportieren OR
             vim_client_state EQ vim_log ) AND
           x_header-flag NE vim_transport_denied AND
           vim_actopts-transp_off NE bc_transport_denied.
          IF x_header-flag EQ space.   "standard logging required
            LOOP AT vim_addr_e071_tab INTO addr_e071.
              addr_e071-trkorr = <status>-corr_nbr.
              MODIFY vim_addr_e071_tab FROM addr_e071.
              ps_ko200 = addr_e071.
              APPEND ps_ko200 TO ps_ko200_tab.
            ENDLOOP.
            ps_transp_addrs = 'X'.
          ENDIF.
        ENDIF.
        LOOP AT vim_addresses_to_save
                                  WHERE viewname EQ x_header-viewname.
*          <f1_x> = vim_addresses_to_save-handle.
          <f1_x> = <vim_addr_handle_x>.
          READ TABLE total WITH KEY <f1_x> BINARY SEARCH.   "#EC *
          ps_tot_ix = sy-tabix.
          object_key = vim_addresses_to_save-handle.
          IF <action> NE geloescht AND <action> NE neuer_geloescht AND
             <action> NE update_geloescht.
* save adress
            REFRESH ps_e071k_tab.
            APPEND LINES OF vim_addr_e071k_tab TO ps_e071k_tab.
            IF vim_addresses_to_save-addrnumber CP '@NEW*'.
* new address
              ps_addr_ref-appl_table = vim_tsadrv-tablename.
              ps_addr_ref-appl_field = vim_tsadrv-fieldname.
              ps_addr_ref-appl_key   = object_key.
              ps_addr_ref-addr_group = vim_addr_group.
              ps_addr_ref-owner = 'X'.
              CALL FUNCTION 'ADDR_NUMBER_GET'
                   EXPORTING
                       address_handle    = vim_addresses_to_save-handle
                        address_reference = ps_addr_ref
*                     PERSONAL_ADDRESS           = ' '
*                     NUMBERRANGE_NUMBER         = '01'
                        generate_transport_entries = ps_transp_addrs
*                     OWNER                      = 'X'
                        table_name  = vim_addr_basetable
                        field_name  = vim_addr_bastab_field
                        objkey      = object_key
                   IMPORTING
                      address_number = vim_addresses_to_save-addrnumber
*                     RETURNCODE_NUMBERRANGE     =
                   TABLES
                        e071k_tab                  = ps_e071k_tab
                   EXCEPTIONS
                        address_handle_not_exist   = 1
                        internal_error             = 2
                        parameter_error            = 3.
              IF sy-subrc NE 0.
                MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno WITH
                           sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                RAISE saving_correction_failed.
              ENDIF.
            ELSE.
* existing address
              IF ps_transp_addrs NE space.
                CALL FUNCTION 'ADDR_TRANSPORT_ENTRIES'
                  EXPORTING
                    addrnumber = vim_addresses_to_save-addrnumber
                    table_name = vim_addr_basetable
                    field_name = vim_addr_bastab_field
                    objkey     = object_key
                  TABLES
                    e071k_tab  = ps_e071k_tab.
              ENDIF.
            ENDIF.                       "new address
          <vim_total_address_number> = vim_addresses_to_save-addrnumber.
            TRANSLATE <action> USING ' U'.
            READ TABLE extract WITH KEY <vim_xtotal_key>   "#EC *
                               TRANSPORTING NO FIELDS.
            IF sy-subrc EQ 0.
              extract = total. MODIFY extract INDEX sy-tabix.
            ENDIF.
            MODIFY total INDEX ps_tot_ix.
            IF ps_transp_addrs NE space.
              CALL FUNCTION 'TR_OBJECTS_INSERT'
                EXPORTING
                  wi_order = <status>-order_nbr
                TABLES
                  wt_ko200 = ps_ko200_tab
                  wt_e071k = ps_e071k_tab
                EXCEPTIONS
                  OTHERS   = 8.
              IF sy-subrc NE 0.
                MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno WITH
                           sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                RAISE saving_correction_failed.
              ENDIF.
            ENDIF.
            CALL FUNCTION 'ADDR_SINGLE_SAVE'
                 EXPORTING
                    address_number         = <vim_total_address_number>
*                   PERSON_NUMBER          = ' '
*                   ADDRESS_TYPE           = 1
*                   EXECUTE_IN_UPDATE_TASK = ' '
                 EXCEPTIONS
                      address_not_exist      = 1
                      person_not_exist       = 2
                      address_number_missing = 3
                      reference_missing      = 4
                      internal_error         = 5
                      database_error         = 6
                      parameter_error        = 7.
            IF sy-subrc NE 0.
              MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno WITH
                         sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
              RAISE saving_correction_failed.
            ENDIF.
            CALL FUNCTION 'ADDR_DEQUEUE'
              EXPORTING
                address_number    = <vim_total_address_number>
              EXCEPTIONS                                    "#EC *
                address_not_exist = 1
                internal_error    = 2
                OTHERS            = 3.
          ELSEIF <action> EQ neuer_geloescht.
* reset address (UF557286/2000)
            CALL FUNCTION 'ADDR_SINGLE_RESET'
              EXPORTING
                address_handle         = vim_addresses_to_save-handle
              EXCEPTIONS
*               NUMBER_NOT_FOUND       = 1
*               HANDLE_NOT_FOUND       = 2
*               PARAMETER_ERROR        = 3
                internal_error         = 1
                OTHERS                 = 0.
            IF sy-subrc = 1.
              MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.
          ENDIF.
          DELETE vim_addresses_to_save.
        ENDLOOP.                       "at vim_addresses to save.
* Delete addresses (temporary: put address into address-groups CADE or
* ZADE)
        IF vim_addr_group = 'CA01'.
          new_addr_group = 'CADE'.
        ELSEIF vim_addr_group = 'ZA01'.
          new_addr_group = 'ZADE'.
        ENDIF.
        IF NOT new_addr_group IS INITIAL.
          LOOP AT total.
            CHECK
             ( <action> EQ geloescht OR <action> EQ update_geloescht )
             AND <vim_total_address_number> NP '@NEW*'.
            <object_key_x> = <f1_x>.
            IF ps_transp_addrs NE space.
              REFRESH ps_e071k_tab.
              APPEND LINES OF vim_addr_e071k_tab TO ps_e071k_tab.
              CALL FUNCTION 'ADDR_TRANSPORT_ENTRIES'
                EXPORTING
                  addrnumber = <vim_total_address_number>
                  table_name = vim_addr_basetable
                  field_name = vim_addr_bastab_field
                  objkey     = object_key
                TABLES
                  e071k_tab  = ps_e071k_tab.
              CALL FUNCTION 'TR_OBJECTS_INSERT'
                EXPORTING
                  wi_order = <status>-order_nbr
                TABLES
                  wt_ko200 = ps_ko200_tab
                  wt_e071k = ps_e071k_tab
                EXCEPTIONS
                  OTHERS   = 8.
              IF sy-subrc NE 0.
                MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno WITH
                           sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                RAISE saving_correction_failed.
              ENDIF.
            ENDIF.
*            PS_ADDR_REF-APPL_TABLE = vim_tsadrv-TABLENAME.
*            PS_ADDR_REF-APPL_FIELD = vim_tsadrv-FIELDNAME.
*            PS_ADDR_REF-APPL_KEY   = <VIM_TOTAL_KEY>.
*            PS_ADDR_REF-ADDR_GROUP = VIM_ADDR_GROUP.
*            PS_ADDR_REF-OWNER = 'X'.
*            CALL FUNCTION 'ADDR_DELETE'
*                 EXPORTING
**                   ADDRESS_HANDLE      = ' '
*                      ADDRESS_NUMBER      = <VIM_TOTAL_ADDRESS_NUMBER>
*                      ADDRESS_REFERENCE   = PS_ADDR_REF
**                   DATE_FROM           = '00010101'
*                 IMPORTING
*                      RETURNCODE          = PS_ADDRRC
*                 TABLES
*                      ERROR_TABLE         = PS_ADDR_ERRTAB
*                 EXCEPTIONS
*                      ADDRESS_NOT_EXIST   = 1
*                      PARAMETER_ERROR     = 2
*                      INTERNAL_ERROR      = 3
*                      REFERENCE_NOT_EXIST = 4.
*            IF SY-SUBRC NE 0.
            IF NOT <vim_total_address_number> IS INITIAL.
              CALL FUNCTION 'ADDR_GROUP_CHANGE'
                   EXPORTING
                        address_number    = <vim_total_address_number>
*                    ADDRESS_HANDLE    = ' '
                        new_address_group = new_addr_group
                   EXCEPTIONS
                        address_not_exist = 1
                        parameter_error   = 2
                        internal_error    = 3
                        OTHERS            = 4.
              IF sy-subrc = 1.
              ELSEIF sy-subrc = 2.
                MESSAGE i298(am) WITH new_addr_group.
*   Adreßgruppe & nicht definiert, Löschvormerkung für Adresse nicht mög
                RAISE saving_correction_failed.
              ELSEIF sy-subrc <> 0.
                MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                RAISE saving_correction_failed.
              ENDIF.
*            ENDIF.
*            IF PS_ADDRRC NE SPACE.
*              LOOP AT PS_ADDR_ERRTAB.
*                MESSAGE ID PS_ADDR_ERRTAB-MSG_ID TYPE 'I'
*                        NUMBER PS_ADDR_ERRTAB-MSG_NUMBER WITH
*                        PS_ADDR_ERRTAB-MSG_VAR1 PS_ADDR_ERRTAB-MSG_VAR2
*                       PS_ADDR_ERRTAB-MSG_VAR3 PS_ADDR_ERRTAB-MSG_VAR4.
*              ENDLOOP.
*              IF PS_ADDRRC EQ 'E'.
*                RAISE SAVING_CORRECTION_FAILED.
*              ENDIF.
*            ENDIF.
              CALL FUNCTION 'ADDR_SINGLE_SAVE'
                   EXPORTING
                    address_number         = <vim_total_address_number>
*                   PERSON_NUMBER          = ' '
*                   ADDRESS_TYPE           = 1
*                   EXECUTE_IN_UPDATE_TASK = ' '
                   EXCEPTIONS
                        address_not_exist      = 1
                        person_not_exist       = 2
                        address_number_missing = 3
                        reference_missing      = 4
                        internal_error         = 5
                        database_error         = 6
                        parameter_error        = 7.
              IF sy-subrc NE 0 AND  sy-subrc NE 1.
                MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno WITH
                           sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                RAISE saving_correction_failed.
              ENDIF.
            ENDIF.            "not <vim_total_address_number> is initial
          ENDLOOP.                                          "at total
        ENDIF.                         "new_addr_group not initial
        CLEAR sy-subrc.
      ENDIF.                           "x_header-adrnbrflag eq 'N'.
    ENDIF.                             "vim_import_testmode ne space.
  ELSE.
    IF vim_adjust_middle_level_mode EQ space.
      MESSAGE s043(sv).
      IF function = save AND vim_called_by_cluster = space.
        PERFORM vim_add_img_notices_pai USING 'S'
                                        CHANGING dummy.
      ENDIF.
    ELSE.
      vim_adjust_middle_level_mode = 'L'.
    ENDIF.
  ENDIF.                               "<status>-upd_flag ne space
  IF maint_mode EQ transportieren.
* call synchronizer also for transp mode "HCG int. message 1832131/2003
* after saving not processed in this case.
    REFRESH e071_loctab.
    APPEND e071 TO e071_loctab.
    PERFORM vim_synchronizer_call
                  USING e071_loctab[]
                        corr_keytab[]
                        'X'.
  ENDIF.
ENDFORM.                               "prepare_saving
