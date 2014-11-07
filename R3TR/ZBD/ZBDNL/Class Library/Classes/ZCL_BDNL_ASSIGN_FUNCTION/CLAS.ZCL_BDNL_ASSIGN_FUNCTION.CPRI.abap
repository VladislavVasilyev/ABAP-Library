*"* private components of class ZCL_BDNL_ASSIGN_FUNCTION
*"* do not include other source files here!!!
private section.

  class-data CD_T__X_SELECT type TY_T__RESULT .

  class-methods __GET_TIME
    importing
      !TIME type STRING
    returning
      value(E) type I
    raising
      ZCX_BDNL_SKIP_ASSIGN .
  class-methods __GET_TIME_MONTH
    importing
      !MONTH type I
    returning
      value(E) type STRING
    raising
      ZCX_BDNL_SKIP_ASSIGN .
