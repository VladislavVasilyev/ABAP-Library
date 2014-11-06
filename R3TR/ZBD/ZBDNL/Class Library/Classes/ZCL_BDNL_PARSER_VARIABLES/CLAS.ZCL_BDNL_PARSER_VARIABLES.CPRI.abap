*"* private components of class ZCL_BDNL_PARSER_VARIABLES
*"* do not include other source files here!!!
private section.

  data GR_O__CURSOR type ref to ZCL_BDNL_CURSOR .

  methods PRIM
    raising
      ZCX_BDNL_EXCEPTION
      CX_STATIC_CHECK .
