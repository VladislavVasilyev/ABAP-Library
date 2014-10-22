*----------------------------------------------------------------------*
***INCLUDE LSVIMF62 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  vim_get_trspkeylen
*&---------------------------------------------------------------------*
*       Delivers key length in bytes of tables whithin a view. Called
*       by generated forms CORR_MAINT_yxz
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM vim_get_trspkeylen USING    p_tabname TYPE tabname
                        CHANGING p_keylength TYPE syfleng.

  TYPES: BEGIN OF tabkeylen_type,
          tabname TYPE tabname,
          keylen TYPE syfleng,
         END OF tabkeylen_type.
  STATICS: tabkeylen_tab TYPE HASHED TABLE OF tabkeylen_type
            WITH UNIQUE KEY tabname.
  DATA: w_tabkeylen TYPE tabkeylen_type,
        x030l_wa TYPE x030l.

  READ TABLE tabkeylen_tab INTO w_tabkeylen
   WITH TABLE KEY tabname = p_tabname.
  IF sy-subrc <> 0.
    CALL FUNCTION 'DDIF_NAMETAB_GET'
      EXPORTING
        tabname  = p_tabname
      IMPORTING
        x030l_wa = x030l_wa.
    w_tabkeylen-tabname = p_tabname.
    w_tabkeylen-keylen  = x030l_wa-keylen.
    IF p_tabname = x_header-texttab AND x_header-genertxtrp <> space.
      w_tabkeylen-keylen = x_header-maxtrtxkln.
    ELSEIF x_header-generictrp <> space.
      w_tabkeylen-keylen = x_header-maxtrkeyln.
    ENDIF.
    INSERT w_tabkeylen INTO TABLE tabkeylen_tab.
  ENDIF.
  p_keylength = w_tabkeylen-keylen.
ENDFORM.                    " vim_get_trspkeylen

*&---------------------------------------------------------------------*
*&      Form  vim_get_bc_keylen
*&---------------------------------------------------------------------*
*       Delivers key length in bytes of tables whithin a view up to
*       255 char. Necessary for writing activation links
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM vim_get_bc_keylen USING    p_tabname TYPE tabname
                        CHANGING p_keylength TYPE syfleng.

  CONSTANTS max_bc_keylen TYPE i VALUE 255.

  TYPES: BEGIN OF tabkeylen_type,
          tabname TYPE tabname,
          keylen TYPE syfleng,
         END OF tabkeylen_type.
  STATICS: tabkeylen_tab TYPE HASHED TABLE OF tabkeylen_type
            WITH UNIQUE KEY tabname.
  DATA: w_tabkeylen TYPE tabkeylen_type,
        x030l_wa TYPE x030l, max_keylen_byte TYPE i.

  READ TABLE tabkeylen_tab INTO w_tabkeylen
   WITH TABLE KEY tabname = p_tabname.
  IF sy-subrc <> 0.
    CALL FUNCTION 'DDIF_NAMETAB_GET'
      EXPORTING
        tabname  = p_tabname
      IMPORTING
        x030l_wa = x030l_wa.
    w_tabkeylen-tabname = p_tabname.
    w_tabkeylen-keylen  = x030l_wa-keylen.
    max_keylen_byte = max_bc_keylen * cl_abap_char_utilities=>charsize.
    IF w_tabkeylen-keylen > max_keylen_byte.
      w_tabkeylen-keylen = max_keylen_byte.
    ENDIF.
    INSERT w_tabkeylen INTO TABLE tabkeylen_tab.
  ENDIF.
  p_keylength = w_tabkeylen-keylen.
ENDFORM.                    " vim_get_bc_keylen
