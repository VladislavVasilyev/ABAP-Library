class ZCL_BDNL_ASSIGN_FUNCTION definition
  public
  final
  create public .

*"* public components of class ZCL_BDNL_ASSIGN_FUNCTION
*"* do not include other source files here!!!
public section.

  class-methods MAP_EXT2_LICENSE
    importing
      !I01 type ANY
      !I02 type ANY
    exporting
      !E type ANY
    raising
      ZCX_BDNL_SKIP_ASSIGN .
  class-methods CONCATENATE
    importing
      !I01 type ANY
      !I02 type ANY
    exporting
      !E type ANY .
  class-methods GET_EXCEL_DATE
    importing
      !I01 type ANY
    exporting
      !E type ANY .
  class-methods GET_VAR
    importing
      !I01 type ANY
    exporting
      !E type ANY .
  class-methods GET_CH
    importing
      !I01 type ref to ZCL_BD00_APPL_TABLE
      !I02 type UJ_DIM_NAME
      !I03 type UJ_ATTR_NAME
    exporting
      !E type ANY .
  class-methods MAP_DATASOURCE
    importing
      !I01 type ANY
    exporting
      !E type ANY .
  class-methods MAP_INVENTORY_MP_CURR
    importing
      !I01 type ANY
    exporting
      !E type ANY .
  class-methods SKIP_EQ
    importing
      !I01 type ANY
      !I02 type ANY
    exporting
      !E type ANY
    raising
      ZCX_BDNL_SKIP_ASSIGN .
  class-methods SKIP_IF
    importing
      !I01 type ANY
      !I02 type ANY
      !I03 type ANY
      !I04 type ANY
    exporting
      !E type ANY
    raising
      ZCX_BDNL_SKIP_ASSIGN .
  class-methods SKIP_IF_BPCTIME
    importing
      !I01 type ANY
      !I02 type ANY
      !I03 type ANY
      !I04 type ANY
    exporting
      !E type ANY
    raising
      ZCX_BDNL_SKIP_ASSIGN .
  class-methods SKIP_NE
    importing
      !I01 type ANY
      !I02 type ANY
    exporting
      !E type ANY
    raising
      ZCX_BDNL_SKIP_ASSIGN .
  class-methods GET_TIME
    importing
      !I01 type ANY
      !I02 type ANY
    exporting
      !E type ANY .
  class-methods CHANGE_YEAR
    importing
      !I01 type ANY
      !I02 type ANY
    exporting
      !E type ANY .
  class-methods CHANGE_MONTH
    importing
      !I01 type ANY
      !I02 type ANY
    exporting
      !E type ANY .
