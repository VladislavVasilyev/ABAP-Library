*---------------------------------------------------------------------*
*       FORM GET_TRANSP_INFO                                          *
*---------------------------------------------------------------------*
* get client state and transport objects                              *
*---------------------------------------------------------------------*
FORM get_transp_info.
  LOCAL: e071.
  DATA: obj_type LIKE objh-objecttype, last_category LIKE objh-objcateg,
        last_clidep LIKE objh-clidep VALUE 'X', gti_e071 LIKE e071,
        last_protect LIKE objh-protect, gti_cliindep_state(1) TYPE c,  "#EC NEEDED
        gti_x030l LIKE x030l,
        gti_tabname TYPE tabname,
        gti_client_role LIKE t000-cccategory,
        gti_flag_safe(1) TYPE c,
        cursetting TYPE cursetting, addr_e071k LIKE e071k,
        importable TYPE objimp value '4',
        tr_result LIKE trpari-s_checked,
        addr_e071k2 LIKE e071k.

* check if logging of changes is necessary
  gti_flag_safe = x_header-flag.
  IF x_header-customauth CO no_transport_classes."transport impossible
    x_header-flag = vim_transport_denied. "no standard logging
    CLEAR: x_header-frm_e071,          "no individual transport
           x_header-frm_e071ks,
           x_header-frm_e071ka.
    IF maint_mode EQ aendern.
      MOVE 'TRSP' TO excl_cua_funct-function. COLLECT excl_cua_funct.
    ELSEIF maint_mode EQ transportieren.
      MESSAGE i128(sv) WITH "Auslieferungsklasse &, kein Transport mög
              x_header-customauth.
      RAISE missing_corr_number.
    ENDIF.
    MOVE 'ORDR' TO excl_cua_funct-function. COLLECT excl_cua_funct.
    sy-subrc = 9.
  ELSEIF x_header-customauth CO no_transport_log_classes.
    IF x_header-frm_e071 EQ space AND x_header-frm_e071ks EQ space AND
       x_header-frm_e071ka EQ space.   "no individual transport routines
      x_header-flag = vim_transport_denied. "no transport
      IF maint_mode EQ aendern.
        MOVE 'TRSP' TO excl_cua_funct-function. COLLECT excl_cua_funct.
      ELSEIF maint_mode EQ transportieren.
        MESSAGE i128(sv) WITH "Auslieferungsklasse &, kein Transport mög
                x_header-customauth.
        RAISE missing_corr_number.
      ENDIF.
      MOVE 'ORDR' TO excl_cua_funct-function. COLLECT excl_cua_funct.
    ELSE.
      x_header-flag = 'X'.             "no standard logging
    ENDIF.
    sy-subrc = 9.
  ENDIF.
  IF sy-subrc EQ 9.
    MODIFY x_header INDEX 1.
  ENDIF.
*<<< Übergangslösung Transportstatus des Mandanten Anfang
* check if client allows transport
  CALL FUNCTION 'VIEW_GET_CLIENT_STATE'
    IMPORTING
      transp_state   = vim_client_state
      cliindep_state = gti_cliindep_state
      client_state   = gti_client_role.
  IF x_header-clidep NE space AND      "clientdependent and
     x_header-customauth CN sap_only_classes. "not delclass `S`
    CASE vim_client_state.
      WHEN vim_local_clnt. "client is local -> transport denied
        IF maint_mode EQ aendern OR maint_mode EQ anzeigen.
          excl_cua_funct-function = 'TRSP'. COLLECT excl_cua_funct.
          excl_cua_funct-function = 'ORDR'. COLLECT excl_cua_funct.
          x_header-flag = vim_transport_denied.
        ELSE.
          MESSAGE i130(sv) WITH "Mandant ist lokal, keine Transporte m
                  sy-mandt.
          RAISE missing_corr_number.
        ENDIF.
      WHEN vim_locked. "client is locked -> no changes but transport
*       IF MAINT_MODE EQ AENDERN.  "only for CUST/CUSY objects!!!!!!
*         MESSAGE I430(TK) WITH SY-MANDT."Mandant &1 'nicht änderbar'
*         MAINT_MODE = STATUS-ACTION = ANZEIGEN.
*         EXIT.
*       ENDIF.
    ENDCASE.
  ELSE. "clientindependent or deliveryclass 'S'
    vim_client_state = vim_log.        "such objects always log
  ENDIF.                               "xheader-clidep ne space.
*<<< Übergangslösung Transportstatus des Mandanten Ende
* if transport allowed -> get transport objects
  REFRESH vim_corr_objtab.
  gti_e071 = e071.
  IF x_header-frm_e071 NE space.       "individual transport objects
    PERFORM (x_header-frm_e071) IN PROGRAM (sy-repid).
  ENDIF.
  IF gti_flag_safe EQ space.                                "240997
* automatic recording of changes switched on in SE54
    APPEND gti_e071 TO vim_corr_objtab.
    IF x_header-adrnbrflag EQ 'N'.     "new version of addresses used
* addresses
      REFRESH: vim_addr_e071k_tab, vim_addr_e071_tab.
      CALL FUNCTION 'ADDR_TRANSPORT_TDAT_ENTRIES'
        TABLES
          e071k_tab = vim_addr_e071k_tab.
      addr_e071k2 = e071k.
      LOOP AT vim_addr_e071k_tab INTO addr_e071k.
        gti_e071-object = addr_e071k2-mastertype
         = addr_e071k-mastertype.
        gti_e071-obj_name = addr_e071k2-mastername
         = addr_e071k-mastername.
        APPEND gti_e071 TO vim_addr_e071_tab.
        APPEND gti_e071 TO vim_corr_objtab.
        MODIFY vim_addr_e071k_tab FROM addr_e071k2.
      ENDLOOP.
    ENDIF.
  ELSEIF x_header-frm_e071 EQ space AND    "no individual transport
         x_header-frm_e071ks EQ space AND  "routines and no standard
         x_header-frm_e071ka EQ space.
* no events concerning change recording are used
    APPEND gti_e071 TO vim_corr_objtab.    "but check cliiendep settings
    x_header-flag = vim_transport_denied. MODIFY x_header INDEX 1.
    IF maint_mode EQ aendern.
      MOVE 'TRSP' TO excl_cua_funct-function. COLLECT excl_cua_funct.
    ENDIF.
    MOVE 'ORDR' TO excl_cua_funct-function. COLLECT excl_cua_funct.
    gti_flag_safe = '@'.
  ENDIF.
* get object category and client dependency for transport objects
  LOOP AT vim_corr_objtab.
    CASE vim_corr_objtab-object.
      WHEN vim_view_type.              "-> view
        obj_type = vim_view.
      WHEN transp_object.              "-> tables
        obj_type = vim_tabl.
      WHEN vim_tran_type.              "-> individual transaction
        obj_type = vim_tran.
      WHEN vim_clus_type.           "-> cluster of views/tables/clusters
        obj_type = vim_clst.
      WHEN OTHERS.                     "-> may be: TLOGO object ?
        obj_type = vim_logo.
    ENDCASE.
    IF obj_type NE vim_logo.
      SELECT SINGLE * FROM objh
                      WHERE objectname EQ vim_corr_objtab-obj_name
                        AND objecttype EQ obj_type. "#EC CI_GENBUFF
    ELSE. "TLOGO -> use obj type as obj name
      SELECT SINGLE * FROM objh
                      WHERE objectname EQ vim_corr_objtab-object
                        AND objecttype EQ obj_type. "#EC CI_GENBUFF
    ENDIF.
    IF sy-subrc NE 0.
      IF obj_type NE vim_logo. "set defaults for table transp. obj.
        IF x_header-viewname EQ vim_corr_objtab-obj_name AND
           ( x_header-bastab EQ space AND
             vim_corr_objtab-object EQ vim_view_type OR
             x_header-bastab NE space AND
             vim_corr_objtab-object EQ transp_object ) OR
           vim_called_by_cluster NE space AND
           vim_calling_cluster EQ vim_corr_objtab-obj_name AND
           vim_corr_objtab-object EQ vim_clus_type.
          IF x_header-clidep EQ space. "clientindependent
            IF x_header-customauth CO customizing_delivery_classes.
              objh-objcateg = vim_cust_syst.
            ELSEIF x_header-customauth CO sap_only_classes.
              objh-objcateg = vim_syst.
            ELSEIF x_header-customauth CO application_delivery_classes.
              objh-objcateg = vim_appl.
            ELSE.
              objh-objcateg = vim_syst.
            ENDIF.
          ELSE.                        "clientdependent
            IF x_header-customauth CO customizing_delivery_classes.
              objh-objcateg = vim_cust.
            ELSEIF x_header-customauth CO sap_only_classes.
              objh-objcateg = vim_cust_syst.
            ELSEIF x_header-customauth CO application_delivery_classes.
              objh-objcateg = vim_appl.
            ELSE.
              objh-objcateg = vim_syst.
            ENDIF.
          ENDIF.
          objh-clidep   = x_header-clidep.
        ELSE.           "unknown object -> check if clientdep. table
          IF vim_corr_objtab-object EQ transp_object. "table
            gti_tabname = vim_corr_objtab-obj_name.
            CALL FUNCTION 'DDIF_NAMETAB_GET'
              EXPORTING
                tabname   = gti_tabname
              IMPORTING
                x030l_wa  = gti_x030l
              EXCEPTIONS
                not_found = 1
                OTHERS    = 2.
            IF sy-subrc EQ 0 AND gti_x030l-flagbyte O vim_clidep.
              objh-objcateg = vim_cust."clientdependent table
              objh-clidep   = 'X'.
            ELSE.                      "no nametab or clientindependent
              objh-objcateg = vim_syst.
              objh-clidep   = space.
            ENDIF.
          ELSE.                        "unknown object -> syst
            objh-objcateg = vim_syst.
            objh-clidep   = space.
          ENDIF.
        ENDIF.
      ELSE. "vim_logo                  "no objh-object -> syst
        objh-objcateg = vim_syst.
        objh-clidep   = space.
* note lockable transport object
        vim_corr_objtab-lockable = 'X'.
        MODIFY vim_corr_objtab.
      ENDIF.                           "obj_type ne vim_logo
    ELSE.
* entry in OBJH found -> check current setting, importability,
* protect-flag
      IF objh-cursetting <> space.           "UF615995/2000b
        cursetting = objh-cursetting.
      ENDIF.                                 "UF615995/2000e
      IF objh-importable <> space
       AND objh-importable < importable.     "#EC PORTABLE
* "most unimportable" object sets standard
        importable = objh-importable.
      ENDIF.
      IF objh-protect NE space.
        IF objh-objectname EQ x_header-viewname AND "current VIM object
           ( x_header-bastab EQ space AND objh-objecttype EQ vim_view OR
             x_header-bastab NE space AND objh-objecttype EQ vim_tabl ).
          IF x_header-frm_e071 EQ space AND
             x_header-frm_e071ks EQ space AND
             x_header-frm_e071ka EQ space. "no individ. transp. routines
            x_header-flag = vim_transport_denied. "no transport
            MOVE 'TRSP' TO excl_cua_funct-function.
            COLLECT excl_cua_funct.
            MOVE 'ORDR' TO excl_cua_funct-function.
            COLLECT excl_cua_funct.
*           EXIT.                                         "240997
          ELSE.
            x_header-flag = 'X'.       "no standard logging
            DELETE vim_corr_objtab.
          ENDIF.
          MODIFY x_header INDEX 1.
        ENDIF. "curr. VIM obj./ignore added individual transport objects
      ENDIF.                           "protect ne space
*     IF OBJH-OBJECTTYPE EQ VIM_LOGO.
* note object as lockable transport object until TR_OBJECTS_* force
* TLOGO-objects too  "changed in 4.0
      IF objh-checkid EQ 'L'.          "note lockable object!
        vim_corr_objtab-lockable = 'X'.
        MODIFY vim_corr_objtab.
      ENDIF.
    ENDIF.                             "sy-subrc ne 0.
    IF ( objh-objcateg EQ vim_syst OR
         objh-objcateg EQ vim_cust_syst ) AND
       last_category NE vim_syst.
      last_category = objh-objcateg.
    ENDIF.
    IF objh-clidep EQ space.
      last_clidep = objh-clidep.
    ENDIF.
  ENDLOOP.
* IF SY-SUBRC NE 0.  "may be user exits.....
  IF sy-subrc NE 0.
    IF ( x_header-frm_e071 NE space OR
       x_header-frm_e071ks EQ space AND x_header-frm_e071ka EQ space ).
      x_header-flag = vim_transport_denied. MODIFY x_header INDEX 1.
      IF maint_mode EQ aendern.
        MOVE 'TRSP' TO excl_cua_funct-function. COLLECT excl_cua_funct.
      ENDIF.
      MOVE 'ORDR' TO excl_cua_funct-function. COLLECT excl_cua_funct.
    ENDIF.
    EXIT. "if no object could be determined exit this routine
  ELSEIF gti_flag_safe EQ '@'.         "temporaryly appended
    REFRESH vim_corr_objtab.
  ENDIF.
* CHECK X_HEADER-FLAG NE VIM_TRANSPORT_DENIED.             "240997
  IF objh-objcateg NE vim_syst AND
     ( last_category EQ vim_syst OR
       last_category EQ vim_cust_syst ).
    objh-objcateg = last_category.
  ENDIF.
  objh-clidep = last_clidep.
* no logging for settings in productive clients
  IF cursetting NE space.
    x_header-cursetting = x_header-flag.
    TRANSLATE x_header-cursetting USING ' XXY'.
    MODIFY x_header INDEX 1.
  ENDIF.
* put importable-flag into x_header.
  IF importable <> 4.
    x_header-importable = importable.
    MODIFY x_header INDEX 1.
  ENDIF.
  IF maint_mode EQ aendern AND objh-clidep NE space AND
     cursetting NE space AND gti_client_role EQ 'P'.
    x_header-flag = vim_transport_denied. MODIFY x_header INDEX 1.
    MOVE 'ORDR' TO excl_cua_funct-function. COLLECT excl_cua_funct.
    EXIT.                                                   "240997
  ENDIF.
* CHECK X_HEADER-FLAG NE VIM_TRANSPORT_DENIED.          "240997
  IF x_header-flag NE vim_transport_denied AND
     vim_actopts-transp_off NE bc_transport_denied AND
     vim_client_state EQ vim_locked AND
     ( objh-objcateg EQ vim_cust OR objh-objcateg EQ vim_cust_syst ) AND
     maint_mode EQ aendern.            "only for CUST/CUSY objects!!!!!!
    MESSAGE i430(tk) WITH sy-mandt.    "Mandant &1 'nicht änderbar'
    maint_mode = status-action = anzeigen.
    ASSIGN dba_sellist-*sys* TO <vim_sellist>.
    vim_enqueue_range = x_header-subsetflag.
    PERFORM enqueue
                USING
                    'D'
                    space.
    EXIT.
  ENDIF.
  CASE gti_cliindep_state.
    WHEN vim_noact.
    WHEN vim_nocliindep_cust.
      IF maint_mode EQ aendern AND objh-objcateg = vim_cust_syst.
        CHECK x_header-flag NE vim_transport_denied.
        CHECK vim_actopts-transp_off NE bc_transport_denied.
        MESSAGE i731(tk).              " WITH SY-MANDT.
        maint_mode = status-action = anzeigen.
        ASSIGN dba_sellist-*sys* TO <vim_sellist>.
        vim_enqueue_range = x_header-subsetflag.
        PERFORM enqueue
                    USING
                        'D'
                        space.
        vim_client_state = vim_noact. EXIT.
      ENDIF.
    WHEN vim_noreposiandcust.
      IF maint_mode EQ aendern AND
       ( objh-objcateg = vim_syst OR objh-objcateg = vim_cust_syst ).
        CHECK x_header-flag NE vim_transport_denied.
        CHECK vim_actopts-transp_off NE bc_transport_denied.
        MESSAGE i730(tk).              " WITH SY-MANDT.
        maint_mode = status-action = anzeigen.
        ASSIGN dba_sellist-*sys* TO <vim_sellist>.
        vim_enqueue_range = x_header-subsetflag.
        PERFORM enqueue
                    USING
                        'D'
                        space.
        vim_client_state = vim_noact. EXIT.
      ENDIF.
    WHEN vim_noreposichanges.
      LOOP AT vim_corr_objtab INTO e071.
        CALL FUNCTION 'TR_CHECK_TYPE'
          EXPORTING
            wi_e071   = e071
          IMPORTING
            pe_result = tr_result.
*  PE_RESULT        syntax  transport  TADIR     TLOCK
*           SPACE     -         -        -         -
*             S       X         -        -         -
*             R       X         X        -         -
*             T       X         X        X         -  (only for sapsccs)
*             L       X         X        X         X
*             P     system object or illegal name selection
*                   (T100, SAPL...., ... )
* no repository object and not lockable?
        IF 'TLP' CS tr_result.
          MESSAGE i729(tk).              "WITH SY-MANDT.
          IF x_header-flag NE vim_transport_denied AND
             vim_actopts-transp_off NE bc_transport_denied.
            maint_mode = status-action = anzeigen.
            ASSIGN dba_sellist-*sys* TO <vim_sellist>.
            vim_enqueue_range = x_header-subsetflag.
            PERFORM enqueue
                        USING
                            'D'
                            space.
            vim_client_state = vim_noact.
          ENDIF.
          EXIT.
        ENDIF.
      ENDLOOP.
  ENDCASE.
ENDFORM.                               "get_transp_info
