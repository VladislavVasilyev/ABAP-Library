*---------------------------------------------------------------------*
*       FORM ADDRESS_MAINTAIN                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM address_maintain.
  DATA: mode, return TYPE i, kz, answer, am_save(1) TYPE c, "#EC *
        am_pos LIKE sy-fdpos, am_length LIKE sy-fdpos,
        func_name TYPE rs38l_fnam.
  DATA: am_handletab LIKE addr1_dia OCCURS 1 WITH HEADER LINE,
        am_sel LIKE addr1_sel, am_address LIKE addr1_val,
        am_ucomm LIKE sy-ucomm, am_title LIKE sy-title.
  DATA: keytab TYPE TABLE OF vimty_textfield,
        keytab_wa TYPE vimty_textfield,
        am_key TYPE vimty_max_textline.

  FIELD-SYMBOLS: <am_title> TYPE c, <am_key> TYPE c,
                 <am_handle_x> TYPE x,
                 <namtab> TYPE vimnamtab,                   "#EC *
                 <keyfld> TYPE ANY.                         "#EC *

  IF x_header-adrnbrflag EQ space.
    MESSAGE e001(sv).
    EXIT.
  ENDIF.
  IF status-action NE anzeigen AND status-action NE transportieren AND
     adrnbr_roflag EQ space.
    MOVE svim_text_012 TO am_title.    "Adresse bearbeiten
  ELSE.
    MOVE svim_text_017 TO am_title.    "Adresse anzeigen
  ENDIF.
  am_pos = strlen( am_title ).
  am_length = 70 - am_pos.
  ASSIGN am_title+am_pos(am_length) TO <am_title>.
  MOVE ':' TO <am_title>.
  ADD 2 TO am_pos.
  SUBTRACT 2 FROM am_length.
  ASSIGN am_title+am_pos(am_length) TO <am_title>.
  CLEAR am_pos.
  PERFORM vim_external_repr_for_key TABLES keytab
                                    USING <f1_x>.
  LOOP AT keytab INTO keytab_wa.
    CONCATENATE am_key keytab_wa-text INTO am_key SEPARATED BY space.
    am_pos = am_pos + keytab_wa-outplen + 1.
    IF am_pos > am_length. EXIT. ENDIF.
  ENDLOOP.
  IF sy-subrc = 0.
    ASSIGN am_key(am_pos) TO <am_key>.
*  IF x_header-clidep NE space.
*    am_length = x_header-keylen - client_length.
*    ASSIGN <f1>+client_length(am_length) TO <am_key>.
*  ELSE.
*    ASSIGN <f1> TO <am_key>.
*  ENDIF.
    MOVE <am_key> TO <am_title>.
  ENDIF.
  ASSIGN am_handletab-handle TO <am_handle_x> CASTING.
  IF x_header-adrnbrflag EQ 'O'.       "use old technique
* Übergangslösung Adressumstellung 3.0F Anfang
    IF <address_number> NE space.
      SELECT adrnr FROM sadr INTO sadr-adrnr
                             WHERE adrnr EQ <address_number>.
        EXIT.
      ENDSELECT.
      IF sy-subrc NE 0.
        CALL FUNCTION 'ADDR_CONVERT_ADRC_TO_SADR'
          CHANGING
            address_number = <address_number>.
*     IF <ADDRESS_NUMBER> NE SPACE AND "new address number -> update
*        STATUS-ACTION NE ANZEIGEN AND STATUS-ACTION NE TRANSPORTIEREN.
*       <STATUS>-UPD_FLAG = 'X'.
*     ENDIF.  "not necessary, adrnbr will never be changed
      ENDIF.
    ENDIF.
* Übergangslösung Adressumstellung 3.0F Ende
    MOVE <address_number> TO sadr-adrnr.
    kz = space.
   IF status-action NE anzeigen AND status-action NE transportieren AND
             adrnbr_roflag EQ space.
      IF <address_number> EQ space.
        mode = 'A'.
      ELSE.
        mode = 'M'.
      ENDIF.
      IF status-action EQ kopieren.
        IF <address_number> NE space.
          SELECT * FROM sadr WHERE adrnr EQ <address_number>.
            kz = 'X'.
            EXIT.
          ENDSELECT.
        ELSE.
          CLEAR sadr.
        ENDIF.
        CLEAR <address_number>.
        mode = 'A'.
      ENDIF.
    ELSE.
      mode = 'D'.
    ENDIF.
    func_name = 'ADDRESS_MAINTAIN'. "struggling against extended check
    DO.
      CALL FUNCTION func_name
        EXPORTING
          adrswa_in         = sadr
          processing_status = mode
          kennzeichen       = kz
          save_intern       = 'X'
          title             = am_title
        IMPORTING
          adrswa_out        = sadr
          returncode        = return
          update_flag       = am_save
        EXCEPTIONS
          not_found         = 4.
      IF sy-subrc NE 0.
        IF status-action NE anzeigen AND
           status-action NE transportieren AND
           adrnbr_roflag EQ space.
          CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'     "#EC *
            EXPORTING
              diagnosetext1 = svim_text_013   "Die Adresse für das
              diagnosetext2 = <am_key>
              diagnosetext3 = svim_text_014 "wurde nicht gefunden.
              textline1     = svim_text_015"Möchten Sie eine neue er
              titel         = svim_text_016"Adresse nicht vorhanden
            IMPORTING
              answer        = answer.
          IF answer EQ 'J'.
            mode = 'A'.
          ELSE.
            return = 4.
            EXIT.
          ENDIF.
        ELSE.
          MESSAGE i055(sv) WITH <am_key>.
          return = 4.
          EXIT.
        ENDIF.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.
   IF status-action NE anzeigen AND status-action NE transportieren AND
             adrnbr_roflag EQ space.
      IF return NE 4 AND sadr-adrnr NE <address_number> OR
         am_save NE space. "transport for address changes is requested
        MOVE: 'X' TO <status>-upd_flag,
               sadr-adrnr TO <address_number>.
      ENDIF.
    ENDIF.
    CLEAR am_ucomm.
  ELSE. "4.0: use new version of address maintenance
   IF status-action NE anzeigen AND status-action NE transportieren AND
             adrnbr_roflag EQ space.
      IF status-action EQ kopieren.
        IF <address_number> NE space.
          IF <address_number> NP '@NEW*'.
            am_sel-addrnumber = <address_number>.
          ELSE.
            am_sel-addrhandle = <f1_x>.
          ENDIF.
          CALL FUNCTION 'ADDR_GET'
            EXPORTING
              address_selection = am_sel
            IMPORTING
              address_value     = am_address
            EXCEPTIONS
              parameter_error   = 1
              address_not_exist = 2
              version_not_exist = 3
              internal_error    = 4.
          IF sy-subrc EQ 0.
            MOVE-CORRESPONDING am_address TO am_handletab."#EC ENHOK
          ENDIF.
        ENDIF.
        CLEAR <address_number>.
        am_handletab-maint_mode = 'CREATE'.
      ELSE.
        IF <address_number> EQ space.
          am_handletab-maint_mode = 'CREATE'.
        ELSE.
          am_handletab-maint_mode = 'CHANGE'.
        ENDIF.
      ENDIF.                           "status-action eq kopieren.
    ELSE.
      IF <address_number> IS INITIAL.  "no address assigned
        MESSAGE i055(sv) WITH <am_key>.
        EXIT.
      ENDIF.
      am_handletab-maint_mode = 'DISPLAY'.
    ENDIF.
    IF am_handletab-maint_mode EQ 'CREATE' OR
       <address_number> CP '@NEW*'.
      <am_handle_x>(x_header-keylen) = <f1_x>.
*      am_handletab-handle = <f1>.
    ELSE.
      CLEAR am_handletab-handle.
    ENDIF.
    IF <address_number> NP '@NEW*'.
      am_handletab-addrnumber = <address_number>.
    ELSE.
      CLEAR am_handletab-addrnumber.
    ENDIF.
    am_handletab-addr_group = vim_addr_group.
    APPEND am_handletab.
* individual preparation of address dialog requested?.....
    CLEAR: vim_addr_field_selection,
           vim_addr_keywords,
           vim_addr_chng_deflt_comm_types,
           vim_addr_frame_text,
           vim_addr_excluded_functions.
    REFRESH vim_addr_excluded_functions.
    vim_addr_titlebar = am_title.
    CLEAR vim_skip_adr_maint.                               "UF120400
    IF x_header-frm_bf_adr NE space.   "...yes
      PERFORM (x_header-frm_bf_adr) IN PROGRAM.
    ENDIF.
    CHECK vim_skip_adr_maint IS INITIAL.                    "UF120400
    CALL FUNCTION 'ADDR_DIALOG_PREPARE'
         EXPORTING
              field_selection           = vim_addr_field_selection
              keywords                  = vim_addr_keywords
*             TITLEBAR                  = AM_TITLE
              titlebar                  = vim_addr_titlebar
              change_default_comm_types = vim_addr_chng_deflt_comm_types
              frame_text                = vim_addr_frame_text
         TABLES
              excluded_functions        = vim_addr_excluded_functions
*             ERROR_TABLE               =
         EXCEPTIONS                                         "#EC *
              internal_error            = 1
              OTHERS                    = 2.
    IF am_handletab-maint_mode EQ 'CHANGE' AND
       am_handletab-addrnumber NE space.
      READ TABLE vim_locked_addresses FROM am_handletab-addrnumber
                                      TRANSPORTING NO FIELDS.
      IF sy-subrc NE 0.                "not yet locked
        CALL FUNCTION 'ADDR_ENQUEUE'
             EXPORTING
                  address_number    = am_handletab-addrnumber
*               MODE_ADRC         = 'E'
*               _SCOPE            = '2'
*               _WAIT             = ' '
*               _COLLECT          = ' '
             EXCEPTIONS
                  address_not_exist = 1
                  foreign_lock      = 2
                  system_failure    = 3
                  internal_error    = 4.
        CASE sy-subrc.
          WHEN 0.
            INSERT am_handletab-addrnumber INTO TABLE
                                           vim_locked_addresses.
          WHEN 1.
            IF status-action NE anzeigen AND
               status-action NE transportieren AND
               adrnbr_roflag EQ space.
              CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
                EXPORTING
                  diagnosetext1 = svim_text_013"Die Adresse für das Obj:
                  diagnosetext2 = <am_key>
                  diagnosetext3 = svim_text_014"wurde nicht gefunden.
                  textline1     = svim_text_015"Möchten Sie eine neue er
                  titel         = svim_text_016"Adresse nicht vorhanden
                IMPORTING
                  answer        = answer.
              IF answer EQ 'J'.
                am_handletab-maint_mode = 'CREATE'.
                IF <address_number> NP '@NEW*'.
                  <am_handle_x>(x_header-keylen) = <f1_x>.
*                  am_handletab-handle = <f1>.
                  CLEAR am_handletab-addrnumber.
                ENDIF.
                MODIFY am_handletab INDEX 1.
              ELSE.
                EXIT.
              ENDIF.
            ELSE.
              MESSAGE i055(sv) WITH <am_key>.
              EXIT.
            ENDIF.
          WHEN 2.
            MESSAGE i049(sv) WITH sy-msgv1.
            am_handletab-maint_mode = 'DISPLAY'.
          WHEN OTHERS.
            MESSAGE i050(sv) WITH <am_key>.
            am_handletab-maint_mode = 'DISPLAY'.
        ENDCASE.
      ENDIF.                           "not yet locked
    ENDIF. "am_handletab-maint_mode eq 'CHANGE' and no new address
    DO.
      CALL FUNCTION 'ADDR_DIALOG'
           IMPORTING
                ok_code           = am_ucomm
           TABLES
                number_handle_tab = am_handletab
*             VALUES            =
           EXCEPTIONS
                address_not_exist = 1
                group_not_valid   = 2
                parameter_error   = 3
                internal_error    = 4.
      CASE sy-subrc.
        WHEN 0.
          READ TABLE am_handletab INDEX 1.
          EXIT.
        WHEN 1.
          IF status-action NE anzeigen AND
             status-action NE transportieren AND
             adrnbr_roflag EQ space.
            CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
              EXPORTING
                diagnosetext1 = svim_text_013 "Die Adresse für das
                diagnosetext2 = <am_key>
                diagnosetext3 = svim_text_014"wurde nicht gefunden.
                textline1     = svim_text_015"Möchten Sie eine neue er
                titel         = svim_text_016"Adresse nicht vorhanden
              IMPORTING
                answer        = answer.
            IF answer EQ 'J'.
              READ TABLE am_handletab INDEX 1.
              am_handletab-maint_mode = 'CREATE'.
              IF <address_number> NP '@NEW*'.
                <am_handle_x>(x_header-keylen) = <f1_x>.
*                am_handletab-handle = <f1>.
                CLEAR am_handletab-addrnumber.
              ENDIF.
              MODIFY am_handletab INDEX 1.
            ELSE.
              am_ucomm = 'CANC'.
              EXIT.
            ENDIF.
          ELSE.
            MESSAGE i055(sv) WITH <am_key>.
            am_ucomm = 'CANC'.
            EXIT.
          ENDIF.
        WHEN OTHERS.
          MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno WITH
                  sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          am_ucomm = 'CANC'. EXIT.
      ENDCASE.
    ENDDO.
    IF am_handletab-maint_mode EQ 'CHANGE' AND
       am_handletab-addrnumber NE space    AND
       ( am_ucomm EQ 'CANC' OR am_handletab-updateflag EQ space ).
      READ TABLE vim_locked_addresses FROM am_handletab-addrnumber
                                      TRANSPORTING NO FIELDS.
      IF sy-subrc EQ 0.                "dequeue
        CALL FUNCTION 'ADDR_DEQUEUE'
               EXPORTING
                 address_number    = am_handletab-addrnumber
*                MODE_ADRC         = 'E'
*                _SCOPE            = '3'
*                _SYNCHRON         = ' '
*                _COLLECT          = ' '
               EXCEPTIONS                                   "#EC *
                 address_not_exist = 1
                 internal_error    = 2.
      ENDIF.
    ENDIF.
   IF status-action NE anzeigen AND status-action NE transportieren AND
             adrnbr_roflag EQ space.
      IF am_ucomm NE 'CANC'.
        IF am_handletab-maint_mode EQ 'CREATE'.
          <address_number> = '@NEW'.
          <address_number>+4(6) = <status>-newadrcnt.
          ADD 1 TO <status>-newadrcnt.
          <status>-upd_flag = 'X'.
        ENDIF.
        IF am_handletab-updateflag NE space. "addr. itself is to be save
          READ TABLE vim_addresses_to_save
                              WITH KEY viewname = x_header-viewname
                                       addrnumber = <address_number>
                              BINARY SEARCH TRANSPORTING NO FIELDS.
          IF sy-subrc NE 0.
            vim_addresses_to_save-addrnumber = <address_number>.
            CLEAR vim_addresses_to_save-handle.
            <vim_addr_handle_x>(x_header-keylen) = <f1_x>.
*            vim_addresses_to_save-handle = <f1>.
            INSERT vim_addresses_to_save INDEX sy-tabix.
          ENDIF.
          IF vim_client_state EQ vim_log AND
             x_header-flag NE vim_transport_denied AND
             vim_actopts-transp_off NE bc_transport_denied.
            <status>-upd_flag = 'X'. "nec. for transport of master entry
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
    CLEAR return.
  ENDIF.                               "am_statetab-value eq space.
* IF STATUS-ACTION NE KOPIEREN AND STATUS-ACTION NE HINZUFUEGEN.
  IF status-action NE kopieren AND status-action NE hinzufuegen AND
     vim_single_entry_function NE 'INS'.
    IF return NE 4 AND am_ucomm NE 'CANC'.
      IF <xmark> EQ markiert.
        <xmark> = nicht_markiert.
        IF <status>-upd_flag EQ space.
          MODIFY extract INDEX exind.
          READ TABLE total WITH KEY <vim_xextract_key> BINARY SEARCH."#EC *
          <mark> = nicht_markiert.
          MODIFY total INDEX sy-tabix.
        ENDIF.
        SUBTRACT: 1 FROM mark_extract,
                  1 FROM mark_total.
      ENDIF.
    ENDIF.
    CLEAR function.
  ENDIF.
ENDFORM.                    "address_maintain
