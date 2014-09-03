class ZCL_BDNL_BADI_PARAMS definition
  public
  final
  create public .

*"* public components of class ZCL_BDNL_BADI_PARAMS
*"* do not include other source files here!!!
public section.
  type-pools ABAP .
  type-pools ZBNLT .

  types:
    begin of ty_s__script
           , order type i
           , appset_id type uj_appset_id
           , appl_id   type uj_appl_id
           , script type uj_docname
           , run type rs_bool
           , end of ty_s__script .
  types:
    ty_t__script type sorted table of ty_s__script with unique key order .

  data GD_V__APPSET_ID type UJ_APPSET_ID read-only .
  data GD_V__APPL_ID type UJ_APPL_ID read-only .
  data GD_T__PARAM type UJK_T_SCRIPT_LOGIC_HASHTABLE read-only .
  data GD_T__CV type UJK_T_CV read-only .
  data GD_T__VARIABLE type ZBNLT_T__VARIABLE read-only .
  data GD_T__SCRIPT type TY_T__SCRIPT .
  data GD_F__DEBUG type RS_BOOL read-only .
  data GR_O__REPLACE type ref to CL_UJK_DO_REPLACE read-only .

  methods CONSTRUCTOR
    importing
      !I_APPSET_ID type UJ_APPSET_ID
      !I_APPL_ID type UJ_APPL_ID
      !IT_PARAM type UJK_T_SCRIPT_LOGIC_HASHTABLE
      !IT_CV type UJK_T_CV
      !IR_REPLACE type ref to CL_UJK_DO_REPLACE optional .
  methods SET_SCRIPT
    importing
      !I_T__SCRIPT type TY_T__SCRIPT .
