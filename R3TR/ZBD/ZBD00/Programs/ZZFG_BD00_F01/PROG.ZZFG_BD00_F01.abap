*&---------------------------------------------------------------------*
*&  Include           ZZFG_BD00_F01
*&---------------------------------------------------------------------*
FORM CREATE_REF_INFOCUBE USING    I_T_SFC   TYPE RSDRI_TH_SFC
                                  I_T_SFK   TYPE RSDRI_TH_SFK
                         CHANGING LR_T_DATA TYPE REF TO DATA.

  DATA
      : LS_SFC          LIKE LINE OF I_T_SFC
      , LS_SFK          LIKE LINE OF I_T_SFK
      , LV_CHANM        TYPE RSCHANM
      , LV_ATTRINM      TYPE RSATTRINM
      , LT_COMP         TYPE ABAP_COMPONENT_TAB
      , LS_COMP         TYPE ABAP_COMPONENTDESCR
      , LR_S_DATA       TYPE REF TO DATA
      , LO_STRUCT       TYPE REF TO CL_ABAP_STRUCTDESCR
      , L_S_COB_PRO     TYPE RSD_S_COB_PRO
      .

  FIELD-SYMBOLS
      : <LT_DATA>       TYPE ANY TABLE
      , <LS_DATA>       TYPE ANY
      .

*--------------------------------------------------------------------*
* Обработка признаков
*--------------------------------------------------------------------*
  LOOP AT I_T_SFC
       INTO LS_SFC.

    SPLIT LS_SFC-CHANM AT `__` INTO LV_CHANM LV_ATTRINM.

    LS_COMP-NAME = LS_SFC-CHAALIAS.

    IF LV_ATTRINM IS NOT INITIAL.
      CALL FUNCTION 'RSD_IOBJ_GET'
        EXPORTING
          I_IOBJNM    = LV_ATTRINM
        IMPORTING
          E_S_COB_PRO = L_S_COB_PRO.
      LS_COMP-TYPE ?= CL_ABAP_DATADESCR=>DESCRIBE_BY_NAME( L_S_COB_PRO-DTELNM ).
    ELSE.
      CALL FUNCTION 'RSD_IOBJ_GET'
        EXPORTING
          I_IOBJNM    = LV_CHANM
        IMPORTING
          E_S_COB_PRO = L_S_COB_PRO.
      LS_COMP-TYPE ?= CL_ABAP_DATADESCR=>DESCRIBE_BY_NAME( L_S_COB_PRO-DTELNM ).
    ENDIF.

    APPEND LS_COMP TO LT_COMP.
  ENDLOOP.
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* Обработка показателей
*--------------------------------------------------------------------*
  LOOP AT I_T_SFK
       INTO LS_SFK.

    LS_COMP-NAME  = LS_SFK-KYFALIAS.
    IF LS_SFK-KYFALIAS = `1ROWCOUNT`.
      LS_COMP-TYPE ?= CL_ABAP_DATADESCR=>DESCRIBE_BY_NAME( 'RSSID' ).
    ELSE.
      CALL FUNCTION 'RSD_IOBJ_GET'
        EXPORTING
          I_IOBJNM    = LS_SFK-KYFNM
        IMPORTING
          E_S_COB_PRO = L_S_COB_PRO.
      LS_COMP-TYPE ?= CL_ABAP_DATADESCR=>DESCRIBE_BY_NAME( L_S_COB_PRO-DTELNM ).
    ENDIF.
    APPEND LS_COMP TO LT_COMP.
  ENDLOOP.
*--------------------------------------------------------------------*

  LO_STRUCT = CL_ABAP_STRUCTDESCR=>CREATE( P_COMPONENTS = LT_COMP
                                           P_STRICT     = ABAP_FALSE ).

  CREATE DATA LR_S_DATA TYPE HANDLE LO_STRUCT.
  ASSIGN LR_S_DATA->*   TO   <LS_DATA>.

  CREATE DATA LR_T_DATA LIKE STANDARD TABLE OF <LS_DATA> WITH NON-UNIQUE DEFAULT KEY.
ENDFORM.                    "create_ref_infocube
