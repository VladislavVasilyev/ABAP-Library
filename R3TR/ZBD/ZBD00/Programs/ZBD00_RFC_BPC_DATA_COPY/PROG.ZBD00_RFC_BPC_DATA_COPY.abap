*&---------------------------------------------------------------------*
*& Report  ZBD00_RFC_BPC_DATA_COPY
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZBD00_RFC_BPC_DATA_COPY.

IF 'DEFINITION' = 'DEFINITION' .
  TYPE-POOLS: ABAP, RSDRC .

  DATA: LV_APPL_ID        TYPE UJA_APPL-APPLICATION_ID ,
        LT_APPL_ID        TYPE STANDARD TABLE OF UJA_APPL-APPLICATION_ID ,
        LV_MEMEBER        TYPE UJ_DIM_MEMBER ,
        LT_SEL            TYPE UJ0_T_SEL ,
        LS_SEL            TYPE UJ0_S_SEL ,
        LT_CLEAR_SEL      TYPE UJ0_T_SEL ,
        LS_CLEAR_SEL      TYPE UJ0_S_SEL ,
        LV_PC             TYPE N LENGTH 2 ,
        LV_NAME           TYPE C LENGTH 7 ,
        LO_MODEL          TYPE REF TO ZCL_BD00_MODEL ,
        LS_RFCDATA_UC     TYPE XSTRING ,
        L_T_RFCDATA       TYPE RSDRI_T_RFCDATA ,
        L_T_FIELD         TYPE RSDP0_T_FIELD ,
        LR_T_DATA         TYPE REF TO DATA,
        LS_RFCMODE        TYPE RSDP0_S_RFCMODE ,
        LD_F__EOD         TYPE RS_BOOL ,
        L_FIRST_CALL      TYPE RS_BOOL ,
        LV_DEST           TYPE RFCDEST ,
        L_T_OUTDATA250    TYPE BAPI6116TDA ,
        LD_V__MEMBER      TYPE STRING ,
        LD_T__PARAM       TYPE STANDARD TABLE OF UJ_VALUE WITH NON-UNIQUE DEFAULT KEY ,
        LD_V__VALUE       TYPE UJ_VALUE ,
        LR_I__CONTEXT     TYPE REF TO IF_UJ_CONTEXT ,
        LV_SYSPART        TYPE RFCDEST ,
        LR_O__TARGET      TYPE REF TO ZCL_BD00_APPL_TABLE ,
        GR_O__RFC_TASK    TYPE REF TO ZCL_BD00_RFC_TASK ,
        LV_TASK_NUM       TYPE I ,
        LV_MSG_01         TYPE STRING ,
        LV_MSG_02         TYPE STRING ,
        LV_COUNT          TYPE I ,
        LV_RAISE_WB       TYPE I .
  FIELD-SYMBOLS: <FS_DATA>        TYPE ANY ,
  <FV_DATA>        TYPE ANY ,
  <FT_DATA>        TYPE ANY TABLE ,
  <L_T_DATA>       TYPE STANDARD TABLE ,
  <LT_APPL_TL>     TYPE HASHED TABLE.

  DATA
        : LS_RANGE   TYPE RSDRI_S_RANGE
        , L_T_RANGE   TYPE RSDRI_T_RANGE
        .
  FIELD-SYMBOLS
  : <LS_SEL>       TYPE UJ0_S_SEL
  , <LS_DIMENSION> TYPE ZBD00_S_DIMN
  .

  DATA
  : LR_T__TECHNAME TYPE REF TO DATA
  , LR_T__APPLNAME TYPE REF TO DATA
  , LR_T__APPLNAME_TL TYPE REF TO DATA
  , LR_S__APPLNAME_TL TYPE REF TO DATA
        .
  FIELD-SYMBOLS
  : <LT_TECH>      TYPE STANDARD TABLE
  , <LT_APPL>      TYPE STANDARD TABLE
  , <LS_APPL>      TYPE ANY
  .

  DATA
  : LD_T__LOG_READ        TYPE ZBD0T_T__LOG_READ
  , LD_T__LOG_WRITE       TYPE ZBD0T_T__LOG_WRITE
  , NUM_READ              TYPE I
  , NUM_WRITE             TYPE UJR_S_STATUS_RECORDS
  , E_MESSAGE             TYPE UJ0_T_MESSAGE
  .
  FIELD-SYMBOLS
  : <LD_S__LOG_READ>  LIKE LINE OF LD_T__LOG_READ
  , <LD_S__LOG_WRITE> LIKE LINE OF LD_T__LOG_WRITE
  , <FS_MESSAGE>      TYPE UJ0_S_MESSAGE
  .
  TYPES
  : BEGIN OF TY_S__DATA
    , NAME  TYPE RSALIAS
    , REF TYPE REF TO DATA
  , END OF TY_S__DATA.

  DATA: LD_S__DATA TYPE TY_S__DATA.
  DATA: LD_S__DIM TYPE ZCL_BD00_MODEL=>TY_S_DIM_LIST.
  DATA: LR_DATA TYPE REF TO DATA.
  DATA: GR_O__WRITE_TO_BPC TYPE REF TO ZCL_BD00_APPL_TABLE.
  DATA: LD_T__FIELD	TYPE ZBD0T_TY_T_CUSTOM_LINK.
  DATA: LD_S__FIELD	TYPE ZBD0T_TY_S_CUSTOM_LINK.
  DATA: LD_V__RULE_ID TYPE ZBD0T_ID_RULES.

  FIELD-SYMBOLS
  : <LD_S__DATA> TYPE ANY
  , <LD_V__DATA> TYPE ANY
  , <LD_T__DIM>  TYPE ZCL_BD00_MODEL=>TY_T_DIM_LIST
  .
ENDIF. " 'DEFINITION'

IF 'SELECTION SCREEN' = 'SELECTION SCREEN' .
  SELECTION-SCREEN BEGIN OF BLOCK APP WITH FRAME TITLE TEXT-001.
  PARAMETERS: P_APPSET TYPE UJA_APPL-APPSET_ID OBLIGATORY VALUE CHECK VISIBLE LENGTH 18 .
  SELECT-OPTIONS: S_APPLS FOR LV_APPL_ID OBLIGATORY NO INTERVALS.
  PARAMETERS: P_LOGSYS TYPE RSLOGSYSDEST-LOGSYS MATCHCODE OBJECT ZBD_LOGSYS OBLIGATORY VISIBLE LENGTH 18 .
  PARAMETERS: P_PS TYPE I MODIF ID 001 DEFAULT 50000 .
  PARAMETERS: P_TN TYPE I MODIF ID 001 DEFAULT 4 .
  PARAMETERS: P_LP TYPE RS_BOOL MODIF ID 001 .
  SELECTION-SCREEN END OF BLOCK APP.

  SELECTION-SCREEN BEGIN OF BLOCK SEL WITH FRAME TITLE TEXT-002.
*line 1
  SELECTION-SCREEN BEGIN OF LINE .
  PARAMETERS: P_D01 TYPE UJA_DIM_APPL-DIMENSION .
  SELECT-OPTIONS: S_D01 FOR LV_MEMEBER .
  SELECTION-SCREEN END OF LINE .
*line 2
  SELECTION-SCREEN BEGIN OF LINE .
  PARAMETERS: P_D02 TYPE UJA_DIM_APPL-DIMENSION .
  SELECT-OPTIONS: S_D02 FOR LV_MEMEBER .
  SELECTION-SCREEN END OF LINE .
*line 3
  SELECTION-SCREEN BEGIN OF LINE .
  PARAMETERS: P_D03 TYPE UJA_DIM_APPL-DIMENSION .
  SELECT-OPTIONS: S_D03 FOR LV_MEMEBER .
  SELECTION-SCREEN END OF LINE .
*line 4
  SELECTION-SCREEN BEGIN OF LINE .
  PARAMETERS: P_D04 TYPE UJA_DIM_APPL-DIMENSION .
  SELECT-OPTIONS: S_D04 FOR LV_MEMEBER .
  SELECTION-SCREEN END OF LINE .
*line 5
  SELECTION-SCREEN BEGIN OF LINE .
  PARAMETERS: P_D05 TYPE UJA_DIM_APPL-DIMENSION .
  SELECT-OPTIONS: S_D05 FOR LV_MEMEBER .
  SELECTION-SCREEN END OF LINE .
*line 6
  SELECTION-SCREEN BEGIN OF LINE .
  PARAMETERS: P_D06 TYPE UJA_DIM_APPL-DIMENSION .
  SELECT-OPTIONS: S_D06 FOR LV_MEMEBER .
  SELECTION-SCREEN END OF LINE .
*line 7
  SELECTION-SCREEN BEGIN OF LINE .
  PARAMETERS: P_D07 TYPE UJA_DIM_APPL-DIMENSION .
  SELECT-OPTIONS: S_D07 FOR LV_MEMEBER .
  SELECTION-SCREEN END OF LINE .
*line 8
  SELECTION-SCREEN BEGIN OF LINE .
  PARAMETERS: P_D08 TYPE UJA_DIM_APPL-DIMENSION .
  SELECT-OPTIONS: S_D08 FOR LV_MEMEBER .
  SELECTION-SCREEN END OF LINE .
*line 9
  SELECTION-SCREEN BEGIN OF LINE .
  PARAMETERS: P_D09 TYPE UJA_DIM_APPL-DIMENSION .
  SELECT-OPTIONS: S_D09 FOR LV_MEMEBER .
  SELECTION-SCREEN END OF LINE .
*line 10
  SELECTION-SCREEN BEGIN OF LINE .
  PARAMETERS: P_D10 TYPE UJA_DIM_APPL-DIMENSION .
  SELECT-OPTIONS: S_D10 FOR LV_MEMEBER .
  SELECTION-SCREEN END OF LINE .
  SELECTION-SCREEN END OF BLOCK SEL.
ENDIF. " 'SELECTION SCREEN'

AT SELECTION-SCREEN .

* для реальных пацанов
  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = '001'
    AND SY-UNAME NE 'AKOZIN00'
    AND SY-UNAME NE 'VVASILYEV00'  .
      SCREEN-ACTIVE = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

START-OF-SELECTION.

CLEAR LV_MSG_01.
CONCATENATE `Start program ZBD00_RFC_BPC_DATA_COPY` ` (` SY-UZEIT(2) `:` SY-UZEIT+2(2) `:` SY-UZEIT+4(2) `).` INTO LV_MSG_01.
WRITE: / LV_MSG_01 COLOR COL_BACKGROUND .
ULINE.
*  break-point.

  IF 'PREPARATIONS' = 'PREPARATIONS' .

    WRITE: / `Parameters and Selections:` COLOR COL_HEADING .

* checking for production and self system
    CONCATENATE LV_SYSPART `*` SY-SYSID `*` INTO LV_SYSPART.
    IF SY-SYSID = 'BP2'.
      MESSAGE E001(00) WITH `Error! ` ` Can not run the program in the production system!` .
    ELSEIF P_LOGSYS CP LV_SYSPART.
      MESSAGE E001(00) WITH `Error!` ` Download data ONLY from other systems!` .
    ENDIF.
    WRITE: / `Appset =` , P_APPSET .

* get selections from selection-screen
* applications
    WRITE: / `Applications =`.
    LOOP AT S_APPLS ASSIGNING <FS_DATA> .
      ASSIGN COMPONENT 'LOW' OF STRUCTURE <FS_DATA> TO <FV_DATA> .
      COLLECT <FV_DATA> INTO LT_APPL_ID .
      WRITE: <FV_DATA> .
    ENDLOOP.
    UNASSIGN <FS_DATA>.

* destination rfc-address
    WRITE: / `Source system =` , P_LOGSYS .
*IF p_logsys is not initial.
    SELECT SINGLE DESTINATION INTO LV_DEST FROM RSLOGSYSDEST
      WHERE LOGSYS = P_LOGSYS.
*ELSE.
* select single destination into lv_dest from RSLOGSYSDEST
*  where LOGSYS = sy-host.
*endif.

* package size
    IF P_PS IS INITIAL .
      LS_RFCMODE-PACKAGESIZE = 50000.
    ELSE.
      LS_RFCMODE-PACKAGESIZE = P_PS .
    ENDIF.
    WRITE: / `Package size =` , LS_RFCMODE-PACKAGESIZE .

* Set number of parallel RFC-processes
    IF P_TN IS INITIAL.
      LV_TASK_NUM = 4.
    ELSE.
      LV_TASK_NUM = P_TN .
    ENDIF.
    WRITE: / `Parallel tasks =` , LV_TASK_NUM .

    CREATE OBJECT GR_O__RFC_TASK
      EXPORTING
        NUM           = LV_TASK_NUM
        PARALLEL_TASK = ABAP_TRUE.

* selections in the BPC format
    DO.
      ADD 1 TO LV_PC.
      CLEAR LV_NAME.
      CONCATENATE `p_d` LV_PC INTO LV_NAME.
      ASSIGN (LV_NAME) TO <FS_DATA>.
      IF <FS_DATA> IS NOT ASSIGNED OR <FS_DATA> IS INITIAL .
        EXIT.
      ENDIF.

      LS_SEL-DIMENSION = <FS_DATA>.
      CLEAR LV_NAME.
      CONCATENATE `s_d` LV_PC `[]` INTO LV_NAME.
      ASSIGN (LV_NAME) TO <FT_DATA>.
      IF <FT_DATA> IS NOT ASSIGNED OR <FT_DATA> IS INITIAL .
        CONTINUE.
      ENDIF.

      LOOP AT <FT_DATA> ASSIGNING <FS_DATA>.
        MOVE-CORRESPONDING <FS_DATA> TO LS_SEL.
        COLLECT LS_SEL INTO LT_SEL .
      ENDLOOP.
    ENDDO.

    WRITE: / `Selections: ` .
    LOOP AT LT_SEL INTO LS_SEL .
      CLEAR LV_MSG_01.
      CONCATENATE LS_SEL-DIMENSION LS_SEL-ATTRIBUTE LS_SEL-SIGN LS_SEL-OPTION
                  LS_SEL-LOW LS_SEL-HIGH INTO LV_MSG_01 SEPARATED BY SPACE .
      WRITE: / LV_MSG_01  .
    ENDLOOP.
    ULINE.
  ENDIF. " 'PREPARATIONS'

*  break-point.

* procession data application by application
  IF 'EXECUTION' = 'EXECUTION' .

    LOOP AT LT_APPL_ID INTO LV_APPL_ID .

      CLEAR LV_MSG_01.
      CONCATENATE  `Start execution for ` LV_APPL_ID ` (` SY-UZEIT(2) `:` SY-UZEIT+2(2) `:` SY-UZEIT+4(2) `).` INTO LV_MSG_01 .
      WRITE: / LV_MSG_01 COLOR COL_TOTAL.

IF 'CREAT OBJECTS' = 'CREAT OBJECTS'.

      CLEAR: LO_MODEL ,
             LR_I__CONTEXT .
*try.
      LO_MODEL = ZCL_BD00_MODEL=>GET_MODEL( I_APPSET_ID = P_APPSET I_APPL_ID = LV_APPL_ID  ) .
* catch zcx_bd00_create_obj .
*endtry.

* set user for standard and z context
      LR_I__CONTEXT ?= CL_UJ_CONTEXT=>GET_CUR_CONTEXT( ).
      LR_I__CONTEXT->SWITCH_TO_SRVADMIN( ).

      CALL METHOD ZCL_BD00_CONTEXT=>SET_CONTEXT
        EXPORTING
          I_APPSET_ID = P_APPSET
          I_APPL_ID   = LV_APPL_ID
          I_S__USER   = LR_I__CONTEXT->DS_USER.

      TRY.
          CL_UJ_CONTEXT=>SET_CUR_CONTEXT( I_APPSET_ID  = P_APPSET
                                          IS_USER      = LR_I__CONTEXT->DS_USER
                                          I_APPL_ID    = LV_APPL_ID ).
        CATCH CX_UJ_OBJ_NOT_FOUND.
          RAISE ERR_APPSET_ID.
      ENDTRY.

* selections for application in the BW format
      CLEAR: LS_RANGE ,
             L_T_RANGE ,
             LS_CLEAR_SEL ,
             LT_CLEAR_SEL .

      LOOP AT LT_SEL
      ASSIGNING <LS_SEL>.

        READ TABLE LO_MODEL->GR_O__APPLICATION->GD_T__DIMENSIONS
        WITH TABLE KEY DIMENSION = <LS_SEL>-DIMENSION
        ATTRIBUTE = <LS_SEL>-ATTRIBUTE
        ASSIGNING <LS_DIMENSION>.

        IF SY-SUBRC = 0.

          LS_CLEAR_SEL-DIMENSION   = <LS_SEL>-DIMENSION .
          LS_CLEAR_SEL-ATTRIBUTE   = <LS_SEL>-ATTRIBUTE .
          LS_CLEAR_SEL-SIGN        = <LS_SEL>-SIGN .
          LS_CLEAR_SEL-OPTION      = <LS_SEL>-OPTION .

          LS_RANGE-CHANM  = <LS_DIMENSION>-TECH_NAME.
          LS_RANGE-SIGN   = <LS_SEL>-SIGN.
          LS_RANGE-COMPOP = <LS_SEL>-OPTION.
          LS_RANGE-LOW    = <LS_SEL>-LOW.

          FIND REGEX `^BAS\([A-Z0-9\_\.]+\)` IN <LS_SEL>-HIGH IGNORING CASE .
          IF SY-SUBRC = 0.
            MESSAGE E001(00) WITH `Error! ` ` Illegal value for high-value selection: ` <LS_SEL>-HIGH .
          ELSE.
            LS_CLEAR_SEL-HIGH      = <LS_SEL>-HIGH .
            LS_RANGE-HIGH = <LS_SEL>-HIGH .
          ENDIF.

          FIND REGEX `^BAS\([A-Z0-9\_\.]+\)` IN LS_RANGE-LOW IGNORING CASE.
          IF SY-SUBRC = 0.

            IF <LS_SEL>-HIGH IS NOT INITIAL.
              MESSAGE E001(00) WITH `Error!` ` High-value must be space with low-value: ` <LS_SEL>-HIGH .
            ENDIF.

            REPLACE ALL OCCURRENCES OF REGEX `(^BAS\(|\))` IN  LS_RANGE-LOW WITH SPACE.
            CLEAR: LD_V__MEMBER , LD_T__PARAM , LD_V__VALUE .
            LD_V__MEMBER = CL_UJK_UTIL=>BAS( I_DIM_NAME = <LS_SEL>-DIMENSION I_MEMBER = LS_RANGE-LOW ).
            SPLIT LD_V__MEMBER AT ',' INTO TABLE LD_T__PARAM.
            LOOP AT LD_T__PARAM INTO LD_V__VALUE.
              LS_RANGE-LOW    = LD_V__VALUE.
              LS_RANGE-HIGH   = SPACE .
              COLLECT LS_RANGE INTO L_T_RANGE .
              LS_CLEAR_SEL-LOW    = LD_V__VALUE.
              LS_CLEAR_SEL-HIGH   = SPACE .
              COLLECT LS_CLEAR_SEL INTO LT_CLEAR_SEL .
            ENDLOOP.

          ELSE.
            COLLECT LS_RANGE INTO L_T_RANGE .
            LS_CLEAR_SEL-LOW = <LS_SEL>-LOW .
            COLLECT LS_CLEAR_SEL INTO LT_CLEAR_SEL .
          ENDIF.
        ELSE.
          CLEAR: LV_MSG_01 , LV_MSG_02 .
          CONCATENATE `Error! Dimension `  <LS_SEL>-DIMENSION INTO LV_MSG_01 .
          CONCATENATE ` is not found for application ` LV_APPL_ID `.`  INTO LV_MSG_02 .
          MESSAGE E001(00) WITH LV_MSG_01 LV_MSG_02 .
        ENDIF.
      ENDLOOP.

* dafinition exit tables
      CLEAR: LR_T__TECHNAME ,
             LR_T__APPLNAME ,
             LR_S__APPLNAME_TL ,
             LR_T__APPLNAME_TL .

      CREATE DATA LR_T__TECHNAME TYPE HANDLE LO_MODEL->GD_S__HANDLE-TAB-TECH_NAME.
      CREATE DATA LR_T__APPLNAME TYPE HANDLE LO_MODEL->GD_S__HANDLE-TAB-APPL_NAME.
      ASSIGN
      : LR_T__TECHNAME->* TO <LT_TECH>
      , LR_T__APPLNAME->* TO <LT_APPL>
      .

      CREATE DATA LR_S__APPLNAME_TL LIKE LINE OF <LT_APPL>.
      ASSIGN LR_S__APPLNAME_TL->* TO <LS_APPL>.
      CREATE DATA LR_T__APPLNAME_TL LIKE HASHED TABLE OF <LS_APPL> WITH UNIQUE DEFAULT KEY.
      ASSIGN LR_T__APPLNAME_TL->* TO <LT_APPL_TL>
      .

      CLEAR: LR_DATA ,
             GR_O__WRITE_TO_BPC ,
             LD_S__FIELD ,
             LD_T__FIELD ,
             LD_V__RULE_ID .

      CREATE DATA LR_DATA LIKE LINE OF <LT_APPL>.
      ASSIGN LR_DATA->* TO <LD_S__DATA>.

      CREATE OBJECT GR_O__WRITE_TO_BPC
        EXPORTING
          I_APPSET_ID  = P_APPSET
          I_APPL_ID    = LV_APPL_ID
          I_TYPE_PK    = ZBD0C_TY_TAB-HAS_UNIQUE_DK
          IF_AUTO_SAVE = ABAP_TRUE.


      ASSIGN LO_MODEL->GR_T__DIMENSION->* TO <LD_T__DIM>.
      LOOP AT <LD_T__DIM> INTO LD_S__DIM.
        LD_S__DATA-NAME = LO_MODEL->GET_TECH_ALIAS( DIMENSION = LD_S__DIM-DIMENSION ATTRIBUTE = LD_S__DIM-ATTRIBUTE ).
        LD_S__FIELD-TG-DIMENSION = LD_S__DIM-DIMENSION.
        ASSIGN COMPONENT LD_S__DIM-DIMENSION OF STRUCTURE <LD_S__DATA> TO <LD_V__DATA>.
        GET REFERENCE OF <LD_V__DATA> INTO LD_S__FIELD-SC-DATA.
        INSERT LD_S__FIELD INTO TABLE LD_T__FIELD.
      ENDLOOP.

      LD_V__RULE_ID = GR_O__WRITE_TO_BPC->SET_RULE_ASSIGN( IT_FIELD = LD_T__FIELD I_MODE_ADD = ZBD0C_MODE_ADD_LINE-COLLECT ).
 ENDIF. " 'CREAT OBJECTS'

* clear target scoup
      IF 'CLEAR' = 'CLEAR'.

        CLEAR LV_MSG_01.
        CONCATENATE `*** Clear ***` ` (` SY-UZEIT(2) `:` SY-UZEIT+2(2) `:` SY-UZEIT+4(2) `).` INTO LV_MSG_01 .
        WRITE: / LV_MSG_01 .

        IF LINES( LT_CLEAR_SEL ) > 0.

          CLEAR LR_O__TARGET .
          TRY.
              CREATE OBJECT LR_O__TARGET
                EXPORTING
                  I_APPSET_ID      = P_APPSET
                  I_APPL_ID        = LV_APPL_ID
                  IT_RANGE         = LT_CLEAR_SEL
                  I_TYPE_PK        = ZBD0C_TY_TAB-STD_NON_UNIQUE_DK
                  IF_INVERT        = ABAP_TRUE
                  IF_SUPPRESS_ZERO = ABAP_FALSE.
            CATCH ZCX_BD00_CREATE_OBJ.
*        raise err_target_create.
          ENDTRY.

          WHILE LR_O__TARGET->NEXT_PACK( ZBD0C_READ_MODE-PACK ) EQ ZBD0C_READ_PACK .
            LR_O__TARGET->WRITE_BACK( ABAP_TRUE ).
          ENDWHILE.
          ZCL_BD00_RFC_TASK=>WAIT_END_ALL_TASK( ).

* Log from clearing class
          CLEAR: LD_T__LOG_READ ,
                 LD_T__LOG_WRITE ,
                 NUM_READ ,
                 NUM_WRITE ,
                 LV_RAISE_WB ,
                 E_MESSAGE .

          CALL METHOD LR_O__TARGET->GET_LOG
            IMPORTING
              E_T__READ = LD_T__LOG_READ.

          CALL METHOD LR_O__TARGET->GET_LOG
            IMPORTING
              E_T__WRITE = LD_T__LOG_WRITE.

          LOOP AT LD_T__LOG_READ ASSIGNING <LD_S__LOG_READ>.
            ADD <LD_S__LOG_READ>-SUP_REC TO NUM_READ.
          ENDLOOP.

          LOOP AT LD_T__LOG_WRITE ASSIGNING <LD_S__LOG_WRITE>.
            ADD <LD_S__LOG_WRITE>-STATUS_RECORDS-NR_SUBMIT TO NUM_WRITE-NR_SUBMIT.
            ADD <LD_S__LOG_WRITE>-STATUS_RECORDS-NR_FAIL TO NUM_WRITE-NR_FAIL.
            ADD <LD_S__LOG_WRITE>-STATUS_RECORDS-NR_SUCCESS TO NUM_WRITE-NR_SUCCESS.
            ADD <LD_S__LOG_WRITE>-CNT_RAISE_WRITE TO LV_RAISE_WB.
            APPEND LINES OF <LD_S__LOG_WRITE>-MESSAGE TO E_MESSAGE.
          ENDLOOP.

          SORT E_MESSAGE.
          DELETE ADJACENT DUPLICATES FROM E_MESSAGE.

          WRITE: / `Read:` , NUM_READ ,
                 / `Rows to write:` , NUM_WRITE-NR_SUBMIT ,
                 / `Failed rows:` , NUM_WRITE-NR_FAIL ,
                 / `Written rows:` , NUM_WRITE-NR_SUCCESS .
        IF LV_RAISE_WB > 0.
          WRITE: / `Number of WB raises:` , LV_RAISE_WB .
        ENDIF.
          IF NUM_WRITE-NR_FAIL > 0 .
            WRITE: / `Error messages: ` COLOR COL_NEGATIVE .
            LOOP AT E_MESSAGE ASSIGNING <FS_MESSAGE> .
              WRITE / <FS_MESSAGE>-MESSAGE COLOR COL_NEGATIVE  .
            ENDLOOP.
          ENDIF.

        ELSE.
          MESSAGE E001(00) WITH `Error! Selections for clearing are empty! ` ` Data clearing is unacceptable!` .
        ENDIF.
      ENDIF. " 'CLEAR'

* Read data from source & Write to target
      L_FIRST_CALL = RS_C_TRUE.
      CLEAR: NUM_READ ,
             NUM_WRITE ,
             LV_RAISE_WB ,
             E_MESSAGE ,
             LD_F__EOD .

    CLEAR LV_MSG_01.
    CONCATENATE `*** Read & Write ***` ` (` SY-UZEIT(2) `:` SY-UZEIT+2(2) `:` SY-UZEIT+4(2) `).` INTO LV_MSG_01 .
    WRITE: / LV_MSG_01 .

      WHILE LD_F__EOD <> ABAP_TRUE.

* read data
        IF 'READ' = 'READ' .

          CALL FUNCTION 'ZBD00_RFC_BPC_READ_BY_PACK' DESTINATION LV_DEST
            EXPORTING
              I_APPSET_ID            = P_APPSET
              I_APPL_ID              = LV_APPL_ID
              I_REFERENCE_DATE       = SY-DATUM
              I_S_RFCMODE            = LS_RFCMODE
              I_ROLLUP_ONLY          = RS_C_FALSE
              I_SUPPRESS_ZERO        = RS_C_FALSE
              I_TYPE_TABLE           = LO_MODEL->GD_V__TYPE_PK
              I_LOOP                 = P_LP
            IMPORTING
              E_END_OF_DATA          = LD_F__EOD
              E_RFCDATA_UC           = LS_RFCDATA_UC
            TABLES
              I_T_RANGE              = L_T_RANGE
              E_T_FIELD              = L_T_FIELD
              I_T_DIM_LIST           = LO_MODEL->GD_T__DIM_LIST
            CHANGING
              C_FIRST_CALL           = L_FIRST_CALL
            EXCEPTIONS
              ILLEGAL_INPUT          = 1
              ILLEGAL_INPUT_SFC      = 2
              ILLEGAL_INPUT_SFK      = 3
              ILLEGAL_INPUT_RANGE    = 4
              ILLEGAL_INPUT_TABLESEL = 5
              NO_AUTHORIZATION       = 6
              ILLEGAL_DOWNLOAD       = 7
              ILLEGAL_TABLENAME      = 8
              TRANS_NO_WRITE_MODE    = 9
              X_MESSAGE              = 10
              ILLEGAL_RESULTTYPE     = 11
              OTHERS                 = 12.
          IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF.

          CALL FUNCTION  'RSDRI_DATA_UNWRAP'  "'ZBD00_DATA_UNWRAP'
            EXPORTING
              I_RFCDATA_UC = LS_RFCDATA_UC
            CHANGING
              C_T_DATA    = <LT_TECH>.

          CALL FUNCTION   'RSDRI_DATA_UNWRAP' "'ZBD00_DATA_UNWRAP'
          EXPORTING
              I_RFCDATA_UC = LS_RFCDATA_UC
          CHANGING
            C_T_DATA    = <LT_APPL>.

          LV_COUNT = LINES( <LT_APPL> ).
          ADD LV_COUNT TO NUM_READ .

        ENDIF. " READ

*        loop at <lt_appl> assigning <ls_appl>.
*          collect <ls_appl> into <lt_appl_tl> .
*        endloop.

* break-point.

* write
        IF 'WRITE' = 'WRITE' .

*        clear lv_msg_01.
*        concatenate `*** Write ***` ` (` sy-uzeit(2) `:` sy-uzeit+2(2) `:` sy-uzeit+4(2) `).` into lv_msg_01 .
*        write: / lv_msg_01 .

          LOOP AT <LT_APPL> INTO <LD_S__DATA>.
            GR_O__WRITE_TO_BPC->RULE_ASSIGN( LD_V__RULE_ID ).
          ENDLOOP.

        ENDIF. " 'WRITE'
        CLEAR <LT_APPL>.
        CLEAR <LT_TECH>.
        CLEAR LS_RFCDATA_UC .
        CLEAR L_T_FIELD .
      ENDWHILE.

      GR_O__WRITE_TO_BPC->WRITE_BACK( ABAP_TRUE ).
      ZCL_BD00_RFC_TASK=>WAIT_END_ALL_TASK( ).

* Log from write class
      CLEAR: LD_T__LOG_READ ,
             LD_T__LOG_WRITE .

      CALL METHOD GR_O__WRITE_TO_BPC->GET_LOG
        IMPORTING
          E_T__WRITE = LD_T__LOG_WRITE.

      LOOP AT LD_T__LOG_WRITE ASSIGNING <LD_S__LOG_WRITE>.
        ADD <LD_S__LOG_WRITE>-STATUS_RECORDS-NR_SUBMIT TO NUM_WRITE-NR_SUBMIT.
        ADD <LD_S__LOG_WRITE>-STATUS_RECORDS-NR_FAIL TO NUM_WRITE-NR_FAIL.
        ADD <LD_S__LOG_WRITE>-STATUS_RECORDS-NR_SUCCESS TO NUM_WRITE-NR_SUCCESS.
        ADD <LD_S__LOG_WRITE>-CNT_RAISE_WRITE TO LV_RAISE_WB.
        APPEND LINES OF <LD_S__LOG_WRITE>-MESSAGE TO E_MESSAGE.
      ENDLOOP.
      SORT E_MESSAGE.
      DELETE ADJACENT DUPLICATES FROM E_MESSAGE.

* Print log
      WRITE: / `Read:` , NUM_READ ,
      / `Rows to write:` , NUM_WRITE-NR_SUBMIT ,
      / `Failed rows:` , NUM_WRITE-NR_FAIL ,
      / `Written rows:` , NUM_WRITE-NR_SUCCESS .
      IF LV_RAISE_WB > 0.
       WRITE: / `Number of WB raises:` , LV_RAISE_WB .
      ENDIF.
      IF NUM_WRITE-NR_FAIL > 0 .
        WRITE: / `Error messages: ` COLOR COL_NEGATIVE .
        LOOP AT E_MESSAGE ASSIGNING <FS_MESSAGE> .
          WRITE / <FS_MESSAGE>-MESSAGE COLOR COL_NEGATIVE  .
        ENDLOOP.
      ENDIF.

      CLEAR LV_MSG_01.
      CONCATENATE `End execution for ` LV_APPL_ID `.` INTO LV_MSG_01 .
      WRITE: / LV_MSG_01 COLOR COL_TOTAL.
      ULINE.
    ENDLOOP. " APPLICATION

  ENDIF .  " 'EXECUTION'

  CLEAR LV_MSG_01.
  CONCATENATE `End program ZBD00_RFC_BPC_DATA_COPY` ` (` SY-UZEIT(2) `:` SY-UZEIT+2(2) `:` SY-UZEIT+4(2) `).` INTO LV_MSG_01.
  WRITE: / LV_MSG_01 COLOR COL_BACKGROUND .
