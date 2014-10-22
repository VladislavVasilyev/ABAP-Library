*---------------------------------------------------------------------*
*       FORM CONSIDER_OLD_EXCLUDE_TAB                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM CONSIDER_OLD_EXCLUDE_TAB
                  TABLES NEW_EXCLUDE_TAB STRUCTURE VIMEXCLFLD.
  DATA: BEGIN OF VIEWNAME_PATTERN,
          VIEWNAME LIKE VIMDESC-VIEWNAME,
          WILDCARD(1) TYPE C VALUE '*',
        END OF VIEWNAME_PATTERN.

  VIEWNAME_PATTERN-VIEWNAME = X_HEADER-MAINTVIEW.
  CONDENSE VIEWNAME_PATTERN NO-GAPS.
  LOOP AT EXCLUDE_TAB WHERE FIELD CP VIEWNAME_PATTERN.
    SHIFT EXCLUDE_TAB-FIELD UP TO '-'. SHIFT EXCLUDE_TAB-FIELD.
    NEW_EXCLUDE_TAB-FIELDNAME = EXCLUDE_TAB-FIELD.
    COLLECT NEW_EXCLUDE_TAB.
  ENDLOOP.
ENDFORM.                               "consider_old_exclude_tab
