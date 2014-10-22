*----------------------------------------------------------------------*
***INCLUDE LSVIMF63 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  vim_comp_roottabkey
*&---------------------------------------------------------------------*
*       Check if view and root table have identical keys.
*----------------------------------------------------------------------*
*      -->P_HEADER  text
*      -->P_NAMTAB  text
*      <--P_KEYS_IDENTICAL  text
*      <--P_RC  text
*----------------------------------------------------------------------*
FORM vim_comp_roottabkey  USING    p_header TYPE vimdesc
                                   p_namtab TYPE vimnamtab_type
                          CHANGING p_keys_identical TYPE xfeld
                                   p_rc TYPE sy-subrc.
  TYPES: BEGIN OF flagstruc_type,
          viewname TYPE viewname,
          keys_ident,
         END OF flagstruc_type.

  STATICS: flagtab TYPE HASHED TABLE OF flagstruc_type
           WITH UNIQUE KEY viewname.
  DATA: w_flagtab TYPE flagstruc_type,
        x031l_tab TYPE TABLE OF x031l.
  FIELD-SYMBOLS: <namtab> TYPE vimnamtab,
                 <x031l> TYPE x031l.

  CLEAR p_rc.
  READ TABLE flagtab WITH TABLE KEY viewname = p_header-viewname
   INTO w_flagtab.
  IF sy-subrc <> 0.
    w_flagtab-viewname = p_header-viewname.
    w_flagtab-keys_ident = 'X'.
    CALL FUNCTION 'DDIF_NAMETAB_GET'
      EXPORTING
        tabname   = p_header-roottab
      TABLES
        x031l_tab = x031l_tab
      EXCEPTIONS
        OTHERS    = 2.
    IF sy-subrc <> 0.
      p_rc = sy-subrc.
    ENDIF.
    LOOP AT p_namtab ASSIGNING <namtab> WHERE keyflag = 'X'.
      IF <namtab>-bastabname <> p_header-roottab.
        sy-subrc = 4.
      ELSE.
        READ TABLE x031l_tab INDEX sy-tabix ASSIGNING <x031l>.
      ENDIF.
      IF sy-subrc <> 0 OR <x031l>-fieldname <> <namtab>-bastabfld.
        clear w_flagtab-keys_ident.
        exit.
      ENDIF.
    ENDLOOP.
    INSERT w_flagtab INTO TABLE flagtab.
  ENDIF.
  p_keys_identical = w_flagtab-keys_ident.
ENDFORM.                    " vim_comp_roottabkey
