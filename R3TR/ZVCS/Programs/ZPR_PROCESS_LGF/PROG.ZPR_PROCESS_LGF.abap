*&---------------------------------------------------------------------*
*& Report  ZPR_PROCESS_LGF
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZPR_PROCESS_LGF.

TYPE-POOLS ABAP.
TYPE-POOLS ZVCST.
TYPE-POOLS ZVCSC.

TABLES
: UJA_APPSET_INFO
, UJA_APPL
.

*--------------------------------------------------------------------*
* Types
*--------------------------------------------------------------------*
TYPES: BEGIN OF TY_S__RESTAB
       , APPSET         TYPE UJ_APPSET_ID
       , APPL           TYPE UJ_APPL_ID
       , SCRIPT         TYPE STRING
       , PATTERN        TYPE STRING
       , NUMLINE        TYPE I
       , OFFSET         TYPE I
       , LENGTH         TYPE I
       , ROWS           TYPE STRING
       , OWNER          TYPE UJ_OWNER
       , CREATE_DATE    TYPE UJ_CREATE_DATE
       , CREATE_TIME    TYPE UJ_CREATE_TIME
       , LSTMOD_DATE    TYPE UJ_LSTMOD_DATE
       , LSTMOD_TIME    TYPE UJ_LSTMOD_TIME
       , LSTMOD_USER    TYPE UJ_LSTMOD_USER
       , END OF TY_S__RESTAB.
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* Constants
*--------------------------------------------------------------------*
CONSTANTS
: CS_TIME_ZONE                TYPE TTZZ-TZONE VALUE 'RUS03'
.

*--------------------------------------------------------------------*
* Data
*--------------------------------------------------------------------*
DATA
: GD_T__PRINTTAB    TYPE SORTED TABLE OF TY_S__RESTAB WITH UNIQUE KEY APPSET APPL SCRIPT NUMLINE OFFSET LENGTH WITH HEADER LINE
, GD_T__RESTAB      TYPE SORTED TABLE OF TY_S__RESTAB WITH UNIQUE KEY APPSET APPL SCRIPT NUMLINE OFFSET LENGTH WITH HEADER LINE
, GD_V__MESSAGE     TYPE STRING
, GD_S__PATH        TYPE ZVCST_S__PATH
, GD_T__OBJECT      TYPE  ZVCST_T__R3TR_OBJ.
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* Parameter/select-options
*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK A00 WITH FRAME TITLE T_A00. " head
PARAMETERS FIND RADIOBUTTON GROUP R1 DEFAULT 'X' USER-COMMAND UC.
SELECTION-SCREEN SKIP.
PARAMETERS DOWNLOAD RADIOBUTTON GROUP R1 .
PARAMETERS UPLOAD   RADIOBUTTON GROUP R1.
SELECTION-SCREEN END OF BLOCK A00.

SELECTION-SCREEN BEGIN OF BLOCK B00 WITH FRAME TITLE T_B00.
PARAMETERS B00_APPS TYPE UJA_APPSET_INFO-APPSET_ID                  MODIF ID A00.
PARAMETERS B00_APPL TYPE UJA_APPL-APPLICATION_ID                    MODIF ID A00.

SELECTION-SCREEN SKIP.

PARAMETERS REGEX   TYPE RS_BOOL AS CHECKBOX                         MODIF ID A00.
PARAMETERS EXCOM   TYPE RS_BOOL AS CHECKBOX                         MODIF ID A00.
SELECT-OPTIONS: B00_PATT FOR (LD_V__PATTERN) NO INTERVALS           MODIF ID A00.
SELECTION-SCREEN SKIP.
PARAMETERS STFILE TYPE RS_BOOL AS CHECKBOX USER-COMMAND UC          MODIF ID A00.
PARAMETERS LOCFILE TYPE STRING                                      MODIF ID A01.
SELECTION-SCREEN END OF BLOCK B00.

SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE T_B01.
SELECT-OPTIONS: B01_APPS FOR UJA_APPSET_INFO-APPSET_ID NO INTERVALS MODIF ID B00.
SELECT-OPTIONS: B01_APPL FOR UJA_APPL-APPLICATION_ID NO INTERVALS   MODIF ID B00.
SELECT-OPTIONS: B01_DIMN FOR UJA_APPL-APPLICATION_ID NO INTERVALS   MODIF ID B00.


SELECTION-SCREEN SKIP.
PARAMETERS:     SCLO AS CHECKBOX DEFAULT ``                        MODIF ID B00.
PARAMETERS:     PACK AS CHECKBOX DEFAULT ``                        MODIF ID B00.
PARAMETERS:     XLTP AS CHECKBOX DEFAULT ``                        MODIF ID B00.
PARAMETERS:     DIMN AS CHECKBOX DEFAULT ``                        MODIF ID B00.
SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (15) CPATH FOR FIELD DPATH                 MODIF ID B00.
PARAMETERS: DPATH TYPE LOCALFILE                                    MODIF ID B00.
SELECTION-SCREEN COMMENT (3) T_BDIR                                 MODIF ID B00.
PARAMETERS: F_SYS AS CHECKBOX DEFAULT `X`                           MODIF ID B00.
SELECTION-SCREEN COMMENT (5) T_F_SYS FOR FIELD F_SYS                MODIF ID B00.
PARAMETERS: F_PAC AS CHECKBOX DEFAULT `X`                           MODIF ID B00.
SELECTION-SCREEN COMMENT (10) T_F_PAC FOR FIELD F_PAC               MODIF ID B00.
PARAMETERS: F_DIR AS CHECKBOX DEFAULT `X`                           MODIF ID B00.
SELECTION-SCREEN COMMENT (5) T_F_DIR FOR FIELD F_DIR                MODIF ID B00.
*parameters: f_ele as checkbox default `X`                           modif id b00.
*selection-screen comment (8) t_f_ele for field f_ele                modif id b00.
SELECTION-SCREEN END OF LINE.


SELECTION-SCREEN END OF BLOCK B01.

SELECTION-SCREEN BEGIN OF BLOCK B02 WITH FRAME TITLE T_B02.
PARAMETERS: UPATH TYPE LOCALFILE                                    MODIF ID C00.
PARAMETERS: B02_APPS TYPE UJ_APPSET_ID                              MODIF ID C00.
SELECTION-SCREEN END OF BLOCK B02.

*--------------------------------------------------------------------*
* Initialization
*--------------------------------------------------------------------*
INITIALIZATION.
  LOCFILE = ZCL_PATH_UTILITES=>GET_INITIAL_DIRECTORY( ).
  CONCATENATE LOCFILE `*.xml` INTO LOCFILE.


  MOVE
  : `Режим работы`                            TO T_A00
  , `Поиск Скрипт Логики по ключевым словам`  TO T_B00
  , `Выгрузить Скрипт Логики в файл`          TO T_B01
  , `Загрузить Скрипт Логику из файлов`       TO T_B02
  , `Директория`                              TO CPATH
  , 'BPCS\'                                   TO T_F_SYS
  , 'APPS\APPL\'                              TO T_F_PAC
  , 'TYPE\'                                   TO T_F_DIR
*  , 'element\'                                to t_f_ele
  .

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = `A01` AND STFILE = ABAP_FALSE.
      SCREEN-INPUT = '0'.
    ENDIF.

    CASE ABAP_TRUE.
      WHEN FIND.
        IF SCREEN-GROUP1 CP `B++` OR SCREEN-GROUP1 CP `C++`.
          SCREEN-ACTIVE = 0.
        ENDIF.

      WHEN DOWNLOAD.
        IF SCREEN-GROUP1 CP `A++` OR SCREEN-GROUP1 CP `C++`.
          SCREEN-ACTIVE = 0.
        ENDIF.
      WHEN UPLOAD.
        IF SCREEN-GROUP1 CP `A++` OR SCREEN-GROUP1 CP `B++`.
          SCREEN-ACTIVE = 0.
        ENDIF.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR LOCFILE.
  IF STFILE = ABAP_TRUE.
    LOCFILE = ZCL_PATH_UTILITES=>DIRECTORY_F4( ).
    CONCATENATE LOCFILE `*.xml` INTO LOCFILE.
  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR DPATH.
  DPATH = ZCL_PATH_UTILITES=>DIRECTORY_F4( ).

AT SELECTION-SCREEN ON VALUE-REQUEST FOR UPATH.
  UPATH = ZCL_PATH_UTILITES=>DIRECTORY_F4( ).
*--------------------------------------------------------------------*

AT SELECTION-SCREEN.
  IF SY-UCOMM = `ONLI`.
    PERFORM CHECK_SELECTION.
  ENDIF .



*--------------------------------------------------------------------*
* Start-of-Selection.
*--------------------------------------------------------------------*
START-OF-SELECTION.

  CASE ABAP_TRUE.
    WHEN FIND.
      PERFORM FIND.
      PERFORM PRINT.
      IF STFILE = ABAP_TRUE.
        PERFORM SAVE_TO_XML_FILE.
      ENDIF.
    WHEN DOWNLOAD.
      PERFORM DOWNLOAD.
    WHEN UPLOAD.
      PERFORM UPLOAD.
  ENDCASE.

END-OF-SELECTION.
*--------------------------------------------------------------------*


*--------------------------------------------------------------------*
* Programms
*--------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  find
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FIND.
  DATA
  : LD_V__DOCNAME TYPE UJ_DOCNAME
  , LD_T__SPLITDOC    TYPE TABLE OF STRING
  , LD_S__TADIR      TYPE ZVCST_S__TADIR
  , LD_S__UJFDOC      TYPE UJF_DOC
  , LD_T__SOURCE      TYPE ZVCST_T__LGFSOURCE
  , L_V__PREVLINE    TYPE I
  , LD_V__OFFSET      TYPE I
  , LD_V__SLENGTH     TYPE I
  , LD_V__TLENGTH     TYPE I
  , LD_S__RESTAB      TYPE TY_S__RESTAB
  , LD_T__RESULTS     TYPE MATCH_RESULT_TAB WITH HEADER LINE
  .


  SELECT  DOCNAME
      INTO LD_V__DOCNAME
      FROM UJF_DOC
      WHERE APPSET       EQ B00_APPS
        AND DOCTYPE      EQ `LGF`
        AND COMPRESSION  NE `X`.

    CLEAR
    : LD_T__SPLITDOC
    , LD_S__TADIR
    .

    LD_S__TADIR-APPSET = B00_APPS.
    LD_S__TADIR-OBJECT   = ZVCSC_BPC_TYPE-SCLO.
    SPLIT LD_V__DOCNAME AT `\` INTO TABLE LD_T__SPLITDOC.

    READ TABLE
    : LD_T__SPLITDOC INDEX 6 INTO LD_S__TADIR-APPLICATION
    , LD_T__SPLITDOC INDEX 7 INTO LD_S__TADIR-OBJ_NAME
    .

    IF B00_APPL IS NOT INITIAL.
      CHECK B00_APPL =  LD_S__TADIR-APPLICATION.
    ENDIF.

    LD_V__DOCNAME = LD_S__TADIR-OBJ_NAME.

    CALL FUNCTION 'ZFM_GET_BPC_LGF'
      EXPORTING
        I_APPSET      = LD_S__TADIR-APPSET
        I_APPLICATION = LD_S__TADIR-APPLICATION
        I_FILENAME    = LD_V__DOCNAME
      IMPORTING
        E_DOC         = LD_S__UJFDOC
      TABLES
        ET_LGF        = LD_T__SOURCE
      EXCEPTIONS
        NOT_EXISTING  = 1
        OTHERS        = 3.
    IF SY-SUBRC <> 0.
      CONTINUE.
    ENDIF.

    REPLACE ALL OCCURRENCES OF CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB IN TABLE LD_T__SOURCE WITH `     `.

    MOVE-CORRESPONDING LD_S__UJFDOC TO GD_T__RESTAB.
    GD_T__RESTAB-APPSET  = LD_S__TADIR-APPSET.
    GD_T__RESTAB-APPL    = LD_S__TADIR-APPLICATION.
    GD_T__RESTAB-SCRIPT  = LD_V__DOCNAME.

    LOOP AT B00_PATT.
      CLEAR LD_T__RESULTS[].
      IF B00_PATT-LOW IS NOT INITIAL.
        IF REGEX = `X`.
          FIND ALL OCCURRENCES OF REGEX B00_PATT-LOW IN TABLE LD_T__SOURCE RESULTS LD_T__RESULTS[] IGNORING CASE.
        ELSE.
          FIND ALL OCCURRENCES OF B00_PATT-LOW IN TABLE LD_T__SOURCE RESULTS LD_T__RESULTS[] IGNORING CASE.
        ENDIF.

        CLEAR L_V__PREVLINE.

        IF SY-SUBRC = 0.
          LOOP AT  LD_T__RESULTS.

            GD_T__RESTAB-PATTERN = B00_PATT-LOW.
            GD_T__RESTAB-OFFSET  = LD_T__RESULTS-OFFSET.
            GD_T__RESTAB-LENGTH  = LD_T__RESULTS-LENGTH.
            GD_T__RESTAB-NUMLINE = LD_T__RESULTS-LINE.

            READ TABLE LD_T__SOURCE INDEX LD_T__RESULTS-LINE
                 INTO GD_T__RESTAB-ROWS.

            IF EXCOM = `X`.
              FIND FIRST OCCURRENCE OF `//` IN GD_T__RESTAB-ROWS MATCH OFFSET LD_V__OFFSET.
              IF SY-SUBRC = 0.
                CHECK LD_T__RESULTS-OFFSET < LD_V__OFFSET.
              ENDIF.
            ENDIF.

            DATA LD_F__WRITE TYPE RS_BOOL.
            CLEAR LD_F__WRITE.

            LOOP AT  GD_T__PRINTTAB
                 INTO LD_S__RESTAB
                 WHERE APPSET  = GD_T__RESTAB-APPSET
                   AND APPL    = GD_T__RESTAB-APPL
                   AND SCRIPT  = GD_T__RESTAB-SCRIPT
                   AND NUMLINE = GD_T__RESTAB-NUMLINE.

              LD_V__TLENGTH = GD_T__RESTAB-OFFSET + GD_T__RESTAB-LENGTH.
              LD_V__SLENGTH = LD_S__RESTAB-OFFSET + LD_S__RESTAB-LENGTH.

              IF GD_T__RESTAB-OFFSET >= LD_S__RESTAB-OFFSET AND
                 LD_V__TLENGTH       <= LD_V__SLENGTH.

                LD_F__WRITE = ABAP_TRUE.
                EXIT.

              ELSEIF LD_S__RESTAB-OFFSET > GD_T__RESTAB-OFFSET AND
                     LD_V__TLENGTH       > LD_V__TLENGTH.

                MOVE-CORRESPONDING GD_T__RESTAB TO GD_T__PRINTTAB.
                MODIFY TABLE GD_T__PRINTTAB.
                LD_F__WRITE = ABAP_TRUE.

              ELSEIF LD_S__RESTAB-OFFSET >= GD_T__RESTAB-OFFSET AND
                     LD_V__SLENGTH       >  LD_V__TLENGTH       AND
                     LD_V__TLENGTH       >  LD_S__RESTAB-OFFSET.

                MOVE-CORRESPONDING GD_T__RESTAB TO GD_T__PRINTTAB.
                GD_T__PRINTTAB-OFFSET = GD_T__RESTAB-OFFSET.
                GD_T__PRINTTAB-LENGTH = LD_S__RESTAB-OFFSET - GD_T__RESTAB-OFFSET.
                INSERT TABLE GD_T__PRINTTAB.
                LD_F__WRITE = ABAP_TRUE.

              ELSEIF GD_T__RESTAB-OFFSET >= LD_S__RESTAB-OFFSET AND
                     LD_V__TLENGTH       > LD_V__SLENGTH       AND
                     GD_T__RESTAB-OFFSET < LD_V__SLENGTH.

                MOVE-CORRESPONDING GD_T__RESTAB TO GD_T__PRINTTAB.
                GD_T__PRINTTAB-OFFSET = LD_S__RESTAB-OFFSET + LD_S__RESTAB-LENGTH.
                GD_T__PRINTTAB-LENGTH = LD_V__TLENGTH - LD_V__SLENGTH.
                INSERT TABLE GD_T__PRINTTAB.
                LD_F__WRITE = ABAP_TRUE.

              ENDIF.
            ENDLOOP.

            IF LD_F__WRITE = ABAP_FALSE.
              MOVE-CORRESPONDING GD_T__RESTAB TO GD_T__PRINTTAB.
              INSERT TABLE GD_T__PRINTTAB.
            ENDIF.

            INSERT TABLE GD_T__RESTAB.

            L_V__PREVLINE = LD_T__RESULTS-LINE.

          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDSELECT.
ENDFORM.                    "find

*&---------------------------------------------------------------------*
*&      Form  print
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM PRINT.
  DATA
  : LD_V__NUMLINE     TYPE C LENGTH 4
  , LD_V__SCLO        TYPE C LENGTH 110
  , LD_V__FILLINE     TYPE C LENGTH 150
  , LD_V__CREATE      TYPE STRING
  , LD_V__CHANGE      TYPE STRING
  , LD_V__ROWS        TYPE STRING
  , LD_V__LENGTH      TYPE I
  , LD_S__PREVIOUS    LIKE LINE OF GD_T__RESTAB
  , LD_V__INDEX       TYPE I
  , LD_F__EXIT        TYPE RS_BOOL
  , LD_V__STRING      TYPE C LENGTH 16
  , LD_V__TMSTP       TYPE TZNTSTMPL
  , LD_V__TIME        TYPE STRING
  , LD_V__DATE        TYPE STRING
  , LD_V__OFFSET      TYPE I
  .

  LD_V__INDEX = LINES( GD_T__PRINTTAB ) + 1.

  DO LD_V__INDEX TIMES.

    READ TABLE GD_T__PRINTTAB INDEX SY-INDEX.
    IF SY-SUBRC <> 0.
      CLEAR LD_S__PREVIOUS-SCRIPT.
      LD_F__EXIT = ABAP_TRUE.
    ENDIF.

    IF NOT ( GD_T__PRINTTAB-SCRIPT  = LD_S__PREVIOUS-SCRIPT AND
             GD_T__PRINTTAB-APPL    = LD_S__PREVIOUS-APPL   AND
             GD_T__PRINTTAB-NUMLINE = LD_S__PREVIOUS-NUMLINE ).
      WRITE LD_V__ROWS.
    ELSEIF GD_T__PRINTTAB-OFFSET = LD_S__PREVIOUS-OFFSET.
      CONTINUE.
    ENDIF.

    IF GD_T__PRINTTAB-SCRIPT <> LD_S__PREVIOUS-SCRIPT OR
       GD_T__PRINTTAB-APPL   <> LD_S__PREVIOUS-APPL.
      IF SY-INDEX > 1.
        LD_V__STRING+0(8) = LD_S__PREVIOUS-CREATE_DATE.
        LD_V__STRING+8(8) = LD_S__PREVIOUS-CREATE_TIME.
        LD_V__TMSTP = LD_V__STRING.
        CONVERT TIME STAMP LD_V__TMSTP TIME ZONE CS_TIME_ZONE  INTO: TIME LD_V__TIME, DATE LD_V__DATE.

        CONCATENATE `Create: `
                    LD_S__PREVIOUS-OWNER ` (`
                    LD_V__DATE+0(4) `.`
                    LD_V__DATE+4(2) `.`
                    LD_V__DATE+6(2) ` `
                    LD_V__TIME+0(2) `:`
                    LD_V__TIME+2(2) `:`
                    LD_V__TIME+4(2) `)`
                    INTO LD_V__CREATE.
        IF GD_T__PRINTTAB-LSTMOD_USER IS NOT INITIAL.
          LD_V__STRING+0(8) = LD_S__PREVIOUS-LSTMOD_DATE.
          LD_V__STRING+8(8) = LD_S__PREVIOUS-LSTMOD_TIME.
          LD_V__TMSTP = LD_V__STRING.
          CONVERT TIME STAMP LD_V__TMSTP TIME ZONE CS_TIME_ZONE  INTO: TIME LD_V__TIME, DATE LD_V__DATE.

          CONCATENATE `Change: `
                      LD_S__PREVIOUS-LSTMOD_USER ` (`
                      LD_V__DATE+0(4) `.`
                      LD_V__DATE+4(2) `.`
                      LD_V__DATE+6(2) ` `
                      LD_V__TIME+0(2) `:`
                      LD_V__TIME+2(2) `:`
                      LD_V__TIME+4(2) `)`
                      INTO LD_V__CHANGE.
          CONCATENATE LD_V__CREATE ` ` LD_V__CHANGE INTO LD_V__FILLINE.
        ELSE.
          LD_V__FILLINE = LD_V__CREATE.
        ENDIF.
        NEW-LINE.
        WRITE
        : LD_V__FILLINE  COLOR COL_KEY RIGHT-JUSTIFIED NO-GAP.

        IF LD_F__EXIT = ABAP_TRUE.
          EXIT.
        ENDIF.
      ENDIF.

      LD_V__SCLO = GD_T__PRINTTAB-SCRIPT.

      NEW-LINE.
      WRITE
      : LD_V__SCLO            COLOR COL_GROUP INTENSIFIED NO-GAP
      , GD_T__PRINTTAB-APPL   COLOR COL_GROUP RIGHT-JUSTIFIED NO-GAP
      , GD_T__PRINTTAB-APPSET COLOR COL_GROUP RIGHT-JUSTIFIED NO-GAP
      .
    ENDIF.

    IF NOT ( GD_T__PRINTTAB-SCRIPT  = LD_S__PREVIOUS-SCRIPT AND
             GD_T__PRINTTAB-APPL    = LD_S__PREVIOUS-APPL   AND
             GD_T__PRINTTAB-APPSET  = LD_S__PREVIOUS-APPSET AND
             GD_T__PRINTTAB-NUMLINE = LD_S__PREVIOUS-NUMLINE ).

      LD_V__NUMLINE = GD_T__PRINTTAB-NUMLINE.

      LD_V__LENGTH = GD_T__PRINTTAB-OFFSET + GD_T__PRINTTAB-LENGTH.
      NEW-LINE.

      WRITE
      : LD_V__NUMLINE                                                    COLOR COL_KEY RIGHT-JUSTIFIED
      , GD_T__PRINTTAB-ROWS+0(GD_T__PRINTTAB-OFFSET)                     NO-GAP
      , GD_T__PRINTTAB-ROWS+GD_T__PRINTTAB-OFFSET(GD_T__PRINTTAB-LENGTH) COLOR COL_TOTAL NO-GAP.

      LD_V__ROWS = GD_T__PRINTTAB-ROWS+LD_V__LENGTH.
    ELSE.
      LD_V__OFFSET = GD_T__PRINTTAB-OFFSET - LD_V__LENGTH.
      CHECK NOT LD_V__OFFSET < 0.

      LD_V__LENGTH = GD_T__PRINTTAB-OFFSET + GD_T__PRINTTAB-LENGTH - LD_V__LENGTH.

      WRITE
      : LD_V__ROWS+0(LD_V__OFFSET)                                      NO-GAP
      , LD_V__ROWS+LD_V__OFFSET(GD_T__PRINTTAB-LENGTH)                  COLOR COL_TOTAL HOTSPOT NO-GAP.

      LD_V__ROWS   = LD_V__ROWS+LD_V__LENGTH.
      LD_V__LENGTH = GD_T__PRINTTAB-OFFSET + GD_T__PRINTTAB-LENGTH.
    ENDIF.

    LD_S__PREVIOUS = GD_T__PRINTTAB.

  ENDDO.

ENDFORM.                    "print

*&---------------------------------------------------------------------*
*&      Form  save_to_xml_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAVE_TO_XML_FILE.
  TYPES: BEGIN OF XML_LINE
       , DATA(256) TYPE X
       , END OF XML_LINE.

  DATA
  : L_IXML                TYPE REF TO IF_IXML
  , L_STREAMFACTORY       TYPE REF TO IF_IXML_STREAM_FACTORY
  , L_OSTREAM             TYPE REF TO IF_IXML_OSTREAM
  , L_RENDERER            TYPE REF TO IF_IXML_RENDERER
  , L_DOCUMENT            TYPE REF TO IF_IXML_DOCUMENT
  , L_ELEMENT_ROOT        TYPE REF TO IF_IXML_ELEMENT
  , NS_ATTRIBUTE          TYPE REF TO IF_IXML_ATTRIBUTE
  , R_ELEMENT_PROPERTIES  TYPE REF TO IF_IXML_ELEMENT
  , R_ELEMENT             TYPE REF TO IF_IXML_ELEMENT
  , R_WORKSHEET           TYPE REF TO IF_IXML_ELEMENT
  , R_TABLE               TYPE REF TO IF_IXML_ELEMENT
  , R_COLUMN              TYPE REF TO IF_IXML_ELEMENT
  , R_ROW                 TYPE REF TO IF_IXML_ELEMENT
  , R_CELL                TYPE REF TO IF_IXML_ELEMENT
  , R_DATA                TYPE REF TO IF_IXML_ELEMENT
  , R_STYLES              TYPE REF TO IF_IXML_ELEMENT
  , R_STYLE               TYPE REF TO IF_IXML_ELEMENT
  , R_FORMAT              TYPE REF TO IF_IXML_ELEMENT
  , L_VALUE               TYPE STRING
  , L_TYPE                TYPE STRING
  , L_XML_TABLE           TYPE TABLE OF XML_LINE
  , L_RC                  TYPE I
  , L_XML_SIZE            TYPE I
  .

  FIELD-SYMBOLS
  : <FIELD> TYPE ANY
  , <DATA_LINE> TYPE ANY
  .

* Creating a ixml factory
  L_IXML = CL_IXML=>CREATE( ).
* Creating the dom object model
  L_DOCUMENT = L_IXML->CREATE_DOCUMENT( ).
* Create root node 'Workbook'
  L_ELEMENT_ROOT  = L_DOCUMENT->CREATE_SIMPLE_ELEMENT(
              NAME = 'Workbook'
*              uri  = 'urn:schemas-microsoft-com:office:spreadsheet'
              PARENT = L_DOCUMENT ).
  L_ELEMENT_ROOT->SET_ATTRIBUTE(
NAME = 'xmlns'
VALUE = 'urn:schemas-microsoft-com:office:spreadsheet' ).
  NS_ATTRIBUTE = L_DOCUMENT->CREATE_NAMESPACE_DECL(
              NAME = 'ss'
              PREFIX = 'xmlns'
              URI = 'urn:schemas-microsoft-com:office:spreadsheet' ).
  L_ELEMENT_ROOT->SET_ATTRIBUTE_NODE( NS_ATTRIBUTE ).  NS_ATTRIBUTE = L_DOCUMENT->CREATE_NAMESPACE_DECL(
              NAME = 'x'
              PREFIX = 'xmlns'
              URI = 'urn:schemas-microsoft-com:office:excel' ).
  L_ELEMENT_ROOT->SET_ATTRIBUTE_NODE( NS_ATTRIBUTE ).
* Create node for document properties.
  R_ELEMENT_PROPERTIES = L_DOCUMENT->CREATE_SIMPLE_ELEMENT(
              NAME = 'DocumentProperties'
              PARENT = L_ELEMENT_ROOT ).
  L_VALUE = SY-UNAME.
  L_DOCUMENT->CREATE_SIMPLE_ELEMENT(
                    NAME = 'Author'
                    VALUE = L_VALUE
                    PARENT = R_ELEMENT_PROPERTIES  ).


  R_STYLES = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Styles' PARENT = L_ELEMENT_ROOT  ).
* Header row - Yellow, Bold
  R_STYLE  = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Style'  PARENT = R_STYLES  ).
  R_STYLE->SET_ATTRIBUTE_NS( NAME = 'ID' PREFIX = 'ss' VALUE = 'Header' ).
  R_FORMAT  = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Font' PARENT = R_STYLE  ).
  R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'Bold' PREFIX = 'ss' VALUE = '1' ).
  R_FORMAT  = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Interior' PARENT = R_STYLE  ).
  R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'Color' PREFIX = 'ss' VALUE = '#FFFF00' ).
  R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'Pattern' PREFIX = 'ss' VALUE = 'Solid' ).
  R_FORMAT  = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Alignment' PARENT = R_STYLE  ).
  R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'Vertical' PREFIX = 'ss' VALUE = 'Bottom' ).
  R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'WrapText' PREFIX = 'ss' VALUE = '1' ).

  DATA
  : LR_O__STRUCTDESCR TYPE REF TO CL_ABAP_STRUCTDESCR
  , LD_S__COMP        TYPE ABAP_COMPDESCR
  , LD_V__VALUE       TYPE STRING
  .

  LR_O__STRUCTDESCR ?= CL_ABAP_TABLEDESCR=>DESCRIBE_BY_DATA( GD_T__RESTAB ).

  LOOP AT LR_O__STRUCTDESCR->COMPONENTS
       INTO LD_S__COMP.

    CHECK LD_S__COMP-NAME = `APPSET`
       OR LD_S__COMP-NAME = `APPL`
       OR LD_S__COMP-NAME = `SCRIPT`
       OR LD_S__COMP-NAME = `PATTERN`
       OR LD_S__COMP-NAME = `NUMLINE`
       OR LD_S__COMP-NAME = `ROWS`.


    CASE LD_S__COMP-NAME.
      WHEN `APPSET`. LD_V__VALUE = LD_S__COMP-NAME.
      WHEN `APPL`.   LD_V__VALUE = LD_S__COMP-NAME.
      WHEN `SCRIPT`. LD_V__VALUE = LD_S__COMP-NAME.
      WHEN `PATTERN`.LD_V__VALUE = LD_S__COMP-NAME.
      WHEN `NUMLINE`.LD_V__VALUE = LD_S__COMP-NAME.
      WHEN `ROWS`.   LD_V__VALUE = LD_S__COMP-NAME.
    ENDCASE.

    " APPSET
    R_STYLE  = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Style' PARENT = R_STYLES  ).
    R_STYLE->SET_ATTRIBUTE_NS( NAME = 'ID' PREFIX = 'ss' VALUE = LD_V__VALUE ).
    R_FORMAT  = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'NumberFormat' PARENT = R_STYLE  ).
    L_VALUE = '@'.
    R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'Format' PREFIX = 'ss' VALUE = L_VALUE ).
  ENDLOOP.

*  Worksheet
*  <Worksheet ss:Name="Sheet1">
  R_WORKSHEET = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Worksheet ' PARENT = L_ELEMENT_ROOT ).
  R_WORKSHEET->SET_ATTRIBUTE_NS( NAME = 'Name' PREFIX = 'ss' VALUE = 'Sheet1' ).
* Table
* <Table ss:ExpandedColumnCount="3" ss:ExpandedRowCount="1" x:FullColumns="1" x:FullRows="1">
  R_TABLE = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Table' PARENT = R_WORKSHEET ).
*  describe table dd03p_tab lines num_rows.
  R_TABLE->SET_ATTRIBUTE_NS( NAME = 'FullColumns' PREFIX = 'x' VALUE = '1' ).
  R_TABLE->SET_ATTRIBUTE_NS( NAME = 'FullRows' PREFIX = 'x' VALUE = '1' ).
* Column formatting
  LOOP AT LR_O__STRUCTDESCR->COMPONENTS
       INTO LD_S__COMP.
*   Columnn
*   <Column>
    R_COLUMN = L_DOCUMENT->CREATE_SIMPLE_ELEMENT(
              NAME = 'Column'
              PARENT = R_TABLE ).

    L_VALUE = 100.
    CONDENSE L_VALUE NO-GAPS.
    R_COLUMN->SET_ATTRIBUTE_NS(
                      NAME = 'Width'
                      PREFIX = 'ss'
                      VALUE =  L_VALUE ).
  ENDLOOP.
* Column headers
*   Row
*   <Row>

  R_ROW = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Row' PARENT = R_TABLE ).

  R_ROW->SET_ATTRIBUTE_NS( NAME = 'StyleID'       PREFIX = 'ss' VALUE = 'Header' ).
  R_ROW->SET_ATTRIBUTE_NS( NAME = 'AutoFitHeight' PREFIX = 'ss' VALUE = '1' ).

  LOOP AT LR_O__STRUCTDESCR->COMPONENTS
     INTO LD_S__COMP.

    CHECK LD_S__COMP-NAME = `APPSET`
       OR LD_S__COMP-NAME = `APPL`
       OR LD_S__COMP-NAME = `SCRIPT`
       OR LD_S__COMP-NAME = `PATTERN`
       OR LD_S__COMP-NAME = `NUMLINE`
       OR LD_S__COMP-NAME = `ROWS`.


    CASE LD_S__COMP-NAME.
      WHEN `APPSET`. LD_V__VALUE = `Appset`.
      WHEN `APPL`.   LD_V__VALUE = `Application`.
      WHEN `SCRIPT`. LD_V__VALUE = `Script Logic`.
      WHEN `PATTERN`.LD_V__VALUE = `Pattern`.
      WHEN `NUMLINE`.LD_V__VALUE = `Num Line`.
      WHEN `ROWS`.   LD_V__VALUE = `Rows`.
    ENDCASE.

    R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell' PARENT = R_ROW ).
    R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data' VALUE = LD_V__VALUE PARENT = R_CELL ).
    R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type' PREFIX = 'ss' VALUE = 'String' ).

  ENDLOOP.
* Finally loop at the data table and output the fields
  LOOP AT GD_T__RESTAB ASSIGNING <DATA_LINE>.
*   Row
*   <Row>
    R_ROW = L_DOCUMENT->CREATE_SIMPLE_ELEMENT(
              NAME = 'Row'
              PARENT = R_TABLE ).
    LOOP AT LR_O__STRUCTDESCR->COMPONENTS
        INTO LD_S__COMP.

      CHECK LD_S__COMP-NAME = `APPSET`
         OR LD_S__COMP-NAME = `APPL`
         OR LD_S__COMP-NAME = `SCRIPT`
         OR LD_S__COMP-NAME = `PATTERN`
         OR LD_S__COMP-NAME = `NUMLINE`
         OR LD_S__COMP-NAME = `ROWS`.

      ASSIGN COMPONENT LD_S__COMP-NAME OF STRUCTURE <DATA_LINE> TO <FIELD>.
      CHECK SY-SUBRC IS INITIAL.


*     <Cell>
      R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT(
                NAME = 'Cell'
                PARENT = R_ROW ).
      CASE LD_S__COMP-TYPE_KIND.
        WHEN 'I' OR 'P' OR 'F' OR 'N'.
          L_TYPE = 'Number'.
          L_VALUE = <FIELD>.
          CONDENSE L_VALUE NO-GAPS.
        WHEN OTHERS.
          L_TYPE = 'String'.
          L_VALUE = <FIELD>.
      ENDCASE.
*     <Data>
      R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT(
                NAME = 'Data'
                VALUE = L_VALUE
                PARENT = R_CELL ).
*     Cell format
      R_DATA->SET_ATTRIBUTE_NS(
                        NAME = 'Type'
                        PREFIX = 'ss'
                        VALUE = L_TYPE ).
    ENDLOOP.
  ENDLOOP.
*   Creating a stream factory
  L_STREAMFACTORY = L_IXML->CREATE_STREAM_FACTORY( ).
*   Connect internal XML table to stream factory
  L_OSTREAM = L_STREAMFACTORY->CREATE_OSTREAM_ITABLE( TABLE = L_XML_TABLE ).
*   Rendering the document
  L_RENDERER = L_IXML->CREATE_RENDERER( OSTREAM  = L_OSTREAM
                                        DOCUMENT = L_DOCUMENT ).
  L_RC = L_RENDERER->RENDER( ).
  L_OSTREAM->GET_PRETTY_PRINT( ).

*   Saving the XML document
  L_XML_SIZE = L_OSTREAM->GET_NUM_WRITTEN_RAW( ).

  DATA STR(256) TYPE C VALUE `<DATA>ываыа</DATA>`.
  DATA X TYPE XML_LINE.

  MOVE STR TO X-DATA.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
    EXPORTING
      BIN_FILESIZE = L_XML_SIZE
      FILENAME     = LOCFILE
      FILETYPE     = 'BIN'
    CHANGING
      DATA_TAB     = L_XML_TABLE
    EXCEPTIONS
      OTHERS       = 24.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 INTO GD_V__MESSAGE.
    MESSAGE I001(00) WITH GD_V__MESSAGE.
  ENDIF.

ENDFORM.                    "save_to_xml_file

*&---------------------------------------------------------------------*
*&      Form  download
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DOWNLOAD.

*  perform create_object_list.

*  create object lr_o__vcs_r3tr_process.

  GD_S__PATH-PATH  = DPATH.
  GD_S__PATH-F_SYS = F_SYS.
  GD_S__PATH-F_PAC = F_PAC.
  GD_S__PATH-F_DIR = F_DIR.
*  gd_s__path-f_ele = f_ele.

  CALL METHOD ZCL_VCS_OBJECTS=>SET_TASK_DOWNLOAD_FOR_BPC
    EXPORTING
      I_T__APPSET_ID = B01_APPS[]
      I_T__APPL_ID   = B01_APPL[]
      I_T__DIMENSION = B01_DIMN[]
      I_S__PATH      = GD_S__PATH
      I_F__LGF       = SCLO
      I_F__PACK      = PACK
      I_F__XLTP      = XLTP
      I_F__DIMN      = DIMN.

  ZCL_VCS_PROCESS=>MASTER_DOWNLOAD( `CHOOSE_DOWNLOAD` ).


ENDFORM.                    "download

*&---------------------------------------------------------------------*
*&      Form  upload
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM UPLOAD.
  DATA
  : LR_O__VCS_R3TR_PROCESS TYPE REF TO ZCL_VCS_PROCESS
  , LD_V__PCPATH           TYPE STRING
  .

  LD_V__PCPATH = UPATH.

  CREATE OBJECT LR_O__VCS_R3TR_PROCESS.

  ZCL_VCS_PROCESS=>MASTER_UPLOAD( I_V__DIRECTORY = LD_V__PCPATH I_V__FORM_NAME = `CHOOSE_DOWNLOAD` ).
ENDFORM.                    "upload

*&---------------------------------------------------------------------*
*&      Form  check_selection
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_SELECTION.

  CASE ABAP_TRUE.
    WHEN FIND.
      IF  B00_APPS  IS INITIAL.
        MESSAGE E001(00) WITH 'Please enter BPC APPSET ID'.
      ENDIF.

      IF B00_PATT[] IS INITIAL.
        MESSAGE E001(00) WITH 'Please enter PATTERN'.
      ENDIF.

      IF REGEX = ABAP_TRUE.
        LOOP AT B00_PATT.
          TRY.
              CL_ABAP_MATCHER=>MATCHES(
                        PATTERN = B00_PATT-LOW
                        IGNORE_CASE = `X`
                        TEXT        = B00_PATT-LOW ).

            CATCH CX_SY_REGEX.
              CONCATENATE `Pattern ` '''' b00_patt-low ''''  ` no valid` into gd_v__message.
              message e001(00) with gd_v__message.
          endtry.
        endloop.
      endif.

      if stfile = abap_true.
        locfile  = zcl_path_utilites=>check_directory( directory = locfile  ).
      endif.

    when upload.
      if b02_apps is not initial.
        select single appset_id
          from uja_appset_info
          into zcl_vcs__bpcs__xltp=>cd_v__appset_id
          where appset_id =  b02_apps.

        if sy-subrc ne 0.
          clear zcl_vcs__bpcs__xltp=>cd_v__appset_id.
          message e001(00) with 'PLEASE ENTER CORRECT BPC APPSET ID'.
        else.
          zcl_vcs__bpcs__sclo=>cd_v__appset_id = zcl_vcs__bpcs__xltp=>cd_v__appset_id.
        endif.
      endif.

  endcase.


endform.                    "check_selection

*&---------------------------------------------------------------------*
*&      Form  choose_download
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->SELECTION  text
*----------------------------------------------------------------------*
form choose_download tables selection structure shvalue..

  zcl_vcs_objects=>cd_f__popup = space.

endform.                    "choose_download
