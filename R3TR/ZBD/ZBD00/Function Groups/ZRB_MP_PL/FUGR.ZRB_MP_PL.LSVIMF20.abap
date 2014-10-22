*---------------------------------------------------------------------*
*       FORM REQUEST_CORR_NUMBER                                      *
*---------------------------------------------------------------------*
*       request correction number                                     *
*---------------------------------------------------------------------*
FORM request_corr_number.
  DATA: rc LIKE sy-subrc, e071_safe LIKE e071.

  CHECK maint_mode EQ transportieren.  "manual transport mode
  IF <status>-l_corr_nbr NE space.
    IF <status>-corr_nbr NE <status>-l_corr_nbr.
      CLEAR: <status>-tr_alrchkd, <status>-corr_enqud.
    ELSE.
      IF vim_external_mode EQ space.
        TRANSLATE <status>-tr_alrchkd USING 'Xx'.
      ENDIF.
    ENDIF.
  ENDIF.
  PERFORM vim_get_img_activity CHANGING e071-activity.  "UF738595/2001
  IF vim_corr_obj_viewname NE x_header-viewname.
    CLEAR e071-trkorr.
    PERFORM get_transp_info.
    CHECK x_header-flag NE vim_transport_denied.
    CHECK vim_actopts-transp_off NE bc_transport_denied.
  ENDIF.
  IF <status>-tr_alrchkd EQ space.
* first get corr nbr for lockable transport objects
    e071_safe = e071.
    CLEAR vim_last_source_system.
    LOOP AT vim_corr_objtab WHERE lockable NE space.
      e071 = vim_corr_objtab.
      PERFORM check_lockable_object USING e071 rc.
      CASE rc.
        WHEN 4. maint_mode = anzeigen.
        WHEN 8. RAISE missing_corr_number.
      ENDCASE.
      IF maint_mode EQ anzeigen OR
         x_header-flag EQ vim_transport_denied OR
         vim_actopts-transp_off EQ bc_transport_denied.
        EXIT.
      ENDIF.
    ENDLOOP.
    e071 = e071_safe.
  ENDIF.                               "<status>-tr_alrchkd eq space
  CHECK maint_mode NE anzeigen AND
        x_header-flag NE vim_transport_denied AND
        vim_actopts-transp_off NE bc_transport_denied.
  vim_corr_obj_viewname = x_header-viewname.
  IF <status>-corr_nbr NE space AND    "task specified and...
     corr_nbr EQ space AND          "...task not setted by caller and...
     <status>-corr_enqud EQ space.     "...corr not yet enqueued
    CALL FUNCTION 'ENQUEUE_E_TRKORR'
         EXPORTING
              trkorr = <status>-corr_nbr
*               X_TRKORR = E02
         EXCEPTIONS
              foreign_lock = 01
              system_failure = 02.
    CASE sy-subrc.
      WHEN 1.
        MESSAGE s092(sv) WITH <status>-corr_nbr. "Korr. wird ger.bearb.
      WHEN 2.
        MESSAGE a095(sv) WITH <status>-corr_nbr. "Systemfehler
    ENDCASE.
    <status>-corr_enqud = 'X'.
  ENDIF.
* if no lockable objects exist get corr nbr for other objects...
* but only if objects exist....
  DESCRIBE TABLE vim_corr_objtab.
  IF <status>-corr_nbr EQ space AND sy-tfill GT 0.
    DO.
      CALL FUNCTION 'TR_ORDER_CHOICE_CORRECTION'
           EXPORTING
                iv_category            = objh-objcateg
                iv_cli_dep             = objh-clidep
           IMPORTING
                ev_order               = <status>-order_nbr
                ev_task                = <status>-corr_nbr
           EXCEPTIONS
                invalid_category       = 01
                no_correction_selected = 02.
      CASE sy-subrc.
        WHEN 1.
          IF objh-objcateg NE vim_syst AND objh-objcateg NE vim_cust.
            CASE objh-objcateg.
              WHEN vim_cust_syst. objh-objcateg = vim_syst.
              WHEN vim_appl.      objh-objcateg = vim_syst.
              WHEN OTHERS.
                MESSAGE ID     sy-msgid
                        TYPE   'I'
                        NUMBER sy-msgno
                        WITH sy-msgv1 sy-msgv2  sy-msgv3 sy-msgv4.
                RAISE missing_corr_number.
            ENDCASE.
            CONTINUE.
          ENDIF.
        WHEN 2.
          CLEAR vim_corr_obj_viewname.
          RAISE missing_corr_number.
      ENDCASE.
      CALL FUNCTION 'ENQUEUE_E_TRKORR'
           EXPORTING
                trkorr = <status>-corr_nbr
*               X_TRKORR = E02
           EXCEPTIONS
                foreign_lock = 01
                system_failure = 02.
      CASE sy-subrc.
*       WHEN 0.
        WHEN 1.
          MESSAGE s092(sv) WITH <status>-corr_nbr. "Korr. wirdger.bearb.
          CONTINUE.
        WHEN 2.
          MESSAGE a095(sv) WITH <status>-corr_nbr. "Systemfehler
          CONTINUE.
      ENDCASE.
      IF ( last_corr_number NE space AND
           <status>-corr_nbr NE last_corr_number ) OR
         <status>-tr_alrchkd EQ space.
        LOOP AT corr_keytab.             "UF 514599/1999beg
          READ TABLE vim_corr_objtab
           WITH KEY pgmid    = corr_keytab-pgmid
           object   = corr_keytab-object obj_name = corr_keytab-objname.
          CHECK sy-subrc = 0 AND vim_corr_objtab-lockable = space.
* new corrnumber for unlockable objects only
          CLEAR vim_corr_objtab-trkorr.
* will be filled again in form PREPARE_CORR
          MODIFY vim_corr_objtab INDEX sy-tabix.
        ENDLOOP.                       "UF 514599/1999end
        REFRESH corr_keytab.
        MOVE <status>-corr_nbr TO last_corr_number.
      ELSEIF last_corr_number EQ space.
        LOOP AT corr_keytab WHERE
                                ( mastertype EQ vim_unlockable_object OR
                                  mastertype EQ vim_lockable_object ).
*                           AND TRKORR EQ SPACE.
* SW: bei TRSP -> neue Korrnummer, alte blieb aber in CORR_KEYTAB-TRKORR
          IF  corr_keytab-trkorr EQ space.
            corr_keytab-trkorr = <status>-corr_nbr.
            MODIFY corr_keytab.
          ELSE.                        "SW ..
            READ TABLE vim_corr_objtab
                    WITH KEY pgmid    = corr_keytab-pgmid
                             object   = corr_keytab-object
                             obj_name = corr_keytab-objname.
            IF sy-subrc = 0.
              corr_keytab-trkorr = <status>-corr_nbr.
              MODIFY corr_keytab.
            ENDIF.
          ENDIF.                       ".. SW
        ENDLOOP.
      ENDIF.
      EXIT.
    ENDDO.
    <status>-corr_enqud = 'X'.
  ENDIF.                               "<status>-corr_nbr eq space
  MOVE: <status>-corr_nbr TO e071k-trkorr,
        <status>-corr_nbr TO e071-trkorr,
        <status>-corr_nbr TO e070-trkorr.
  TRANSLATE <status>-tr_alrchkd USING ' x'.
ENDFORM.
