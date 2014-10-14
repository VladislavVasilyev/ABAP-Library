class ZCL_BDNL_RUN_LOGIC definition
  public
  final
  create public .

*"* public components of class ZCL_BDNL_RUN_LOGIC
*"* do not include other source files here!!!
public section.
  type-pools ABAP .
  type-pools ZBNLT .

  types:
    begin of ty_s__current_for
      , container type ref to zcl_bdnl_container
      , end of ty_s__current_for .
  types:
    ty_t__current_for type standard table of ty_s__current_for with non-unique default key .
  types:
    begin of  ty_s__rules
            , search type zbnlt_t__search
            , n_search type i
            , assign type zbnlt_t__assign
            , n_assign type i
            , assign_not_found type zbnlt_t__assign
            , n_assign_not_found type i
            , end of ty_s__rules .
  types:
    ty_t__rules type standard table of ty_s__rules with non-unique default key .

  data GD_S__RULES type TY_S__RULES .
  data GD_S__STACK type ZBNLT_S__STACK .
  data GD_T__CONTAINERS type ZBNLT_T__CONTAINERS .
  data GD_T__FOR_CONTAINERS type ZBNLT_T__CONTAINERS .
  data GD_T__FOR_CONTAINERS1 type TY_T__CURRENT_FOR .
  data GR_O__PARAMS type ref to ZCL_BDNL_BADI_PARAMS .

  methods RUN_________________________NV
    raising
      ZCX_BDNL_EXCEPTION
      ZCX_BD00_CREATE_OBJ .
  methods RUN_________________________ST
    raising
      ZCX_BDNL_EXCEPTION
      ZCX_BD00_CREATE_OBJ .
  methods RUN
    raising
      ZCX_BDNL_EXCEPTION
      ZCX_BD00_CREATE_OBJ .
  methods CONSTRUCTOR
    importing
      !I_O__PARAM type ref to ZCL_BDNL_BADI_PARAMS
      !I_F__RSPC type RS_BOOL default ABAP_FALSE
      !I_F__PARALLEL_TASK type RS_BOOL default ABAP_FALSE
      !I_V__NUM_TASKS type I optional
    raising
      ZCX_BDNL_EXCEPTION .
