class ZCL_BDCH_RUN_NEW_LOGIC definition
  public
  create public .

*"* public components of class ZCL_BDCH_RUN_NEW_LOGIC
*"* do not include other source files here!!!
public section.
  type-pools UJ00 .
  type-pools UJK0 .
  type-pools UJR0 .
  type-pools ZBLNC .

  interfaces IF_UJD_TASK .

  data DV_F__LOGMAIL type RS_BOOL .
  data GD_F__DEBUG type RS_BOOL .
  data GD_V__TIME_END type TZNTSTMPL .
  data GD_V__TIME_START type TZNTSTMPL .
  data GR_O__BADI_PARAM type ref to ZCL_BDNL_BADI_PARAMS .
  data GV_F__RSPC type RS_BOOL .

  methods CONSTRUCTOR
    importing
      !IO_CONFIG type ref to CL_UJD_CONFIG
      !IF_RSPC type RS_BOOL optional
    raising
      CX_UJ_DB_ERROR
      CX_UJD_DATAMGR_ERROR .
  methods PROCESS_RSPC
    importing
      !IS_DATA type UJ0_S_ITAB optional
      !I_V__RSPC_VAR type RSPC_VARIANT
      !I_V__CHAIN_ID type RSPC_CHAIN
      !I_V__TYPE type RSPC_TYPE
    exporting
      !ET_MESSAGE type UJ0_T_MESSAGE
      !ES_DATA type UJ0_S_ITAB
      !EF_SUCCESS type UJ_FLG
      !E_EVENT_NO type UJ_INTEGER
    raising
      CX_UJD_DATAMGR_ERROR
      CX_UJ_STATIC_CHECK .
