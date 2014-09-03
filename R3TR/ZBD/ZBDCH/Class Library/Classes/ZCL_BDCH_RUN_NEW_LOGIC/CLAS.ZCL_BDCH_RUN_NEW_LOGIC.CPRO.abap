*"* protected components of class ZCL_BDCH_RUN_NEW_LOGIC
*"* do not include other source files here!!!
protected section.

  data DS_BADI_PARAM type UJK_S_BADI_PARAM .
  data D_APPL_ID type UJ_APPL_ID .
  data D_APPSET_ID type UJ_APPSET_ID .
  data D_LOGIC_FILE_PATH type UJ_DOCNAME .
  data D_MEMBERSELECTION type STRING .
  data D_SELECTION type STRING .
  data D_USER_ID type UJ_USER_ID .
  data GD_T__LOGIC_FILE type ZCL_BDNL_BADI_PARAMS=>TY_T__SCRIPT .

  methods GET_SELECTION_RSPC
    importing
      !I_V__RSPC_VAR type RSPC_VARIANT .
  methods GET_REPLACEPARAM_RSPC
    importing
      !I_V__RSPC_VAR type RSPC_VARIANT .
  methods GET_FILTER
    importing
      !I_SELECTION type STRING
      !I_MEMBERSELECTION type STRING
    exporting
      !ET_FILTER_TAB type UJD_TH_DIM_MEM
      !E_FILTER_STR type STRING
    raising
      CX_UJ_STATIC_CHECK .
  methods GET_PARAMETER
    raising
      CX_UJ_DB_ERROR
      CX_UJD_DATAMGR_ERROR .
  methods RUN_LOGIC
    importing
      !IT_K_CV type UJK_T_CV
    exporting
      !EF_SUCCESS type UJ_FLG
      !EF_WARNING type UJ_FLG .
