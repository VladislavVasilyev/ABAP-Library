*"* private components of class ZCL_BD00_APPL_CTRL
*"* do not include other source files here!!!
private section.

  data GD_S__LAST_RULE type TY_S_CLASS_REG .
  data GD_F__DELETE type RS_BOOL .

  methods AUTO_WRITE_BACK
    importing
      !LINES type I
    raising
      ZCX_BD00_RFC_TASK .
  class ZCL_BD00_APPL_CTRL definition load .
  class-methods GET_KEY_LINK
    importing
      !ID type ZBD0T_ID_RULES
    returning
      value(LINK) type ZCL_BD00_APPL_CTRL=>TY_S_RULES_REESTR .
  methods GET_CONST
    returning
      value(E_CONST) type TY_T_CONST .
