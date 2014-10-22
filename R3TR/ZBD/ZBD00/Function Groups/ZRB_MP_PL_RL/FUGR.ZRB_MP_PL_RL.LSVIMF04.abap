*&---------------------------------------------------------------------*
*&      Form  LOGS_ANALYSE
*&---------------------------------------------------------------------*
*       Analyses table logs concerning the current maintenance view by
*       calling report RSVTPROT
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM logs_analyse.

  RANGES: sel_obj FOR objh-objectname,
          sel_type FOR objh-objecttype.

  sel_obj-sign = sel_type-sign = 'I'.
  sel_obj-option = sel_type-option = 'EQ'.
  IF vim_called_by_cluster NE space.
    sel_type-low = vim_clst.
    sel_obj-low = vim_calling_cluster.
  ELSE.
    sel_obj-low = x_header-viewname.
    IF x_header-bastab NE space
     AND x_header-maintview = x_header-viewname.
* table but no table-variant
      sel_type-low = vim_tabl.
    ELSE.
* view, view-variant, or table variant
      sel_type-low = vim_view.
    ENDIF.
  ENDIF.
  APPEND sel_obj. APPEND sel_type.
  SUBMIT rsvtprot VIA SELECTION-SCREEN USING SELECTION-SCREEN 1010
                  WITH cusobj IN sel_obj
                  WITH stype IN sel_type
                  WITH acc_arch = ' ' AND RETURN.
ENDFORM.                               " LOGS_ANALYSE
