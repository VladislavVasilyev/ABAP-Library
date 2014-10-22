*---------------------------------------------------------------------*
*       FORM CHECK_TRANSP_OBJS_FOR_MAINT                              *
*---------------------------------------------------------------------*
*  check transport objects for logging during maintenance             *
*---------------------------------------------------------------------*
FORM check_transp_objs_for_maint USING ctofm_return TYPE i.
  DATA: obj_appendable(1) TYPE c, rc LIKE sy-subrc, e071_safe LIKE e071,
      last_order LIKE e071-trkorr, ctofm_ko200_tab LIKE ko200 OCCURS 10,
        ctofm_keytab_safe LIKE corr_keytab OCCURS 50,
        last_corr LIKE e071-trkorr.

  CLEAR ctofm_return.
  CHECK maint_mode EQ aendern.
* Insert IMG-activity
  PERFORM vim_get_img_activity CHANGING e071-activity.  "UF738595/2001
  IF vim_corr_obj_viewname NE x_header-viewname.
    CLEAR e071-trkorr.
    PERFORM get_transp_info.
    CHECK x_header-flag NE vim_transport_denied.
    CHECK vim_actopts-transp_off NE bc_transport_denied.
    IF maint_mode EQ anzeigen. ctofm_return = 4. EXIT. ENDIF.
  ELSE. " csn ext.382209 2002 XB
    IF NOT objh IS INITIAL.
      IF x_header-importable IS INITIAL.
        x_header-importable = objh-importable.
      ENDIF.
    ENDIF.
  ENDIF.
  CHECK vim_client_state EQ vim_log.
  IF <status>-corr_nbr NE <status>-l_corr_nbr.
    CLEAR: <status>-tr_alrchkd, <status>-corr_enqud.
  ENDIF.
  IF <status>-tr_alrchkd NE space.
    vim_corr_obj_viewname = x_header-viewname.
    EXIT.
  ENDIF.
* first get corr nbr for lockable transport objects
  e071_safe = e071.
  CLEAR vim_last_source_system.
  LOOP AT vim_corr_objtab WHERE lockable NE space.
    e071 = vim_corr_objtab.
    PERFORM check_lockable_object USING e071 ctofm_return.
    IF ctofm_return NE 0 OR x_header-flag EQ vim_transport_denied.
      EXIT.
    ENDIF.
  ENDLOOP.
  IF ctofm_return NE 0 OR x_header-flag EQ vim_transport_denied.
    e071 = e071_safe. EXIT.
  ENDIF.
  vim_corr_obj_viewname = x_header-viewname.
* second: check unlockable objects
* REFRESH VIM_ULO_TRSP_OBJS.
  LOOP AT vim_corr_objtab WHERE lockable EQ space.
    e071 = vim_corr_objtab.
*   APPEND E071 TO VIM_ULO_TRSP_OBJS.
    APPEND e071 TO ctofm_ko200_tab.
  ENDLOOP.
  IF sy-subrc EQ 0.                    "only if unlockable objects exist
* CTOFM_KO200_TAB = VIM_ULO_TRSP_OBJS.
    LOOP AT corr_keytab.                "save keys of other objects
      LOOP AT vim_corr_objtab WHERE lockable EQ space
                                AND object   EQ corr_keytab-mastertype
                                AND obj_name EQ corr_keytab-mastername.
        EXIT.
      ENDLOOP.
      CHECK sy-subrc NE 0.
      APPEND corr_keytab TO ctofm_keytab_safe.
      DELETE corr_keytab.
    ENDLOOP.
    last_order = <status>-order_nbr.
    last_corr = <status>-corr_nbr.
    CALL FUNCTION 'TR_OBJECTS_CHECK'
      IMPORTING
        we_order                = <status>-order_nbr
        we_task                 = <status>-corr_nbr
        we_objects_appendable   = obj_appendable
      TABLES
        wt_ko200                = ctofm_ko200_tab
        wt_e071k                = corr_keytab
      EXCEPTIONS
        cancel_edit_other_error = 1
        show_only_other_error   = 2
        OTHERS                  = 3.
    IF sy-subrc NE 0.
      rc = sy-subrc.
      MESSAGE ID      sy-msgid
              TYPE    'I'
              NUMBER  sy-msgno
              WITH    sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      IF rc = 2.
*     MAINT_MODE = STATUS-ACTION = ANZEIGEN.
        ctofm_return = 4.
        e071 = e071_safe. EXIT.
      ELSE.                            "cancel edit
*     RAISE MISSING_CORR_NUMBER.
        ctofm_return = 8. e071 = e071_safe. EXIT.
      ENDIF.
    ENDIF.
    IF <status>-corr_nbr NE space AND last_corr NE space.
      IF last_corr NE <status>-corr_nbr.
        IF <status>-order_nbr NE last_order.
          MESSAGE i129(sv). "Zusammengehörige Objekte in verschied
*       RAISE MISSING_CORR_NUMBER.
          ctofm_return = 4. e071 = e071_safe. EXIT.
        ENDIF.
      ENDIF.
    ELSE.
      IF <status>-corr_nbr EQ space.
        <status>-corr_nbr = last_corr.
        <status>-order_nbr = last_order.
      ENDIF.
    ENDIF.
    LOOP AT ctofm_keytab_safe INTO corr_keytab. "restore saved entries
      APPEND corr_keytab.
    ENDLOOP.
    IF obj_appendable EQ space.        "no ...INSERT - call required
      vim_client_state = vim_noact.
    ENDIF.
  ENDIF.                               "unlockable objects exist
  e071 = e071_safe.
  <status>-tr_alrchkd = 'x'.
ENDFORM.                               "check_transp_objs_for_maint
*&---------------------------------------------------------------------*
*&      Form  vim_get_img_activity
*&---------------------------------------------------------------------*
*       Gets IMG-activity the dialogue has been called from.
*       UF738595/2001
*----------------------------------------------------------------------*
*      <--P_ACTIVITY  IMG-activity
*----------------------------------------------------------------------*
FORM vim_get_img_activity  CHANGING p_activity TYPE e071-activity.

  CALL FUNCTION 'READ_IMG_ACTIVITY_FROM_MEMORY'
    IMPORTING
      img_activity = p_activity.
ENDFORM.                    " get_img_activity
