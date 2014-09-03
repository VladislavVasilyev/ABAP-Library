*"* protected components of class ZCL_BD00_INT_TABLE
*"* do not include other source files here!!!
protected section.

  aliases GO_RLINE
    for ZIF_BD00_INT_TABLE~GO_LINE .

  data GO_LINE type ref to ZCL_BD00_APPL_LINE .
  data GREF_TABLE type ref to DATA .
  data GV_INDEX type I .
  type-pools ABAP .
  data GD_V__TABLE_KIND type ABAP_TABLEKIND .
  data:
    gt_result type standard table of ref to data .
  data GO_TARGET type ref to ZCL_BD00_APPL_CTRL .

  methods ADD_INDEX .
  class ZCL_BD00_APPL_CTRL definition load .
  methods delete_line for event ev_delete_line of ZCL_BD00_APPL_CTRL.
  methods CHANGE_FLINE
    for event EV_CHANGE_LINE of ZCL_BD00_APPL_CTRL .
  methods CHANGE_TABLE
    for event EV_CHANGE_TABLE of ZCL_BD00_APPL_CTRL .
  methods CLEAR_INDEX .
  methods NEXT_LINE
    returning
      value(E_ST) type ZBD0C_TY_READ_ST .
  methods SET_RESULT
    importing
      !IR_RESULT type ref to DATA
      !I_INDEX type I optional .
