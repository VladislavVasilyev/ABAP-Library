*&--------------------------------------------------------------------*
*&      Form VIM_SET_IMPRES_HEADER                                    *
*&--------------------------------------------------------------------*
* ...                                                                 *
*&--------------------------------------------------------------------*
FORM VIM_SET_IMPRES_HEADER.
  IF VIM_CALLED_BY_CLUSTER EQ SPACE.
    IMP_RESULTS-OBJTAB-OBJECT-OBJECTNAME = X_HEADER-VIEWNAME.
    IF X_HEADER-VIEWNAME <> X_HEADER-MAINTVIEW.             "Subviews ..
      CLEAR IMP_RESULTS-OBJTAB-OBJECT-OBJECTTYPE.
    ELSE.
      IMP_RESULTS-OBJTAB-OBJECT-OBJECTTYPE = X_HEADER-BASTAB.
    ENDIF.                             ".. Subviews
    TRANSLATE IMP_RESULTS-OBJTAB-OBJECT-OBJECTTYPE USING ' VXS'.
  ELSE.
    IMP_RESULTS-OBJTAB-OBJECT-OBJECTNAME = VIM_CALLING_CLUSTER.
    IMP_RESULTS-OBJTAB-OBJECT-OBJECTTYPE = 'C'.
  ENDIF.
  IF X_HEADER-BASTAB NE SPACE.
    IMP_RESULTS-OBJTAB-TABNAME = X_HEADER-MAINTVIEW.
    IF X_HEADER-VIEWNAME <> X_HEADER-MAINTVIEW.             "Subviews ..
      IMP_RESULTS-OBJTAB-VIEWNAME = X_HEADER-VIEWNAME.
    ELSE.                              ".. Subviews
      CLEAR IMP_RESULTS-OBJTAB-VIEWNAME.
    ENDIF.
  ELSE.
    IMP_RESULTS-OBJTAB-TABNAME = X_HEADER-ROOTTAB.
    IMP_RESULTS-OBJTAB-VIEWNAME = X_HEADER-VIEWNAME.
  ENDIF.
  IMP_RESULTS-KEYLEN = X_HEADER-KEYLEN.                     "SW
  IMP_RESULTS-GENKEYLEN = X_HEADER-KEYLEN.                  "SW
ENDFORM.                               "vim_set_impres_header
