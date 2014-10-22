*---------------------------------------------------------------------*
*       FORM COMPLETE_SUBSETFIELDS                                    *
*---------------------------------------------------------------------*
*  fill subset comment fields in view-wa from *view-wa (detail screen)*
*---------------------------------------------------------------------*
FORM complete_subsetfields.

  FIELD-SYMBOLS: <namtab> TYPE vimnamtab.

  LOOP AT x_namtab ASSIGNING <namtab>
   WHERE readonly EQ subset AND keyflag EQ space.
    ASSIGN: COMPONENT <namtab>-viewfield OF STRUCTURE <initial>
             TO <value>,
            COMPONENT <namtab>-viewfield OF STRUCTURE <table1>
             TO <subsetfield>.
*    ASSIGN <INITIAL>+X_NAMTAB-POSITION(X_NAMTAB-FLENGTH)
*           TO <VALUE>.
*    ASSIGN <TABLE1>+X_NAMTAB-POSITION(X_NAMTAB-FLENGTH)
*           TO <SUBSETFIELD>.
    MOVE <value> TO <subsetfield>.
  ENDLOOP.
ENDFORM.
