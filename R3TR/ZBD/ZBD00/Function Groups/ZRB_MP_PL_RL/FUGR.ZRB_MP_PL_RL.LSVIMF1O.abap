*---------------------------------------------------------------------*
*       FORM VIM_FILL_WHERETAB                                        *
*---------------------------------------------------------------------*
* fill internal table for dynamic select                              *
*---------------------------------------------------------------------*
FORM VIM_FILL_WHERETAB.
  CALL FUNCTION 'VIEW_FILL_WHERETAB'
       EXPORTING
            TABLENAME               = X_HEADER-ROOTTAB
       TABLES
            SELLIST                 = DBA_SELLIST
            WHERETAB                = VIM_WHERETAB
            X_NAMTAB                = X_NAMTAB
    EXCEPTIONS                                              "#EC *
            NO_CONDITIONS_FOR_TABLE = 01.
ENDFORM.                               "vim_fill_wheretab.
