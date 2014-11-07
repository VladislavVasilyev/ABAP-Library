class ZCL_BDNL_ASSIGN_FUNCTION definition
  public
  final
  create public .

*"* public components of class ZCL_BDNL_ASSIGN_FUNCTION
*"* do not include other source files here!!!
public section.

  types:
    begin of ty_s__result
    , key type string
    , e   type string
    , end of ty_s__result .
  types:
    ty_t__result type hashed table of ty_s__result with unique key key .

  class-methods TEST
    importing
      !I01 type ANY
      !I02 type ANY optional
      !I03 type ANY optional
    exporting
      !E type ANY
    raising
      ZCX_BDNL_SKIP_ASSIGN .
  class-methods __CONVERT_TO_RANGE_TABLE
    importing
      !I01 type ANY
      !I02 type ANY
      !I03 type ANY
    exporting
      !E type ANY .
  class-methods ROUND
    importing
      !I01 type ANY
      !I02 type ANY
    exporting
      !E type UJ_KEYFIGURE
    raising
      CX_STATIC_CHECK
      CX_DYNAMIC_CHECK .
  class-methods RIGHTSYM
    importing
      !I01 type ANY
      !I02 type ANY optional
      !I03 type ANY optional
    exporting
      !E type ANY
    raising
      ZCX_BDNL_SKIP_ASSIGN .
  class-methods PREV_MONTH
    importing
      !I01 type ANY
    exporting
      !E type ANY
    raising
      ZCX_BDNL_SKIP_ASSIGN .
  class-methods NUM
    importing
      !I01 type ANY
    exporting
      !E type UJ_KEYFIGURE
    raising
      CX_SY_CONVERSION_NO_NUMBER .
  class-methods MAP_EXT2_LICENSE
    importing
      !I01 type ANY
      !I02 type ANY
    exporting
      !E type ANY
    raising
      ZCX_BDNL_SKIP_ASSIGN .
  class-methods LEFTSYM
    importing
      !I01 type ANY
      !I02 type ANY optional
      !I03 type ANY optional
    exporting
      !E type ANY
    raising
      ZCX_BDNL_SKIP_ASSIGN .
  class-methods GET_VAR
    importing
      !I01 type ANY
    exporting
      !E type ANY .
  class-methods CONCATENATE
    importing
      !I01 type ANY
      !I02 type ANY
      !I03 type ANY optional
      !I04 type ANY optional
      !I05 type ANY optional
    exporting
      !E type ANY .
  class-methods CBG
    importing
      !I01 type ANY
      !I02 type ANY
    exporting
      !E type STRING .
  class-methods GET_EXCEL_DATE
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
  class-methods GET_KF
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
  class-methods IF
    importing
      !I01 type ANY
      !I02 type ANY
      !I03 type ANY
      !I04 type ANY
      !I05 type ANY
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
  class-methods CHANGE_MONTH
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
  class-methods GET_TIME
    importing
      !I01 type ANY
      !I02 type ANY
    exporting
      !E type ANY .
  class-methods X_SELECT
    importing
      !I01 type ANY
      !I02 type ANY
      !I03 type ANY
      !I04 type ANY optional
      !I05 type ANY optional
    exporting
      !E type STRING
    raising
      CX_UJ_OBJ_NOT_FOUND
      CX_UJ_STATIC_CHECK .
