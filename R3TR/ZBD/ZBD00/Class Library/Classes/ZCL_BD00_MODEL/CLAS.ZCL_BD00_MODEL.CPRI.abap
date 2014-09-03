*"* private components of class ZCL_BD00_MODEL
*"* do not include other source files here!!!
private section.

  methods CREATE_SFC .
  methods CREATE_SFK .
  methods CREATE_TABLE .
  methods CREATE_LINE .
  methods CONSTRUCTOR
    importing
      !I_APPSET_ID type UJ_APPSET_ID optional
      !I_APPL_ID type UJ_APPL_ID optional
      !I_INFOCUBE type RSINFOPROV optional
      !I_DIMENSION type UJ_DIM_NAME optional
    raising
      ZCX_BD00_CREATE_OBJ .
