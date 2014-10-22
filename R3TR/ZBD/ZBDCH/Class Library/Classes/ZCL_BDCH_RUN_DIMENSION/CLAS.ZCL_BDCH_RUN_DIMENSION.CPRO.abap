*"* protected components of class ZCL_BDCH_RUN_DIMENSION
*"* do not include other source files here!!!
protected section.

  data GD_V__APPSET_ID type UJ_APPSET_ID .
  data GD_V__USER_ID type UJ_USER_ID .

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
