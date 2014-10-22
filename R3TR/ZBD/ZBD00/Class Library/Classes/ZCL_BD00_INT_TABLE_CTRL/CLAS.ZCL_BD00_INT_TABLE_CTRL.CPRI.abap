*"* private components of class ZCL_BD00_INT_TABLE_CTRL
*"* do not include other source files here!!!
private section.

  class ZCL_BD00_INT_TABLE definition load .
  class-methods GET_DEFINITION
    importing
      !I_INDEX type ZCL_BD00_INT_TABLE=>VAR_INDEX
      !IO_MODEL type ref to ZCL_BD00_MODEL optional
      !IR_DATA type ref to DATA optional
    returning
      value(ET_DEFINITION) type TY_T_DEFINITION .
  class ZCL_BD00_APPL_CTRL definition load .
  class-methods CREATE_LOCAL_TD
    importing
      !IT_OBJECT_REESTR type TY_T_OBJECT_REESTR
      !IT_RULE_LINK type ZCL_BD00_APPL_CTRL=>TY_S_RULES_REESTR
      !I_MODE_ADD type ZBD00_MODE_ADD_LINE optional
    exporting
      !ET_FIELD_SYMBOLS type TY_T_STRING
      !ET_ASSIGN_SYMBOLS type TY_T_STRING .
  class-methods CREATE_GLOBAL_TD
    importing
      !IT_OBJECT_REESTR type TY_T_OBJECT_REESTR
    returning
      value(ET_CODE) type TY_T_STRING .
  class-methods CREATE_CONSTRUCTOR
    importing
      !IT_OBJECT_REESTR type TY_T_OBJECT_REESTR
    exporting
      !ET_DEFINITION type TY_T_STRING
      !ET_IMPLEMENTATIOM type TY_T_STRING .
  class-methods CREATE_CODE_LINE_SEARCH
    importing
      !IS_RULE_LINK type ZCL_BD00_APPL_CTRL=>TY_S_CUST_LINK
      !IT_OBJECT_REESTR type TY_T_OBJECT_REESTR
    returning
      value(EV_CODE) type STRING .
  class-methods CREATE_CODE_ASSIGN_LINK
    importing
      !IT_RULE_LINK type ZCL_BD00_APPL_CTRL=>TY_S_RULES_REESTR
      !IT_OBJECT_REESTR type TY_T_OBJECT_REESTR
    returning
      value(ET_CODE) type TY_T_STRING .
  class-methods CREATE_CODE_NON_UNIQUE_KEY
    importing
      !IT_RULE_LINK type ZCL_BD00_APPL_CTRL=>TY_S_RULES_REESTR
      !IT_OBJECT_REESTR type TY_T_OBJECT_REESTR
    returning
      value(ET_CODE) type TY_T_STRING .
  class-methods CREATE_CODE_UNIQUE_KEY
    importing
      !IT_RULE_LINK type ZCL_BD00_APPL_CTRL=>TY_S_RULES_REESTR
      !IT_OBJECT_REESTR type TY_T_OBJECT_REESTR
    returning
      value(ET_CODE) type TY_T_STRING .
  class-methods GET_REESTR_OBJECT
    importing
      !IT_LINK type ZCL_BD00_APPL_CTRL=>TY_S_RULES_REESTR
    returning
      value(ET_REESTR_OBJECT) type TY_T_OBJECT_REESTR .
  class-methods GET_CODE_TYPES_STRUCT
    importing
      !IO_MODEL type ref to ZCL_BD00_MODEL
      !NAME type TY_S_NAME
    exporting
      !CODE type TY_T_STRING .
  class-methods GET_CODE_TYPES_TABLE
    importing
      !NAME type TY_S_NAME
      !NAME_TY type TY_S_NAME
      !IO_MODEL type ref to ZCL_BD00_MODEL
    exporting
      !CODE type TY_T_STRING .
  class-methods GET_CODE_ADD_LINE
    importing
      !IO_TG type ref to ZCL_BD00_APPL_CTRL
      !IO_LINE type ref to ZCL_BD00_APPL_CTRL
    exporting
      !CODE type TY_T_STRING .
  class-methods GET_CODE_FULL_KEY
    importing
      !NAME type STRING
      !IO_MODEL type ref to ZCL_BD00_MODEL
    exporting
      !CODE type TY_T_STRING .
