*"* private components of class ZCL_BDNL_CURSOR
*"* do not include other source files here!!!
private section.

  data GD_T__LOGIC type ZBNLT_T__LGFSOURCE .
  data GD_T__TOKENLIST type ZBNLT_T__MATCH_RES .

  methods GET_SUBTRACT
    importing
      !INDEX type I
    raising
      ZCX_BDNL_SYNTAX_ERROR .
  methods GET_CBG
    importing
      !INDEX type I
    raising
      ZCX_BDNL_EXCEPTION .
  methods GET_STVARV
    importing
      !INDEX type I
    raising
      ZCX_BDNL_EXCEPTION .
