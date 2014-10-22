*&---------------------------------------------------------------------*
*&  Include           ZZFG_BD00_SERVICESF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  wrap_str_to_c255
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_STRING  text
*      <--P_E_T_OUTDATA  text
*----------------------------------------------------------------------*
FORM WRAP_STR_TO_C255
  USING    I_STRING      TYPE STRING
  CHANGING C_T_RFCDATA   TYPE RSDRI_T_RFCDATA.

  DATA: L_S_RFCDATA   TYPE RSDRI_S_RFCDATA,
        L_STRLEN      TYPE I,
        L_LINELEN     TYPE I,
        L_REST        TYPE I,
        L_OFFSET      TYPE I,
        L_CONT        TYPE C.

* determine length of destination line
  DESCRIBE FIELD L_S_RFCDATA-LINE LENGTH L_LINELEN IN CHARACTER MODE.

* determine length of the string
  L_REST = STRLEN( I_STRING ).

* initialize offset
  L_OFFSET = 0.

* loop over the length of a table line
  WHILE L_REST > 0.

    IF L_REST > L_LINELEN. "remainder does not fit into 1 line
      L_STRLEN = L_LINELEN.
      L_CONT   = 'X'.
    ELSE.                  "remainder does fit into 1 line
      L_STRLEN = L_REST.
      L_CONT   = SPACE.
    ENDIF.

    CLEAR L_S_RFCDATA.
    L_S_RFCDATA-LINE = I_STRING+L_OFFSET(L_STRLEN).
    L_S_RFCDATA-CONT = L_CONT.

    APPEND L_S_RFCDATA TO C_T_RFCDATA.

    L_OFFSET = L_OFFSET + L_LINELEN.
    L_REST   = L_REST   - L_LINELEN.

  ENDWHILE.

ENDFORM.                    " wrap_str_to_c255

*---------------------------------------------------------------------*
*  FORM wrap_str_to_c250
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
*  -->  I_STRING
*  -->  C_T_RFCDATA
*---------------------------------------------------------------------*
FORM WRAP_STR_TO_C250
  USING    I_STRING      TYPE STRING
  CHANGING C_T_RFCDATA   TYPE BAPI6116TDA.

  DATA: L_S_RFCDATA   TYPE BAPI6116DA,
        L_STRLEN      TYPE I,
        L_LINELEN     TYPE I,
        L_REST        TYPE I,
        L_OFFSET      TYPE I,
        L_CONT        TYPE C.

* determine length of destination line
  DESCRIBE FIELD L_S_RFCDATA-DATA LENGTH L_LINELEN IN CHARACTER MODE.

* determine length of the string
  L_REST = STRLEN( I_STRING ).

* initialize offset
  L_OFFSET = 0.

* loop over the length of a table line
  WHILE L_REST > 0.

    IF L_REST > L_LINELEN. "remainder does not fit into 1 line
      L_STRLEN = L_LINELEN.
      L_CONT   = 'X'.
    ELSE.                  "remainder does fit into 1 line
      L_STRLEN = L_REST.
      L_CONT   = SPACE.
    ENDIF.

    CLEAR L_S_RFCDATA.
    L_S_RFCDATA-DATA         = I_STRING+L_OFFSET(L_STRLEN).
    L_S_RFCDATA-CONTINUATION = L_CONT.

    APPEND L_S_RFCDATA TO C_T_RFCDATA.

    L_OFFSET = L_OFFSET + L_LINELEN.
    L_REST   = L_REST   - L_LINELEN.

  ENDWHILE.

ENDFORM.                    " wrap_str_to_c250
*&---------------------------------------------------------------------*
*&      Form  unwrap_c255_to_str
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_T_RFCDATA  text
*      <--P_L_STRING  text
*----------------------------------------------------------------------*
FORM UNWRAP_C255_TO_STR
  USING    I_T_RFCDATA   TYPE RSDRI_T_RFCDATA
  CHANGING E_STRING      TYPE STRING.

  CONSTANTS: L_C_LENGTH   TYPE I VALUE 255.

  DATA: L_BUFFER     TYPE GT_BUFFER,
        L_OFFSET     TYPE I.

  FIELD-SYMBOLS: <L_S_RFCDATA>  TYPE RSDRI_S_RFCDATA,
                 <L_BUFFER>     TYPE GT_BUFFER.

* initialize
  CLEAR: E_STRING.

* have <L_BUFFER> pointing to L_BUFFER
  ASSIGN L_BUFFER TO <L_BUFFER>.

* concatenate all line into string
  LOOP AT I_T_RFCDATA ASSIGNING <L_S_RFCDATA>.
    <L_BUFFER>+L_OFFSET(L_C_LENGTH) = <L_S_RFCDATA>-LINE.
    L_OFFSET = L_OFFSET + L_C_LENGTH.
  ENDLOOP.

* type cast
  E_STRING = L_BUFFER.

ENDFORM.                    " unwrap_c255_to_str
*&---------------------------------------------------------------------*
*&      Form  data_wrap_std
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_T_DATA  text
*      <--P_E_T_OUTDATA  text
*----------------------------------------------------------------------*
FORM DATA_WRAP_STD
  USING    I_T_DATA     TYPE ANY TABLE
  CHANGING E_T_OUTDATA  TYPE RSDRI_T_RFCDATA.

  DATA: L_STRING     TYPE STRING.

  FIELD-SYMBOLS: <L_S_DATA>  TYPE ANY.

* initialize
  CLEAR E_T_OUTDATA.

* loop over I_T_DATA and wrap each line
  LOOP AT I_T_DATA ASSIGNING <L_S_DATA>.

    CLEAR: L_STRING.

    CALL METHOD CL_ABAP_CONTAINER_UTILITIES=>FILL_CONTAINER_C
      EXPORTING
        IM_VALUE     = <L_S_DATA>
      IMPORTING
        EX_CONTAINER = L_STRING.

    PERFORM WRAP_STR_TO_C255
      USING    L_STRING
      CHANGING E_T_OUTDATA.

  ENDLOOP.

ENDFORM.                    " data_wrap_std
*&---------------------------------------------------------------------*
*&      Form  data_wrap_uc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_T_DATA  text
*      <--P_E_OUTDATA_UC  text
*----------------------------------------------------------------------*
FORM DATA_WRAP_UC
  USING    I_T_DATA      TYPE ANY TABLE
           I_COMPRESS    TYPE RS_BOOL
  CHANGING E_OUTDATA_UC  TYPE XSTRING.

  IF I_COMPRESS = RS_C_TRUE.
    EXPORT RSDRI = I_T_DATA
      TO DATA BUFFER E_OUTDATA_UC
      COMPRESSION ON.
  ELSE.
    EXPORT RSDRI = I_T_DATA
      TO DATA BUFFER E_OUTDATA_UC
      COMPRESSION OFF.
  ENDIF.

*  IF sy-subrc <> 0.
*    RAISE conversion_error.
*  ENDIF.

ENDFORM.                    " data_wrap_uc

*---------------------------------------------------------------------*
*  FORM data_wrap_250
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
*  -->  I_T_DATA
*  -->  E_T_OUTDATA250
*---------------------------------------------------------------------*
FORM DATA_WRAP_250
  USING    I_T_DATA        TYPE STANDARD TABLE
  CHANGING E_T_OUTDATA250  TYPE BAPI6116TDA.

  DATA: L_STRING     TYPE STRING.

  FIELD-SYMBOLS: <L_S_DATA>  TYPE ANY.

* initialize
  CLEAR E_T_OUTDATA250.

* loop over I_T_DATA and wrap each line
  LOOP AT I_T_DATA ASSIGNING <L_S_DATA>.

    CLEAR: L_STRING.

    CALL METHOD CL_ABAP_CONTAINER_UTILITIES=>FILL_CONTAINER_C
      EXPORTING
        IM_VALUE     = <L_S_DATA>
      IMPORTING
        EX_CONTAINER = L_STRING.

    PERFORM WRAP_STR_TO_C250
      USING    L_STRING
      CHANGING E_T_OUTDATA250.

  ENDLOOP.

ENDFORM.                    " data_wrap_250
*&---------------------------------------------------------------------*
*&      Form  data_unwrap_std
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_T_RFCDATA  text
*      <--P_C_T_DATA  text
*----------------------------------------------------------------------*
FORM DATA_UNWRAP_STD
  USING    I_T_RFCDATA    TYPE RSDRI_T_RFCDATA
  CHANGING C_T_DATA       TYPE ANY TABLE.

  FIELD-SYMBOLS: <L_S_DATA>     TYPE ANY,
                 <L_S_RFCDATA>  TYPE RSDRI_S_RFCDATA,
                 <L_TS_DATA>    TYPE STANDARD TABLE,
                 <L_TO_DATA>    TYPE SORTED TABLE,
                 <L_TH_DATA>    TYPE HASHED TABLE.

  DATA: L_STRING    TYPE STRING,
        L_T_RFCDATA TYPE RSDRI_T_RFCDATA,
        L_TYPE_TABLE   TYPE ABAP_TABLEKIND
        .

* dynamically create a WA-line for C_T_DATA
  ASSIGN LOCAL COPY OF INITIAL LINE OF C_T_DATA TO <L_S_DATA>.

  DATA LR_T_DESCR_DATA   TYPE REF TO CL_ABAP_TABLEDESCR.
  LR_T_DESCR_DATA ?= CL_ABAP_TABLEDESCR=>DESCRIBE_BY_DATA( C_T_DATA ).

  CASE LR_T_DESCR_DATA->TABLE_KIND.
    WHEN CL_ABAP_TABLEDESCR=>TABLEKIND_STD.
      ASSIGN C_T_DATA TO <L_TS_DATA>.
    WHEN CL_ABAP_TABLEDESCR=>TABLEKIND_HASHED.
      ASSIGN C_T_DATA TO <L_TH_DATA>.
    WHEN CL_ABAP_TABLEDESCR=>TABLEKIND_SORTED.
      ASSIGN C_T_DATA TO <L_TO_DATA>.
  ENDCASE.

* loop over I_T_DATA and wrap each line
  LOOP AT I_T_RFCDATA ASSIGNING <L_S_RFCDATA>.

    APPEND <L_S_RFCDATA> TO L_T_RFCDATA.

*   --- one record is complete
    IF <L_S_RFCDATA>-CONT <> 'X'.

      PERFORM UNWRAP_C255_TO_STR
        USING    L_T_RFCDATA
        CHANGING L_STRING.

      CLEAR: L_T_RFCDATA,
             <L_S_DATA>.

      CALL METHOD CL_ABAP_CONTAINER_UTILITIES=>READ_CONTAINER_C
        EXPORTING
          IM_CONTAINER = L_STRING
        IMPORTING
          EX_VALUE     = <L_S_DATA>.

      CASE LR_T_DESCR_DATA->TABLE_KIND.
        WHEN CL_ABAP_TABLEDESCR=>TABLEKIND_STD.
          APPEND <L_S_DATA>  TO <L_TS_DATA>.
        WHEN CL_ABAP_TABLEDESCR=>TABLEKIND_HASHED.
          INSERT <L_S_DATA> INTO TABLE <L_TH_DATA>.
        WHEN CL_ABAP_TABLEDESCR=>TABLEKIND_SORTED.
          APPEND <L_S_DATA> TO <L_TO_DATA>.
      ENDCASE.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " data_unwrap_std
*&---------------------------------------------------------------------*
*&      Form  data_unwrap_uc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_RFCDATA_UC  text
*      <--P_C_T_DATA  text
*----------------------------------------------------------------------*
FORM DATA_UNWRAP_UC
  USING    I_RFCDATA_UC    TYPE XSTRING
  CHANGING C_T_DATA        TYPE ANY TABLE.

  FIELD-SYMBOLS
  : <L_T_DATA>     TYPE STANDARD TABLE
  , <L_S_DATA>     TYPE ANY
  , <L_TS_DATA>    TYPE STANDARD TABLE
  , <L_TO_DATA>    TYPE SORTED TABLE
  , <L_TH_DATA>    TYPE HASHED TABLE.

  DATA
  : LR_T_DESCR_DATA   TYPE REF TO CL_ABAP_TABLEDESCR
  , LR_T__DATA        TYPE REF TO DATA
  , LR_S__DATA        TYPE REF TO DATA
  .

  LR_T_DESCR_DATA ?= CL_ABAP_TABLEDESCR=>DESCRIBE_BY_DATA( C_T_DATA ).

  CASE LR_T_DESCR_DATA->TABLE_KIND.
    WHEN CL_ABAP_TABLEDESCR=>TABLEKIND_STD.
      ASSIGN C_T_DATA TO <L_TS_DATA>.
    WHEN CL_ABAP_TABLEDESCR=>TABLEKIND_HASHED.
      ASSIGN C_T_DATA TO <L_TH_DATA>.
    WHEN CL_ABAP_TABLEDESCR=>TABLEKIND_SORTED.
      ASSIGN C_T_DATA TO <L_TO_DATA>.
  ENDCASE.


* non-initial C_T_DATA ----------------------------------------------
  IF NOT C_T_DATA IS INITIAL.

*   dynamically create a copy of C_T_DATA
    ASSIGN LOCAL COPY OF C_T_DATA TO <L_T_DATA>.

*   re-convert
    IMPORT RSDRI = <L_T_DATA>
      FROM DATA BUFFER I_RFCDATA_UC.

    IF SY-SUBRC <> 0.
      RAISE CONVERSION_ERROR.
    ENDIF.

*   append lines
    CASE LR_T_DESCR_DATA->TABLE_KIND.
      WHEN CL_ABAP_TABLEDESCR=>TABLEKIND_STD.
        APPEND LINES OF <L_T_DATA>  TO <L_TS_DATA>.
      WHEN CL_ABAP_TABLEDESCR=>TABLEKIND_HASHED.
        INSERT LINES OF <L_T_DATA> INTO TABLE <L_TH_DATA>.
      WHEN CL_ABAP_TABLEDESCR=>TABLEKIND_SORTED.
        APPEND LINES OF <L_T_DATA> TO <L_TO_DATA>.
    ENDCASE.
    CLEAR <L_T_DATA>.

* initial C_T_DATA --------------------------------------------------
  ELSE.

    CREATE DATA LR_S__DATA LIKE LINE OF C_T_DATA.
    ASSIGN LR_S__DATA->* TO <L_S_DATA>.
    CREATE DATA LR_T__DATA LIKE STANDARD TABLE OF <L_S_DATA> WITH NON-UNIQUE DEFAULT KEY.
    ASSIGN LR_T__DATA->* TO <L_T_DATA>.


*   re-convert
    IMPORT RSDRI =  <L_T_DATA> "c_t_data
      FROM DATA BUFFER I_RFCDATA_UC.

    IF SY-SUBRC <> 0.
      RAISE CONVERSION_ERROR.
    ENDIF.

    CASE LR_T_DESCR_DATA->TABLE_KIND.
      WHEN CL_ABAP_TABLEDESCR=>TABLEKIND_STD.
        APPEND LINES OF <L_T_DATA>  TO <L_TS_DATA>.
      WHEN CL_ABAP_TABLEDESCR=>TABLEKIND_HASHED.
        INSERT LINES OF <L_T_DATA> INTO TABLE <L_TH_DATA>.
      WHEN CL_ABAP_TABLEDESCR=>TABLEKIND_SORTED.
        APPEND LINES OF <L_T_DATA> TO <L_TO_DATA>.
    ENDCASE.
    CLEAR <L_T_DATA>.

  ENDIF.

ENDFORM.                    " data_unwrap_uc

*&---------------------------------------------------------------------*
*&      Form  data_unwrap_std_250
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_T_RFCDATA  text
*      <--P_C_T_DATA  text
*----------------------------------------------------------------------*
FORM DATA_UNWRAP_STD_250
  USING    I_T_RFCDATA    TYPE BAPI6116TDA
  CHANGING C_T_DATA       TYPE STANDARD TABLE.

  FIELD-SYMBOLS: <L_S_DATA>     TYPE ANY,
                 <L_S_RFCDATA>  TYPE BAPI6116DA.

  DATA: L_STRING    TYPE STRING,
        L_T_RFCDATA TYPE BAPI6116TDA.



* dynamically create a WA-line for C_T_DATA
  ASSIGN LOCAL COPY OF INITIAL LINE OF C_T_DATA TO <L_S_DATA>.

* loop over I_T_DATA and wrap each line
  LOOP AT I_T_RFCDATA ASSIGNING <L_S_RFCDATA>.

    APPEND <L_S_RFCDATA> TO L_T_RFCDATA.

*   --- one record is complete
    IF <L_S_RFCDATA>-CONTINUATION NE RS_C_TRUE.

      PERFORM UNWRAP_C250_TO_STR
        USING    L_T_RFCDATA
        CHANGING L_STRING.

      CLEAR: L_T_RFCDATA,
             <L_S_DATA>.

      CALL METHOD CL_ABAP_CONTAINER_UTILITIES=>READ_CONTAINER_C
        EXPORTING
          IM_CONTAINER = L_STRING
        IMPORTING
          EX_VALUE     = <L_S_DATA>.

      APPEND <L_S_DATA> TO C_T_DATA.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " data_unwrap_std_250
*---------------------------------------------------------------------*
*  FORM unwrap_c250_to_str
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
*  -->  I_T_RFCDATA
*  -->  E_STRING
*---------------------------------------------------------------------*
FORM UNWRAP_C250_TO_STR
  USING    I_T_RFCDATA   TYPE BAPI6116TDA
  CHANGING E_STRING      TYPE STRING.

  DATA: BUFFER       TYPE GT_BUFFER.
  DATA: OFFSET       TYPE I.
  FIELD-SYMBOLS: <L_S_RFCDATA>  TYPE BAPI6116DA,
                 <L_STRING>     TYPE GT_BUFFER.


* initialize
  CLEAR: E_STRING, BUFFER, OFFSET.
  ASSIGN BUFFER TO <L_STRING>.

* concatenate all line into string
  LOOP AT I_T_RFCDATA ASSIGNING <L_S_RFCDATA>.
*    CONCATENATE e_string <l_s_rfcdata>-data INTO e_string.
    <L_STRING>+OFFSET(250) = <L_S_RFCDATA>-DATA.
    ADD 250 TO OFFSET.
  ENDLOOP.

* Make sure the trailer gets not chopped off
  <L_STRING>+OFFSET(1) = 'X'.

  E_STRING = BUFFER.

ENDFORM.                    " unwrap_c250_to_str
*&---------------------------------------------------------------------*
*&      Form  RELATE_KYFS_WITH_UNITS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_L_T_COMPONENT  text
*----------------------------------------------------------------------*
FORM RELATE_KYFS_WITH_UNITS
  CHANGING C_T_COMPONENT   TYPE GT_T_COMPONENT.

  FIELD-SYMBOLS: <L_S_COMPONENT>  TYPE GT_S_COMPONENT.

  DATA: L_S_IOBJ  TYPE RSD_S_IOBJ,
        L_S_KYF   TYPE RSD_S_KYF,
        L_S_UNIT  TYPE GT_S_COMPONENT.

  LOOP AT C_T_COMPONENT ASSIGNING <L_S_COMPONENT>.

*   --- get information on the component
    CALL FUNCTION 'RSD_IOBJ_GET'
      EXPORTING
        I_IOBJNM        = <L_S_COMPONENT>-NAME
        I_OBJVERS       = RS_C_OBJVERS-ACTIVE
        I_BYPASS_BUFFER = RS_C_FALSE
      IMPORTING
        E_S_IOBJ        = L_S_IOBJ
        E_S_KYF         = L_S_KYF
      EXCEPTIONS
        IOBJ_NOT_FOUND  = 1
        OTHERS          = 0.

*    --- If this infoobject is not found then the underlying data
*    --- structure's components are obviously not infoobject names.
*    --- Therefore the component cannot be related to a unit and
*    --- the form can be left.
    IF SY-SUBRC <> 0.
*     exit.
      CONTINUE.        "because of navigational attributes ...
    ENDIF.

*   --- no key figure -> nothing to do
    IF L_S_IOBJ-IOBJTP <> RSD_C_OBJTP-KEYFIGURE.
      <L_S_COMPONENT>-UNITCOMP = 0.
      CONTINUE.
    ENDIF.

*   --- fixed unit/currency?
    IF NOT L_S_KYF-FIXCUKY IS INITIAL.
      <L_S_COMPONENT>-UNITCOMP  = -1.
      <L_S_COMPONENT>-UNITFIXED = L_S_KYF-FIXCUKY.
      CONTINUE.
    ELSEIF NOT L_S_KYF-FIXUNIT IS INITIAL.
      <L_S_COMPONENT>-UNITCOMP  = -1.
      <L_S_COMPONENT>-UNITFIXED = L_S_KYF-FIXUNIT.
      CONTINUE.
    ENDIF.

*   --- empty unit -> go on with next component
    IF L_S_KYF-UNINM IS INITIAL.
      CLEAR: <L_S_COMPONENT>-UNITCOMP,
             <L_S_COMPONENT>-UNITFIXED.
    ENDIF.

*   --- find related unit/currency component
    CLEAR <L_S_COMPONENT>-UNITFIXED.

    READ TABLE C_T_COMPONENT WITH KEY NAME = L_S_KYF-UNINM
      INTO L_S_UNIT
      TRANSPORTING POSITION.

    IF SY-SUBRC <= 2.
      <L_S_COMPONENT>-UNITCOMP = L_S_UNIT-POSITION.
    ELSE.
      <L_S_COMPONENT>-UNITCOMP = 0.
    ENDIF.

  ENDLOOP.

ENDFORM.                               " RELATE_KYFS_WITH_UNITS
*&---------------------------------------------------------------------*
*&      Form  REMOVE_IRRELEVANT_COMPONENTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      --> I_TH_SFC      list of characteristics
*      --> I_TH_SFK      list of key figures
*      <-> C_T_COMPONENT components of data structure
*----------------------------------------------------------------------*
FORM REMOVE_IRRELEVANT_COMPONENTS
  USING    I_TH_SFC      TYPE RSDRI_TH_SFC
           I_TH_SFK      TYPE RSDRI_TH_SFK
  CHANGING C_T_COMPONENT TYPE GT_T_COMPONENT
           E_RELEVANT    TYPE I.

  FIELD-SYMBOLS: <L_S_COMPONENT>   TYPE GT_S_COMPONENT,
                 <L_S_SFC>         TYPE RSDRI_S_SFC,
                 <L_S_SFK>         TYPE RSDRI_S_SFK.

  DATA: L_UNITFL  TYPE RS_BOOL.

* initialize
  DESCRIBE TABLE C_T_COMPONENT LINES E_RELEVANT.

* SFC and SFK initial -> use all components
  CHECK NOT I_TH_SFC IS INITIAL AND NOT I_TH_SFK IS INITIAL.

* check if a component appears in either SFC or SFK;
* remove all components that don't (except units)
  LOOP AT C_T_COMPONENT ASSIGNING <L_S_COMPONENT>.

*   --- check if component is a unit/currency
    PERFORM CHECK_IOBJ_PROPERTIES IN PROGRAM SAPLRSDRC_SELDR
      USING    <L_S_COMPONENT>-NAME
      CHANGING L_UNITFL.
    IF L_UNITFL = RS_C_TRUE.
      E_RELEVANT = E_RELEVANT - 1.
      <L_S_COMPONENT>-SHOWFL = RS_C_FALSE.
      CONTINUE.
    ENDIF.

*   --- check if component is in SFC
    READ TABLE I_TH_SFC
      WITH KEY CHAALIAS = <L_S_COMPONENT>-NAME              "#EC *
      ASSIGNING <L_S_SFC>.
    IF SY-SUBRC <= 2.
      <L_S_COMPONENT>-IOBJNM = <L_S_SFC>-CHANM.
      CONTINUE.
    ENDIF.

*   --- check if component is in SFK
    READ TABLE I_TH_SFK
      WITH KEY KYFALIAS = <L_S_COMPONENT>-NAME              "#EC *
      ASSIGNING <L_S_SFK>.
    IF SY-SUBRC <= 2.
      <L_S_COMPONENT>-IOBJNM = <L_S_SFK>-KYFNM.
      CONTINUE.
    ENDIF.

*   --- component is in neither SFC nor SFK -> remove it
    E_RELEVANT = E_RELEVANT - 1.
    <L_S_COMPONENT>-SHOWFL = RS_C_FALSE.
  ENDLOOP.

ENDFORM.                               " REMOVE_IRRELEVANT_COMPONENTS
