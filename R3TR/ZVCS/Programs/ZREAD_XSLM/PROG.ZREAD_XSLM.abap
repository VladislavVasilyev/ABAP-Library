*&---------------------------------------------------------------------*
*& Report  ZREAD_XSLM
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZREAD_XSLM.
TYPE-POOLS: OLE2 .
PARAMETERS: FILENAME  LIKE  RLGRAP-FILENAME,
            I_STR_C TYPE  I,
            I_STR_R TYPE  I,
            I_END_C TYPE  I,
            I_END_R TYPE  I.

TYPES:       BEGIN OF TY_S_SENDERLINE,
         LINE(4096)               TYPE C,
       END OF TY_S_SENDERLINE,

       TY_T_SENDER                TYPE TY_S_SENDERLINE  OCCURS 0.
DATA: EXCEL_TAB     TYPE  TY_T_SENDER.
DATA: LD_SEPARATOR  TYPE  C.
DATA: APPLICATION   TYPE  OLE2_OBJECT,
      WORKBOOK      TYPE  OLE2_OBJECT,
      RANGE         TYPE  OLE2_OBJECT,
      WORKSHEET     TYPE  OLE2_OBJECT.
DATA: H_CELL        TYPE  OLE2_OBJECT,
      H_CELL1       TYPE  OLE2_OBJECT.
DATA: LD_RC         TYPE  I.
DATA: ER_DATA TYPE REF TO  DATA.

DATA: LO_FIELD_TYPE TYPE REF TO CL_ABAP_DATADESCR.
DATA: LT_COLUMNS TYPE TABLE OF STRING.
DATA: LO_DATAREF TYPE REF TO DATA.
DATA: LT_COMPONENTS TYPE ABAP_COMPONENT_TAB.
DATA: LT_COLUMN_DATA TYPE TABLE OF STRING.
DATA: LO_STRUCT_DESCR TYPE REF TO CL_ABAP_STRUCTDESCR.
FIELD-SYMBOLS: <LS_DATA> TYPE ANY.
FIELD-SYMBOLS: <LT_DATA_EX> TYPE STANDARD TABLE.
FIELD-SYMBOLS: <LV_LINE> TYPE ANY.
FIELD-SYMBOLS: <LS_COLUMNS> TYPE STRING.
FIELD-SYMBOLS: <LV_DATA_FIELD> TYPE ANY.
FIELD-SYMBOLS: <LS_DATA_STRUCT> TYPE ANY.
FIELD-SYMBOLS: <LT_DATA_STRUCT> TYPE STANDARD TABLE.
FIELD-SYMBOLS: <LS_COLUMN_DATA> TYPE ANY.
FIELD-SYMBOLS: <LS_COMPONENTS> TYPE ABAP_COMPONENTDESCR.


DEFINE M_MESSAGE.
  CASE SY-SUBRC.
    WHEN 0.
    WHEN 1.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    WHEN OTHERS. RAISE UPLOAD_OLE.
  ENDCASE.
END-OF-DEFINITION.


IF I_STR_R > I_END_R. RAISE INCONSISTENT_PARAMETERS. ENDIF.
IF I_STR_C > I_END_C. RAISE INCONSISTENT_PARAMETERS. ENDIF.


CLASS CL_ABAP_CHAR_UTILITIES DEFINITION LOAD.
LD_SEPARATOR = CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB.


IF APPLICATION-HEADER = SPACE OR APPLICATION-HANDLE = -1.
  CREATE OBJECT APPLICATION 'Excel.Application'.
  M_MESSAGE.
ENDIF.
CALL METHOD OF
    APPLICATION
    'Workbooks' = WORKBOOK.
M_MESSAGE.
CALL METHOD OF
    WORKBOOK
    'Open'

  EXPORTING
    #1       = FILENAME.
M_MESSAGE.

GET PROPERTY OF  APPLICATION 'ACTIVESHEET' = WORKSHEET.
M_MESSAGE.


CALL METHOD OF
    WORKSHEET
    'Cells'   = H_CELL
  EXPORTING
    #1        = I_STR_R
    #2        = I_STR_C.
M_MESSAGE.
CALL METHOD OF
    WORKSHEET
    'Cells'   = H_CELL1
  EXPORTING
    #1        = I_END_R
    #2        = I_END_C.
M_MESSAGE.

CALL METHOD OF
    WORKSHEET
    'RANGE'   = RANGE
  EXPORTING
    #1        = H_CELL
    #2        = H_CELL1.
M_MESSAGE.
CALL METHOD OF
    RANGE
    'SELECT'.
M_MESSAGE.


CALL METHOD OF
    RANGE
    'COPY'.
M_MESSAGE.


CALL METHOD CL_GUI_FRONTEND_SERVICES=>CLIPBOARD_IMPORT
  IMPORTING
    DATA                 = EXCEL_TAB
  EXCEPTIONS
    CNTL_ERROR           = 1
*   ERROR_NO_GUI         = 2
*   NOT_SUPPORTED_BY_GUI = 3
    OTHERS               = 4.
*  IF sy-subrc <> 0.
*  MESSAGE a037(alsmex).
* ENDIF.

CREATE DATA LO_DATAREF LIKE LINE OF EXCEL_TAB.
ASSIGN LO_DATAREF->* TO <LS_DATA>.

READ TABLE EXCEL_TAB ASSIGNING <LS_DATA> INDEX 1.
IF SY-SUBRC = 0.
  ASSIGN COMPONENT `LINE` OF STRUCTURE <LS_DATA> TO <LV_LINE>.
  SPLIT <LV_LINE> AT CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB INTO TABLE LT_COLUMNS.
*    APPEND <ls_data> TO <lt_data_ex>.
  DELETE EXCEL_TAB INDEX 1.
ENDIF.

LO_FIELD_TYPE ?=
CL_ABAP_DATADESCR=>DESCRIBE_BY_NAME( `UJ_LARGE_STRING` ).

LOOP AT LT_COLUMNS ASSIGNING <LS_COLUMNS>.
  APPEND INITIAL LINE TO LT_COMPONENTS ASSIGNING <LS_COMPONENTS>.
  <LS_COMPONENTS>-NAME = <LS_COLUMNS>.
  <LS_COMPONENTS>-TYPE = LO_FIELD_TYPE.
ENDLOOP.



LO_STRUCT_DESCR =
CL_ABAP_STRUCTDESCR=>CREATE(
P_COMPONENTS = LT_COMPONENTS
P_STRICT = ABAP_FALSE ).


CREATE DATA LO_DATAREF TYPE HANDLE LO_STRUCT_DESCR.
ASSIGN LO_DATAREF->* TO <LS_DATA_STRUCT> .


CREATE DATA LO_DATAREF LIKE TABLE OF <LS_DATA_STRUCT> .
ASSIGN LO_DATAREF->* TO <LT_DATA_STRUCT>.


CREATE DATA LO_DATAREF LIKE LINE OF EXCEL_TAB.
ASSIGN LO_DATAREF->* TO <LS_DATA>.
LOOP AT EXCEL_TAB ASSIGNING <LS_DATA>.
  APPEND INITIAL LINE TO <LT_DATA_STRUCT> ASSIGNING <LS_DATA_STRUCT>.
  ASSIGN COMPONENT `LINE` OF STRUCTURE <LS_DATA> TO <LV_LINE>.
  SPLIT <LV_LINE> AT CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB INTO TABLE LT_COLUMN_DATA.
  LOOP AT LT_COLUMN_DATA ASSIGNING <LS_COLUMN_DATA>.
    ASSIGN COMPONENT SY-TABIX
    OF STRUCTURE <LS_DATA_STRUCT> TO <LV_DATA_FIELD>.
    IF SY-SUBRC <> 0.
      CONTINUE.
    ENDIF.
    <LV_DATA_FIELD> = <LS_COLUMN_DATA>.
  ENDLOOP.
ENDLOOP.
GET REFERENCE OF <LT_DATA_STRUCT> INTO ER_DATA.

REFRESH EXCEL_TAB.
CALL METHOD CL_GUI_FRONTEND_SERVICES=>CLIPBOARD_EXPORT
  IMPORTING
    DATA                 = EXCEL_TAB
  CHANGING
    RC                   = LD_RC
  EXCEPTIONS
    CNTL_ERROR           = 1
*   ERROR_NO_GUI         = 2
*   NOT_SUPPORTED_BY_GUI = 3
    OTHERS               = 4.

CALL METHOD OF
    APPLICATION
    'QUIT'.
M_MESSAGE.


FREE OBJECT H_CELL.       M_MESSAGE.
FREE OBJECT H_CELL1.      M_MESSAGE.
FREE OBJECT RANGE.        M_MESSAGE.
FREE OBJECT WORKSHEET.    M_MESSAGE.
FREE OBJECT WORKBOOK.     M_MESSAGE.
FREE OBJECT APPLICATION.  M_MESSAGE.
