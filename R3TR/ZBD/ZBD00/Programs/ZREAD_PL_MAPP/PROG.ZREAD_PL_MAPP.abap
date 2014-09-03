*&---------------------------------------------------------------------*
*& Report  ZREAD_PL_MAPP
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZREAD_PL_MAPP.

TYPE-POOLS: ABAP, VRM.

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
    : LV_DELIMITER TYPE CHAR01 READ-ONLY.

    CLASS-METHODS
    : GET_INITIAL_DIRECTORY RETURNING VALUE(R_PATH) TYPE STRING
    , SET_DELIMITER_LISTBOX
    , SET_DELIMITER
    , FILE_F4 RETURNING VALUE(R_FILE) TYPE STRING
    , DIRECTORY_F4 RETURNING VALUE(R_PATH) TYPE STRING
    , UPLOAD IMPORTING I_FILEPATH TYPE ANY
             RETURNING VALUE(RT_STRTAB) TYPE STRINGTAB
    .

ENDCLASS.                    "lcl_application DEFINITION

DEFINE MAC__STATUS_BAR.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      TEXT       = &1
      PERCENTAGE = &2.
        WAIT UP TO 2 SECONDS.
END-OF-DEFINITION.

TYPE-POOLS: ABAP, ZBPCT, UJA00, UJ00.
INCLUDE ZBPC_TECHCS.
TABLES UJA_DIMENSION.
*--------------------------------------------------------------------*


SELECTION-SCREEN BEGIN OF  BLOCK B4 WITH FRAME TITLE B4_TITLE.
PARAMETERS: P_FILE TYPE STRING LOWER CASE MODIF ID B4.
PARAMETERS: P_DELMT TYPE CHAR1 AS LISTBOX VISIBLE LENGTH 20
                       DEFAULT LCL_APPLICATION=>LC_COMMA MODIF ID B4.  "delimiter
SELECTION-SCREEN END OF BLOCK B4.

INITIALIZATION.

  P_FILE = LCL_APPLICATION=>GET_INITIAL_DIRECTORY( ).
  LCL_APPLICATION=>SET_DELIMITER_LISTBOX( ).

AT SELECTION-SCREEN OUTPUT.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  P_FILE = LCL_APPLICATION=>DIRECTORY_F4( ).

*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
START-OF-SELECTION.

  TYPES
  : BEGIN OF TY_S__MEMBER_LIST
  , NAME TYPE STRING
  , INDEX TYPE I
  , END OF TY_S__MEMBER_LIST.

  DATA
  : LCX_ERROR              TYPE REF TO CX_ROOT
  , LV_ERROR               TYPE STRING
  , LV_MESSAGE             TYPE STRING
  , TEXTID                 TYPE TEXTID
  , LO_EXCEPT              TYPE REF TO CX_ROOT
  , LD_T__STRTAB           TYPE STRINGTAB
  , LD_S__STRTAB           TYPE STRING
  , LD_T__MEMBER           TYPE TABLE OF STRING
  , LD_V__MEMBER           TYPE STRING
  , LD_T__SC_COMP          TYPE ABAP_COMPONENT_TAB
  , LD_T__TG_COMP          TYPE ABAP_COMPONENT_TAB
  , LD_S__COMP             TYPE ABAP_COMPONENTDESCR
  , LD_S__RB_MP_PL         TYPE ZRB_MP_PL
  , LD_T__RB_MP_PL         TYPE SORTED TABLE OF ZRB_MP_PL WITH NON-UNIQUE KEY ID_RULE NUMBER_KEY
  , LD_S__SC_FIELD         TYPE TY_S__MEMBER_LIST
  , LD_S__TG_FIELD         TYPE TY_S__MEMBER_LIST
  , LD_T__SC               TYPE SORTED TABLE OF TY_S__MEMBER_LIST WITH UNIQUE KEY INDEX
  , LD_T__TG               TYPE SORTED TABLE OF TY_S__MEMBER_LIST WITH UNIQUE KEY INDEX
  , LD_V__INDEX_RULEID     TYPE I
  , LD_V__INDEX_APPSET     TYPE I
  .

  FIELD-SYMBOLS
  : <LD_S__SC_RBMPPL>               TYPE ZRB_MP_PL
  .



  ZCL_DEBUG=>BREAK_POINT( ).

  LCL_APPLICATION=>SET_DELIMITER( ).

  TRY.
      MAC__STATUS_BAR 'Чтениие файла ...' 10.

      CL_GUI_FRONTEND_SERVICES=>GUI_UPLOAD(
      EXPORTING
        FILENAME = P_FILE
      CHANGING
        DATA_TAB = LD_T__STRTAB
      EXCEPTIONS
        OTHERS   = 19 ).


      LOOP AT LD_T__STRTAB INTO LD_S__STRTAB.
        SPLIT LD_S__STRTAB AT P_DELMT INTO TABLE LD_T__MEMBER.

        IF SY-TABIX = 1.
          LOOP AT LD_T__MEMBER INTO LD_V__MEMBER.
            FIND REGEX `^(TG\.|SC\.)` IN LD_V__MEMBER.
            IF SY-SUBRC = 0.
              LD_S__TG_FIELD-NAME = LD_V__MEMBER+3.
              LD_S__TG_FIELD-INDEX = SY-TABIX.

              CASE LD_V__MEMBER+0(2).
                WHEN `TG`.
                  INSERT LD_S__TG_FIELD INTO TABLE LD_T__TG.
                WHEN `SC`.
                  INSERT LD_S__TG_FIELD INTO TABLE LD_T__SC.
              ENDCASE.
            ELSEIF LD_V__MEMBER = `RULE_ID`.
              LD_V__INDEX_RULEID = SY-TABIX.
            ELSEIF LD_V__MEMBER = `APPSET`.
              LD_V__INDEX_APPSET = SY-TABIX.
            ENDIF.
          ENDLOOP.
        ELSE.
          CLEAR LD_S__RB_MP_PL-NUMBER_KEY.

          "rule_id
          READ TABLE LD_T__MEMBER
               INDEX LD_V__INDEX_RULEID
               INTO  LD_S__RB_MP_PL-ID_RULE.
          " appset
          READ TABLE LD_T__MEMBER
               INDEX LD_V__INDEX_APPSET
               INTO  LD_S__RB_MP_PL-APPSET.

          " TG application
          READ TABLE LD_T__TG
               WITH KEY NAME = `APPLICATION`
               INTO LD_S__TG_FIELD.

          READ TABLE LD_T__MEMBER
               INDEX LD_S__TG_FIELD-INDEX
               INTO  LD_S__RB_MP_PL-TG_APPL.

          " SC application
          READ TABLE LD_T__SC
               WITH KEY NAME = `APPLICATION`
               INTO LD_S__SC_FIELD.

          READ TABLE LD_T__MEMBER
               INDEX LD_S__SC_FIELD-INDEX
               INTO  LD_S__RB_MP_PL-SC_APPL.


          LOOP AT LD_T__TG INTO LD_S__TG_FIELD WHERE NAME NE `APPLICATION`.
            LD_S__RB_MP_PL-TG_DIMN = LD_S__TG_FIELD-NAME.

            READ TABLE LD_T__SC
                 WITH KEY NAME = LD_S__TG_FIELD-NAME
                 INTO LD_S__SC_FIELD.

            IF SY-SUBRC = 0.
              LD_S__RB_MP_PL-SC_DIMN = LD_S__SC_FIELD-NAME.
            ENDIF.

            READ TABLE LD_T__MEMBER
                 INDEX LD_S__TG_FIELD-INDEX
                 INTO  LD_V__MEMBER.

            IF LD_V__MEMBER IS NOT INITIAL AND LD_V__MEMBER <> `<ALL>`.
              LD_S__RB_MP_PL-TG_VALUE = LD_V__MEMBER.
            ENDIF.

            ADD 1 TO LD_S__RB_MP_PL-NUMBER_KEY.
            INSERT LD_S__RB_MP_PL INTO TABLE LD_T__RB_MP_PL."ld_s__sc_field

            CLEAR
            : LD_S__RB_MP_PL-TG_DIMN
            , LD_S__RB_MP_PL-TG_VALUE
            , LD_S__RB_MP_PL-SC_DIMN
            , LD_S__RB_MP_PL-SC_VALUE.
          ENDLOOP.

          LOOP AT LD_T__SC INTO LD_S__SC_FIELD WHERE NAME NE `APPLICATION`.
            LD_S__RB_MP_PL-SC_DIMN = LD_S__SC_FIELD-NAME.

            CLEAR LD_V__MEMBER.

            READ TABLE LD_T__MEMBER
                INDEX LD_S__SC_FIELD-INDEX
                INTO  LD_V__MEMBER.

            READ TABLE LD_T__RB_MP_PL
                 WITH KEY ID_RULE = LD_S__RB_MP_PL-ID_RULE
                          APPSET  = LD_S__RB_MP_PL-APPSET
                          SC_DIMN = LD_S__SC_FIELD-NAME
                 ASSIGNING <LD_S__SC_RBMPPL> .

            IF SY-SUBRC = 0.
              IF LD_V__MEMBER IS NOT INITIAL.
                <LD_S__SC_RBMPPL>-SC_VALUE = LD_V__MEMBER.
              ELSE.
                CLEAR
                : <LD_S__SC_RBMPPL>-SC_DIMN
                , <LD_S__SC_RBMPPL>-SC_VALUE
                .
              ENDIF.
            ELSEIF LD_V__MEMBER IS NOT INITIAL.
              LD_S__RB_MP_PL-SC_VALUE = LD_V__MEMBER.
              ADD 1 TO LD_S__RB_MP_PL-NUMBER_KEY.
              INSERT LD_S__RB_MP_PL INTO TABLE LD_T__RB_MP_PL."ld_s__sc_field
            ENDIF.

            CLEAR
            : LD_S__RB_MP_PL-TG_DIMN
            , LD_S__RB_MP_PL-TG_VALUE
            , LD_S__RB_MP_PL-SC_DIMN
            , LD_S__RB_MP_PL-SC_VALUE.

          ENDLOOP.
        ENDIF.
      ENDLOOP.

      MAC__STATUS_BAR 'Очистка таблицы  ZRB_MP_PL' 20.

      DELETE FROM ZRB_MP_PL.
      INSERT ZRB_MP_PL FROM TABLE LD_T__RB_MP_PL.

      MAC__STATUS_BAR 'Маппинг обновлен ...' 90.

    CATCH CX_ROOT INTO LO_EXCEPT.
      WHILE LO_EXCEPT IS NOT INITIAL.
        LV_ERROR = LO_EXCEPT->GET_TEXT( ).
        WRITE: / SY-INDEX, LV_ERROR COLOR COL_GROUP.
        LO_EXCEPT = LO_EXCEPT->PREVIOUS.
      ENDWHILE.
  ENDTRY.


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

    CONCATENATE R_PATH '\*.csv' INTO R_PATH.

  ENDMETHOD.                    "get_initial_directory
  METHOD SET_DELIMITER_LISTBOX.

* set delimiter listbox.
    DATA: LT_VRM_VALUES TYPE VRM_VALUES.
    DATA: LS_VRM_VALUES LIKE LINE OF LT_VRM_VALUES.
    DATA: LV_NAME TYPE VRM_ID  VALUE 'P_DELMT'.

    REFRESH LT_VRM_VALUES.

    LS_VRM_VALUES-KEY = LCL_APPLICATION=>LC_COMMA.
    LS_VRM_VALUES-TEXT = 'Точка с запятой'.
    APPEND LS_VRM_VALUES TO LT_VRM_VALUES.

    LS_VRM_VALUES-KEY = LCL_APPLICATION=>LC_TAB.
    LS_VRM_VALUES-TEXT = 'Табуляция'.
    APPEND LS_VRM_VALUES TO LT_VRM_VALUES.

    LS_VRM_VALUES-KEY = LCL_APPLICATION=>LC_PIPE.
    LS_VRM_VALUES-TEXT = 'Вертикальная черта'.
    APPEND LS_VRM_VALUES TO LT_VRM_VALUES.

    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        ID     = LV_NAME
        VALUES = LT_VRM_VALUES.

  ENDMETHOD.                    "set_delimiter_listbox
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
    IF P_DELMT = LCL_APPLICATION=>LC_TAB.
      LCL_APPLICATION=>LV_DELIMITER = CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB.
    ELSE.
      LCL_APPLICATION=>LV_DELIMITER = P_DELMT.
    ENDIF.
  ENDMETHOD.                    "set_delimiter

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
