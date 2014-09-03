REPORT  Z_EXCEL_XML_DOM_CREATE.TYPE-POOLS: IXML.
TYPES: BEGIN OF XML_LINE,
        DATA(256) TYPE X,
       END OF XML_LINE.
DATA: L_IXML            TYPE REF TO IF_IXML,
L_STREAMFACTORY   TYPE REF TO IF_IXML_STREAM_FACTORY,
L_OSTREAM         TYPE REF TO IF_IXML_OSTREAM,
L_RENDERER        TYPE REF TO IF_IXML_RENDERER,
L_DOCUMENT        TYPE REF TO IF_IXML_DOCUMENT.
DATA:
L_ELEMENT_ROOT    TYPE REF TO IF_IXML_ELEMENT,
NS_ATTRIBUTE      TYPE REF TO IF_IXML_ATTRIBUTE,
R_ELEMENT_PROPERTIES  TYPE REF TO IF_IXML_ELEMENT,
R_ELEMENT         TYPE REF TO IF_IXML_ELEMENT,
R_WORKSHEET       TYPE REF TO IF_IXML_ELEMENT,
R_TABLE           TYPE REF TO IF_IXML_ELEMENT,
R_COLUMN          TYPE REF TO IF_IXML_ELEMENT,
R_ROW             TYPE REF TO IF_IXML_ELEMENT,
R_CELL            TYPE REF TO IF_IXML_ELEMENT,
R_DATA            TYPE REF TO IF_IXML_ELEMENT,
L_VALUE           TYPE STRING,
L_TYPE            TYPE STRING,
L_TEXT(100)       TYPE C,
R_STYLES          TYPE REF TO IF_IXML_ELEMENT,
R_STYLE           TYPE REF TO IF_IXML_ELEMENT,
R_FORMAT          TYPE REF TO IF_IXML_ELEMENT,
NUM_ROWS          TYPE I.
DATA: L_XML_TABLE       TYPE TABLE OF XML_LINE,
L_XML_SIZE        TYPE I,
L_RC              TYPE I.
DATA: LT_SPFLI          TYPE TABLE OF SPFLI.
DATA: L_SPFLI           TYPE SPFLI.
PARAMETERS:
  P_TAB     LIKE DD02L-TABNAME     DEFAULT 'sflight'.
DATA:
DATA_TAB        TYPE REF TO DATA,
GOTSTATE        TYPE  DDGOTSTATE,
DD03P_TAB       TYPE TABLE OF DD03P,
DD03P           TYPE DD03P.
FIELD-SYMBOLS:
<DATA_TAB>       TYPE STANDARD TABLE,
<DATA_LINE>      TYPE ANY,
<FIELD>          TYPE ANY.

START-OF-SELECTION.
  CALL FUNCTION 'DDIF_TABL_GET'
    EXPORTING
      NAME                = P_TAB
*     STATE               = 'A'
      LANGU               = SY-LANGU
    IMPORTING
      GOTSTATE            = GOTSTATE
    TABLES
      DD03P_TAB           = DD03P_TAB
    EXCEPTIONS
      ILLEGAL_INPUT       = 1
      OTHERS              = 2
            .
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSEIF GOTSTATE IS INITIAL.
    WRITE: / 'Table', P_TAB, 'does not exist'.
    EXIT.
  ENDIF.
  CREATE DATA DATA_TAB  TYPE STANDARD TABLE OF (P_TAB).
  ASSIGN DATA_TAB->* TO <DATA_TAB>.  SELECT * FROM (P_TAB) INTO TABLE <DATA_TAB> UP TO 10 ROWS.
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
*  Styles
* <Styles>
*  <Style ss:ID="Default" ss:Name="Normal">
*   <Alignment ss:Vertical="Bottom"/>
*   <Borders/>
*   <Font/>
*   <Interior/>
*   <NumberFormat/>
*   <Protection/>
*  </Style>
*  <Style ss:ID="s21">
*   <NumberFormat ss:Format="@"/>
*  </Style>
*  <Style ss:ID="s22">
*    <NumberFormat ss:Format="Fixed"/>
*  <Style ss:ID="s27">
*   <Alignment ss:Vertical="Bottom" ss:WrapText="1"/>
*   <Font x:Family="Swiss" ss:Bold="1"/>
*   <Interior ss:Color="#FFFF00" ss:Pattern="Solid"/>
*   <NumberFormat ss:Format="@"/>
*  </Style>
  R_STYLES = L_DOCUMENT->CREATE_SIMPLE_ELEMENT(
                   NAME = 'Styles'
                   PARENT = L_ELEMENT_ROOT  ).
* Header row - Yellow, Bold
  R_STYLE  = L_DOCUMENT->CREATE_SIMPLE_ELEMENT(
                    NAME = 'Style'
                    PARENT = R_STYLES  ).
  R_STYLE->SET_ATTRIBUTE_NS(
                    NAME = 'ID'
                    PREFIX = 'ss'
                    VALUE = 'Header' ).
  R_FORMAT  = L_DOCUMENT->CREATE_SIMPLE_ELEMENT(
                    NAME = 'Font'
                    PARENT = R_STYLE  ).
  R_FORMAT->SET_ATTRIBUTE_NS(
                    NAME = 'Bold'
                    PREFIX = 'ss'
                    VALUE = '1' ).
  R_FORMAT  = L_DOCUMENT->CREATE_SIMPLE_ELEMENT(
                    NAME = 'Interior'
                    PARENT = R_STYLE  ).
  R_FORMAT->SET_ATTRIBUTE_NS(
                    NAME = 'Color'
                    PREFIX = 'ss'
                    VALUE = '#FFFF00' ).
  R_FORMAT->SET_ATTRIBUTE_NS(
                    NAME = 'Pattern'
                    PREFIX = 'ss'
                    VALUE = 'Solid' ).
  R_FORMAT  = L_DOCUMENT->CREATE_SIMPLE_ELEMENT(
                    NAME = 'Alignment'
                    PARENT = R_STYLE  ).
  R_FORMAT->SET_ATTRIBUTE_NS(
                    NAME = 'Vertical'
                    PREFIX = 'ss'
                    VALUE = 'Bottom' ).
  R_FORMAT->SET_ATTRIBUTE_NS(
                    NAME = 'WrapText'
                    PREFIX = 'ss'
                    VALUE = '1' ).
  LOOP AT DD03P_TAB INTO DD03P WHERE FIELDNAME <> 'MANDT'.
    CASE DD03P-INTTYPE.
      WHEN 'I' OR 'N'.
*       General format
      WHEN 'P' OR 'F'.
*       Numeric with specific number of decimals
        R_STYLE  = L_DOCUMENT->CREATE_SIMPLE_ELEMENT(
                          NAME = 'Style'
                          PARENT = R_STYLES  ).
        L_VALUE = DD03P-FIELDNAME.
        R_STYLE->SET_ATTRIBUTE_NS(
                          NAME = 'ID'
                          PREFIX = 'ss'
                          VALUE = L_VALUE ).
        R_FORMAT  = L_DOCUMENT->CREATE_SIMPLE_ELEMENT(
                          NAME = 'NumberFormat'
                          PARENT = R_STYLE  ).
        IF DD03P-DECIMALS > 0.
          L_VALUE = '0.'.
          DO DD03P-DECIMALS TIMES.
            CONCATENATE L_VALUE '0' INTO L_VALUE.
          ENDDO.
        ELSE.
          L_VALUE = ''.
        ENDIF.
        R_FORMAT->SET_ATTRIBUTE_NS(
                          NAME = 'Format'
                          PREFIX = 'ss'
                          VALUE = L_VALUE ).
      WHEN OTHERS.
*       Fixed text
        R_STYLE  = L_DOCUMENT->CREATE_SIMPLE_ELEMENT(
                          NAME = 'Style'
                          PARENT = R_STYLES  ).
        L_VALUE = DD03P-FIELDNAME.
        R_STYLE->SET_ATTRIBUTE_NS(
                          NAME = 'ID'
                          PREFIX = 'ss'
                          VALUE = L_VALUE ).
        R_FORMAT  = L_DOCUMENT->CREATE_SIMPLE_ELEMENT(
                          NAME = 'NumberFormat'
                          PARENT = R_STYLE  ).
        L_VALUE = '@'.
        R_FORMAT->SET_ATTRIBUTE_NS(
                          NAME = 'Format'
                          PREFIX = 'ss'
                          VALUE = L_VALUE ).
    ENDCASE.
  ENDLOOP.
*  Worksheet
*  <Worksheet ss:Name="Sheet1">
  R_WORKSHEET = L_DOCUMENT->CREATE_SIMPLE_ELEMENT(
              NAME = 'Worksheet '
              PARENT = L_ELEMENT_ROOT ).
  R_WORKSHEET->SET_ATTRIBUTE_NS(
NAME = 'Name'
PREFIX = 'ss'
VALUE = 'Sheet1' ).
* Table
* <Table ss:ExpandedColumnCount="3" ss:ExpandedRowCount="1" x:FullColumns="1" x:FullRows="1">
  R_TABLE = L_DOCUMENT->CREATE_SIMPLE_ELEMENT(
              NAME = 'Table'
              PARENT = R_WORKSHEET ).
  DESCRIBE TABLE DD03P_TAB LINES NUM_ROWS.
*  l_value = num_rows - 1.
*  r_table->set_attribute_ns(
*                    name = 'ExpandedColumnCount'
*                    PREFIX = 'ss'
*                    value = l_value ).
*
*  describe table <data_tab> lines num_rows.
*  l_value = num_rows." + 1.
*  r_table->set_attribute_ns(
*                    name = 'ExpandedRowCount'
*                    PREFIX = 'ss'
*                    value = l_value ).
  R_TABLE->SET_ATTRIBUTE_NS(
                      NAME = 'FullColumns'
                      PREFIX = 'x'
                      VALUE = '1' ).
  R_TABLE->SET_ATTRIBUTE_NS(
                    NAME = 'FullRows'
                    PREFIX = 'x'
                    VALUE = '1' ).
** Column formatting
  LOOP AT DD03P_TAB INTO DD03P WHERE FIELDNAME <> 'MANDT'.
*   Columnn
*   <Column>
    R_COLUMN = L_DOCUMENT->CREATE_SIMPLE_ELEMENT(
              NAME = 'Column'
              PARENT = R_TABLE ).
    CASE DD03P-INTTYPE.
      WHEN 'I' OR 'N'.
*       General format
      WHEN 'P' OR 'F'.
        L_VALUE = DD03P-FIELDNAME.
        R_COLUMN->SET_ATTRIBUTE_NS(
                          NAME = 'StyleID'
                          PREFIX = 'ss'
                          VALUE = L_VALUE ).
    ENDCASE.
    L_VALUE = ( DD03P-OUTPUTLEN + 5 ) * 5.
    CONDENSE L_VALUE NO-GAPS.
    R_COLUMN->SET_ATTRIBUTE_NS(
                      NAME = 'Width'
                      PREFIX = 'ss'
                      VALUE = L_VALUE ).
*    r_column->set_attribute_ns(
*                      name = 'AutoFitWidth'
*                      PREFIX = 'ss'
*                      value = '1' ).
*
  ENDLOOP.
* Column headers
*   Row
*   <Row>
  R_ROW = L_DOCUMENT->CREATE_SIMPLE_ELEMENT(
            NAME = 'Row'
            PARENT = R_TABLE ).
  R_ROW->SET_ATTRIBUTE_NS(
                    NAME = 'StyleID'
                    PREFIX = 'ss'
                    VALUE = 'Header' ).
  R_ROW->SET_ATTRIBUTE_NS(
                    NAME = 'AutoFitHeight'
                    PREFIX = 'ss'
                    VALUE = '1' ).
*  r_row->set_attribute_ns(
*                    name = 'Height'
*                    PREFIX = 'ss'
*                    value = '40' ).  LOOP AT dd03p_tab INTO dd03p WHERE fieldname <> 'MANDT'.
*     <Data>
  R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT(
            NAME = 'Cell'
            PARENT = R_ROW ).
  L_VALUE = DD03P-DDTEXT.    "fieldname, scrtext_m etc.
  R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT(
            NAME = 'Data'
            VALUE = L_VALUE
            PARENT = R_CELL ).
  R_DATA->SET_ATTRIBUTE_NS(
                    NAME = 'Type'
                    PREFIX = 'ss'
                    VALUE = 'String' ).  "endloop.
* Finally loop at the data table and output the fields
  LOOP AT <DATA_TAB> ASSIGNING <DATA_LINE>.
*   Row
*   <Row>
    R_ROW = L_DOCUMENT->CREATE_SIMPLE_ELEMENT(
              NAME = 'Row'
              PARENT = R_TABLE ).
    LOOP AT DD03P_TAB INTO DD03P WHERE FIELDNAME <> 'MANDT'.
      ASSIGN COMPONENT DD03P-FIELDNAME OF STRUCTURE <DATA_LINE> TO <FIELD>.
      CHECK SY-SUBRC IS INITIAL.
*     <Cell>
      R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT(
                NAME = 'Cell'
                PARENT = R_ROW ).
      CASE DD03P-INTTYPE.
        WHEN 'I' OR 'P' OR 'F' OR 'N'.
          L_TYPE = 'Number'.
          L_VALUE = <FIELD>.
          CONDENSE L_VALUE NO-GAPS.
        WHEN 'D' OR 'T'.
          L_TYPE = 'String'.
          WRITE <FIELD> TO L_TEXT.
          L_VALUE = L_TEXT.
        WHEN OTHERS.
*          l_value = <field>.    "Without conversion exit
          WRITE <FIELD> TO L_TEXT.
          SHIFT L_TEXT LEFT DELETING LEADING SPACE.
          L_VALUE = L_TEXT.
          L_TYPE = 'String'.
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
*    l_ostream->GET_PRETTY_PRINT( ).

*   Saving the XML document
  L_XML_SIZE = L_OSTREAM->GET_NUM_WRITTEN_RAW( ).

DATA STR(256) TYPE C VALUE `<DATA>ываыа</DATA>`.
DATA X TYPE XML_LINE.

MOVE STR TO X-DATA.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
    EXPORTING
      BIN_FILESIZE = L_XML_SIZE
      FILENAME     = 'C:\xml\flights.xml'
      FILETYPE     = 'BIN'
    CHANGING
      DATA_TAB     = L_XML_TABLE
    EXCEPTIONS
      OTHERS       = 24.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
