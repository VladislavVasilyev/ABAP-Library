*&---------------------------------------------------------------------*
*& Report  ZTEST_DIMENSION
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZTEST_DIMENSION.

DATA GR_O__DIMFILES     TYPE REF TO CL_UJA_DIM_FILES.
DATA GR_O__DIM          TYPE REF TO CL_UJA_DIM.

DATA ET_LOGIC_FILE_NAME	TYPE UJK_T_DOC_NAME.
DATA ES_ITAB            TYPE UJ0_S_ITAB.

DATA E_XML              TYPE XSTRING.
DATA E_OPT_FILE	        TYPE XSTRING.
DATA EF_SUCCESS	        TYPE UJ_FLG.



CREATE OBJECT GR_O__DIMFILES
  EXPORTING
    I_APPSET_ID = `DEMO`
    I_DIMENSION = `CURRENCY`.

*call method gr_o__dimfiles->read_dim_mbr_data
*  importing
*    et_logic_file_name = et_logic_file_name
*    es_itab            = es_itab
*    ef_success         = ef_success.

BREAK-POINT.

*create object gr_o__dim
*  exporting
*    i_appset_id = `BUDGET_2014`
*    i_dimension = `CURRENCY`.



DATA IF_XML  TYPE UJ_FLG."  default space
DATA IF_XLS  TYPE UJ_FLG."  default space
DATA IF_XLT  TYPE UJ_FLG."  default space
DATA E_DIM_ZIP  TYPE UJ_DOC_CONTENT.
*data ef_success  type uj_flg
DATA ET_MESSAGE_LINES  TYPE UJ0_T_MESSAGE.
DATA LD_S__UJF_DOC_XLS TYPE UJF_DOC.
DATA CONTENT        TYPE STANDARD TABLE OF X255 WITH NON-UNIQUE DEFAULT KEY.
DATA LENGTH TYPE I.
DATA A TYPE I.
DATA XLS  TYPE UJF_DOC-DOC_CONTENT.
DATA DELTAPROPERTY  TYPE UJF_DOC-DOC_CONTENT.
DATA DELTASEQUENCE  TYPE UJF_DOC-DOC_CONTENT.


BREAK-POINT.
IF A = 1.
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_UPLOAD
    EXPORTING
      FILENAME   = `c:\test\CURRENCY.xls`
      FILETYPE   = `BIN`
    IMPORTING
      FILELENGTH = LENGTH
    CHANGING
      DATA_TAB   = CONTENT
    EXCEPTIONS
      OTHERS     = 24.

  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
  EXPORTING
  INPUT_LENGTH       = LENGTH
*   FIRST_LINE         = 0
*   LAST_LINE          = 0
   IMPORTING
     BUFFER             = XLS
    TABLES
      BINARY_TAB         = CONTENT.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_UPLOAD
    EXPORTING
      FILENAME   = `c:\test\DELTAPROPERTY.SCV`
      FILETYPE   = `BIN`
    IMPORTING
      FILELENGTH = LENGTH
    CHANGING
      DATA_TAB   = CONTENT
    EXCEPTIONS
      OTHERS     = 24.

  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
   EXPORTING
   INPUT_LENGTH       = LENGTH
*   FIRST_LINE         = 0
*   LAST_LINE          = 0
    IMPORTING
      BUFFER             = DELTAPROPERTY
     TABLES
       BINARY_TAB         = CONTENT.



  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_UPLOAD
    EXPORTING
      FILENAME   = `c:\test\DELTASEQUENCE.SCV`
      FILETYPE   = `BIN`
    IMPORTING
      FILELENGTH = LENGTH
    CHANGING
      DATA_TAB   = CONTENT
    EXCEPTIONS
      OTHERS     = 24.

  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
   EXPORTING
   INPUT_LENGTH       = LENGTH
*   FIRST_LINE         = 0
*   LAST_LINE          = 0
    IMPORTING
      BUFFER             = DELTASEQUENCE
     TABLES
       BINARY_TAB         = CONTENT.

  DATA LR_O_DIM      TYPE REF TO CL_UJA_DIM.
  DATA LR_I__CONTEXT TYPE REF TO IF_UJ_CONTEXT.

  DATA IS_USER  TYPE UJ0_S_USER.

  IS_USER-USER_ID = `X5`.

  CL_UJ_CONTEXT=>SET_CUR_CONTEXT(
  I_APPSET_ID = `DEMO`
  IS_USER     = IS_USER
*    i_appl_id   = gt_cur_context-context->d_appl_id
  ).

  LR_I__CONTEXT ?= CL_UJ_CONTEXT=>GET_CUR_CONTEXT( ).

  LR_I__CONTEXT->SWITCH_TO_SRVADMIN( ).


  CREATE OBJECT LR_O_DIM
    EXPORTING
      I_APPSET_ID = `DEMO`
      I_DIMENSION = `CURRENCY`.


  CALL METHOD LR_O_DIM->SAVE_DIM_FILES
    EXPORTING
      I_XLS           = XLS
      I_DELTA_MEMBER  = DELTAPROPERTY
      I_DELTA_MBR_SEQ = DELTASEQUENCE.

  COMMIT WORK.

  LR_O_DIM->PROCESS_DIMENSION( ).

  RETURN.
ENDIF.

*call method gr_o__dimfiles->get_zip_file
*  exporting
*    if_xlt           = abap_true
*  importing
*    e_dim_zip        = e_dim_zip
*    ef_success       = ef_success
*    et_message_lines = et_message_lines.





*gr_o__dimfiles->SAVE_DIM_FILES( i ).

" copy dimension's files
*if_xls
*if_xlt
*if_xml

*create object gr_o__dim
*  exporting
*    i_appset_id = `DEMO`
*    i_dimension = `CURRENCY`.
*
*
**gr_o__dim->update_dim_versions( ).
*
**gr_o__dimfiles->copy_dim_files(  i_des_appset_id = `DEMO`
**                                 i_des_dimension = `CURRENCY`  ).
*
*
**gr_o__dim->save_dim_files( ).
**gr_o__dim->update_dim_versions( ).
*
*
**gr_o__dimfiles->read_dim_file( exporting i_file_name = `\ROOT\WEBFOLDERS\DEMO\ADMINAPP\CURRENCY.XLS` importing e_content = e_dim_zip  ).
*
*
*
*
*
*gr_o__dim->process_dimension( ).

*save_dim_files( ).

COMMIT WORK.



SELECT  SINGLE DOC_CONTENT
  FROM  UJF_DOC
  INTO  E_DIM_ZIP
  WHERE DOCNAME = `\ROOT\WEBFOLDERS\BUDGET_2014\ADMINAPP\CURRENCY.XLS`.


IF SY-SUBRC = 0.
  DATA    LT_DATA TYPE STANDARD TABLE OF X255.
  DATA    LV_FILE_LENGTH TYPE I.

  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      BUFFER        = E_DIM_ZIP
    IMPORTING
      OUTPUT_LENGTH = LV_FILE_LENGTH
    TABLES
      BINARY_TAB    = LT_DATA.


  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
    EXPORTING
      BIN_FILESIZE = LV_FILE_LENGTH
      FILENAME     = `c:\test\CURRENCY.xls`
      FILETYPE     = 'BIN'
    CHANGING
      DATA_TAB     = LT_DATA "l_xml_table
    EXCEPTIONS
      OTHERS       = 24.
ENDIF.

SELECT  SINGLE DOC_CONTENT
  FROM  UJF_DOC
  INTO  E_DIM_ZIP
  WHERE DOCNAME = `\ROOT\WEBFOLDERS\BUDGET_2014\ADMINAPP\CURRENCY.XLT`.

IF SY-SUBRC = 0.
  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      BUFFER        = E_DIM_ZIP
    IMPORTING
      OUTPUT_LENGTH = LV_FILE_LENGTH
    TABLES
      BINARY_TAB    = LT_DATA.


  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
    EXPORTING
      BIN_FILESIZE = LV_FILE_LENGTH
      FILENAME     = `c:\test\CURRENCY.xlt`
      FILETYPE     = 'BIN'
    CHANGING
      DATA_TAB     = LT_DATA "l_xml_table
    EXCEPTIONS
      OTHERS       = 24.
ENDIF.

SELECT  SINGLE DOC_CONTENT
  FROM  UJF_DOC
  INTO  E_DIM_ZIP
  WHERE DOCNAME = `\ROOT\WEBFOLDERS\BUDGET_2014\ADMINAPP\CURRENCYDELTAPROPERTY.CSV`.

IF SY-SUBRC = 0.
  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      BUFFER        = E_DIM_ZIP
    IMPORTING
      OUTPUT_LENGTH = LV_FILE_LENGTH
    TABLES
      BINARY_TAB    = LT_DATA.

DATA L_STRING TYPE STRING.

  CALL FUNCTION 'SCMS_BINARY_TO_STRING'
    EXPORTING
      INPUT_LENGTH = LV_FILE_LENGTH
      ENCODING     = '4103'
    IMPORTING
      TEXT_BUFFER  = L_STRING
    TABLES
      BINARY_TAB   = LT_DATA.


  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
    EXPORTING
      BIN_FILESIZE = LV_FILE_LENGTH
      FILENAME     = `c:\test\DELTAPROPERTY.SCV`
      FILETYPE     = 'BIN'
    CHANGING
      DATA_TAB     = LT_DATA "l_xml_table
    EXCEPTIONS
      OTHERS       = 24.

ENDIF.

SELECT  SINGLE DOC_CONTENT
  FROM  UJF_DOC
  INTO  E_DIM_ZIP
  WHERE DOCNAME = `\ROOT\WEBFOLDERS\BUDGET_2014\ADMINAPP\CURRENCYDELTASEQUENCE.CSV`.

IF SY-SUBRC = 0.
  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      BUFFER        = E_DIM_ZIP
    IMPORTING
      OUTPUT_LENGTH = LV_FILE_LENGTH
    TABLES
      BINARY_TAB    = LT_DATA.


  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
    EXPORTING
      BIN_FILESIZE = LV_FILE_LENGTH
      FILENAME     = `c:\test\DELTASEQUENCE.SCV`
      FILETYPE     = 'BIN'
    CHANGING
      DATA_TAB     = LT_DATA "l_xml_table
    EXCEPTIONS
      OTHERS       = 24.

ENDIF.


SELECT  SINGLE DOC_CONTENT
  FROM  UJF_DOC
  INTO  E_DIM_ZIP
  WHERE DOCNAME = `\ROOT\WEBFOLDERS\BUDGET_2014\ADMINAPP\CURRENCYOPTIONS.XML`.

IF SY-SUBRC = 0.
  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      BUFFER        = E_DIM_ZIP
    IMPORTING
      OUTPUT_LENGTH = LV_FILE_LENGTH
    TABLES
      BINARY_TAB    = LT_DATA.


  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
    EXPORTING
      BIN_FILESIZE = LV_FILE_LENGTH
      FILENAME     = `c:\test\CURRENCY.XML`
      FILETYPE     = 'BIN'
    CHANGING
      DATA_TAB     = LT_DATA "l_xml_table
    EXCEPTIONS
      OTHERS       = 24.
ENDIF.


SELECT  SINGLE DOC_CONTENT
  FROM  UJF_DOC
  INTO  E_DIM_ZIP
  WHERE DOCNAME = `\ROOT\WEBFOLDERS\BUDGET_2014\ADMINAPP\CURRENCYDELTAHIERARCHY.CSV`.

IF SY-SUBRC = 0.
  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      BUFFER        = E_DIM_ZIP
    IMPORTING
      OUTPUT_LENGTH = LV_FILE_LENGTH
    TABLES
      BINARY_TAB    = LT_DATA.


  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
    EXPORTING
      BIN_FILESIZE = LV_FILE_LENGTH
      FILENAME     = `c:\test\CURRENCYDELTAHIERARCHY.CSV`
      FILETYPE     = 'BIN'
    CHANGING
      DATA_TAB     = LT_DATA "l_xml_table
    EXCEPTIONS
      OTHERS       = 24.
ENDIF.







BREAK-POINT.