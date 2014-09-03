class ZCL_BD00_APPL_LINE definition
  public
  inheriting from ZCL_BD00_APPL_CTRL
  create public

  global friends ZCL_BD00_APPL_CTRL
                 ZCL_BD00_APPL_TABLE
                 ZCL_BD00_INT_TABLE .

*"* public components of class ZCL_BD00_APPL_LINE
*"* do not include other source files here!!!
public section.

  methods CLEAR_DATA .
  type-pools ABAP .
  methods SET_LINE
    importing
      !I_LINE type ref to DATA
      !IF_COPY type RS_BOOL default ABAP_FALSE
      !I_INDEX type I optional .
  type-pools ZBD0T .
  methods CONSTRUCTOR
    importing
      !IO_MODEL type ref to ZCL_BD00_MODEL
      !IT_CONST type ZBD0T_TY_T_CONSTANT optional .
