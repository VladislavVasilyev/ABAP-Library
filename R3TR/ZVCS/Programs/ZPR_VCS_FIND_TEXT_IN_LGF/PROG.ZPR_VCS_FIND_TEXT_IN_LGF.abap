*&---------------------------------------------------------------------*
*& Report  ZPR_VCS_FIND_TEXT_IN_LGF
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZPR_VCS_FIND_TEXT_IN_LGF.

TYPE-POOLS ZVCST.
TYPE-POOLS ZVCSC.
TYPE-POOLS ABAP.

TABLES
: UJA_APPSET_INFO
.

CONSTANTS
 : CS_TIME_ZONE                TYPE TTZZ-TZONE VALUE 'RUS03'
 .

*----------------------------------------------------------------------*
*       CLASS process_path DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS PROCESS_PATH DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS
    : FILE_F4
        RETURNING VALUE(R_FILE) TYPE STRING
    , GET_INITIAL_DIRECTORY
        RETURNING VALUE(R_PATH) TYPE STRING
    , CHECK_PATH
        IMPORTING I_PATH     TYPE STRING OPTIONAL
        RETURNING VALUE(R_FILE) TYPE STRING
    .
ENDCLASS.                    "process_path DEFINITION
*----------------------------------------------------------------------*
*       CLASS process_path IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS PROCESS_PATH IMPLEMENTATION.
  METHOD GET_INITIAL_DIRECTORY.
    CL_GUI_FRONTEND_SERVICES=>GET_DESKTOP_DIRECTORY(
     CHANGING
       DESKTOP_DIRECTORY    = R_PATH ).
    CL_GUI_CFW=>FLUSH( ).

    CONCATENATE R_PATH '\*.xml' INTO R_PATH.
  ENDMETHOD.                    "get_initial_directory

  METHOD FILE_F4.

    DATA: LT_FILE_TABLE TYPE FILETABLE.
    DATA: LS_FILE_TABLE LIKE LINE OF LT_FILE_TABLE.

    DATA: LV_RC TYPE SY-SUBRC.

    CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG(
      CHANGING
        FILE_TABLE = LT_FILE_TABLE
        RC         = LV_RC ).
    CLEAR LS_FILE_TABLE .
    READ TABLE LT_FILE_TABLE INTO LS_FILE_TABLE INDEX 1.
    IF SY-SUBRC  = 0.
      R_FILE = LS_FILE_TABLE-FILENAME.
    ENDIF.

  ENDMETHOD.                                                "file_f4
  METHOD CHECK_PATH.
    DATA
    : STRING_XY TYPE STRING
    , L_REGEX TYPE STRING
    , L_FILENAME TYPE STRING
    , L_PATH TYPE STRING
    .

    IF I_PATH IS SUPPLIED.
      IF I_PATH IS INITIAL.
        MESSAGE E001(00) WITH 'Please enter Path to File'.
      ENDIF.

      MOVE I_PATH TO STRING_XY.
      L_REGEX = '\A([a-z]):\\([^/:*?"<>$ \r\n]*\\[^/:*?"<>$ \r\n]*.XML)$'.
      FIND FIRST OCCURRENCE OF REGEX L_REGEX IN STRING_XY IGNORING CASE.

      IF SY-SUBRC <> 0.
        MESSAGE E001(00) WITH 'Please enter valid dpath'.
      ENDIF.

      L_PATH = STRING_XY.
    ENDIF.

    SET LOCALE LANGUAGE 'E'.
    SET LOCALE LANGUAGE SY-LANGU.

    CONCATENATE L_PATH L_FILENAME INTO R_FILE.
    CONDENSE R_FILE NO-GAPS.
  ENDMETHOD.                    "check_xml_file

ENDCLASS.                    "process_path IMPLEMENTATION

TYPES: BEGIN OF XML_LINE
       , DATA(256) TYPE X
       , END OF XML_LINE.

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

DATA
: GD_S__BPCDIR      TYPE ZVCST_S__TADIR
, GD_V__DOCNAME     TYPE UJ_DOCNAME
, GD_T__SPLITDOC    TYPE TABLE OF STRING
, GD_S__UJFDOC      TYPE UJF_DOC
, GD_T__SOURCE      TYPE ZVCST_T__LGFSOURCE
, GD_T__RESULTS     TYPE MATCH_RESULT_TAB WITH HEADER LINE
, GD_T__RESTAB      TYPE SORTED TABLE OF TY_S__RESTAB WITH UNIQUE KEY APPSET APPL SCRIPT NUMLINE OFFSET LENGTH WITH HEADER LINE
, GD_T__PRINTTAB    TYPE SORTED TABLE OF TY_S__RESTAB WITH UNIQUE KEY APPSET APPL SCRIPT NUMLINE OFFSET LENGTH WITH HEADER LINE
, GD_S__RESTAB      TYPE TY_S__RESTAB
, GD_V__PREVLINE    TYPE I
, GD_V__OFFSET      TYPE I
, GD_V__SLENGTH     TYPE I
, GD_V__TLENGTH     TYPE I
, GD_V__MESSAGE     TYPE STRING
, GD_V__TIME        TYPE STRING
, GD_V__DATE        TYPE STRING
, GD_V__TMSTP       TYPE TZNTSTMPL
, GD_V__STRING      TYPE C LENGTH 16
.


*--------------------------------------------------------------------*
* Selection-screen
*--------------------------------------------------------------------*
PARAMETERS APPS    TYPE UJA_APPSET_INFO-APPSET_ID.
PARAMETERS APPL    TYPE UJA_APPL-APPLICATION_ID.
SELECTION-SCREEN SKIP.

PARAMETERS REGEX   TYPE RS_BOOL AS CHECKBOX.
PARAMETERS EXCOM   TYPE RS_BOOL AS CHECKBOX.
SELECT-OPTIONS: PATT FOR (LD_V__PATTERN) NO INTERVALS.
SELECTION-SCREEN SKIP.

PARAMETERS STFILE TYPE RS_BOOL AS CHECKBOX USER-COMMAND UC.
PARAMETERS LOCFILE TYPE STRING MODIF ID FIL.
*--------------------------------------------------------------------*


*--------------------------------------------------------------------*
* Initialization
*--------------------------------------------------------------------*
INITIALIZATION.
  LOCFILE = PROCESS_PATH=>GET_INITIAL_DIRECTORY( ).

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = `FIL` AND STFILE = ABAP_FALSE.
      SCREEN-INPUT = '0'.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR LOCFILE.
  LOCFILE = PROCESS_PATH=>FILE_F4( ).


AT SELECTION-SCREEN.
  IF SY-UCOMM = `ONLI`.
    PERFORM CHECK_SELECTION.
  ENDIF .

*--------------------------------------------------------------------*
* Start-of-Selection.
*--------------------------------------------------------------------*
START-OF-SELECTION.

  SELECT  DOCNAME
      INTO GD_V__DOCNAME
      FROM UJF_DOC
      WHERE APPSET       EQ APPS
        AND DOCTYPE      EQ `LGF`
        AND COMPRESSION  NE `X`.

    CLEAR
    : GD_T__SPLITDOC
    , GD_S__BPCDIR
    .

    GD_S__BPCDIR-APPSET = APPS.
    GD_S__BPCDIR-OBJECT   = ZVCSC_BPC_TYPE-SCLO.
    SPLIT GD_V__DOCNAME AT `\` INTO TABLE GD_T__SPLITDOC.

    READ TABLE
    : GD_T__SPLITDOC INDEX 6 INTO GD_S__BPCDIR-APPLICATION
    , GD_T__SPLITDOC INDEX 7 INTO GD_S__BPCDIR-OBJ_NAME
    .

    IF APPL IS NOT INITIAL.
      CHECK APPL =  GD_S__BPCDIR-APPLICATION.
    ENDIF.

    GD_V__DOCNAME = GD_S__BPCDIR-OBJ_NAME.

    CALL FUNCTION 'ZFM_GET_BPC_LGF'
      EXPORTING
        I_APPSET       = GD_S__BPCDIR-APPSET
        I_APPLICATION  = GD_S__BPCDIR-APPLICATION
        I_FILENAME     = GD_V__DOCNAME
      IMPORTING
        E_DOC          = GD_S__UJFDOC
      TABLES
        ET_LGF         = GD_T__SOURCE
      EXCEPTIONS
        NOT_EXISTING   = 1
        LGF_IS_INITIAL = 2
        OTHERS         = 3.
    IF SY-SUBRC <> 0.
      CONTINUE.
    ENDIF.

    REPLACE ALL OCCURRENCES OF CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB IN TABLE GD_T__SOURCE WITH `     `.

    MOVE-CORRESPONDING GD_S__UJFDOC TO GD_T__RESTAB.
    GD_T__RESTAB-APPSET  = GD_S__BPCDIR-APPSET.
    GD_T__RESTAB-APPL    = GD_S__BPCDIR-APPLICATION.
    GD_T__RESTAB-SCRIPT  = GD_V__DOCNAME.

    LOOP AT PATT.
      CLEAR GD_T__RESULTS[].
      IF PATT-LOW IS NOT INITIAL.
        IF REGEX = `X`.
          FIND ALL OCCURRENCES OF REGEX PATT-LOW IN TABLE GD_T__SOURCE RESULTS GD_T__RESULTS[] IGNORING CASE.
        ELSE.
          FIND ALL OCCURRENCES OF PATT-LOW IN TABLE GD_T__SOURCE RESULTS GD_T__RESULTS[] IGNORING CASE.
        ENDIF.

        CLEAR GD_V__PREVLINE.

        IF SY-SUBRC = 0.
          LOOP AT  GD_T__RESULTS.

            GD_T__RESTAB-PATTERN = PATT-LOW.
            GD_T__RESTAB-OFFSET  = GD_T__RESULTS-OFFSET.
            GD_T__RESTAB-LENGTH  = GD_T__RESULTS-LENGTH.
            GD_T__RESTAB-NUMLINE = GD_T__RESULTS-LINE.

            READ TABLE GD_T__SOURCE INDEX GD_T__RESULTS-LINE
                 INTO GD_T__RESTAB-ROWS.

            IF EXCOM = `X`.
              FIND FIRST OCCURRENCE OF `//` IN GD_T__RESTAB-ROWS MATCH OFFSET GD_V__OFFSET.
              IF SY-SUBRC = 0.
                CHECK GD_T__RESULTS-OFFSET < GD_V__OFFSET.
              ENDIF.
            ENDIF.

            DATA LD_F__WRITE TYPE RS_BOOL.
            CLEAR LD_F__WRITE.

            LOOP AT  GD_T__PRINTTAB
                 INTO GD_S__RESTAB
                 WHERE APPSET  = GD_T__RESTAB-APPSET
                   AND APPL    = GD_T__RESTAB-APPL
                   AND SCRIPT  = GD_T__RESTAB-SCRIPT
                   AND NUMLINE = GD_T__RESTAB-NUMLINE.

              GD_V__TLENGTH = GD_T__RESTAB-OFFSET + GD_T__RESTAB-LENGTH.
              GD_V__SLENGTH = GD_S__RESTAB-OFFSET + GD_S__RESTAB-LENGTH.

              IF GD_T__RESTAB-OFFSET >= GD_S__RESTAB-OFFSET AND
                 GD_V__TLENGTH       <= GD_V__SLENGTH.

                LD_F__WRITE = ABAP_TRUE.
                EXIT.

              ELSEIF GD_S__RESTAB-OFFSET > GD_T__RESTAB-OFFSET AND
                     GD_V__TLENGTH       > GD_V__TLENGTH.

                MOVE-CORRESPONDING GD_T__RESTAB TO GD_T__PRINTTAB.
                MODIFY TABLE GD_T__PRINTTAB.
                LD_F__WRITE = ABAP_TRUE.

              ELSEIF GD_S__RESTAB-OFFSET >= GD_T__RESTAB-OFFSET AND
                     GD_V__SLENGTH       >  GD_V__TLENGTH       AND
                     GD_V__TLENGTH       >  GD_S__RESTAB-OFFSET.

                MOVE-CORRESPONDING GD_T__RESTAB TO GD_T__PRINTTAB.
                GD_T__PRINTTAB-OFFSET = GD_T__RESTAB-OFFSET.
                GD_T__PRINTTAB-LENGTH = GD_S__RESTAB-OFFSET - GD_T__RESTAB-OFFSET.
                INSERT TABLE GD_T__PRINTTAB.
                LD_F__WRITE = ABAP_TRUE.

              ELSEIF GD_T__RESTAB-OFFSET >= GD_S__RESTAB-OFFSET AND
                     GD_V__TLENGTH       > GD_V__SLENGTH       AND
                     GD_T__RESTAB-OFFSET < GD_V__SLENGTH.

                MOVE-CORRESPONDING GD_T__RESTAB TO GD_T__PRINTTAB.
                GD_T__PRINTTAB-OFFSET = GD_S__RESTAB-OFFSET + GD_S__RESTAB-LENGTH.
                GD_T__PRINTTAB-LENGTH = GD_V__TLENGTH - GD_V__SLENGTH.
                INSERT TABLE GD_T__PRINTTAB.
                LD_F__WRITE = ABAP_TRUE.

              ENDIF.
            ENDLOOP.

            IF LD_F__WRITE = ABAP_FALSE.
              MOVE-CORRESPONDING GD_T__RESTAB TO GD_T__PRINTTAB.
              INSERT TABLE GD_T__PRINTTAB.
            ENDIF.

            INSERT TABLE GD_T__RESTAB.

            GD_V__PREVLINE = GD_T__RESULTS-LINE.

          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDSELECT.


*--------------------------------------------------------------------*
* Print Report
*--------------------------------------------------------------------*
  DATA
  : GD_V__NUMLINE     TYPE C LENGTH 4
  , GD_V__SCLO        TYPE C LENGTH 110
  , GD_V__FILLINE     TYPE C LENGTH 150
  , GD_V__CREATE      TYPE STRING
  , GD_V__CHANGE      TYPE STRING
  , GD_V__ROWS        TYPE STRING
  , GD_V__LENGTH      TYPE I
  , GD_S__PREVIOUS    LIKE LINE OF GD_T__RESTAB
  , GD_V__INDEX       TYPE I
  , GD_F__EXIT        TYPE RS_BOOL.
  .

  GD_V__INDEX = LINES( GD_T__PRINTTAB ) + 1.

  DO GD_V__INDEX TIMES.

    READ TABLE GD_T__PRINTTAB INDEX SY-INDEX.
    IF SY-SUBRC <> 0.
      CLEAR GD_S__PREVIOUS-SCRIPT.
      GD_F__EXIT = ABAP_TRUE.
    ENDIF.

    IF NOT ( GD_T__PRINTTAB-SCRIPT  = GD_S__PREVIOUS-SCRIPT AND
             GD_T__PRINTTAB-APPL    = GD_S__PREVIOUS-APPL   AND
             GD_T__PRINTTAB-NUMLINE = GD_S__PREVIOUS-NUMLINE ).
      WRITE GD_V__ROWS.
    ELSEIF GD_T__PRINTTAB-OFFSET = GD_S__PREVIOUS-OFFSET.
      CONTINUE.
    ENDIF.

    IF GD_T__PRINTTAB-SCRIPT <> GD_S__PREVIOUS-SCRIPT OR
       GD_T__PRINTTAB-APPL   <> GD_S__PREVIOUS-APPL.
      IF SY-INDEX > 1.
        GD_V__STRING+0(8) = GD_S__PREVIOUS-CREATE_DATE.
        GD_V__STRING+8(8) = GD_S__PREVIOUS-CREATE_TIME.
        GD_V__TMSTP = GD_V__STRING.
        CONVERT TIME STAMP GD_V__TMSTP TIME ZONE CS_TIME_ZONE  INTO: TIME GD_V__TIME, DATE GD_V__DATE.

        CONCATENATE `Create: `
                    GD_S__PREVIOUS-OWNER ` (`
                    GD_V__DATE+0(4) `.`
                    GD_V__DATE+4(2) `.`
                    GD_V__DATE+6(2) ` `
                    GD_V__TIME+0(2) `:`
                    GD_V__TIME+2(2) `:`
                    GD_V__TIME+4(2) `)`
                    INTO GD_V__CREATE.
        IF GD_T__PRINTTAB-LSTMOD_USER IS NOT INITIAL.
          GD_V__STRING+0(8) = GD_S__PREVIOUS-LSTMOD_DATE.
          GD_V__STRING+8(8) = GD_S__PREVIOUS-LSTMOD_TIME.
          GD_V__TMSTP = GD_V__STRING.
          CONVERT TIME STAMP GD_V__TMSTP TIME ZONE CS_TIME_ZONE  INTO: TIME GD_V__TIME, DATE GD_V__DATE.

          CONCATENATE `Change: `
                      GD_S__PREVIOUS-LSTMOD_USER ` (`
                      GD_V__DATE+0(4) `.`
                      GD_V__DATE+4(2) `.`
                      GD_V__DATE+6(2) ` `
                      GD_V__TIME+0(2) `:`
                      GD_V__TIME+2(2) `:`
                      GD_V__TIME+4(2) `)`
                      INTO GD_V__CHANGE.
          CONCATENATE GD_V__CREATE ` ` GD_V__CHANGE INTO GD_V__FILLINE.
        ELSE.
          GD_V__FILLINE = GD_V__CREATE.
        ENDIF.
        NEW-LINE.
        WRITE
        : GD_V__FILLINE  COLOR COL_KEY RIGHT-JUSTIFIED NO-GAP.

        IF GD_F__EXIT = ABAP_TRUE.
          EXIT.
        ENDIF.
      ENDIF.

      GD_V__SCLO = GD_T__PRINTTAB-SCRIPT.

      NEW-LINE.
      WRITE
      : GD_V__SCLO            COLOR COL_GROUP INTENSIFIED NO-GAP
      , GD_T__PRINTTAB-APPL   COLOR COL_GROUP RIGHT-JUSTIFIED NO-GAP
      , GD_T__PRINTTAB-APPSET COLOR COL_GROUP RIGHT-JUSTIFIED NO-GAP
      .
    ENDIF.

    IF NOT ( GD_T__PRINTTAB-SCRIPT = GD_S__PREVIOUS-SCRIPT AND GD_T__PRINTTAB-NUMLINE = GD_S__PREVIOUS-NUMLINE ).

      GD_V__NUMLINE = GD_T__PRINTTAB-NUMLINE.

      GD_V__LENGTH = GD_T__PRINTTAB-OFFSET + GD_T__PRINTTAB-LENGTH.
      NEW-LINE.

      WRITE
      : GD_V__NUMLINE                                                    COLOR COL_KEY RIGHT-JUSTIFIED
      , GD_T__PRINTTAB-ROWS+0(GD_T__PRINTTAB-OFFSET)                     NO-GAP
      , GD_T__PRINTTAB-ROWS+GD_T__PRINTTAB-OFFSET(GD_T__PRINTTAB-LENGTH) COLOR COL_TOTAL NO-GAP.

      GD_V__ROWS = GD_T__PRINTTAB-ROWS+GD_V__LENGTH.
    ELSE.
      GD_V__OFFSET = GD_T__PRINTTAB-OFFSET - GD_V__LENGTH.
      CHECK NOT GD_V__OFFSET < 0.

      GD_V__LENGTH = GD_T__PRINTTAB-OFFSET + GD_T__PRINTTAB-LENGTH - GD_V__LENGTH.

      WRITE
      : GD_V__ROWS+0(GD_V__OFFSET)                                      NO-GAP
      , GD_V__ROWS+GD_V__OFFSET(GD_T__PRINTTAB-LENGTH)                  COLOR COL_TOTAL HOTSPOT NO-GAP.

      GD_V__ROWS   = GD_V__ROWS+GD_V__LENGTH.
      GD_V__LENGTH = GD_T__PRINTTAB-OFFSET + GD_T__PRINTTAB-LENGTH.
    ENDIF.

    GD_S__PREVIOUS = GD_T__PRINTTAB.

  ENDDO.

*--------------------------------------------------------------------*
* Save to XML File
*--------------------------------------------------------------------*
  IF STFILE = ABAP_TRUE.
    PERFORM SAVE_TO_XML_FILE.
  ENDIF.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  save_to_xml_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAVE_TO_XML_FILE.

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
*&      Form  check_selection
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_SELECTION.

  IF  APPS  IS INITIAL.
    MESSAGE E001(00) WITH 'Please enter BPC APPSET ID'.
  ENDIF.

  IF PATT[] IS INITIAL.
    MESSAGE E001(00) WITH 'Please enter PATTERN'.
  ENDIF.

  IF REGEX = ABAP_TRUE.
    LOOP AT PATT.
      TRY.
          CL_ABAP_MATCHER=>MATCHES(
                    PATTERN = PATT-LOW
                    IGNORE_CASE = `X`
                    TEXT        = PATT-LOW ).

        CATCH CX_SY_REGEX.
          CONCATENATE `Pattern ` '''' patt-low ''''  ` no valid` into gd_v__message.
          message e001(00) with gd_v__message.
      endtry.
    endloop.
  endif.

  if stfile = abap_true.
    locfile  = process_path=>check_path( i_path = locfile  ).
  endif.

endform.                    "check_selection
