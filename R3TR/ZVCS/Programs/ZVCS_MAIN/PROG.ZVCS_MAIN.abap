*&---------------------------------------------------------------------*
*& Report  ZVCS_MAIN
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZVCS_MAIN.

*****************************
* Type Pools
*****************************
TYPE-POOLS: SEOO, SEOP, SEOS, SEOK, SREXT, SYDES, SEDI, SSCR, ZVCST, ZVCSC.

*****************************
* Tables
*****************************
TABLES
: TLIBG
, TRDIR
, SSCRFIELDS
, SEOCLSKEY
, VSEOINTERF
, TADIR
, DD01L
, DD04L
, DD02L
, DD40L
, DD30L
, D020S
, DDTYPET
, T100
, TDEVC
, ENHOBJ
, UJA_APPSET_INFO
, UJA_APPL
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
    , DIRECTORY_F4
        IMPORTING PCFILE TYPE C OPTIONAL
        RETURNING VALUE(R_PATH) TYPE STRING
    , CHECK_PATH
        IMPORTING I_PATH     TYPE LOCALFILE OPTIONAL
        RETURNING VALUE(R_FILE) TYPE STRING
    , GET_INITIAL_DIRECTORY
        RETURNING VALUE(R_PATH) TYPE STRING
    .
ENDCLASS.                    "process_path DEFINITION

DATA
: PCFILE       TYPE LOCALFILE
, PATH1        TYPE LOCALFILE
, LD_S__PATH   TYPE ZVCST_S__PATH
, LD_T__OBJECT TYPE  ZVCST_T__R3TR_OBJ.


**********************************************************************
* Parameter/select-options
**********************************************************************
SELECTION-SCREEN BEGIN OF BLOCK B0000 WITH FRAME TITLE T_B0. " head
PARAMETERS DOWNLOAD RADIOBUTTON GROUP R1 DEFAULT 'X' USER-COMMAND UC.
PARAMETERS UPLOAD   RADIOBUTTON GROUP R1.
SELECTION-SCREEN END OF BLOCK B0000.

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE T_B1. " download
SELECTION-SCREEN BEGIN OF BLOCK B12 WITH FRAME TITLE T_B12.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (5) CPATH FOR FIELD DPATH             MODIF ID A10.
PARAMETERS: DPATH TYPE LOCALFILE                               MODIF ID A10.
SELECTION-SCREEN COMMENT (3) T_BDIR                            MODIF ID A23.
PARAMETERS: F_SYS AS CHECKBOX DEFAULT `X`                      MODIF ID A23.
SELECTION-SCREEN COMMENT (5) T_F_SYS FOR FIELD F_SYS           MODIF ID A23.
PARAMETERS: F_PAC AS CHECKBOX DEFAULT `X`                      MODIF ID A23.
SELECTION-SCREEN COMMENT (8) T_F_PAC FOR FIELD F_PAC           MODIF ID A23.
PARAMETERS: F_DIR AS CHECKBOX DEFAULT `X`                      MODIF ID A23.
SELECTION-SCREEN COMMENT (5) T_F_DIR FOR FIELD F_DIR           MODIF ID A23.
PARAMETERS: F_ELE AS CHECKBOX DEFAULT `X`                      MODIF ID A23.
SELECTION-SCREEN COMMENT (8) T_F_ELE FOR FIELD F_ELE           MODIF ID A23.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END   OF BLOCK B12.

SELECTION-SCREEN BEGIN OF BLOCK A WITH FRAME TITLE COMMENT.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(8) CCOMP                            MODIF ID A00.
PARAMETERS: COMPLETE RADIOBUTTON GROUP C1                      MODIF ID A00.
SELECTION-SCREEN COMMENT 18(8) CNOSOUR                         MODIF ID A00.
PARAMETERS: NOSOURCE RADIOBUTTON GROUP C1 DEFAULT 'X'          MODIF ID A00.
SELECTION-SCREEN COMMENT 38(10) CNOCR                          MODIF ID A00.
PARAMETERS: NOCROSS RADIOBUTTON GROUP C1                       MODIF ID A00.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(19) CGRADE                          MODIF ID A00.
PARAMETERS: GRADE TYPE SCR_GRADE                               MODIF ID A00.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK A.

SELECTION-SCREEN BEGIN OF BLOCK B11 WITH FRAME TITLE T_SELECT.
SELECT-OPTIONS: DEVC     FOR TDEVC-DEVCLASS                    MODIF ID A00. " memory id lib.
SELECT-OPTIONS: INTF     FOR VSEOINTERF-CLSNAME                MODIF ID A00.
SELECT-OPTIONS: MCLSNAME FOR T100-ARBGB                        MODIF ID A00.
SELECT-OPTIONS: CLSNAME  FOR SEOCLSKEY-CLSNAME                 MODIF ID A00.
PARAMETERS:     FRIENDS  AS CHECKBOX DEFAULT 'X'               MODIF ID A00.
SELECT-OPTIONS: FUNCAREA FOR TLIBG-AREA                        MODIF ID A00.
SELECT-OPTIONS: PROGRAM  FOR TRDIR-NAME                        MODIF ID A00.
PARAMETERS:     DYNPRO   AS CHECKBOX DEFAULT 'X'               MODIF ID A00.
SELECT-OPTIONS: TABLE    FOR DD02L-TABNAME                     MODIF ID A00.
SELECT-OPTIONS: VIEW     FOR DD02L-TABNAME                     MODIF ID A00.
SELECT-OPTIONS: TABLETYP FOR DD40L-TYPENAME                    MODIF ID A00.
SELECT-OPTIONS: SEARCHLP FOR DD30L-SHLPNAME                    MODIF ID A00.
SELECT-OPTIONS: DOMAIN   FOR DD01L-DOMNAME                     MODIF ID A00.
SELECT-OPTIONS: DELEMENT FOR DD04L-ROLLNAME                    MODIF ID A00.
SELECT-OPTIONS: TYPGROUP FOR DDTYPET-TYPEGROUP                 MODIF ID A00.
SELECT-OPTIONS: ENHS     FOR ENHOBJ-ENHNAME                    MODIF ID A00.

SELECTION-SCREEN END     OF BLOCK B11.
SELECTION-SCREEN BEGIN OF BLOCK B13 WITH FRAME TITLE T_BPC.
SELECT-OPTIONS: APPS FOR UJA_APPSET_INFO-APPSET_ID NO INTERVALS MODIF ID A00.
SELECT-OPTIONS: APPL FOR UJA_APPL-APPLICATION_ID NO INTERVALS   MODIF ID A00.
PARAMETERS:     SCLO AS CHECKBOX DEFAULT ``                     MODIF ID A00.
PARAMETERS:     PACK AS CHECKBOX DEFAULT ``                     MODIF ID A00.
PARAMETERS:     XLTP AS CHECKBOX DEFAULT ``                     MODIF ID A00.
SELECTION-SCREEN END OF BLOCK B13.

SELECTION-SCREEN END OF BLOCK B1.

SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE T_B2.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(30) CUP_SING                        MODIF ID B00.
PARAMETERS: UP_SING RADIOBUTTON GROUP J1 DEFAULT 'X'           MODIF ID B00.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(30) CUP_IND                         MODIF ID B00.
PARAMETERS: UP_INDEX RADIOBUTTON GROUP J1                      MODIF ID B00.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(25) CFILE_UP                        MODIF ID B00.
PARAMETERS: UPATH TYPE LOCALFILE DEFAULT '.xml'                MODIF ID B00.
SELECTION-SCREEN END OF LINE.
PARAMETERS POSTFIX(1)                                          MODIF ID B00.
SELECTION-SCREEN END OF BLOCK B2.

************************************************************************
* Initialization
************************************************************************
INITIALIZATION.
  MOVE
  : `Mode`                            TO T_B0
  , 'Parameters for Download'         TO T_B1
  , 'Parameters for Upload'           TO T_B2
  , 'Setting dpath'                   TO T_B12
  , ' \'                              TO T_BDIR
  , 'Selections'                      TO T_SELECT
  , 'R3TR\'                           TO T_F_SYS
  , 'package\'                        TO T_F_PAC
  , 'type\'                           TO T_F_DIR
  , 'element\'                        TO T_F_ELE
  , 'Crossreference'                  TO COMMENT
  , 'Complete'                        TO CCOMP
  , 'NoSource'                        TO CNOSOUR
  , 'NoCrossref'                      TO CNOCR
  , 'Grade of Sourcescan'             TO CGRADE
  , 'Path'                            TO CPATH
  , 'Path'                            TO CFILE_UP
  , 'Upload single XML-File'          TO CUP_SING
  , 'Upload file FILE_INDEX.XML'      TO CUP_IND
  .

************************************************************************
* At selection-screen
************************************************************************
AT SELECTION-SCREEN OUTPUT.
*  dpath    = process_path=>get_initial_directory( ).
*  upath    = process_path=>get_initial_directory( ).

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = `AIA`.
      SCREEN-INPUT = '0'.
    ENDIF.

    CASE ABAP_TRUE.
      WHEN DOWNLOAD.
      WHEN UPLOAD.
    ENDCASE.

    IF DOWNLOAD = ABAP_TRUE AND SCREEN-GROUP1 CP `B++`.
      SCREEN-ACTIVE  = '0'.
    ENDIF.

    IF UPLOAD = ABAP_TRUE AND SCREEN-GROUP1 CP `A++`.
      SCREEN-ACTIVE  = '0'.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

***********************************************************************
* At selection-screen on value request
***********************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR DPATH.
  DPATH = PROCESS_PATH=>DIRECTORY_F4( ).         " xml index

AT SELECTION-SCREEN ON VALUE-REQUEST FOR UPATH.
  UPATH = PROCESS_PATH=>DIRECTORY_F4( ).         " xml index


AT SELECTION-SCREEN.
  IF SY-UCOMM = `ONLI`.
    PERFORM CHECK_SELECTION.
  ENDIF .

**********************************************************************
* start-of-selection
**********************************************************************
START-OF-SELECTION.

  PERFORM MAIN.

END-OF-SELECTION.
**********************************************************************



*----------------------------------------------------------------------*
* CLASS IMPLEMENTATION
*----------------------------------------------------------------------*

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

    R_PATH = `C:\temp\`.
  ENDMETHOD.                    "get_initial_directory

  METHOD FILE_F4.
    DATA
    : LT_FILE_TABLE TYPE FILETABLE
    , LS_FILE_TABLE LIKE LINE OF LT_FILE_TABLE.

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

    CHECK PCFILE IS SUPPLIED.

    IF STRLEN( R_PATH ) = 3." указание на диск
      R_PATH = R_PATH+0(2).
    ENDIF.

    CASE PCFILE.
      WHEN `XML`.
        CONCATENATE R_PATH `\*.xml` INTO R_PATH.
      WHEN `TXT`.
        CONCATENATE R_PATH `\*.txt` INTO R_PATH.
    ENDCASE.
  ENDMETHOD.                    "directory_f4

  METHOD CHECK_PATH.
    DATA
    : STRING_XY TYPE STRING
    , L_REGEX TYPE STRING
    , L_FILENAME TYPE STRING
    , L_PATH TYPE STRING
    .

    IF I_PATH IS SUPPLIED.
      IF I_PATH IS INITIAL.
        MESSAGE E001(00) WITH 'Please enter dpath'.
      ENDIF.

      MOVE I_PATH TO STRING_XY.
      L_REGEX = '\A([a-z]):\\([^/:*?"<>$ \r\n]*\\)$'.
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

*----------------------------------------------------------------------*
* Forms
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  main
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM MAIN.

  IF DOWNLOAD EQ 'X'.

    " download
    PERFORM DOWNLOAD.

  ELSEIF UPLOAD EQ 'X'.

    " upload
    PERFORM UPLOAD.

  ENDIF.

ENDFORM . " main

*&---------------------------------------------------------------------*
*&      Form  download
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DOWNLOAD.

*  data
*  : lr_o__vcs_r3tr_process type ref to zcl_vcs_r3tr_process
*  .

  PERFORM CREATE_OBJECT_LIST.

*  create object lr_o__vcs_r3tr_process.

  LD_S__PATH-PATH  = DPATH.
  LD_S__PATH-F_SYS = F_SYS.
  LD_S__PATH-F_PAC = F_PAC.
  LD_S__PATH-F_DIR = F_DIR.
  LD_S__PATH-F_ELE = F_ELE.

  ZCL_VCS_OBJECTS=>SET_TASK_DOWNLOAD_FOR_R3TR( I_T__OBJECT = LD_T__OBJECT I_S__PATH = LD_S__PATH ).
*  zcl_vcs_objects=>set_task_download_for_bpc( i_t__appset_id = apps[] i_t__appl_id = appl[] i_s__path = ld_s__path i_f__lgf = sclo i_f__pack = pack i_f__xltp = xltp ).

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

*  lr_o__vcs_r3tr_process->master_upload( i_v__directory = ld_v__pcpath
*                                         i_v__form_name = `CHOOSE_DOWNLOAD`
*                                       ).
ENDFORM.                    "upload

*&---------------------------------------------------------------------*
*&      Form  create_object_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CREATE_OBJECT_LIST.

  DATA
  : LD_S__OBJECT TYPE ZVCST_S__R3TR_OBJ
  .

  LD_S__OBJECT-PGID = ZVCSC_R3TR.

  IF NOT DEVC[] IS INITIAL.
    LD_S__OBJECT-TYPE = ZVCSC_R3TR_TYPE-DEVC.
    LD_S__OBJECT-OBJ_RANGE = DEVC[].
    INSERT LD_S__OBJECT INTO TABLE LD_T__OBJECT.
  ENDIF.

  IF NOT INTF[] IS INITIAL.
    LD_S__OBJECT-TYPE = ZVCSC_R3TR_TYPE-INTF.
    LD_S__OBJECT-OBJ_RANGE = INTF[].
    INSERT LD_S__OBJECT INTO TABLE LD_T__OBJECT.
  ENDIF.

  IF NOT MCLSNAME[] IS INITIAL.
    LD_S__OBJECT-TYPE = ZVCSC_R3TR_TYPE-MSAG.
    LD_S__OBJECT-OBJ_RANGE = MCLSNAME[].
    INSERT LD_S__OBJECT INTO TABLE LD_T__OBJECT.
  ENDIF.

  IF NOT CLSNAME[] IS INITIAL.
    LD_S__OBJECT-TYPE = ZVCSC_R3TR_TYPE-CLAS.
    LD_S__OBJECT-OBJ_RANGE = CLSNAME[].
    INSERT LD_S__OBJECT INTO TABLE LD_T__OBJECT.
  ENDIF.

  IF NOT FUNCAREA[] IS INITIAL.
    LD_S__OBJECT-TYPE = ZVCSC_R3TR_TYPE-FUGR.
    LD_S__OBJECT-OBJ_RANGE = FUNCAREA[].
    INSERT LD_S__OBJECT INTO TABLE LD_T__OBJECT.
  ENDIF.

  IF NOT PROGRAM[] IS INITIAL.
    LD_S__OBJECT-TYPE = ZVCSC_R3TR_TYPE-PROG.
    LD_S__OBJECT-OBJ_RANGE = PROGRAM[].
    INSERT LD_S__OBJECT INTO TABLE LD_T__OBJECT.
  ENDIF.

  IF NOT TABLE[] IS INITIAL.
    LD_S__OBJECT-TYPE = ZVCSC_R3TR_TYPE-TABL.
    LD_S__OBJECT-OBJ_RANGE = TABLE[].
    INSERT LD_S__OBJECT INTO TABLE LD_T__OBJECT.
  ENDIF.

  IF NOT VIEW[] IS INITIAL.
    LD_S__OBJECT-TYPE = ZVCSC_R3TR_TYPE-VIEW.
    LD_S__OBJECT-OBJ_RANGE = VIEW[].
    INSERT LD_S__OBJECT INTO TABLE LD_T__OBJECT.
  ENDIF.

  IF NOT TABLETYP[] IS INITIAL.
    LD_S__OBJECT-TYPE = ZVCSC_R3TR_TYPE-TTYP.
    LD_S__OBJECT-OBJ_RANGE = TABLETYP[].
    INSERT LD_S__OBJECT INTO TABLE LD_T__OBJECT.
  ENDIF.

  IF NOT SEARCHLP[] IS INITIAL.
    LD_S__OBJECT-TYPE = ZVCSC_R3TR_TYPE-SHLP.
    LD_S__OBJECT-OBJ_RANGE = SEARCHLP[].
    INSERT LD_S__OBJECT INTO TABLE LD_T__OBJECT.
  ENDIF.

  IF NOT DOMAIN[] IS INITIAL.
    LD_S__OBJECT-TYPE = ZVCSC_R3TR_TYPE-DOMA.
    LD_S__OBJECT-OBJ_RANGE = DOMAIN[].
    INSERT LD_S__OBJECT INTO TABLE LD_T__OBJECT.
  ENDIF.

  IF NOT DELEMENT[] IS INITIAL.
    LD_S__OBJECT-TYPE = ZVCSC_R3TR_TYPE-DTEL.
    LD_S__OBJECT-OBJ_RANGE = DELEMENT[].
    INSERT LD_S__OBJECT INTO TABLE LD_T__OBJECT.
  ENDIF.

  IF NOT TYPGROUP[] IS INITIAL.
    LD_S__OBJECT-TYPE = ZVCSC_R3TR_TYPE-TYPE.
    LD_S__OBJECT-OBJ_RANGE = TYPGROUP[].
    INSERT LD_S__OBJECT INTO TABLE LD_T__OBJECT.
  ENDIF.

  IF NOT ENHS[] IS INITIAL.
    LD_S__OBJECT-TYPE = ZVCSC_R3TR_TYPE-ENHS.
    LD_S__OBJECT-OBJ_RANGE = ENHS[].
    INSERT LD_S__OBJECT INTO TABLE LD_T__OBJECT.
  ENDIF.



*friends
*dynpro

ENDFORM.                    "create_object_list

*&---------------------------------------------------------------------*
*&      Form  choose_download
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHOOSE_DOWNLOAD TABLES SELECTION STRUCTURE SHVALUE..

  ZCL_VCS_OBJECTS=>CD_F__POPUP = SPACE.

ENDFORM.                    "choose_download

*&---------------------------------------------------------------------*
*&      Form  check_selection
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CHECK_SELECTION .

  CONSTANTS
  : C_Z TYPE C VALUE `Z`
  , C_Y TYPE C VALUE `Y`
  .

  IF DOWNLOAD EQ 'X'.

    IF  CLSNAME[]  IS INITIAL
    AND MCLSNAME[] IS INITIAL
    AND FUNCAREA[] IS INITIAL
    AND PROGRAM[]  IS INITIAL
    AND DEVC[]     IS INITIAL
    AND INTF[]     IS INITIAL
    AND DOMAIN[]   IS INITIAL
    AND DELEMENT[] IS INITIAL
    AND TABLE[]    IS INITIAL
    AND VIEW[]     IS INITIAL
    AND TABLETYP[] IS INITIAL
    AND SEARCHLP[] IS INITIAL
    AND TYPGROUP[] IS INITIAL
    AND ENHS[]     IS INITIAL.
*      message e000(38) with 'Please restrict selection'.
    ENDIF.

* Entwicklungsklassen ueberpruefen
    LOOP AT DEVC.
      IF NOT DEVC-LOW IS INITIAL.
        IF DEVC-LOW(1) NE C_Z
        AND DEVC-LOW(1) NE C_Y
        AND DEVC-LOW NE '$TMP'.
          MESSAGE E000(38) WITH 'Package must begin with Z or Y'.
        ENDIF.
      ENDIF.
      IF NOT DEVC-HIGH IS INITIAL.
        IF DEVC-HIGH(1) NE C_Z
        AND DEVC-HIGH(1) NE C_Y
        AND DEVC-HIGH NE '$TMP'.
          MESSAGE E000(38) WITH 'Package must begin with Z or Y'.
        ENDIF.
      ENDIF.
    ENDLOOP.

* Table ueberpruefen
    LOOP AT TABLE.
      IF NOT TABLE-LOW IS INITIAL.
        IF TABLE-LOW(1) NE C_Z
        AND TABLE-LOW(1) NE C_Y.
          MESSAGE E000(38) WITH 'Table must begin with Z or Y'.
        ENDIF.
      ENDIF.
      IF NOT TABLE-HIGH IS INITIAL.
        IF TABLE-HIGH(1) NE C_Z
        AND TABLE-HIGH(1) NE C_Y.
          MESSAGE E000(38) WITH 'Table must begin with Z or Y'.
        ENDIF.
      ENDIF.
    ENDLOOP.

* Domain ueberpruefen
    LOOP AT DOMAIN.
      IF NOT DOMAIN-LOW IS INITIAL.
        IF DOMAIN-LOW(1) NE C_Z
        AND DOMAIN-LOW(1) NE C_Y.
          MESSAGE E000(38) WITH 'Domain must begin with Z or Y'.
        ENDIF.
      ENDIF.
      IF NOT DOMAIN-HIGH IS INITIAL.
        IF DOMAIN-HIGH(1) NE C_Z
        AND DOMAIN-HIGH(1) NE C_Y.
          MESSAGE E000(38) WITH 'Domain must begin with Z or Y'.
        ENDIF.
      ENDIF.
    ENDLOOP.

* Dataelement ueberpruefen
    LOOP AT DELEMENT.
      IF NOT DELEMENT-LOW IS INITIAL.
        IF DELEMENT-LOW(1) NE C_Z
        AND DELEMENT-LOW(1) NE C_Y.
          MESSAGE E000(38) WITH 'Delement must begin with Z or Y'.
        ENDIF.
      ENDIF.
      IF NOT DELEMENT-HIGH IS INITIAL.
        IF DELEMENT-HIGH(1) NE C_Z
        AND DELEMENT-HIGH(1) NE C_Y.
          MESSAGE E000(38) WITH 'Delement must begin with Z or Y'.
        ENDIF.
      ENDIF.
    ENDLOOP.

* Tabletyp ueberpruefen
    LOOP AT TABLETYP.
      IF NOT TABLETYP-LOW IS INITIAL.
        IF TABLETYP-LOW(1) NE C_Z
        AND TABLETYP-LOW(1) NE C_Y.
          MESSAGE E000(38) WITH 'Tabletype must begin with Z or Y'.
        ENDIF.
      ENDIF.
      IF NOT TABLETYP-HIGH IS INITIAL.
        IF TABLETYP-HIGH(1) NE C_Z
        AND TABLETYP-HIGH(1) NE C_Y.
          MESSAGE E000(38) WITH 'Tabletype must begin with Z or Y'.
        ENDIF.
      ENDIF.
    ENDLOOP.

* Dataelement ueberpruefen
    LOOP AT SEARCHLP.
      IF NOT SEARCHLP-LOW IS INITIAL.
        IF SEARCHLP-LOW(1) NE C_Z
        AND SEARCHLP-LOW(1) NE C_Y.
          MESSAGE E000(38) WITH 'Searchhelp must begin with Z or Y'.
        ENDIF.
      ENDIF.
      IF NOT SEARCHLP-HIGH IS INITIAL.
        IF SEARCHLP-HIGH(1) NE C_Z
        AND SEARCHLP-HIGH(1) NE C_Y.
          MESSAGE E000(38) WITH 'Searchelp must begin with Z or Y'.
        ENDIF.
      ENDIF.
    ENDLOOP.

* Message Class
    LOOP AT MCLSNAME.
      IF NOT MCLSNAME-LOW IS INITIAL.
        IF MCLSNAME-LOW(1) NE C_Z
        AND MCLSNAME-LOW(1) NE C_Y.
          MESSAGE E001(00) WITH 'Message Classname must begin with Z or Y'.
        ENDIF.
      ENDIF.
      IF NOT MCLSNAME-HIGH IS INITIAL.
        IF MCLSNAME-HIGH(1) NE C_Z
        AND MCLSNAME-HIGH(1) NE C_Y.
          MESSAGE E001(00) WITH 'Message Classname must begin with Z or Y'.
        ENDIF.
      ENDIF.
    ENDLOOP.

* Klassenname ueberpruefen
    LOOP AT CLSNAME.
      IF NOT CLSNAME-LOW IS INITIAL.
        IF CLSNAME-LOW(1) NE C_Z
        AND CLSNAME-LOW(1) NE C_Y.
          MESSAGE E000(38) WITH 'Classname must begin with Z or Y'.
        ENDIF.
      ENDIF.
      IF NOT CLSNAME-HIGH IS INITIAL.
        IF CLSNAME-HIGH(1) NE C_Z
        AND CLSNAME-HIGH(1) NE C_Y.
          MESSAGE E000(38) WITH 'Classname must begin with Z or Y'.
        ENDIF.
      ENDIF.
    ENDLOOP.

* Funktionsgruppenname ueberpruefen
    LOOP AT FUNCAREA.
      IF NOT FUNCAREA-LOW IS INITIAL.
        IF FUNCAREA-LOW(1) NE C_Z
        AND FUNCAREA-LOW(1) NE C_Y.
          MESSAGE E000(38) WITH 'Funcarea must begin with Z or Y'.
        ENDIF.
      ENDIF.
      IF NOT FUNCAREA-HIGH IS INITIAL.
        IF FUNCAREA-HIGH(1) NE C_Z
        AND FUNCAREA-HIGH(1) NE C_Y.
          MESSAGE E000(38) WITH 'Funcarea must begin with Z or Y'.
        ENDIF.
      ENDIF.
    ENDLOOP.

* Programs
    LOOP AT PROGRAM.
      IF NOT PROGRAM-LOW IS INITIAL.
        IF PROGRAM-LOW(1) NE C_Z
        AND PROGRAM-LOW(1) NE C_Y.
          MESSAGE E000(38) WITH 'Program must begin with Z or Y'.
        ENDIF.
      ENDIF.
      IF NOT PROGRAM-HIGH IS INITIAL.
        IF PROGRAM-HIGH(1) NE C_Z
        AND PROGRAM-HIGH(1) NE C_Y.
          MESSAGE E000(38) WITH 'Program must begin with Z or Y'.
        ENDIF.
      ENDIF.
    ENDLOOP.

***********************
* Falls es in eine Datei geschrieben werden soll
* For .XML
    DPATH = PROCESS_PATH=>CHECK_PATH( I_PATH = DPATH ).

***********************
* Falls es in mehrere Dateien aufgeteilt wird
*    if sfiles eq 'X'
*    or ctxt   eq 'X'.

* Pfad kontrollieren, ob initial
    IF DPATH IS INITIAL.
      MESSAGE E000(38) WITH 'Please enter dpath'.
    ENDIF.

* Ist der Pfad fuer die .txt Dateien initial
*      if path1 is initial
*      and ctxt eq 'X'.
*        message e000(38) with 'Please enter dpath'.
*      endif.
*
** Pfad ueberpruefen
*      data: length type i,
*            path_xy like dpath,
*            index_xy type sy-index.
*      do 2 times.
*        clear path_xy.
*        move sy-index to index_xy.
*        if index_xy eq 1.
*          if sfiles eq 'X'.
*            move dpath to path_xy.
*          else.
*            continue.
*          endif.
*        else.
*          if ctxt eq 'X'.
*            move path1 to path_xy.
*          else.
*            continue.
*          endif.
*        endif.
*
*        if not path_xy is initial.
*          length = strlen( path_xy ).
*          if length < 3.
*            message e000(38) with 'Please enter valid dpath'.
*          endif.
*          perform check_if_not_xml_file using path_xy.
*          length = length - 1.
*          if path_xy+length(1) ne '/'
*          and path_xy+length(1) ne '\'.
*            concatenate path_xy '\' into path_xy.
*          endif.
*
*          if index_xy eq 1.
*            move path_xy to dpath.
*          else.
*            move path_xy to path1.
*          endif.
*        endif.
*
*      enddo.
*
*    endif.
*
** Macht keinen Sinn in diesem Fall das Pgm. aufzurufen
*    if sfiles is initial
*    and save is initial
*    and display is initial
*    and calledit is initial
*    and ctxt is initial.
*      message e000(38) with 'Please mark at least one checkbox'.
*    endif.
*
*  endif.
*  if upload eq 'X'.
*    data: file_oasis type localfile.
*    move upath to file_oasis.
*    set locale language 'D'.
*    translate file_oasis to upper case.
*    set locale language sy-langu.
* file_index.xml hochladen: Dateiname ueberpruefen
*    if up_index eq 'X'.
*      if not file_oasis cs c_file_index_xml.
*        message e000(38) with 'Please enter file_index.xml'.
*      endif.
*      if not postfix is initial.
*        clear postfix.
*        message e000(38)
*        with 'Please dont enter Postfix for file_index.xml uploads'.
*      endif.
*    endif.
* check, if .XML
*    perform check_if_xml_file using upath.
  ENDIF.

ENDFORM.                    " check_selection
