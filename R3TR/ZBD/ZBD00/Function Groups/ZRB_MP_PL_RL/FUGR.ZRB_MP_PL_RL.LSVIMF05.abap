*---------------------------------------------------------------------*
*       FORM SHOW_FUNCTION_DOCU                                       *
*---------------------------------------------------------------------*
FORM SHOW_FUNCTION_DOCU.
  CALL FUNCTION 'IWB_HTML_HELP_OBJECT_SHOW'
       EXPORTING
*         DEVCLASS                    =
*         TCODE                       =
            PROGRAM                     = VIM_DOCU_PROG
*         DYNPRONR                    =
            EXTENSION                   = VIM_DOCU_EXTENSION
*    IMPORTING
*         ACTION                      =
       EXCEPTIONS
            OBJECT_NOT_FOUND            = 1
            RFC_ERROR                   = 2
            NO_PROFIL_PARAMETER         = 3
            IMPORT_PARAMETER_IS_INVALID = 4
            OTHERS                      = 5.

* CALL FUNCTION 'DSYS_SHOW'
*      EXPORTING
**          APPLICATION        = 'SO70'
*           DOKCLASS           = 'WINH'
**          DOKLANGU           = SY-LANGU
*           DOKNAME            = 'CATAB.HLP'
*           DOKTITLE           = ' '
*           HOMETEXT           = ' '
*           OUTLINE            = ' '
*           VIEWNAME           = 'STANDARD'
*           Z_ORIGINAL_OUTLINE = ' '
*           CALLED_FROM_SO70   = ' '
*      IMPORTING
*           APPL               =
*           PF03               =
*           PF15               =
*           PF12               =
*      EXCEPTIONS
*           CLASS_UNKNOWN      = 1
*           OBJECT_NOT_FOUND   = 2
*           OTHERS             = 3.
  IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE 'I' NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.
