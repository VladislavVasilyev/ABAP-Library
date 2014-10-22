*&---------------------------------------------------------------------*
*& report  zpr_bpc_load_dim
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT  ZPR_BPC_LOAD_DIM1.
TYPE-POOLS: ABAP, VRM, ZVCST.

TABLES
: UJA_APPSET_INFO
, UJA_APPL
.

*----------------------------------------------------------------------*
*       CLASS lcx_except  DEFINITIO
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS LCX_EXCEPT DEFINITION
  INHERITING FROM CX_STATIC_CHECK
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    DATA MESSAGE TYPE STRING.
    METHODS CONSTRUCTOR
      IMPORTING
        !TEXTID   LIKE TEXTID OPTIONAL
        !PREVIOUS LIKE PREVIOUS OPTIONAL
        !MESS     TYPE STRING OPTIONAL.
    METHODS IF_MESSAGE~GET_TEXT REDEFINITION.

ENDCLASS.                    "lcx_except  DEFINITIO
*----------------------------------------------------------------------*
*       CLASS lcx_except IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS LCX_EXCEPT IMPLEMENTATION.
  METHOD CONSTRUCTOR.
    CALL METHOD SUPER->CONSTRUCTOR
      EXPORTING
        TEXTID   = TEXTID
        PREVIOUS = PREVIOUS.
    MESSAGE = MESS.
  ENDMETHOD.                    "constructor
  METHOD IF_MESSAGE~GET_TEXT.
    RESULT = MESSAGE.
  ENDMETHOD.                    "if_message~get_text
ENDCLASS.                    "lcx_except IMPLEMENTATION
*----------------------------------------------------------------------*
*       CLASS lcl_application DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS LCL_APPLICATION DEFINITION FINAL.
  PUBLIC SECTION.

    CONSTANTS: LC_COMMA TYPE CHAR01 VALUE `;`,
               LC_PIPE  TYPE CHAR01 VALUE `|`,
               LC_TAB   TYPE CHAR01 VALUE `T`.

    CLASS-DATA
    : LV_DELIMITER TYPE CHAR01 READ-ONLY
    , LV_LANG      TYPE CHAR2 READ-ONLY
    .

    CLASS-METHODS
    : GET_INITIAL_DIRECTORY RETURNING VALUE(R_PATH) TYPE STRING
    , SET_DELIMITER_LISTBOX
    , SET_DELIMITER
    , SET_LANG
    , SET_LANG_LISTBOX
    , FILE_F4 RETURNING VALUE(R_FILE) TYPE STRING
    , DIRECTORY_F4 RETURNING VALUE(R_PATH) TYPE STRING
    , UPLOAD IMPORTING I_FILEPATH TYPE ANY
             RETURNING VALUE(RT_STRTAB) TYPE STRINGTAB
    .

ENDCLASS.                    "lcl_application DEFINITION
*----------------------------------------------------------------------*
*       CLASS LCL_CHOOSE DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS LCL_CHOOSE  DEFINITION FINAL.

  PUBLIC SECTION.
    CLASS-METHODS
    : CHOOSE IMPORTING I_V__FORM_NAME TYPE STRING
             CHANGING  I_T__DIM       TYPE ZVCST_T__SOURCE
    .

ENDCLASS.                    "lcl_choose DEFINITION

DEFINE STATUS_BAR>.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      TEXT       = &1
      PERCENTAGE = &2.
END-OF-DEFINITION.

TYPE-POOLS: ABAP, ZBPCT, UJA00, UJ00.
INCLUDE ZBPC_TECHCS.
TABLES UJA_DIMENSION.
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B0 WITH FRAME TITLE M_TITLE.
PARAMETERS: UPLOAD RADIOBUTTON GROUP SASY DEFAULT 'X' USER-COMMAND SYN.
PARAMETERS: LOAD   RADIOBUTTON GROUP SASY .
SELECTION-SCREEN END OF BLOCK B0.

SELECTION-SCREEN BEGIN OF  BLOCK B4 WITH FRAME TITLE B4_TITLE.
PARAMETERS: P_APPSET TYPE UJA_APPSET_INFO-APPSET_ID MODIF ID B4.
PARAMETERS: P_FILE TYPE STRING LOWER CASE MODIF ID B4.
PARAMETERS: LANG  TYPE CHAR2 AS LISTBOX VISIBLE LENGTH 5
                       DEFAULT `EN`
                       MODIF ID B4.  "delimiter
PARAMETERS: SWITCHST TYPE RS_BOOL MODIF ID B3.
SELECTION-SCREEN END OF BLOCK B4.

INITIALIZATION.

  P_FILE = LCL_APPLICATION=>GET_INITIAL_DIRECTORY( ).

  CASE SY-LANGU.
    WHEN `E`.
      LANG = `EN`.
    WHEN `R`.
      LANG = `RU`.
  ENDCASE.

  LCL_APPLICATION=>SET_LANG_LISTBOX( ).

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    CASE ABAP_TRUE.
      WHEN UPLOAD.
        CASE SCREEN-GROUP1.
          WHEN 'B3' OR 'B31' OR 'B32' OR 'B33'.
            SCREEN-ACTIVE  = '0'.
        ENDCASE.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.

  M_TITLE       = 'Режим работы'.

  CASE ABAP_TRUE.
    WHEN LOAD.    B4_TITLE = 'Загрузить мастер-данные из файла'.
    WHEN UPLOAD.  B4_TITLE = 'Выгрузить мастер-данные в файл'.
  ENDCASE.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  CASE ABAP_TRUE.
    WHEN UPLOAD.  P_FILE = LCL_APPLICATION=>DIRECTORY_F4( ).
    WHEN LOAD.    P_FILE = LCL_APPLICATION=>FILE_F4( ).
  ENDCASE.

*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
START-OF-SELECTION.
  TYPES
  : BEGIN OF TY_S_DIM
    , DIMN_VAL      TYPE /BIC/OIZBDIMNVAL
    , ATTRIBUTE     TYPE /BIC/OIZBATTRID
    , ATTR_VAL      TYPE C LENGTH 255
    , END   OF TY_S_DIM
  , BEGIN OF TY_S_SCR
    , ID            TYPE C LENGTH 20
    , LANGU         TYPE C LENGTH 1
    , EVDESCRIPTION TYPE C LENGTH 60
    , END OF TY_S_SCR
  .

  DATA
  : LCX_ERROR             TYPE REF TO CX_ROOT
  , LV_ERROR              TYPE STRING
  , LV_ST_IOBJ            TYPE ABAP_BOOL
  , LT_DIMENSION_LIST     TYPE ZBPCT_T_UJ_DIM_NAME WITH HEADER LINE
  , LV_UPDATE_MODE        TYPE ZBPCT_TY_MODE
  , LV_MESSAGE            TYPE STRING
  , TEXTID                TYPE TEXTID
  , LV_TIME               TYPE STRING
  , LO_EXCEPT             TYPE REF TO CX_ROOT
  , BEGIN OF LS_LIST_ERROR
    , APPSET_ID           TYPE UJ_APPSET_ID
    , DIM_NAME            LIKE LINE OF LT_DIMENSION_LIST
    , T_MESSAGE           TYPE UJ0_T_MESSAGE
    , F_DEL_FORMULA       TYPE UJ_FLG
    , F_SUCCESS           TYPE UJ_FLG
    , SUBRC               TYPE I
    , END OF LS_LIST_ERROR
  , LT_LIST_ERROR         LIKE STANDARD TABLE OF LS_LIST_ERROR WITH HEADER LINE
  , EF_SUCCESS               TYPE UJ_FLG
*  , ef_del_formula           type uj_flg
*  , lt_list_with_del_formula type zbpct_t_uj_dim_name with header line
  , ET_MESSAGE               TYPE UJ0_T_MESSAGE
  , LS_MESSAGE               LIKE LINE OF ET_MESSAGE
  , STATE                    LIKE SY-SUBRC
*  , ld_t__strtab             type stringtab
*  , ld_s__strtab             type string
  , LR_O__MBR_DATA            TYPE REF TO CL_UJA_DIM
  , LD_V__DIMENSION           TYPE UJ_DIM_NAME
  , LD_T__WORKSHEET           TYPE ZVCST_T__XMLWORKSHEET
  , LD_S__WORKSHEET           TYPE ZVCST_S__XMLWORKSHEET
  , LD_T__WORKSHEETS          TYPE ZVCST_T__SOURCE
  , LD_T__SEQ_FILED           TYPE ZVCST_T__SOURCE
  , LD_S__WORKSHEETS          TYPE ZVCST_S__SOURCE
  , LR_O__ADMIN_MGR           TYPE REF TO CL_UJA_ADMIN_MGR
  , IT_DIM_LIST               TYPE UJA_T_DIM_NAME
  , IS_DIM_LIST               TYPE UJA_S_DIM_NAME
  , E_SUCCESS                 TYPE UJ_FLG
  , ET_DIM_FILE_VERSION       TYPE UJA_T_DIM_FILE_VERSION
  , UXML                      TYPE REF TO ZCL_EXCEL_XML_UPLOAD
  , LD_T__DIMENSION           TYPE STANDARD TABLE OF UJA_DIMENSION
  , LD_S__DIMENSION           TYPE UJA_DIMENSION
  , LR_O__STRUCTDESCR         TYPE REF TO CL_ABAP_STRUCTDESCR
  , LD_V__STATUS_MESS         TYPE STRING
  .

  FIELD-SYMBOLS
  : <LD_T__DATA>          TYPE ANY TABLE
  , <LD_S__WORKSHEET>     TYPE ZVCST_S__XMLWORKSHEET
  .
  ZCL_DEBUG=>BREAK_POINT( ).

  LCL_APPLICATION=>SET_LANG( ).

  TRY.
*--------------------------------------------------------------------*
* check setting
*--------------------------------------------------------------------*
      IF P_APPSET IS INITIAL.
        RAISE EXCEPTION TYPE LCX_EXCEPT
          EXPORTING MESS = 'Не указан один или несколько параметров'.
      ENDIF.

*--------------------------------------------------------------------*
* Установка контекста
*--------------------------------------------------------------------*
      DATA
      : LD_S__BPC_USER TYPE UJ0_S_USER
      , LR_I__CONTEXT  TYPE REF TO IF_UJ_CONTEXT
      , LD_V__LANGSAVE TYPE SY-LANGU
      .

      LD_V__LANGSAVE = SY-LANGU.
      SY-LANGU       = LANG.

      LD_S__BPC_USER-USER_ID = `X5`.

      CALL METHOD CL_UJ_CONTEXT=>SET_CUR_CONTEXT
        EXPORTING
          I_APPSET_ID = P_APPSET
          IS_USER     = LD_S__BPC_USER.

      LR_I__CONTEXT ?= CL_UJ_CONTEXT=>GET_CUR_CONTEXT( ).
      LR_I__CONTEXT->SWITCH_TO_SRVADMIN( ).
      LD_S__BPC_USER = LR_I__CONTEXT->DS_USER.

      CREATE OBJECT LR_O__ADMIN_MGR
        EXPORTING
          I_APPSET_ID = P_APPSET.

      SY-LANGU = LD_V__LANGSAVE.

*--------------------------------------------------------------------*
* run program
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
* Download
*--------------------------------------------------------------------*
      CASE ABAP_TRUE.
        WHEN LOAD.

          IF SWITCHST = ABAP_TRUE.

            CONCATENATE `Набор приложений не доступен. В связи с обновлением измерений. BP пользователь ` SY-UNAME `.`  INTO LD_V__STATUS_MESS.

            CALL METHOD LR_O__ADMIN_MGR->SET_APPSET_STATUS
              EXPORTING
                IS_USER     = LD_S__BPC_USER
                I_IS_ONLINE = ABAP_FALSE
                I_MESSAGE   = LD_V__STATUS_MESS
              IMPORTING
                E_SUCCESS   = E_SUCCESS.

            CALL FUNCTION 'DB_COMMIT'.
          ENDIF.

          CREATE OBJECT UXML.
          UXML->UPLOAD_FROM_PC( P_FILE ).
          LD_T__WORKSHEETS = UXML->GET_WORKSHEETS( ).

          CALL METHOD LCL_CHOOSE=>CHOOSE
            EXPORTING
              I_V__FORM_NAME = `CHOOSE_DOWNLOAD`
            CHANGING
              I_T__DIM       = LD_T__WORKSHEETS.

          CHECK LD_T__WORKSHEETS IS NOT INITIAL.

          LOOP AT LD_T__WORKSHEETS INTO LD_S__WORKSHEET-NAME.
            APPEND LD_S__WORKSHEET TO LD_T__WORKSHEET.
          ENDLOOP.

          CALL METHOD UXML->PRINT_WORKBOOK
            CHANGING
              I_T__WORKSHEET = LD_T__WORKSHEET.

          DATA LD_S__USER_DEF_FOR_MOD TYPE UJA_USER_DEF.
          DATA LD_T__USER_DEF         TYPE UJA_USER_DEF.


          LOOP AT LD_T__WORKSHEET ASSIGNING <LD_S__WORKSHEET>.
            LD_V__DIMENSION = <LD_S__WORKSHEET>-NAME.

            " lock dimensions
            CALL METHOD LR_O__ADMIN_MGR->UPDATE_DIM_FILE_LOCK
              EXPORTING
                I_LOCK          = ABAP_TRUE
                I_DIMENSION	=
                LD_V__DIMENSION
              IMPORTING
                E_SUCCESS	=
                E_SUCCESS.

            CALL FUNCTION 'DB_COMMIT'.

            APPEND LD_V__DIMENSION TO  IT_DIM_LIST.

            CALL FUNCTION 'ZFM_ZVCS_MERGE_CSV'
              EXPORTING
                I_APPSET_ID = P_APPSET
                I_DIMENSION = LD_V__DIMENSION
                I_DATA      = <LD_S__WORKSHEET>-TABLE.
          ENDLOOP.

          CALL FUNCTION 'DB_COMMIT'.

          IF IT_DIM_LIST IS NOT INITIAL.
            CALL METHOD LR_O__ADMIN_MGR->PROCESS_DIMENSION
              EXPORTING
                IT_DIM_LIST = IT_DIM_LIST
              IMPORTING
                ET_MESSAGE  = ET_MESSAGE
                E_SUCCESS   = E_SUCCESS.
          ENDIF.

          " unlock dimensions
          LOOP AT IT_DIM_LIST INTO LD_V__DIMENSION.
            CALL METHOD LR_O__ADMIN_MGR->UPDATE_DIM_FILE_LOCK
              EXPORTING
                I_LOCK          = ABAP_FALSE
                I_DIMENSION	=
                LD_V__DIMENSION
              IMPORTING
                E_SUCCESS	=
                E_SUCCESS.
          ENDLOOP.

          CALL FUNCTION 'DB_COMMIT'.

          IF SWITCHST = ABAP_TRUE.
            CALL METHOD LR_O__ADMIN_MGR->SET_APPSET_STATUS
              EXPORTING
                IS_USER     = LD_S__BPC_USER
                I_IS_ONLINE = ABAP_TRUE
                I_MESSAGE   = LD_V__STATUS_MESS
              IMPORTING
                E_SUCCESS   = E_SUCCESS.

            CALL FUNCTION 'DB_COMMIT'.
          ENDIF.

          WRITE `Обработка измерений закончена.`.

          LOOP AT ET_MESSAGE INTO LS_MESSAGE.
            IF SY-TABIX = 1.
              WRITE `Ошибки: ` COLOR COL_NEGATIVE.
              LV_MESSAGE = LS_MESSAGE-MESSAGE.
              WRITE /10 LV_MESSAGE COLOR COL_NEGATIVE.
            ENDIF.
          ENDLOOP.

*--------------------------------------------------------------------*
* Upload
*--------------------------------------------------------------------*
        WHEN UPLOAD.

          SELECT DIMENSION
            FROM UJA_DIMENSION
            INTO CORRESPONDING FIELDS OF TABLE LD_T__DIMENSION
            WHERE APPSET_ID = P_APPSET.

          LOOP AT LD_T__DIMENSION INTO LD_S__DIMENSION.
            APPEND LD_S__DIMENSION-DIMENSION TO LD_T__WORKSHEETS.
          ENDLOOP.

          CALL METHOD LCL_CHOOSE=>CHOOSE
            EXPORTING
              I_V__FORM_NAME = `CHOOSE_DOWNLOAD`
            CHANGING
              I_T__DIM       = LD_T__WORKSHEETS.

          CHECK LD_T__WORKSHEETS IS NOT INITIAL.

          LOOP AT LD_T__WORKSHEETS INTO  LD_S__WORKSHEET-NAME.
            LD_V__DIMENSION = LD_S__WORKSHEET-NAME.

            CREATE OBJECT LR_O__MBR_DATA
              EXPORTING
                I_APPSET_ID = P_APPSET
                I_DIMENSION = LD_V__DIMENSION.

            CALL METHOD LR_O__MBR_DATA->READ_MBR_DATA
              EXPORTING
                IF_SORT            = ABAP_TRUE
                IF_INC_NON_DISPLAY = ABAP_FALSE
                IF_INC_GENERATE    = ABAP_FALSE
                IF_SKIP_CACHE      = ABAP_TRUE
                IF_INC_TXT         = ABAP_TRUE
              IMPORTING
                ER_DATA            = LD_S__WORKSHEET-TABLE.

            DATA
            : LR_S__LINE          TYPE REF TO DATA
            , LD_T__PARENTH       TYPE ZVCST_T__SOURCE
            , LD_T__ALL           TYPE ZVCST_T__SOURCE
            , LD_V__ID            TYPE ZVCST_S__SOURCE
            , LD_V__EVDISCR       TYPE ZVCST_S__SOURCE
            , LD_S__SEQUENCE      TYPE ZVCST_S__SEQUENCE
            , LD_T__SEQUENCE      TYPE STANDARD TABLE OF ZVCST_S__SEQUENCE
            , LD_V__CNT           TYPE I
            .

            FIELD-SYMBOLS
            : <LD_S__DATA>        TYPE ANY
            , <LD_S__COMP>        TYPE ABAP_COMPDESCR
            , <LD_S__SEQUENCE>     TYPE ZVCST_S__SEQUENCE
            .

            ASSIGN LD_S__WORKSHEET-TABLE->* TO <LD_T__DATA>.
            CREATE DATA LR_S__LINE LIKE LINE OF <LD_T__DATA>.
            LR_O__STRUCTDESCR    ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( LR_S__LINE ).

            CLEAR
            : LD_S__SEQUENCE
            , LD_S__WORKSHEET-SEQUENCE
            .

            LOOP AT LR_O__STRUCTDESCR->COMPONENTS ASSIGNING <LD_S__COMP>.
              LD_S__SEQUENCE-FIELD = <LD_S__COMP>-NAME.
              APPEND LD_S__SEQUENCE TO LD_S__WORKSHEET-SEQUENCE.
            ENDLOOP.

            SORT LD_S__WORKSHEET-SEQUENCE BY FIELD ASCENDING.

            READ TABLE LD_S__WORKSHEET-SEQUENCE
                 WITH TABLE KEY FIELD = `ID`
                 ASSIGNING <LD_S__SEQUENCE>.

            <LD_S__SEQUENCE>-SEQUENCE = 1.

            READ TABLE LD_S__WORKSHEET-SEQUENCE
                 WITH TABLE KEY FIELD = `EVDESCRIPTION`
                 ASSIGNING <LD_S__SEQUENCE>.

            <LD_S__SEQUENCE>-SEQUENCE = 2.

            LD_V__CNT = 2.
            LOOP AT LD_S__WORKSHEET-SEQUENCE ASSIGNING <LD_S__SEQUENCE>
              WHERE FIELD CP `PARENTH*`.

              FIND FIRST OCCURRENCE OF REGEX `\<PARENTH\d+\>` IN <LD_S__SEQUENCE>-FIELD.
              IF SY-SUBRC = 0.
                ADD 1 TO LD_V__CNT.
                <LD_S__SEQUENCE>-SEQUENCE = LD_V__CNT.
              ENDIF.
            ENDLOOP.

            LOOP AT LD_S__WORKSHEET-SEQUENCE ASSIGNING <LD_S__SEQUENCE>
                WHERE SEQUENCE = 0.
              ADD 1 TO LD_V__CNT.
              <LD_S__SEQUENCE>-SEQUENCE = LD_V__CNT.
            ENDLOOP.

            SORT LD_S__WORKSHEET-SEQUENCE BY SEQUENCE ASCENDING.

            LD_S__WORKSHEET-NAME = LD_V__DIMENSION.
            LD_S__WORKSHEET-F__FILTER         = ABAP_TRUE.
            LD_S__WORKSHEET-F__VALIDTEXTLENGTH = ABAP_TRUE.
            LD_S__WORKSHEET-F__SPLITVERTICAL  = ABAP_TRUE.

            APPEND LD_S__WORKSHEET TO LD_T__WORKSHEET.
          ENDLOOP.

          IF LD_T__WORKSHEET IS NOT INITIAL.
            DATA DXML TYPE REF TO ZCL_EXCEL_XML_DOWNLOAD.
            CREATE OBJECT DXML.
            DXML->CREATE_XML_WORKBOOK( LD_T__WORKSHEET ).
            DXML->DOWNLOAD_ON_PC( P_FILE ).
          ENDIF.

      ENDCASE.

    CATCH CX_ROOT INTO LO_EXCEPT.
      WHILE LO_EXCEPT IS NOT INITIAL.
        LV_ERROR = LO_EXCEPT->GET_TEXT( ).
        WRITE: / SY-INDEX, LV_ERROR COLOR COL_GROUP.
        LO_EXCEPT = LO_EXCEPT->PREVIOUS.
      ENDWHILE.
  ENDTRY.

  IF LINES( LT_LIST_ERROR[] ) > 0.
    WRITE: / '== ЛОГ ==' COLOR COL_GROUP.

    LOOP AT LT_LIST_ERROR.
      WRITE: / LT_LIST_ERROR-APPSET_ID, LT_LIST_ERROR-DIM_NAME.

      IF LT_LIST_ERROR-F_SUCCESS = ABAP_TRUE.
        IF LT_LIST_ERROR-F_SUCCESS = ABAP_TRUE AND LT_LIST_ERROR-F_DEL_FORMULA = ABAP_TRUE.
          WRITE: 'Сохранено без формул' COLOR COL_GROUP.
        ELSE.
          WRITE: 'Сохранено без ошибок'.
        ENDIF.
      ELSE.
        CASE LT_LIST_ERROR-SUBRC.
          WHEN 1. WRITE: 'Не было сохранено, возникло необработаное исключение'                                 COLOR COL_GROUP.
          WHEN 2. WRITE: 'Не было сохранено, так архив не был создан'                                           COLOR COL_GROUP.
          WHEN 3. WRITE: 'Не было сохранено, так как архив не был создан или не содержит измерений с формулами' COLOR COL_GROUP.
        ENDCASE.
      ENDIF.

      IF LINES( LT_LIST_ERROR-T_MESSAGE ) > 0.
        LOOP AT LT_LIST_ERROR-T_MESSAGE
           INTO LS_MESSAGE.
          WRITE /15 LS_MESSAGE-MESSAGE COLOR COL_GROUP.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDIF.


*----------------------------------------------------------------------*
*       CLASS lcl_application IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS LCL_APPLICATION IMPLEMENTATION.
  METHOD GET_INITIAL_DIRECTORY.

    CL_GUI_FRONTEND_SERVICES=>GET_DESKTOP_DIRECTORY(
      CHANGING
        DESKTOP_DIRECTORY    = R_PATH ).
    CL_GUI_CFW=>FLUSH( ).

    CONCATENATE R_PATH '\*.xml' INTO R_PATH.

  ENDMETHOD.                    "get_initial_directory
  METHOD SET_DELIMITER_LISTBOX.

* set delimiter listbox.
    DATA: LT_VRM_VALUES TYPE VRM_VALUES.
    DATA: LS_VRM_VALUES LIKE LINE OF LT_VRM_VALUES.
    DATA: LV_NAME TYPE VRM_ID  VALUE 'P_DELMT'.

    REFRESH LT_VRM_VALUES.

    LS_VRM_VALUES-KEY = LCL_APPLICATION=>LC_TAB.
    LS_VRM_VALUES-TEXT = 'Табуляция'.
    APPEND LS_VRM_VALUES TO LT_VRM_VALUES.

    LS_VRM_VALUES-KEY = LCL_APPLICATION=>LC_COMMA.
    LS_VRM_VALUES-TEXT = 'Точка с запятой'.
    APPEND LS_VRM_VALUES TO LT_VRM_VALUES.

    LS_VRM_VALUES-KEY = LCL_APPLICATION=>LC_PIPE.
    LS_VRM_VALUES-TEXT = 'Вертикальная черта'.
    APPEND LS_VRM_VALUES TO LT_VRM_VALUES.

    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        ID     = LV_NAME
        VALUES = LT_VRM_VALUES.

  ENDMETHOD.                    "set_delimiter_listbox
  METHOD SET_LANG_LISTBOX .
    DATA: LT_VRM_VALUES TYPE VRM_VALUES.
    DATA: LS_VRM_VALUES LIKE LINE OF LT_VRM_VALUES.
    DATA: LV_NAME TYPE VRM_ID  VALUE 'LANG'.

    REFRESH LT_VRM_VALUES.

    LS_VRM_VALUES-KEY = `RU`.
    LS_VRM_VALUES-TEXT = 'RU'.
    APPEND LS_VRM_VALUES TO LT_VRM_VALUES.

    LS_VRM_VALUES-KEY = `EN`.
    LS_VRM_VALUES-TEXT = `EN`.
    APPEND LS_VRM_VALUES TO LT_VRM_VALUES.

    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        ID     = LV_NAME
        VALUES = LT_VRM_VALUES.

  ENDMETHOD.                    "SET_LANG_LISTBOX
  METHOD UPLOAD.

    CL_GUI_FRONTEND_SERVICES=>GUI_UPLOAD(
          EXPORTING
            FILENAME = I_FILEPATH
          CHANGING
            DATA_TAB = RT_STRTAB
          EXCEPTIONS
            OTHERS   = 19 ).
    IF SY-SUBRC <> 0.
      MESSAGE E001(00) WITH 'File not found, check file path and name'.
    ENDIF.

    DELETE RT_STRTAB WHERE TABLE_LINE IS INITIAL.

  ENDMETHOD.                    "upload
  METHOD SET_DELIMITER.
*    if p_delmt = lcl_application=>lc_tab.
*      lcl_application=>lv_delimiter = cl_abap_char_utilities=>horizontal_tab.
*    else.
*      lcl_application=>lv_delimiter = p_delmt.
*    endif.
  ENDMETHOD.                    "set_delimiter
  METHOD SET_LANG.
    LCL_APPLICATION=>LV_LANG = SY-LANGU.
  ENDMETHOD.                    "set_lang
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
  METHOD DIRECTORY_F4.

    CL_GUI_FRONTEND_SERVICES=>DIRECTORY_BROWSE(
        CHANGING
          SELECTED_FOLDER      = R_PATH
        EXCEPTIONS
          OTHERS               = 4 ).

  ENDMETHOD.                    "directory_f4
ENDCLASS.                    "lcl_application IMPLEMENTATION
*----------------------------------------------------------------------*
*       CLASS LCL_CHOOSE IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS LCL_CHOOSE IMPLEMENTATION.
  METHOD CHOOSE.
    TYPES: BEGIN OF TY_S__CHOOSE.
    INCLUDE TYPE UJA_S_DIM_NAME.
    TYPES: CHECKBOX(1) TYPE  C
         , INDEX(4) TYPE C
         , END OF TY_S__CHOOSE.

    DATA
    : LD_S_FUNCTION       TYPE SVALP
    , LD_T__FUNCTIONS     TYPE STANDARD TABLE OF SVALP
    , LD_T__CHOOSE        TYPE STANDARD TABLE OF TY_S__CHOOSE
    , LD_S__CHOOSE        TYPE TY_S__CHOOSE
    .

    LOOP AT I_T__DIM INTO LD_S__CHOOSE-DIMENSION.
      LD_S__CHOOSE-INDEX = SY-TABIX.
      APPEND LD_S__CHOOSE TO LD_T__CHOOSE.
    ENDLOOP.


    MOVE
    : 'OK'                TO LD_S_FUNCTION-FUNC_NAME
    , SY-CPROG            TO LD_S_FUNCTION-PROG_NAME
    , I_V__FORM_NAME      TO LD_S_FUNCTION-FORM_NAME.

    APPEND LD_S_FUNCTION TO LD_T__FUNCTIONS.

    CALL FUNCTION 'POPUP_GET_SELECTION_FROM_LIST'
      EXPORTING
        DISPLAY_ONLY                 = 'X'
        TABLE_NAME                   = `UJA_S_DIM_NAME`
        TITLE_BAR                    = 'Список Измерений'
      TABLES
        LIST                         = LD_T__CHOOSE
        FUNCTIONS                    = LD_T__FUNCTIONS
      EXCEPTIONS
        NO_TABLEFIELDS_IN_DICTIONARY = 1
        NO_TABLE_STRUCTURE           = 2
        NO_TITLE_BAR                 = 3
        OTHERS                       = 4.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE 'E' NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    LOOP AT LD_T__CHOOSE INTO LD_S__CHOOSE
      WHERE CHECKBOX = ABAP_FALSE.
      DELETE I_T__DIM WHERE TABLE_LINE = LD_S__CHOOSE-DIMENSION.
    ENDLOOP.

    IF I_T__DIM IS INITIAL.
      MESSAGE `Измерения не выбраны.` TYPE `S`.
    ENDIF.

  ENDMETHOD.                    "CHOOSE
ENDCLASS.                    "LCL_CHOOSE IMPLEMENTATION


*&---------------------------------------------------------------------*
*&      Form  choose_download
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->SELECTION  text
*----------------------------------------------------------------------*
FORM CHOOSE_DOWNLOAD TABLES SELECTION STRUCTURE SHVALUE.

  ZCL_VCS_OBJECTS=>CD_F__POPUP = SPACE.

ENDFORM.                    "choose_download
