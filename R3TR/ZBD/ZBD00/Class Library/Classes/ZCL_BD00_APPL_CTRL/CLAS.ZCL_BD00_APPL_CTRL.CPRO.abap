*"* protected components of class ZCL_BD00_APPL_CTRL
*"* do not include other source files here!!!
protected section.

  data GR_O__TABLE type ref to ZCL_BD00_APPL_TABLE .
  data GD_F__AUTO_SAVE type RS_BOOL .
  data GD_T__CONST type TY_T_CONST .
  class-data GD_T__CLASS_REG type TY_T_CLASS_REG .
  data GD_V__DEFAULT_RULE type ZBD0T_ID_RULES .
  class-data GD_V__LAST_CREATE_ID type ZBD0T_ID_RULES .
  data GR_O__LINE type ref to ZCL_BD00_APPL_LINE .
  class-data:
    cd_t__object_reestr type hashed table of ty_s_object_reestr with unique key OBJECT .

  methods SET_CONST
    importing
      !IT_CONST type ZBD0T_TY_T_CONSTANT .
  methods GET_RULE_ID
    returning
      value(ID) type ZBD0T_ID_RULES .
