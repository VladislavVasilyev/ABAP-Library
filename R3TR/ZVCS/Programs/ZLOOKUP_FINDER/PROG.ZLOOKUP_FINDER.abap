*****************Actual Source Code for the Program********************
***********************************************************************
*  PROGRAM          # LOOKUP_FINDER                                   *
*  RELEASE          # 1.0                                             *
*  DATE WRITTEN     # 04/04/2008                                      *
*  MODULE           # BW/BI                                           *
*  TYPE             # Executable Report                               *
*  Author           # Lijo John                                       *
***********************************************************************
*  TITLE            # Program to find out lookups                     *
*                                                                     *
*  PURPOSE          # The program takes the technical name of a       *
*                     dataprovider as input and displays the          *
*                     Transformations or update rules where it is     *
*                     looked up. The output gives details like source *
*                     and target of lookup, transformation id, rule id*
*                     and the line number, It can also be used to     *
*                     find patterns e.g:break-point, *TWD* etc in   *
*                     routines                                        *
*                                                                     *
***********************************************************************
* LOGICAL DATABASE  # N/A                                             *
* FUNCTION KEYS     # None                                            *
***********************************************************************
***********************************************************************
REPORT  ZLOOKUP_FINDER LINE-SIZE 600.
***********************************************************************
***Type pools/Tables declerations for ALV Grid display/selections***
TYPE-POOLS SLIS.
DATA FCAT1 TYPE SLIS_T_FIELDCAT_ALV.
DATA: BEGIN OF T_DISPLAY OCCURS 0,
         TARGETNAME LIKE RSTRAN-TARGETNAME,
         SOURCENAME LIKE RSTRAN-SOURCENAME,
         TRANID LIKE RSTRAN-TRANID,
         ROUTINE LIKE RSTRAN-STARTROUTINE,
         LINE_NO LIKE RSAABAP-LINE_NO,
         LINE LIKE RSAABAP-LINE,
END OF T_DISPLAY.
DATA : INPUT_PATTERN1(75) TYPE C.
DATA : INPUT_PATTERN2(75) TYPE C.
DATA : SAME_SOURCE(30) TYPE C.
SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE TEXT-004.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 6(22) CINFOPRO FOR FIELD INFOPROV.
PARAMETERS INFOPROV LIKE INPUT_PATTERN1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 6(20) CMDOBJEC FOR FIELD MDOBJECT.
PARAMETERS: MDOBJECT AS CHECKBOX.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 6(20) TEXT-003 FOR FIELD PATTERN.
PARAMETERS: PATTERN AS CHECKBOX.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK B01.

INITIALIZATION.

MOVE `INFOPROV` TO CINFOPRO.
MOVE `MDOBJECT` TO CMDOBJEC.

***Internal table declerations***************************************
TYPES:  BEGIN OF T_TRANS_LOOKUP_FINDER,
         TARGETNAME TYPE RSTRAN-TARGETNAME,
         SOURCENAME TYPE RSTRAN-SOURCENAME,
         TRANID TYPE RSTRAN-TRANID,
         ROUTINE TYPE RSTRAN-STARTROUTINE,
         LINE_NO TYPE RSAABAP-LINE_NO,
         LINE TYPE RSAABAP-LINE,
        END OF T_TRANS_LOOKUP_FINDER.

DATA: I_LOOKUP_FINDER TYPE STANDARD TABLE OF T_TRANS_LOOKUP_FINDER,
      WA_LOOKUP_FINDER TYPE T_TRANS_LOOKUP_FINDER,
      I_TRANS_LOOKUP_FINDER TYPE STANDARD TABLE OF T_TRANS_LOOKUP_FINDER,
      WA_TRANS_LOOKUP_FINDER TYPE T_TRANS_LOOKUP_FINDER,
      I_TRANS_FINAL TYPE STANDARD TABLE OF T_TRANS_LOOKUP_FINDER,
      WA_TRANS_FINAL TYPE T_TRANS_LOOKUP_FINDER.
DATA : I(7) TYPE N.
DATA  OLD_CUBE(20) TYPE C VALUE ' '.
DATA  OLD_SOURCE(20) TYPE C VALUE ' '.
***Selections for update rules***************************************
START-OF-SELECTION.

IF ( INFOPROV NE '' ).
  IF ( PATTERN NE 'X' ).
    IF ( MDOBJECT NE 'X' ).
      CONCATENATE 'from*A' INFOPROV '00' '' INTO INPUT_PATTERN1.
    ELSE.
      CONCATENATE 'from*p' INFOPROV '' INTO INPUT_PATTERN1.
    ENDIF.
    CONCATENATE '8' INFOPROV '*' INTO SAME_SOURCE.
    SELECT DISTINCT
           INFOCUBE
           ISOURCE
           B~UPDID
           ROUTINE
           LINE_NO
           LINE
           INTO TABLE I_LOOKUP_FINDER FROM
           RSUPDINFO AS A  INNER JOIN RSUPDROUT AS B ON A~UPDID = B~UPDID
                           INNER JOIN RSAABAP AS C ON C~CODEID = B~CODEID
                           WHERE
                           A~OBJVERS = 'A' AND B~OBJVERS = 'A' AND
                           C~OBJVERS = 'A' AND A~OBJVERS = 'A'
                           AND
                           B~ROUTINE GE 9000.
  ELSE.
    INPUT_PATTERN1 = INFOPROV.
    SELECT DISTINCT
           INFOCUBE
           ISOURCE
           B~UPDID
           ROUTINE
           LINE_NO
           LINE
           INTO TABLE I_LOOKUP_FINDER FROM
           RSUPDINFO AS A  INNER JOIN RSUPDROUT AS B ON A~UPDID = B~UPDID
                           INNER JOIN RSAABAP AS C ON C~CODEID = B~CODEID
                           WHERE
                           A~OBJVERS = 'A' AND B~OBJVERS = 'A' AND
                           C~OBJVERS = 'A' AND A~OBJVERS = 'A'.

    SELECT DISTINCT
           TARGETNAME
           SOURCENAME
           A~TRANID
           C~CODEID
           LINE_NO
           LINE
           INTO TABLE I_TRANS_LOOKUP_FINDER FROM
           RSTRAN AS A INNER JOIN RSTRANSTEPROUT AS B
                           ON A~TRANID = B~TRANID
                       INNER JOIN RSAABAP AS C ON B~CODEID = C~CODEID
                           WHERE
                           A~OBJVERS = 'A' AND B~OBJVERS = 'A' AND
                           C~OBJVERS = 'A'.
    APPEND LINES OF I_TRANS_LOOKUP_FINDER TO I_LOOKUP_FINDER.
  ENDIF.

***Selections for Transformations(start routine)*********************
  SELECT DISTINCT
         TARGETNAME
         SOURCENAME
         TRANID
         STARTROUTINE
         LINE_NO
         LINE
         INTO TABLE I_TRANS_LOOKUP_FINDER FROM
        RSTRAN AS A INNER JOIN RSAABAP AS B ON A~STARTROUTINE = B~CODEID
                         WHERE
                         A~OBJVERS = 'A' AND B~OBJVERS = 'A'.
  APPEND LINES OF I_TRANS_LOOKUP_FINDER TO I_LOOKUP_FINDER.
***Selections for Transformations(End routine)***********************
  SELECT DISTINCT
         TARGETNAME
         SOURCENAME
         TRANID
         ENDROUTINE
         LINE_NO
         LINE
         INTO TABLE I_TRANS_LOOKUP_FINDER FROM
         RSTRAN AS A  INNER JOIN RSAABAP AS B ON A~ENDROUTINE = B~CODEID
                         WHERE
                         A~OBJVERS = 'A' AND B~OBJVERS = 'A'.
  APPEND LINES OF I_TRANS_LOOKUP_FINDER TO I_LOOKUP_FINDER.
***Selections for Transformations(Expert routine)********************
  SELECT DISTINCT
         TARGETNAME
         SOURCENAME
         TRANID
         EXPERT
         LINE_NO
         LINE
         INTO TABLE I_TRANS_LOOKUP_FINDER FROM
         RSTRAN AS A  INNER JOIN RSAABAP AS B ON A~EXPERT = B~CODEID
                         WHERE
                         A~OBJVERS = 'A' AND B~OBJVERS = 'A'.
  APPEND LINES OF I_TRANS_LOOKUP_FINDER TO I_LOOKUP_FINDER.
***Extracting records where lookup code is written*******************
  SORT I_LOOKUP_FINDER BY TARGETNAME SOURCENAME TRANID ROUTINE LINE_NO.
  LOOP AT I_LOOKUP_FINDER INTO WA_LOOKUP_FINDER.
    TRANSLATE WA_LOOKUP_FINDER-LINE TO UPPER CASE.
    IF ( WA_LOOKUP_FINDER-LINE CP INPUT_PATTERN1 ) AND
       ( WA_LOOKUP_FINDER-SOURCENAME NP SAME_SOURCE ).
      IF ( PATTERN NE 'X' ).
        APPEND WA_LOOKUP_FINDER TO T_DISPLAY.
        OLD_CUBE = WA_LOOKUP_FINDER-TARGETNAME.
        OLD_SOURCE = WA_LOOKUP_FINDER-SOURCENAME.
      ELSE.
        APPEND WA_LOOKUP_FINDER TO T_DISPLAY.
      ENDIF.
    ENDIF.
  ENDLOOP.

****code to diaplay the data in table/ALV grid format ***************
*MOVE i_lookup_finder[] TO t_display[].
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = 'ZBW_LOOKUP_FINDER'
      I_INTERNAL_TABNAME     = 'T_DISPLAY'
      I_INCLNAME             = 'ZBW_LOOKUP_FINDER'
    CHANGING
      CT_FIELDCAT            = FCAT1
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM = 'ZBW_LOOKUP_FINDER'
      IT_FIELDCAT        = FCAT1
    TABLES
      T_OUTTAB           = T_DISPLAY
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.
ENDIF.
*************************************************************************
