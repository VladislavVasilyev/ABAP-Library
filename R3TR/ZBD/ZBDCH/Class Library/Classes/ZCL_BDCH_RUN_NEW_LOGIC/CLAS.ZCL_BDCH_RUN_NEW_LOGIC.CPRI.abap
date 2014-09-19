*"* private components of class ZCL_BDCH_RUN_NEW_LOGIC
*"* do not include other source files here!!!
private section.

  data DO_CONFIG type ref to CL_UJD_CONFIG .
  data DO_SELECT_READER type ref to IF_UJD_GET_TRANSFORM .
  data D_PACKAGE_ID type UJ_PACKAGE_ID .
  data D_SENDMAIL type STRING .
  data GD_F__PARALLEL_TASK type RS_BOOL .
  data GD_V__CHAIN_ID type RSPC_CHAIN .
  data GD_V__NUM_TASKS type I .
  data GD_V__RSPC_TYPE type RSPC_TYPE .
  data GD_V__RSPC_VAR type RSPC_VARIANT .
  data GD_V__TIME_ID type STRING .
  data GR_O__REPLACE type ref to CL_UJK_DO_REPLACE .
  data GT_MESSAGE type UJ0_T_MESSAGE .
  data GD_F__NORUN type RS_BOOL .

  methods GET_VALUE_RSPC
    importing
      !I_V__VALUE type STRING
    returning
      value(E_V__VALUE) type STRING .
  methods GET_NR_PACK
    importing
      !I_V__NR_PACK type I
      !I_V__SIZE type I default 6
    returning
      value(E_V__TEXT) type STRING .
  methods HOR_TAB
    importing
      !IN type CLIKE
      !N type I
    returning
      value(OUT) type STRING .
  type-pools ZBD0T .
  methods GET_NR_ROWS
    importing
      !I_S__READ type ZBD0T_S__LOG_READ optional
      !I_S__WRITE type ZBD0T_S__LOG_WRITE optional
      !I_V__SIZE type I default 7
    returning
      value(E_V__TEXT) type STRING .
  methods SEND_EMAIL
    importing
      !IF_SUCCES type UJ_FLG
      !IF_WARNING type UJ_FLG
      !IF_LOG type RS_BOOL .
  methods PRINT_LOG .
  methods GET_SPACE_TEXT
    importing
      !I_V__SIZE type I
    returning
      value(E_V__TEXT) type STRING .
  methods CONVERT_TIME
    importing
      !I_V__START type TZNTSTMPL
      !I_V__END type TZNTSTMPL
    exporting
      !E_V__DATA_START type STRING
      !E_V__TIME_START type STRING
      !E_V__DELTA_TIME type STRING .
  methods GET_TIME
    importing
      !I_V__START type TZNTSTMPL
      !I_V__END type TZNTSTMPL
    returning
      value(E_V__TEXT) type STRING .
  type-pools ZBNLT .
  methods PRINT_LOG_FOR_TABLE
    importing
      !I_T__CONTAINERS type ZBNLT_T__CONTAINERS
      !I_V__PATH type UJ_DOCNAME
    returning
      value(E_F__WARNING) type RS_BOOL .
  methods GET_CV_LOGIC
    importing
      !IT_FILTER_TAB type UJD_TH_DIM_MEM
    exporting
      !ET_K_CV type UJK_T_CV .
  methods SET_BADI_PARAM
    importing
      !I_PARA type STRING .
