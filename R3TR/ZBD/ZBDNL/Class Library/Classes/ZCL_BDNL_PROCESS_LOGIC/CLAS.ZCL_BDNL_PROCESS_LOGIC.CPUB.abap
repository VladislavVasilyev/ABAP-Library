class ZCL_BDNL_PROCESS_LOGIC definition
  public
  final
  create public .

*"* public components of class ZCL_BDNL_PROCESS_LOGIC
*"* do not include other source files here!!!
public section.
  type-pools ZBNLT .

  interfaces IF_BADI_INTERFACE .
  interfaces IF_UJ_CUSTOM_LOGIC .

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

  data gr_o__badi_param type ref to zcl_bdnl_badi_params.

  class-data CD_F__DEBUG type RS_BOOL read-only .
  class-data CD_V__APPL_ID type UJ_APPL_ID read-only .
  class-data CD_V__APPSET_ID type UJ_APPSET_ID read-only .
  class-data CD_T__PARAM type UJK_T_SCRIPT_LOGIC_HASHTABLE read-only .
  class-data CD_T__VARIABLE type ZBNLT_T__VARIABLE read-only .
  class-data CD_T__SCRIPT type TY_T__SCRIPT read-only .
