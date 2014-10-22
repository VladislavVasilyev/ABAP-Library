*---------------------------------------------------------------------*
*       FORM PREPARE_CORR                                             *
*---------------------------------------------------------------------*
*       prepare command file tables (E070, E071)                      *
*---------------------------------------------------------------------*
FORM prepare_corr.
  DATA: x030l_sadr type x030l,
        pc_objtype LIKE objs-objecttype,
        pc_maint_mode(1) TYPE c.

  CHECK x_header-flag NE vim_transport_denied.
  CHECK vim_actopts-transp_off NE bc_transport_denied.
  CHECK maint_mode EQ transportieren OR"transport mode or change mode
        vim_client_state EQ vim_log.   "and logging required
  IF <status>-tr_alrchkd EQ 'x'.
* send warning if generic transport is required "HCG and no BCset import
    IF x_header-generictrp NE space and vim_import_profile EQ space.
      MESSAGE i141(sv) WITH vim_max_trsp_keylength
                            vim_max_trsp_identical_key
                            x_header-maxtrkeyln.
    ELSEIF x_header-genertxtrp NE space and vim_import_profile EQ space.
      MESSAGE i141(sv) WITH vim_max_trsp_keylength
                            vim_max_trsp_identical_key
                            x_header-maxtrtxkln.
    ENDIF.
    DESCRIBE TABLE vim_corr_objtab.
    IF sy-tfill GT 0.                  "save objects in corr_keytab
      CLEAR corr_keytab.
      MOVE x_header-viewname TO corr_keytab-mastername.
      LOOP AT vim_corr_objtab.
        IF vim_corr_objtab-lockable EQ space.
          corr_keytab-mastertype = vim_unlockable_object.
        ELSE.
          corr_keytab-mastertype = vim_lockable_object.
        ENDIF.
        MOVE: vim_corr_objtab-pgmid    TO corr_keytab-pgmid,
              vim_corr_objtab-object   TO corr_keytab-object,
*             VIM_CORR_OBJTAB-OBJ_NAME TO CORR_KEYTAB-OBJNAME,
              vim_corr_objtab-objfunc  TO corr_keytab-objfunc,
        vim_corr_objtab-activity TO corr_keytab-activity. "UF738595/2001
        sy-fdpos = strlen( vim_corr_objtab-obj_name ).
        IF sy-fdpos GT vim_71k_name_length.
          corr_keytab-objname = vim_long_objname.
          corr_keytab-tabkey  = vim_corr_objtab-obj_name.
        ELSE.
          corr_keytab-objname = vim_corr_objtab-obj_name.
        ENDIF.
        READ TABLE corr_keytab
                   WITH KEY pgmid      = corr_keytab-pgmid
                            object     = corr_keytab-object
                            objname    = corr_keytab-objname
                            objfunc    = corr_keytab-objfunc
                            mastertype = corr_keytab-mastertype
                            mastername = corr_keytab-mastername
                   TRANSPORTING NO FIELDS.
        CHECK sy-subrc NE 0.
        IF vim_corr_objtab-trkorr EQ space.
          MOVE: <status>-corr_nbr    TO corr_keytab-trkorr,
                <status>-corr_nbr    TO vim_corr_objtab-trkorr.
          MODIFY vim_corr_objtab.
        ELSE.
          corr_keytab-trkorr = vim_corr_objtab-trkorr.
        ENDIF.
        corr_keytab-flag = 'V'.
        APPEND corr_keytab.
      ENDLOOP.
    ENDIF.                             "sy-tfill
  ENDIF.                               "<status>-tr_alrchkd eq 'x'.
  IF maint_mode EQ transportieren.
    MOVE 'X' TO get_corr_keytab.
    IF <status>-keytbinvld EQ space.
      LOOP AT vim_corr_objtab WHERE lockable EQ space.
        LOOP AT corr_keytab WHERE mastertype EQ vim_corr_objtab-object
                             AND mastername EQ vim_corr_objtab-obj_name.
          EXIT.
        ENDLOOP.
        IF sy-subrc EQ 0.
          CLEAR get_corr_keytab.
        ENDIF.
      ENDLOOP.
    ELSE.
      LOOP AT vim_corr_objtab WHERE lockable EQ space.
        LOOP AT corr_keytab WHERE mastertype EQ vim_corr_objtab-object
                             AND mastername EQ vim_corr_objtab-obj_name.
          DELETE corr_keytab.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
  ENDIF.
  MOVE <status>-corr_nbr TO <status>-l_corr_nbr.
  <status>-tr_alrchkd = 'X'.
  IF ( status-action EQ transportieren OR
       vim_client_state EQ vim_log ) AND
     x_header-adrnbrflag EQ 'O' AND sadr_namtab_read EQ space.
    CALL FUNCTION 'DDIF_NAMETAB_GET'
      EXPORTING
        tabname           = 'SADR'
      IMPORTING
        X030L_WA          = x030l_sadr
      EXCEPTIONS
        OTHERS            = 2.
    IF sy-subrc EQ 0.
      MOVE 'X' TO sadr_namtab_read.
      sadr_keylen = x030l_sadr-keylen
                     / cl_abap_char_utilities=>charsize.
* Übrgangslösung Adreßtabellen SADR2...SADR5 zu 3.0A Anfang
      IF x_header-bastab EQ space.
        pc_objtype = 'V'.
      ELSE.
        pc_objtype = 'S'.
      ENDIF.
      CALL FUNCTION 'VIEW_CHECK_OBJ_LIST_FOR_ADDR'
        EXPORTING
          objectname                     = x_header-viewname
          objecttype                     = pc_objtype
        EXCEPTIONS
          not_all_address_tables_in_list = 01.
      IF sy-subrc NE 0. "regenerating of object list required
        pc_maint_mode = x_header-bastab.
        TRANSLATE pc_maint_mode USING ' VXS'.
        CALL FUNCTION 'OBJ_GENERATE'
          EXPORTING
            iv_objectname    = x_header-viewname
            iv_objecttype    = pc_maint_mode
            iv_maint_mode    = aendern
            iv_no_correction = 'X'
          EXCEPTIONS                                       "#EC *
            OTHERS           = 5.
      ENDIF.
* Übrgangslösung Adreßtabellen SADR2...SADR5 zu 3.0A Ende
    ELSE.
      RAISE nametab_get_failed.                            "#EC *
    ENDIF.
  ENDIF.
ENDFORM.                    "PREPARE_CORR
