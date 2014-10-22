*---------------------------------------------------------------------*
*       FORM UPDATE_CORR                                              *
*---------------------------------------------------------------------*
*       update correction command file                                *
* UF230499: no changing of X_HEADER-KEYLEN if key is to long for
*           transport. Move appropriate key length to KEYLEN instead.
* UF170200: same for translated text fields
*---------------------------------------------------------------------*
* CORR_ACTION ->(glob) action: D - delete from, A - add to command file
*---------------------------------------------------------------------*
FORM update_corr.
  LOCAL: x_header.
  DATA: rc LIKE sy-subrc, fails TYPE i, flag TYPE c, rc1 LIKE sy-subrc,
        uc_addr_71ktab LIKE e071k OCCURS 0,
        addr_e071k LIKE e071k,                               "#EC NEEDED
        object_key TYPE ad_objkey, keylen TYPE syfleng,
        txtkeylen TYPE syfleng,
        sys_type(10) TYPE c,
        texttab_wa TYPE REF TO data,                       "#EC NEEDED
        max_trsp_keylength_in_byte type i.
  FIELD-SYMBOLS: <adr_obj_key> TYPE x,
                 <texttab_wa> TYPE ANY,                     "#EC *
                 <texttab_wax> TYPE x,                      "#EC *
                 <lang> TYPE ANY.                           "#EC *

  CHECK maint_mode EQ aendern OR maint_mode EQ transportieren.
  CHECK x_header-flag NE vim_transport_denied.
  CHECK vim_actopts-transp_off NE bc_transport_denied.
  max_trsp_keylength_in_byte = vim_max_trsp_keylength
   * cl_abap_char_utilities=>charsize.
  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'transport/systemtype'            "#EC CI_CCALL
                     ID 'VALUE' FIELD sys_type.
  IF x_header-keylen GT max_trsp_keylength_in_byte.
    keylen = x_header-maxtrkeyln.                           "UF230499
  ELSE.                                                     "UF230499
    keylen = x_header-keylen.                               "UF230499
  ENDIF.
  IF x_header-textkeylen GT max_trsp_keylength_in_byte.
    txtkeylen = x_header-maxtrtxkln.                        "UF230499
  ELSE.                                                     "UF230499
    txtkeylen = x_header-textkeylen.                        "UF230499
  ENDIF.
  IF x_header-adrnbrflag EQ 'N'.
    ASSIGN object_key TO <adr_obj_key> CASTING.
    LOOP AT vim_addr_e071k_tab INTO addr_e071k.
      e071k-trkorr = <status>-corr_nbr.
    ENDLOOP.
  ENDIF.
  IF status-action EQ transportieren.
* force marked entries
************************************************************************
    CHECK vim_client_state NE vim_local_clnt.
    IF status-mode EQ list_bild.
* overview_screen
      IF ( x_header-frm_e071ks NE space OR x_header-flag EQ space ) AND
         vim_called_by_cluster NE space.
        PERFORM vim_store_state_info.
        CALL FUNCTION 'VIEWCLUSTER_TRANS_DEPENDENT'
          EXPORTING
            view_name   = x_header-viewname
            action      = corr_action
            status_mode = status-mode
            workarea    = extract
            no_dialog   = vim_external_mode
            corr_number = <status>-corr_nbr.
      ENDIF.
      CLEAR counter.
      LOOP AT extract.
        CHECK <xmark> EQ markiert.
        PERFORM move_extract_to_view_wa.
        IF x_header-flag EQ space.     "standard logging required
          IF x_header-bastab EQ space. "view
            PERFORM (corr_formname) IN PROGRAM (sy-repid)
                                                   USING corr_action rc.
          ELSE.                        "base table
            corr_keytab =  e071k.
            corr_keytab-objname = x_header-maintview.
            MOVE <vim_xextract_key> TO <vim_corr_keyx>(keylen).
            PERFORM update_corr_keytab USING corr_action rc.
            IF x_header-texttbexst NE space AND  "base table with
            <vim_xextract_text> NE <text_initial_x>.     "text table
* only texttable's original language shall be transported internally
              corr_keytab =  e071k.
              corr_keytab-objname = x_header-texttab.
              MOVE <vim_xextract_text> TO <vim_corr_keyx>(txtkeylen).
              PERFORM update_corr_keytab USING corr_action rc1.
              IF rc1 EQ 0. MOVE rc1 TO rc. ENDIF.
            ENDIF.
          ENDIF.
          IF x_header-texttbexst <> space AND        "SW Texttransl ..
             vim_texttab_is_ro EQ space.
            PERFORM vim_text_keytab_entry
                    USING <vim_xextract_key> corr_action rc1.
            IF rc1 EQ 0. MOVE rc1 TO rc. ENDIF.
          ENDIF.                       ".. Texttransl
          IF x_header-adrnbrflag EQ 'O' AND <address_number> NE space.
            PERFORM vim_address_keytab_entries USING corr_action rc1.
            IF rc1 EQ 0. MOVE rc1 TO rc. ENDIF.
          ELSEIF x_header-adrnbrflag EQ 'N' AND
                 <address_number> NE space.
            APPEND LINES OF vim_addr_e071k_tab TO uc_addr_71ktab.
*            object_key = <vim_total_key>.
            <adr_obj_key>(keylen) = <vim_xextract_key>. "UF474925/2000
            CALL FUNCTION 'ADDR_TRANSPORT_ENTRIES'
              EXPORTING
                addrnumber = <address_number>
                table_name = vim_addr_basetable
                field_name = vim_addr_bastab_field
                objkey     = object_key
              TABLES
                e071k_tab  = uc_addr_71ktab.
            vim_exit_11_12_active = 'X'.
            LOOP AT uc_addr_71ktab INTO corr_keytab WHERE
             mastername = vim_addr_e071k_master_46 OR    "UF688403/2000
             mastername = vim_addr_e071k_master.
* Rel < 4.6A: ignore old type address entries inserted only for downward
*             compatibility
              PERFORM update_corr_keytab USING corr_action rc1.
              IF rc1 EQ 0. MOVE rc1 TO rc. ENDIF.
            ENDLOOP.
            REFRESH uc_addr_71ktab.
            CLEAR vim_exit_11_12_active.
          ENDIF.
        ENDIF.                         "standard logging required
        IF x_header-frm_e071ks NE space.
          vim_exit_11_12_active = 'X'.
          PERFORM (x_header-frm_e071ks) IN PROGRAM (sy-repid).
          IF sy-subrc EQ 0. MOVE sy-subrc TO rc. ENDIF.
          CLEAR vim_exit_11_12_active.
        ELSE.
          IF x_header-frm_e071 NE space AND
             x_header-frm_e071ka EQ space.
            <status>-keytbmodfd = 'X'.
          ENDIF.
          IF x_header-flag NE space.
            EXIT.
          ENDIF.
        ENDIF.
        IF rc NE 0.
          ADD 1 TO fails.
          IF replace_mode NE space.
            READ TABLE total WITH KEY <vim_xextract_key> BINARY SEARCH."#EC *
            <mark> = <xmark> = nicht_markiert.
            MODIFY total INDEX sy-tabix.
            MODIFY extract.
            SUBTRACT: 1 FROM mark_total, 1 FROM mark_extract.
            ok_code = 'IGN '.
          ENDIF.
        ELSE.
          READ TABLE total WITH KEY <vim_xextract_key> BINARY SEARCH."#EC *
          <mark> = <xmark> = nicht_markiert.
*          IF rc EQ 0.                          "??? UF222098
          CASE corr_action.
            WHEN hinzufuegen.
              MOVE transportieren TO <action>.
            WHEN geloescht.
              CLEAR <action>.
          ENDCASE.
          <xact> = <action>.
*          ENDIF.
          MODIFY total INDEX sy-tabix.
          MODIFY extract.
          SUBTRACT: 1 FROM mark_total, 1 FROM mark_extract.
        ENDIF.
        ADD 1 TO counter.
      ENDLOOP.
      IF counter GT fails.
        IF fails GT 0.
          MOVE 4 TO rc.
        ELSE.
          CLEAR rc.
        ENDIF.
      ELSE.
        MOVE 8 TO rc.
      ENDIF.
      IF replace_mode EQ space.
        IF corr_action EQ hinzufuegen.
          IF counter EQ 1.
            IF rc EQ 0.
          MESSAGE s098(sv) WITH <status>-corr_nbr. "Eintr. in K. aufgen.
            ELSE.
          MESSAGE s107(sv) WITH <status>-corr_nbr. "Eintr. schon enthal.
            ENDIF.
          ELSE.
            SUBTRACT fails FROM counter.
            CASE rc.
              WHEN 0.
                MESSAGE s105(sv) WITH counter
                                <status>-corr_nbr. "Eintr. in K. aufgen.
              WHEN 4.
                MESSAGE s109(sv) WITH counter fails
                                  <status>-corr_nbr. "Eintr. schon enth.
              WHEN 8.
                MESSAGE s108(sv) WITH fails
                                  <status>-corr_nbr. "Eintr. schon enth.
            ENDCASE.
          ENDIF.
        ELSE.
          IF counter EQ 1.
            IF rc EQ 0.
          MESSAGE s099(sv) WITH <status>-corr_nbr. "Eintr.aus K. gelösch
            ELSE.
          MESSAGE s110(sv) WITH <status>-corr_nbr. "Eintr. schon enthal.
            ENDIF.
          ELSE.
            SUBTRACT fails FROM counter.
            CASE rc.
              WHEN 0.
                MESSAGE s106(sv) WITH counter
                               <status>-corr_nbr. "Eintr. aus K. gelösch
              WHEN 4.
                MESSAGE s111(sv) WITH counter fails
                                  <status>-corr_nbr. "Eintr. nicht enth.
              WHEN 8.
                MESSAGE s112(sv) WITH fails
                                  <status>-corr_nbr. "Eintr. nicht enth.
            ENDCASE.
          ENDIF.
        ENDIF.
      ENDIF.                           "replace_mode eq space
    ELSE.
* detail screen
      IF x_header-flag EQ space.
* standard logging required
        IF x_header-bastab EQ space.
* view
          PERFORM (corr_formname) IN PROGRAM (sy-repid)
                                                   USING corr_action rc.
        ELSE.
* base table
          corr_keytab =  e071k.
          corr_keytab-objname = x_header-maintview.
*          MOVE <table1> TO corr_keytab-tabkey(x_header-keylen).
          MOVE <table1_x> TO <vim_corr_keyx>(keylen).
          PERFORM update_corr_keytab USING corr_action rc.
          IF x_header-texttbexst NE space
           AND <table1_text> NE <text_initial>.
* base table with text table
            corr_keytab =  e071k.
            corr_keytab-objname = x_header-texttab.
            MOVE <table1_xtext> TO <vim_corr_keyx>(txtkeylen).
            PERFORM update_corr_keytab USING corr_action rc1.
            IF rc1 EQ 0. MOVE rc1 TO rc. ENDIF.
          ENDIF.
        ENDIF.
        IF x_header-texttbexst <> space AND        "SW Texttransl ..
           vim_texttab_is_ro EQ space.
          PERFORM vim_text_keytab_entry
                  USING <table1_x> corr_action rc1.
          IF rc1 EQ 0. MOVE rc1 TO rc. ENDIF.
        ENDIF.                         ".. Texttransl
        IF x_header-adrnbrflag EQ 'O' AND <address_number> NE space.
          PERFORM vim_address_keytab_entries USING corr_action rc1.
          IF rc1 EQ 0. MOVE rc1 TO rc. ENDIF.
        ELSEIF x_header-adrnbrflag EQ 'N' AND
               <address_number> NE space.
* transport addresses
          APPEND LINES OF vim_addr_e071k_tab TO uc_addr_71ktab.
*          object_key = <vim_extract_key>.
          <adr_obj_key>(keylen) = <vim_xextract_key>.
          CALL FUNCTION 'ADDR_TRANSPORT_ENTRIES'
            EXPORTING
              addrnumber = <address_number>
              table_name = vim_addr_basetable
              field_name = vim_addr_bastab_field
              objkey     = object_key
            TABLES
              e071k_tab  = uc_addr_71ktab.
          vim_exit_11_12_active = 'X'.
          LOOP AT uc_addr_71ktab INTO corr_keytab WHERE
           mastername = vim_addr_e071k_master_46 OR    "UF688403/2000
           mastername = vim_addr_e071k_master.
* Rel < 4.6A: ignore old type address entries inserted only for downward
*             compatibility
            PERFORM update_corr_keytab USING corr_action rc1.
            IF rc1 EQ 0. MOVE rc1 TO rc. ENDIF.
          ENDLOOP.
          REFRESH uc_addr_71ktab.
          CLEAR vim_exit_11_12_active.
        ENDIF.
      ENDIF.                           "standard logging required
      IF x_header-frm_e071ks NE space.
        vim_exit_11_12_active = 'X'.
        PERFORM (x_header-frm_e071ks) IN PROGRAM (sy-repid).
        IF sy-subrc EQ 0. MOVE sy-subrc TO rc. ENDIF.
        CLEAR vim_exit_11_12_active.
      ELSE.
        IF x_header-frm_e071 NE space AND
           x_header-frm_e071ka EQ space.
          IF x_header-flag NE space.
            <status>-keytbmodfd = 'E'.
          ELSE.
            <status>-keytbmodfd = 'X'.
          ENDIF.
        ENDIF.
      ENDIF.
      IF <status>-keytbmodfd NE 'E'.
        IF vim_called_by_cluster NE space.
          PERFORM vim_store_state_info.
          CALL FUNCTION 'VIEWCLUSTER_TRANS_DEPENDENT'
            EXPORTING
              view_name   = x_header-viewname
              action      = corr_action
              status_mode = status-mode
              workarea    = extract
              no_dialog   = vim_external_mode
              corr_number = <status>-corr_nbr.
        ENDIF.
      ELSE.
        <status>-keytbmodfd = 'X'.
      ENDIF.
      READ TABLE total WITH KEY <vim_xextract_key> BINARY SEARCH."#EC *
      IF rc EQ 0.
        CASE corr_action.
          WHEN hinzufuegen.
            MOVE transportieren TO <action>.
          WHEN geloescht.
            CLEAR <action>.
        ENDCASE.
        <xact> = <action>.
        MOVE 'X' TO flag.
      ELSE.
        IF replace_mode NE space.
          ok_code = 'IGN '.
        ENDIF.
      ENDIF.
      IF <xmark> EQ markiert.
        <mark> = <xmark> = nicht_markiert.
        SUBTRACT: 1 FROM mark_total, 1 FROM mark_extract.
        MOVE 'X' TO flag.
      ENDIF.
      IF flag NE space.
        MODIFY total INDEX sy-tabix.
        MODIFY extract INDEX nextline.
      ENDIF.
      IF replace_mode EQ space.
        IF corr_action EQ hinzufuegen.
          IF rc EQ 0.
            MESSAGE s098(sv) WITH <status>-corr_nbr."Eintr. in K. aufg.
          ELSE.
            MESSAGE s107(sv) WITH <status>-corr_nbr."Eintr. schon enthl.
          ENDIF.
        ELSE.
          IF rc EQ 0.
            MESSAGE s099(sv) WITH <status>-corr_nbr."Eintr.aus K. gelösc
          ELSE.
            MESSAGE s110(sv) WITH <status>-corr_nbr."Eintr. schon enthl.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.
* logging of changed entries
***********************************************************************
    CHECK vim_client_state EQ vim_log.
    corr_action = hinzufuegen.
*   REFRESH CORR_KEYTAB. "only delete all keys for current object
    LOOP AT vim_corr_objtab WHERE objfunc NE space.
      LOOP AT corr_keytab WHERE mastertype EQ vim_corr_objtab-object
                            AND mastername EQ vim_corr_objtab-obj_name.
        DELETE corr_keytab.
      ENDLOOP.
    ENDLOOP.
    LOOP AT total.
      IF x_header-flag EQ space.       "standard logging required
        IF x_header-bastab EQ space.   "view
          CHECK <action> NE original AND <action> NE neuer_geloescht.
          MOVE <vim_total_struc> TO <table1>.
          PERFORM (corr_formname) IN PROGRAM (sy-repid)
                                                  USING corr_action rc.
        ELSE.                          "base table
          IF x_header-texttbexst EQ space.
            CHECK <action> NE original AND <action> NE neuer_geloescht.
          ELSE.
          CHECK <action> NE original AND <action> NE neuer_geloescht OR
                                         <action_text> NE original AND
                                       <action_text> NE neuer_geloescht.
          ENDIF.
          MOVE <vim_total_struc> TO <table1>.
          corr_keytab =  e071k.
          corr_keytab-objname = x_header-maintview.
          MOVE <vim_xtotal_key> TO <vim_corr_keyx>(keylen).
          PERFORM update_corr_keytab USING corr_action rc.
          IF x_header-texttbexst NE space AND       "base table with
             <vim_xtotal_text> NE <text_initial_x>. "text table
            corr_keytab =  e071k.
            corr_keytab-objname = x_header-texttab.
            MOVE <vim_xtotal_text> TO <vim_corr_keyx>(txtkeylen).
            PERFORM update_corr_keytab USING corr_action rc1.
          ENDIF.
        ENDIF.                         "base table or view
        IF x_header-adrnbrflag EQ 'O' AND <address_number> NE space.
          PERFORM vim_address_keytab_entries USING corr_action rc1.
        ELSEIF x_header-adrnbrflag EQ 'N' AND <address_number> NE space.
          READ TABLE vim_addresses_to_save
                        WITH KEY viewname = x_header-viewname
                                 addrnumber = <address_number>
                        BINARY SEARCH TRANSPORTING NO FIELDS.
          IF sy-subrc NE 0.            "only existing addresses possible
            APPEND LINES OF vim_addr_e071k_tab TO uc_addr_71ktab.
*            object_key = <vim_extract_key>.
            <adr_obj_key>(keylen) = <vim_xtotal_key>. "UF686454/2000
            CALL FUNCTION 'ADDR_TRANSPORT_ENTRIES'
              EXPORTING
                addrnumber = <address_number>
                table_name = vim_addr_basetable
                field_name = vim_addr_bastab_field
                objkey     = object_key
              TABLES
                e071k_tab  = uc_addr_71ktab.
            vim_exit_11_12_active = 'X'.
            LOOP AT uc_addr_71ktab INTO corr_keytab WHERE
             mastername = vim_addr_e071k_master_46 OR    "UF688403/2000
             mastername = vim_addr_e071k_master.
* Rel < 4.6A: ignore old type address entries inserted only for downward
*             compatibility
              PERFORM update_corr_keytab USING corr_action rc1.
              IF rc1 EQ 0. MOVE rc1 TO rc. ENDIF.
            ENDLOOP.
            REFRESH uc_addr_71ktab.
            CLEAR vim_exit_11_12_active.
          ENDIF.
        ENDIF.
      ENDIF.                           "standard logging required
      IF x_header-frm_e071ks NE space.
        vim_exit_11_12_active = 'X'.
        PERFORM (x_header-frm_e071ks) IN PROGRAM (sy-repid).
        CLEAR vim_exit_11_12_active.
      ELSE.
        IF x_header-flag NE space.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.
    IF x_header-flag EQ space AND      "standard logging required
       x_header-texttbexst <> space.   "SW Texttransl ..
      PERFORM vim_text_keytab_entries USING corr_action rc1
                                            keylen          "UF170200
                                            txtkeylen.      "UF170200
    ENDIF.                             ".. Texttransl
  ENDIF.                               "maint_mode transport or update
  IF x_header-frm_e071ka NE space.
    vim_exit_11_12_active = 'X'.
    PERFORM (x_header-frm_e071ka) IN PROGRAM (sy-repid).
    CLEAR vim_exit_11_12_active.
    IF status-action EQ transportieren AND x_header-flag NE space AND
       x_header-frm_e071 NE space AND x_header-frm_e071ks EQ space AND
       vim_called_by_cluster NE space.
      PERFORM vim_store_state_info.
      CALL FUNCTION 'VIEWCLUSTER_TRANS_DEPENDENT'
        EXPORTING
          view_name   = x_header-viewname
          action      = corr_action
          status_mode = status-mode
          workarea    = extract
          no_dialog   = vim_external_mode
          corr_number = <status>-corr_nbr.
    ENDIF.
  ENDIF.
ENDFORM.                    "update_corr
