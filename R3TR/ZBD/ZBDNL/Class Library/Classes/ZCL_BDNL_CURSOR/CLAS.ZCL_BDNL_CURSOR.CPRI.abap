*"* private components of class ZCL_BDNL_CURSOR
*"* do not include other source files here!!!
private section.

  data GD_T__LOGIC type ZBNLT_T__LGFSOURCE .
  data:
    gd_t__escape_list type sorted table of i with unique key table_line .
  data GD_T__TOKENLIST type ZBNLT_T__MATCH_RES .
  data GD_T__VARIABLE type ZBNLT_T__VARIABLE .

  methods GET_SUBTRACT
    importing
      !INDEX type I .
  methods GET_STVARV
    importing
      !INDEX type I
    raising
      ZCX_BDNL_EXCEPTION .
  methods GET_CBG
    importing
      !INDEX type I
    raising
      ZCX_BDNL_EXCEPTION .
  methods CHECK_VARIABLES
    raising
      ZCX_BDNL_EXCEPTION .
