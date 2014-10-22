*---------------------------------------------------------------------*
*       FORM CHECK_LOCKABLE_OBJECT                                    *
*---------------------------------------------------------------------*
*  check lockable transport objects                                   *
*---------------------------------------------------------------------*
* <---> CLO_E071 ......
* <---- return code: 0 - ok, 4 - display only, 8 - cancel edit        *
*---------------------------------------------------------------------*
FORM CHECK_LOCKABLE_OBJECT USING CLO_E071 STRUCTURE E071
                                 CLO_RETURN TYPE I.
  DATA: CLO_TADIR LIKE TADIR, CLO_DDERR LIKE DDERR,              "#EC NEEDED
        CLO_LOCKED(1) TYPE C, CLO_LOCKABLE(1) TYPE C,
        CLO_EDITABLE(1) TYPE C, CLO_LOCK_TASK LIKE E071-TRKORR,
        CLO_LOCK_USER LIKE SY-UNAME, CLO_LOCK_ORDER LIKE E071-TRKORR,
        CLO_TRANSPORTABLE(1) TYPE C, CLO_ICORR LIKE E070-TRKORR,
        CLO_TE071 LIKE KO200 OCCURS 0, CLO_TTADIR LIKE TADIR OCCURS 0,
        CLO_TE071K LIKE E071K OCCURS 0.

  APPEND CLO_E071 TO CLO_TE071.
  CALL FUNCTION 'TR_EDIT_CHECK_OBJECTS_KEYS'
       EXPORTING
            WI_ORDER                       = CLO_E071-TRKORR
            WI_WITH_DIALOG                 = 'R'
*           WI_OBJ_CATEGOGY_MIX            = 'X'
            WI_SEND_MESSAGE                = ' '
       IMPORTING
*           WE_ORDER                       =
            WE_TASK                        = CLO_E071-TRKORR
*           WE_OBJECTS_APPENDABLE          =
*           EV_ERRNUM                      =
*           EV_OBJECT_UNLOCKED             =
       TABLES
            WT_E071                        = CLO_TE071
            WT_E071K                       = CLO_TE071K
            WT_TADIR                       = CLO_TTADIR
       EXCEPTIONS
            CANCEL_EDIT_APPEND_ERROR_KEYS  = 1
            CANCEL_EDIT_APPEND_ERROR_OBJCT = 2
            CANCEL_EDIT_APPEND_ERROR_ORDER = 3
            CANCEL_EDIT_BUT_SE01           = 4
            CANCEL_EDIT_NO_HEADER_OBJECT   = 5
            CANCEL_EDIT_NO_ORDER_SELECTED  = 6
            CANCEL_EDIT_REPAIRED_OBJECT    = 7
            CANCEL_EDIT_SYSTEM_ERROR       = 8
            CANCEL_EDIT_TADIR_MISSING      = 9
            CANCEL_EDIT_TADIR_UPDATE_ERROR = 10
            CANCEL_EDIT_UNKNOWN_DEVCLASS   = 11
            CANCEL_EDIT_UNKNOWN_OBJECTTYPE = 12
            CANCEL_EDIT_NO_CHECK_CALL      = 13
            CANCEL_EDIT_CATEGORY_MIXTURE   = 14
            CANCEL_EDIT_USER_AFTER_ERROR   = 15
            CANCEL_EDIT_CUSTOM_OBJ_AT_SAP  = 16
            CANCEL_EDIT_ACCESS_DENIED      = 17
            SHOW_ONLY_CLOSED_SYSTEM        = 18
            SHOW_ONLY_CONSOLIDATION_LEVEL  = 19
            SHOW_ONLY_DDIC_IN_CUSTOMER_SYS = 20
            SHOW_ONLY_DELIVERY_SYSTEM      = 21
            SHOW_ONLY_DIFFERENT_ORDERTYPES = 22
            SHOW_ONLY_DIFFERENT_TASKTYPES  = 23
            SHOW_ONLY_ENQUEUE_FAILED       = 24
            SHOW_ONLY_GENERATED_OBJECT     = 25
            SHOW_ONLY_ILL_LOCK             = 26
            SHOW_ONLY_LOCK_ENQUEUE_FAILED  = 27
            SHOW_ONLY_MIXED_ORDERS         = 28
            SHOW_ONLY_MIX_LOCAL_TRANSP_OBJ = 29
            SHOW_ONLY_NO_SHARED_REPAIR     = 30
            SHOW_ONLY_OBJECT_LOCKED        = 31
            SHOW_ONLY_REPAIRED_OBJECT      = 32
            SHOW_ONLY_SHOW_CLIENT          = 33
            SHOW_ONLY_TADIR_MISSING        = 34
            SHOW_ONLY_UNKNOWN_DEVCLASS     = 35
            SHOW_ONLY_CLOSED_CLIENT        = 36
            SHOW_ONLY_CLOSED_ALE_OBJECT    = 37
            SHOW_ONLY_UNALLOWED_SUPERUSER  = 38
            SHOW_ONLY_NO_REPAIR_SYSTEM     = 39
            SHOW_ONLY_NO_LICENSE           = 40
            SHOW_ONLY_CENTRAL_BASIS        = 41
            SHOW_ONLY_USER_AFTER_ERROR     = 42
            SHOW_ONLY_OBJECT_NOT_PATCHABLE = 43.
  IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE 'I' NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    IF SY-SUBRC LE 17.
      CLO_RETURN = 8. EXIT.
    ELSE.
      CLO_RETURN = 4. <STATUS>-CORR_NBR = VIM_LOCKED_IN_CORR. EXIT.
    ENDIF.
  ELSE.
    READ TABLE CLO_TE071 INTO CLO_E071 INDEX 1.
    READ TABLE CLO_TTADIR INTO CLO_TADIR INDEX 1.
    IF CLO_TADIR-DEVCLASS IS INITIAL.
      CALL FUNCTION 'TR_EDIT_CHECK_OBJECTS_KEYS'
           EXPORTING
                WI_ORDER                       = CLO_E071-TRKORR
                WI_WITH_DIALOG                 = 'X'
*           WI_OBJ_CATEGOGY_MIX            = 'X'
                WI_SEND_MESSAGE                = ' '
           IMPORTING
*           WE_ORDER                       =
                WE_TASK                        = CLO_E071-TRKORR
*           WE_OBJECTS_APPENDABLE          =
*           EV_ERRNUM                      =
*           EV_OBJECT_UNLOCKED             =
           TABLES
                WT_E071                        = CLO_TE071
                WT_E071K                       = CLO_TE071K
                WT_TADIR                       = CLO_TTADIR
           EXCEPTIONS
                CANCEL_EDIT_APPEND_ERROR_KEYS  = 1
                CANCEL_EDIT_APPEND_ERROR_OBJCT = 2
                CANCEL_EDIT_APPEND_ERROR_ORDER = 3
                CANCEL_EDIT_BUT_SE01           = 4
                CANCEL_EDIT_NO_HEADER_OBJECT   = 5
                CANCEL_EDIT_NO_ORDER_SELECTED  = 6
                CANCEL_EDIT_REPAIRED_OBJECT    = 7
                CANCEL_EDIT_SYSTEM_ERROR       = 8
                CANCEL_EDIT_TADIR_MISSING      = 9
                CANCEL_EDIT_TADIR_UPDATE_ERROR = 10
                CANCEL_EDIT_UNKNOWN_DEVCLASS   = 11
                CANCEL_EDIT_UNKNOWN_OBJECTTYPE = 12
                CANCEL_EDIT_NO_CHECK_CALL      = 13
                CANCEL_EDIT_CATEGORY_MIXTURE   = 14
                CANCEL_EDIT_USER_AFTER_ERROR   = 15
                CANCEL_EDIT_CUSTOM_OBJ_AT_SAP  = 16
                CANCEL_EDIT_ACCESS_DENIED      = 17
                SHOW_ONLY_CLOSED_SYSTEM        = 18
                SHOW_ONLY_CONSOLIDATION_LEVEL  = 19
                SHOW_ONLY_DDIC_IN_CUSTOMER_SYS = 20
                SHOW_ONLY_DELIVERY_SYSTEM      = 21
                SHOW_ONLY_DIFFERENT_ORDERTYPES = 22
                SHOW_ONLY_DIFFERENT_TASKTYPES  = 23
                SHOW_ONLY_ENQUEUE_FAILED       = 24
                SHOW_ONLY_GENERATED_OBJECT     = 25
                SHOW_ONLY_ILL_LOCK             = 26
                SHOW_ONLY_LOCK_ENQUEUE_FAILED  = 27
                SHOW_ONLY_MIXED_ORDERS         = 28
                SHOW_ONLY_MIX_LOCAL_TRANSP_OBJ = 29
                SHOW_ONLY_NO_SHARED_REPAIR     = 30
                SHOW_ONLY_OBJECT_LOCKED        = 31
                SHOW_ONLY_REPAIRED_OBJECT      = 32
                SHOW_ONLY_SHOW_CLIENT          = 33
                SHOW_ONLY_TADIR_MISSING        = 34
                SHOW_ONLY_UNKNOWN_DEVCLASS     = 35
                SHOW_ONLY_CLOSED_CLIENT        = 36
                SHOW_ONLY_CLOSED_ALE_OBJECT    = 37
                SHOW_ONLY_UNALLOWED_SUPERUSER  = 38
                SHOW_ONLY_NO_REPAIR_SYSTEM     = 39
                SHOW_ONLY_NO_LICENSE           = 40
                SHOW_ONLY_CENTRAL_BASIS        = 41
                SHOW_ONLY_USER_AFTER_ERROR     = 42
                SHOW_ONLY_OBJECT_NOT_PATCHABLE = 43.
      IF SY-SUBRC NE 0.
        MESSAGE ID SY-MSGID TYPE 'I' NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        IF SY-SUBRC LE 17.
          CLO_RETURN = 8. EXIT.
        ELSE.
          CLO_RETURN = 4. <STATUS>-CORR_NBR = VIM_LOCKED_IN_CORR. EXIT.
        ENDIF.
      ELSE.
        READ TABLE CLO_TE071 INTO CLO_E071 INDEX 1.
        READ TABLE CLO_TTADIR INTO CLO_TADIR INDEX 1.
      ENDIF.
    ENDIF.
  ENDIF.
* PERFORM MCOMMEDITCHECK(RDDINSYS)
*                        CHANGING CLO_E071 CLO_TADIR CLO_DDERR.
* IF CLO_DDERR-SEVERITY EQ 'F'.
*   IF CLO_DDERR-ERRNUM EQ '16'.       "repair requested
*     PERFORM FCOMMEDITCHECK(RDDINSYS)
*                            CHANGING CLO_E071 CLO_TADIR CLO_DDERR.
*     IF CLO_DDERR-SEVERITY EQ 'F'.
*       CASE CLO_DDERR-ERRNUM.
*         WHEN 4.                      "display
**          MAINT_MODE = STATUS-ACTION = ANZEIGEN.
**          EXIT.
*           CLO_RETURN = 4. <STATUS>-CORR_NBR = VIM_LOCKED_IN_CORR.
*           EXIT.
*         WHEN 12.                     "cancel edit
**          RAISE MISSING_CORR_NUMBER.
*           CLO_RETURN = 8. EXIT.
*       ENDCASE.
*     ENDIF.
*   ELSEIF CLO_DDERR-ERRNUM EQ '17' OR "no TADIR or
*          CLO_DDERR-ERRNUM EQ '18'.   "missing devclass
*     IF CLO_DDERR-ERRNUM EQ '17'.
*       MESSAGE S133(SV). "Bitte Transporteigenschaften eingeben
*     ELSE.
*       MESSAGE S486(TK) WITH CLO_TADIR-DEVCLASS.
*     ENDIF.
*     CLO_TADIR-PGMID    = CLO_E071-PGMID.
*     CLO_TADIR-OBJECT   = CLO_E071-OBJECT.
*     CLO_TADIR-OBJ_NAME = CLO_E071-OBJ_NAME.
*     CALL FUNCTION 'TADIR_PFLEGE'
*          EXPORTING
*               ADIR      = CLO_TADIR
*               E71TEMP   = CLO_E071
*               START_ROW = 2
*          IMPORTING
*               NEWADIR   = CLO_TADIR
*               PDDERR    = CLO_DDERR
*          EXCEPTIONS
*               ILL_TYPE  = 01.
*     IF SY-SUBRC NE 0.
*       MESSAGE I095(SV) WITH E071-TRKORR. "Systemfehler
**      RAISE MISSING_CORR_NUMBER.
*       CLO_RETURN = 8. EXIT.
*     ENDIF.
*     IF CLO_DDERR-SEVERITY EQ 'F'.
*       CASE CLO_DDERR-ERRNUM.
*         WHEN 4.                      "display
**          MAINT_MODE = STATUS-ACTION = ANZEIGEN.
**          EXIT.
*           CLO_RETURN = 4. <STATUS>-CORR_NBR = VIM_LOCKED_IN_CORR.
*           EXIT.
*         WHEN 12.                     "cancel edit
**          RAISE MISSING_CORR_NUMBER.
*           CLO_RETURN = 8. EXIT.
*       ENDCASE.
*     ELSE.
*       CALL FUNCTION 'TRINT_CHANGE_TADIR_MASTERLANG'
*            EXPORTING
*                 WI_TADIR_PGMID               = CLO_TADIR-PGMID
*                 WI_TADIR_OBJECT              = CLO_TADIR-OBJECT
*                 WI_TADIR_OBJ_NAME            = CLO_TADIR-OBJ_NAME
*                 WI_TADIR_MASTERLANG          = SY-LANGU
*            EXCEPTIONS
*                 MASTERLANG_NOT_ALLOWED       = 1.
*       IF SY-SUBRC NE 0. "language not allowed
*         MESSAGE ID SY-MSGID TYPE 'I' NUMBER SY-MSGNO
*           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*       ENDIF.
*     ENDIF.
*   ELSE.  "other problems in MCOMM....
*     MESSAGE ID SY-MSGID TYPE 'I' NUMBER SY-MSGNO
*             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
**    MESSAGE I733(TK).
*     IF CLO_DDERR-ERRNUM EQ '4'.   "display
*       CLO_RETURN = 4. <STATUS>-CORR_NBR = VIM_LOCKED_IN_CORR.
*       EXIT.
*     ELSE.                         "cancel
*       CLO_RETURN = 8. EXIT.
*     ENDIF.
**    MESSAGE I095(SV) WITH E071-TRKORR. "Systemfehler
**    RAISE MISSING_CORR_NUMBER.
*   ENDIF.                             " clo_dderr-errnum in ( 17, 18 )
* ENDIF.                               "clo_dderr-severity eq 'F'
* first check if devclass is ok
* SELECT SINGLE * FROM TADIR INTO CLO_TADIR "already done in MCOMMEDITCH
*                            WHERE PGMID    = CLO_E071-PGMID
*                              AND OBJECT   = CLO_E071-OBJECT
*                              AND OBJ_NAME = CLO_E071-OBJ_NAME.
* IF TADIR-DEVCLASS(1) EQ '$'. "local object -> no transport
  IF CLO_TADIR IS INITIAL.             "may be no lockable object?
    CALL FUNCTION 'TR_CHECK_OBJECT_LOCK'
         EXPORTING
              WI_OBJECT                  = CLO_E071-OBJECT
              WI_OBJNAME                 = CLO_E071-OBJ_NAME
              WI_PGMID                   = CLO_E071-PGMID
         IMPORTING
              WE_LOCKABLE_OBJECT         = CLO_LOCKABLE
              WE_LOCKED                  = CLO_LOCKED
              WE_LOCK_TASK               = CLO_LOCK_TASK
              WE_LOCK_TASK_USER          = CLO_LOCK_USER
              WE_LOCK_ORDER              = CLO_LOCK_ORDER
              WE_OBJECT_EDITABLE         = CLO_EDITABLE
* 4.0 Namesp. WE_POSSIBLE_USER_EDIT_TASK = CLO_TADIR-KORRNUM
              WE_POSSIBLE_USER_EDIT_TASK = CLO_ICORR
         EXCEPTIONS
              EMPTY_KEY                  = 01
              NO_SYSTEMNAME              = 02
              NO_SYSTEMTYPE              = 03
              UNALLOWED_LOCK_ORDER       = 04.
    IF SY-SUBRC NE 0.
      MESSAGE I095(SV) WITH E071-TRKORR. "Systemfehler
*     RAISE MISSING_CORR_NUMBER.
      CLO_RETURN = 8. EXIT.
    ENDIF.
    IF CLO_LOCKABLE EQ SPACE.          "yes no lockable object
      VIM_CORR_OBJTAB-LOCKABLE = SPACE.
      MODIFY VIM_CORR_OBJTAB.
      EXIT.
    ELSE.                              "inconsistent object.
      MESSAGE I095(SV) WITH E071-TRKORR. "Systemfehler
      CLO_RETURN = 8. EXIT.
    ENDIF.
  ENDIF.                               "clo_tadir is initial
  CALL FUNCTION 'VIEW_GET_DEVCLASS_STATE'
       EXPORTING
            DEV_CLASS          = CLO_TADIR-DEVCLASS
       IMPORTING
            TRANSPORT_POSSIBLE = CLO_TRANSPORTABLE
    EXCEPTIONS                                              "#EC *
            NOT_FOUND          = 01.
  IF CLO_TRANSPORTABLE EQ SPACE.       "local object -> no transport
    X_HEADER-FLAG = VIM_TRANSPORT_DENIED.
    MODIFY X_HEADER INDEX 1.
  ELSE.
* second check if all objects have valid source systems
    IF VIM_LAST_SOURCE_SYSTEM EQ SPACE.
      VIM_LAST_SOURCE_SYSTEM = CLO_TADIR-SRCSYSTEM.
    ELSE.
      IF CLO_TADIR-SRCSYSTEM EQ SY-SYSID.    "if one object has sy-sysid
        IF VIM_LAST_SOURCE_SYSTEM NE SY-SYSID."all objs must have sy-sys
          MESSAGE I134(SV). "Inkonsistenz in Objektdefinition, nur Anzei
*       MAINT_MODE = STATUS-ACTION = ANZEIGEN.
*       EXIT.
          CLO_RETURN = 4. <STATUS>-CORR_NBR = VIM_LOCKED_IN_CORR. EXIT.
        ENDIF.
      ELSE. "if one object has another source system, all objects must
        IF VIM_LAST_SOURCE_SYSTEM EQ SY-SYSID. "another source system
          MESSAGE I134(SV). "Inkonsistenz in Objektdefinition, nur Anzei
*       MAINT_MODE = STATUS-ACTION = ANZEIGEN.
*       EXIT.
          CLO_RETURN = 4. <STATUS>-CORR_NBR = VIM_LOCKED_IN_CORR. EXIT.
        ENDIF.
      ENDIF.
    ENDIF.
    CALL FUNCTION 'TR_CHECK_OBJECT_LOCK'
         EXPORTING
              WI_OBJECT                  = CLO_E071-OBJECT
              WI_OBJNAME                 = CLO_E071-OBJ_NAME
              WI_PGMID                   = CLO_E071-PGMID
         IMPORTING
              WE_LOCKABLE_OBJECT         = CLO_LOCKABLE
              WE_LOCKED                  = CLO_LOCKED
              WE_LOCK_TASK               = CLO_LOCK_TASK
              WE_LOCK_TASK_USER          = CLO_LOCK_USER
              WE_LOCK_ORDER              = CLO_LOCK_ORDER
              WE_OBJECT_EDITABLE         = CLO_EDITABLE
* 4.0 Namesp. WE_POSSIBLE_USER_EDIT_TASK = CLO_TADIR-KORRNUM
              WE_POSSIBLE_USER_EDIT_TASK = CLO_ICORR
         EXCEPTIONS
              EMPTY_KEY                  = 01
              NO_SYSTEMNAME              = 02
              NO_SYSTEMTYPE              = 03
              UNALLOWED_LOCK_ORDER       = 04.
    IF SY-SUBRC NE 0.
      MESSAGE I095(SV) WITH E071-TRKORR. "Systemfehler
*     RAISE MISSING_CORR_NUMBER.
      CLO_RETURN = 8. EXIT.
    ENDIF.
    IF CLO_LOCKABLE EQ SPACE.
      VIM_CORR_OBJTAB-LOCKABLE = SPACE.
      MODIFY VIM_CORR_OBJTAB.
      EXIT.
    ENDIF.
    IF CLO_LOCKED NE SPACE.
      IF CLO_EDITABLE EQ SPACE.
        MESSAGE I132(SV) WITH CLO_LOCK_TASK CLO_LOCK_USER.
*       MAINT_MODE = STATUS-ACTION = ANZEIGEN.
*       EXIT.
        CLO_RETURN = 4. <STATUS>-CORR_NBR = VIM_LOCKED_IN_CORR. EXIT.
      ELSE.
*       CLO_E071-TRKORR = CLO_TADIR-KORRNUM.   "4.0 Namespace
        CLO_E071-TRKORR = CLO_ICORR.   "4.0 Namespace
      ENDIF.
    ENDIF.                             "clo_locked
  ENDIF.                               "devclass
  IF <STATUS>-CORR_NBR NE SPACE AND CLO_E071-TRKORR NE SPACE.
    IF CLO_E071-TRKORR NE <STATUS>-CORR_NBR.
      IF <STATUS>-ORDER_NBR NE CLO_LOCK_ORDER.
        MESSAGE I129(SV). "Zusammengehörige Objekte in verschied
*       RAISE MISSING_CORR_NUMBER.
        CLO_RETURN = 4. <STATUS>-CORR_NBR = VIM_LOCKED_IN_CORR. EXIT.
      ENDIF.
      VIM_CORR_OBJTAB-TRKORR = CLO_E071-TRKORR.
      MODIFY VIM_CORR_OBJTAB.
    ENDIF.
  ELSE.
    IF <STATUS>-CORR_NBR EQ SPACE.
      <STATUS>-CORR_NBR = CLO_E071-TRKORR.
      <STATUS>-ORDER_NBR = CLO_LOCK_ORDER.
    ENDIF.
  ENDIF.
  TRANSLATE <STATUS>-TR_ALRCHKD USING ' x'.
  CLEAR CLO_RETURN.
ENDFORM.                               "check_lockable_object
