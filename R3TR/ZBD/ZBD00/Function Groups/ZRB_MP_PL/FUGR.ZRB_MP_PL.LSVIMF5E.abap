*----------------------------------------------------------------------*
*   INCLUDE LSVIMF5E                                                   *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  vim_make_guid
*&---------------------------------------------------------------------*
*       Sets GUID values in a dataset. Only used if a new entry is
*       created. If p_viewfield is set, only one GUID is filled.
*----------------------------------------------------------------------*
*  -->  p_viewfield   Name of GUID field in table/view
*  <--  p2        text
*----------------------------------------------------------------------*
FORM vim_make_guid USING p_viewfield TYPE viewfield.

  DATA: fieldname TYPE fnam_____4,
        old_guid TYPE REF TO data.
  FIELD-SYMBOLS: <x_namtab> TYPE vimnamtab, <guid> TYPE ANY,
                 <old_guid> TYPE ANY, <work_area> TYPE ANY.

  IF p_viewfield = space.
* set all GUIDs in structure
    LOOP AT x_namtab ASSIGNING <x_namtab> WHERE keyflag = space
     AND bastabname <> x_header-texttab AND domname IN vim_guid_domain.
* non-key and non-textfields only
      CONCATENATE x_header-maintview <x_namtab>-viewfield
       INTO fieldname SEPARATED BY '-'.
      ASSIGN (fieldname) TO <guid> CASTING TYPE (fieldname).
      IF <status>-prof_found = vim_pr_into_view
* importing BC-set manually
       OR vim_import_profile <> space
* importing BC-set in background
       OR vim_special_mode = vim_upgrade.
* importing from remote system/client
        CHECK <guid> IS INITIAL.
      ENDIF.
      CREATE DATA old_guid TYPE (fieldname).
      ASSIGN old_guid->* TO <old_guid>.
      CASE <x_namtab>-domname.
        WHEN 'SYSUUID'.
          ASSIGN (fieldname) TO <guid> CASTING TYPE guid_16.
          MOVE <guid> TO <old_guid>.
          CALL FUNCTION 'GUID_CREATE'
               IMPORTING
                    ev_guid_16 = <guid>.
        WHEN 'SYSUUID_C'.
          ASSIGN (fieldname) TO <guid> CASTING TYPE guid_32.
          MOVE <guid> TO <old_guid>.
          CALL FUNCTION 'GUID_CREATE'
               IMPORTING
                    ev_guid_32 = <guid>.
        WHEN 'SYSUUID_22'.
          ASSIGN (fieldname) TO <guid> CASTING TYPE guid_22.
          MOVE <guid> TO <old_guid>.
          CALL FUNCTION 'GUID_CREATE'
               IMPORTING
                    ev_guid_22 = <guid>.
        WHEN 'SYSUUID_25'.
          ASSIGN (fieldname) TO <guid> CASTING TYPE rssguid25.
          MOVE <guid> TO <old_guid>.
          CALL FUNCTION 'RSS_SYSTEM_GET_UNIQUE_ID'
               IMPORTING
                    e_uni_idc25 = <guid>.
      ENDCASE.
      IF x_header-frm_af_uid <> space.
        ASSIGN (x_header-maintview) TO <work_area>
         CASTING TYPE (x_header-maintview).
        PERFORM (x_header-frm_af_uid) IN PROGRAM (x_header-fpoolname)
                                      USING <old_guid>
                                      CHANGING <guid>
                                               <work_area>.
      ENDIF.
    ENDLOOP.
  ELSE.
* set GUID for p_viewfield only
    READ TABLE x_namtab ASSIGNING <x_namtab>
     WITH KEY viewfield = p_viewfield.
    CHECK sy-subrc = 0 AND <x_namtab>-domname IN vim_guid_domain.
* non-key and non-textfields only
    CONCATENATE x_header-maintview <x_namtab>-viewfield
     INTO fieldname SEPARATED BY '-'.
    ASSIGN (fieldname) TO <guid> CASTING TYPE (fieldname).
    IF <status>-prof_found = vim_pr_into_view
* importing BC-set manually
     OR vim_import_profile <> space
* importing BC-set in background
     OR vim_special_mode = vim_upgrade.
* importing from remote system/client
      CHECK <guid> IS INITIAL.
    ENDIF.
    CREATE DATA old_guid TYPE (fieldname).
    ASSIGN old_guid->* TO <old_guid>.
    CASE <x_namtab>-domname.
      WHEN 'SYSUUID'.
        ASSIGN (fieldname) TO <guid> CASTING TYPE guid_16.
        MOVE <guid> TO <old_guid>.
        CALL FUNCTION 'GUID_CREATE'
             IMPORTING
                  ev_guid_16 = <guid>.
      WHEN 'SYSUUID_C'.
        ASSIGN (fieldname) TO <guid> CASTING TYPE guid_32.
        MOVE <guid> TO <old_guid>.
        CALL FUNCTION 'GUID_CREATE'
             IMPORTING
                  ev_guid_32 = <guid>.
      WHEN 'SYSUUID_22'.
        ASSIGN (fieldname) TO <guid> CASTING TYPE guid_22.
        MOVE <guid> TO <old_guid>.
        CALL FUNCTION 'GUID_CREATE'
             IMPORTING
                  ev_guid_22 = <guid>.
      WHEN 'SYSUUID_25'.
        ASSIGN (fieldname) TO <guid> CASTING TYPE rssguid25.
        MOVE <guid> TO <old_guid>.
        CALL FUNCTION 'RSS_SYSTEM_GET_UNIQUE_ID'
             IMPORTING
                  e_uni_idc25 = <guid>.
    ENDCASE.
    IF x_header-frm_af_uid <> space.
      ASSIGN (x_header-maintview) TO <work_area>
       CASTING TYPE (x_header-maintview).
      PERFORM (x_header-frm_af_uid) IN PROGRAM (x_header-fpoolname)
                                    USING <old_guid>
                                    CHANGING <guid>
                                             <work_area>.
    ENDIF.
  ENDIF.
ENDFORM.                               " vim_make_guid
