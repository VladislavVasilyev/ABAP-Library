*---------------------------------------------------------------------*
*       FORM UPDATE_CORR_KEYTAB
*---------------------------------------------------------------------*
*       update CORR_KEYTAB
*---------------------------------------------------------------------*
* UET_ACTION ---> action: A - add to, D - delete from CORR_KEYTAB     *
*                         P - check if entry exists in CORR_KEYTAB    *
*                         W - do nothing
* CORR_KEYTAB (global) ---> header of CORR_KEYTAB with current entry  *
*---------------------------------------------------------------------*
FORM update_corr_keytab USING value(uet_action) uet_rc.
  DATA: e071k_safe LIKE e071k,
        asteriskpos TYPE i.
  MOVE: 1 TO uet_rc,
        corr_keytab TO e071k_safe.
* modify tabkey if only generic transport allowed
  IF vim_exit_11_12_active EQ space.
    IF e071k_safe-objname EQ x_header-texttab.
      IF x_header-genertxtrp NE space.
        asteriskpos
         = x_header-trtxgkpos / cl_abap_char_utilities=>charsize.
        CHECK e071k_safe-tabkey NE space.
        e071k_safe-tabkey+asteriskpos = '*'.
      ENDIF.
    ELSE.
      asteriskpos
       = x_header-trgkeypos / cl_abap_char_utilities=>charsize.
      IF x_header-generictrp NE space.
        e071k_safe-tabkey+asteriskpos = '*'.
      ENDIF.
    ENDIF.
  ELSE. "exits active - clear VIEWNAME for non-ddic-viewtables.
    CLEAR e071k_safe-viewname.
  ENDIF.
  CASE uet_action.
    WHEN hinzufuegen.
      IF e071k_safe-object EQ transp_object.     "table keys
        LOOP AT corr_keytab WHERE objname    EQ e071k_safe-objname
                              AND tabkey     EQ e071k_safe-tabkey
                              AND mastername EQ e071k_safe-mastername.
          IF corr_keytab-pgmid EQ vim_deleted_key.
            MOVE e071k_safe TO corr_keytab.
            MODIFY corr_keytab.
            CLEAR uet_rc.
          ENDIF.
          EXIT.
        ENDLOOP.
      ELSE.                            "other objects
        LOOP AT corr_keytab WHERE pgmid      EQ e071k_safe-pgmid
                              AND object     EQ e071k_safe-object
                              AND objname    EQ e071k_safe-objname
                              AND tabkey     EQ e071k_safe-tabkey
                              AND mastername EQ e071k_safe-mastername.
          IF corr_keytab-objfunc EQ 'D'.
            MOVE e071k_safe TO corr_keytab.
            MODIFY corr_keytab.
            CLEAR uet_rc.
          ENDIF.
          EXIT.
        ENDLOOP.
      ENDIF.
      IF sy-subrc NE 0.
        MOVE e071k_safe TO corr_keytab.
        APPEND corr_keytab.
        CLEAR uet_rc.
      ENDIF.
    WHEN geloescht.
      IF e071k_safe-object EQ transp_object.     "table keys
        LOOP AT corr_keytab WHERE objname    EQ e071k_safe-objname
                              AND tabkey     EQ e071k_safe-tabkey
                              AND mastername EQ e071k_safe-mastername
                              AND pgmid      NE vim_deleted_key.
          corr_keytab-pgmid = vim_deleted_key.
          MODIFY corr_keytab.
          CLEAR uet_rc.
          EXIT.
        ENDLOOP.
      ELSE.                            "other objects
        IF e071k_safe-mastername EQ space. "avoid error in exit rout.
          e071k_safe-mastername = master_name.
        ENDIF.
        LOOP AT corr_keytab WHERE pgmid      EQ e071k_safe-pgmid
                              AND object     EQ e071k_safe-object
                              AND objname    EQ e071k_safe-objname
                              AND tabkey     EQ e071k_safe-tabkey
                              AND mastername EQ e071k_safe-mastername.
*                             AND OBJFUNC    NE 'D'.
          IF corr_keytab-objfunc NE 'D'.
            corr_keytab-objfunc = 'D'.
            MODIFY corr_keytab.
            CLEAR uet_rc.
          ENDIF.
          EXIT.
        ENDLOOP.
* << Übergangslösung, da objekte zum Tabkey noch nicht eingelesen werden
        IF sy-subrc NE 0.
          MOVE e071k_safe TO corr_keytab.
          corr_keytab-objfunc = 'D'.
          APPEND corr_keytab.
          CLEAR uet_rc.
        ENDIF.
* >> Übergangslösung, da objekte zum Tabkey noch nicht eingelesen werden
      ENDIF.
    WHEN pruefen.
      IF e071k_safe-object EQ transp_object.     "table keys
        LOOP AT corr_keytab WHERE objname    EQ e071k_safe-objname
                              AND tabkey     EQ e071k_safe-tabkey
                              AND mastername EQ e071k_safe-mastername
                              AND pgmid      NE vim_deleted_key.
          CLEAR uet_rc.
          EXIT.
        ENDLOOP.
      ELSE.                            "other objects
        LOOP AT corr_keytab WHERE pgmid      EQ e071k_safe-pgmid
                              AND object     EQ e071k_safe-object
                              AND objname    EQ e071k_safe-objname
                              AND tabkey     EQ e071k_safe-tabkey
                              AND mastername EQ e071k_safe-mastername
                              AND objfunc    NE 'D'.
          CLEAR uet_rc.
          EXIT.
        ENDLOOP.
      ENDIF.
    WHEN vim_writing_bc_imp_log.
      APPEND corr_keytab.
  ENDCASE.
  IF uet_rc EQ 0 AND uet_action NE pruefen.
    MOVE 'X' TO <status>-keytbmodfd.
  ENDIF.
ENDFORM.                    "UPDATE_CORR_KEYTAB
