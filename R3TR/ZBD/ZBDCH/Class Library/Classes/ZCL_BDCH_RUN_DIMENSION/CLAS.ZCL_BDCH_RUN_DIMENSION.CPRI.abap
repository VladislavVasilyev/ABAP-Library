*"* private components of class ZCL_BDCH_RUN_DIMENSION
*"* do not include other source files here!!!
private section.

  data GR_I__CONTEXT type ref to IF_UJ_CONTEXT .
  data GD_V__SENDMAIL type STRING .
  data GD_V__SELECTION type STRING .
  data GD_V__PACKAGE_ID type UJ_PACKAGE_ID .
  data GD_V__MODE type STRING .
  data GD_V__MEMBERSELECTION type STRING .
  data GD_T__DIMENSION type standard table of UJ_DIM_NAME .
  data GD_V__APPL_ID type UJ_APPL_ID .
  data GD_S__BADI_PARAM type UJK_S_BADI_PARAM .
  data GD_F__LOGMAIL type RS_BOOL .
  data GD_F__DEBUG type RS_BOOL .
  data GD_F__MASTERFILE type RS_BOOL .
  data DO_CONFIG type ref to CL_UJD_CONFIG .

  methods DOWNLOAD
    exporting
      !EF_SUCCESS type UJ_FLG
      !EF_WARNING type UJ_FLG .
  methods UPLOAD
    exporting
      !EF_SUCCESS type UJ_FLG
      !ET_MESSAGE type UJ0_T_MESSAGE .
  methods GET_CV_LOGIC
    importing
      !IT_FILTER_TAB type UJD_TH_DIM_MEM
    exporting
      !ET_K_CV type UJK_T_CV .
  methods SET_BADI_PARAM
    importing
      !I_PARA type STRING .
