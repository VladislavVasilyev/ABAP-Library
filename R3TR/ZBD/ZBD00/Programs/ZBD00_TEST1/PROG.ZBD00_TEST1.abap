*&---------------------------------------------------------------------*
*& Report  ZBD00_TEST1
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZBD00_TEST1.

DEFINE MAC__APPEND_TO_DIM_LIST.
  LD_S__DIM_LIST-DIMENSION   = &1.
  LD_S__DIM_LIST-ATTRIBUTE   = &2.
  LD_S__DIM_LIST-F_KEY       = &3.
  LD_S__DIM_LIST-ORDERBY     = &4.
  INSERT LD_S__DIM_LIST INTO TABLE LD_T__DIM_LIST.
END-OF-DEFINITION.

DEFINE MAC__SET_RULE_FOR_DATA.
  CLEAR LD_S__CUST_LINK.
  LD_S__CUST_LINK-TG-DIMENSION = &1.
  LD_S__CUST_LINK-TG-ATTRIBUTE = &2.
  GET REFERENCE OF &3 INTO LD_S__CUST_LINK-SC-DATA.
  INSERT LD_S__CUST_LINK INTO TABLE LD_T__CUST_LINK.
END-OF-DEFINITION.

DEFINE MAC__SET_RULE_FOR_CONST.
  CLEAR LD_S__CUST_LINK.
  LD_S__CUST_LINK-TG-DIMENSION = &1.
  LD_S__CUST_LINK-TG-ATTRIBUTE = &2.
  LD_S__CUST_LINK-SC-CONST     = &3.
  INSERT LD_S__CUST_LINK INTO TABLE LD_T__CUST_LINK.
END-OF-DEFINITION.

DEFINE MAC__SET_RULE_FOR_OBJECT.
  CLEAR LD_S__CUST_LINK.
  LD_S__CUST_LINK-TG-DIMENSION = &1.
  LD_S__CUST_LINK-TG-ATTRIBUTE = &2.
  LD_S__CUST_LINK-SC-DIMENSION = &4.
  LD_S__CUST_LINK-SC-ATTRIBUTE = &5.
  LD_S__CUST_LINK-SC-OBJECT   ?= &3.
  INSERT LD_S__CUST_LINK INTO TABLE LD_T__CUST_LINK.
END-OF-DEFINITION.

DEFINE MAC__SET_MATH_OPERAND_OBJECT.
  CLEAR OPERAND.
  OPERAND-VAR = &1.
  OPERAND-OBJECT = &2.
  INSERT OPERAND INTO TABLE MATH-OPERAND.
END-OF-DEFINITION.

DEFINE MAC__SET_MATH_OPERAND_DATA.
  CLEAR OPERAND.
  OPERAND-VAR = &1.
  GET REFERENCE OF &2 INTO OPERAND-DATA.
  INSERT OPERAND INTO TABLE MATH-OPERAND.
END-OF-DEFINITION.

DEFINE MAC__SET_MATH_OPERAND_CONST.
  CLEAR OPERAND.
  OPERAND-VAR = &1.
  OPERAND-CONST = &2.
  INSERT OPERAND INTO TABLE MATH-OPERAND.
END-OF-DEFINITION.


TYPE-POOLS: ZBD0T, ZBD0C.

DATA
: LD_T__CUST_LINK       TYPE ZBD0T_TY_T_CUSTOM_LINK
, LD_S__CUST_LINK       TYPE ZBD0T_TY_S_CUSTOM_LINK
, LD_T__DIM_LIST        TYPE ZBD00_T_CH_KEY
, LD_S__DIM_LIST        TYPE ZBD00_S_CH_KEY
, LD_S__ALIAS           TYPE ZBD00_S_ALIAS
, LD_T__ALIAS           TYPE ZBD00_T_ALIAS
, LD_S__CONST           TYPE ZBD0T_TY_S_CONSTANT
, LD_T__CONST           TYPE ZBD0T_TY_T_CONSTANT
.

DATA
: INVENTORY_MP          TYPE REF TO ZCL_BD00_APPL_TABLE
, HEAD                  TYPE REF TO ZCL_BD00_APPL_TABLE
, SEARCH                TYPE REF TO ZCL_BD00_APPL_TABLE
, TARGET                TYPE REF TO ZCL_BD00_APPL_TABLE
, MATH                  TYPE ZBD0T_TY_S_RULE_MATH
, OPERAND               TYPE ZBD0T_TY_S_MATH_OPERAND
, LO_RFC_TASK           TYPE REF TO ZCL_BD00_RFC_TASK
.

ZCL_BD00_CONTEXT=>SET_CONTEXT( I_APPSET_ID = `DEMO` I_APPL_ID = `DEMO_01`).

CREATE OBJECT LO_RFC_TASK
  EXPORTING
    NUM = 1.

BREAK-POINT.
*--------------------------------------------------------------------*
* HEAD
CREATE OBJECT HEAD
  EXPORTING
*    it_range    = dt_sel
*    it_dim_list = lt_dim_list
    I_TYPE_PK   = ZBD0C_TY_TAB-STD_NON_UNIQUE_DK
    IF_SUPPRESS_ZERO = ABAP_TRUE.

BREAK-POINT.
HEAD->FREE_OBJECT( ).

HEAD->NEXT_PACK( ZBD0C_READ_MODE-ARFC ).
HEAD->NEXT_LINE( ).

*--------------------------------------------------------------------*
* SEARCH
MAC__APPEND_TO_DIM_LIST
: `SCENARIO`    ``           ABAP_TRUE    1
, `PERIOD`      `YEAR`       ABAP_TRUE    2
, `ACCOUNT`     ``           ABAP_TRUE    3
, `ENTITY`      ``           ABAP_TRUE    4
, `CURRENCY`    ``           ABAP_FALSE   5
.

LD_S__ALIAS-BPC_NAME-DIMENSION = `PERIOD`.
LD_S__ALIAS-BPC_NAME-ATTRIBUTE = `YEAR`.
LD_S__ALIAS-BPC_ALIAS-DIMENSION = `PERIOD`.

INSERT LD_S__ALIAS INTO TABLE LD_T__ALIAS.


CREATE OBJECT SEARCH
  EXPORTING
*     it_range    = dt_sel
    IT_DIM_LIST = LD_T__DIM_LIST
    IT_ALIAS    = LD_T__ALIAS
    I_TYPE_PK   = ZBD0C_TY_TAB-SRD_NON_UNIQUE.
*
SEARCH->NEXT_PACK( ZBD0C_READ_MODE-ARFC ).
SEARCH->NEXT_LINE( ).

*--------------------------------------------------------------------*
* TARGET
LD_S__CONST-DIMENSION = `ACCOUNT`.
LD_S__CONST-CONST = `ACCOUNT`.

INSERT LD_S__CONST INTO TABLE LD_T__CONST.

CREATE OBJECT TARGET
  EXPORTING
*     it_range    = dt_sel
*    it_dim_list = lt_dim_list
IF_AUTO_SAVE  = `X`
    IT_CONST    = LD_T__CONST
    I_TYPE_PK   = ZBD0C_TY_TAB-HAS_UNIQUE_DK.


* RULES ASSIGN

* RULE #01
DATA SCENARIO TYPE UJ_VALUE VALUE `ASD`.
DATA LD_V__I TYPE UJ_KEYFIGURE VALUE -1.

* ASSIGN
MAC__SET_RULE_FOR_OBJECT
: `ACCOUNT` `` SEARCH `ACCOUNT` ``
, `ENTITY`  `` SEARCH `ENTITY`  ``.

MAC__SET_RULE_FOR_DATA
: `SCENARIO` `` SCENARIO.

MAC__SET_RULE_FOR_CONST
: `PERIOD` `` `2014.JAN`.

* MATH
MATH-EXP = `HEAD * SEARCH * DATA / CONST * -100.123`.

MAC__SET_MATH_OPERAND_OBJECT
: `Head`        HEAD
, `SEArCH`      SEARCH.

MAC__SET_MATH_OPERAND_DATA
:`DATA` LD_V__I.

MAC__SET_MATH_OPERAND_CONST
: `CONST`  `100-`.

BREAK-POINT.
DATA RULE_1_ASSIGN TYPE ZBD0T_ID_RULES.
DATA RULE_2_ASSIGN TYPE ZBD0T_ID_RULES.
DATA RULE_1_SEARCH TYPE ZBD0T_ID_RULES.

RULE_1_ASSIGN = TARGET->SET_RULE_ASSIGN(
        IT_FIELD         = LD_T__CUST_LINK
        IS_MATH          = MATH
        IO_DEFAULT       = HEAD
        I_MODE_ADD       = ZBD0C_MODE_ADD_LINE-INSERT ).

RULE_2_ASSIGN = TARGET->SET_RULE_ASSIGN(
*        rules_field    = ld_t__cust_link
*        rules_math     = math
        IO_DEFAULT        = TARGET
        I_MODE_ADD       = ZBD0C_MODE_ADD_LINE-COLLECT ).



RULE_1_SEARCH = SEARCH->SET_RULE_SEARCH( IO_DEFAULT = HEAD ).


SEARCH->NEXT_LINE( RULE_1_SEARCH ).

SEARCH->NEXT_LINE( ).

TARGET->RULE_ASSIGN( RULE_1_ASSIGN ).
TARGET->RULE_ASSIGN( RULE_2_ASSIGN ).

SEARCH->NEXT_LINE(  ).
SEARCH->NEXT_LINE(  ).


TARGET->WRITE_BACK( ).

HEAD->FREE_OBJECT( ).
ZCL_BD00_APPL_TABLE=>FREE_ALL_OBJECT( ).
*zcl_bd00_rfc_task=>wait_end_all_task( ).

*data lt_cust_link type zbd0t_ty_t_custom_link.
*data ls_cust_link type zbd0t_ty_s_custom_link.
*
*
**
**break-point.
**insert ls_cust_link into table lt_cust_link.
**
**a_in_d0_001->set_key_link( id = `01` it_obj_link = lt_cust_link io_obj = a_in_i0_001 ).
**
**a_in_d0_001->next_line( id = `01` ).
*
**data lt_link type zbd0t_ty_t_link_key.
**data ls_link type zbd0t_ty_s_link_key.
*
*ls_link-tg-dimension = `ACCOUNT`.
*ls_link-sc-dimension = `ACCOUNT`.
*
*insert ls_link into table lt_link.
*
*a_in_d0_001->set_key_link( io_obj = a_in_i0_001 it_link = lt_link ).
*
*clear: ls_link, lt_Link.
*
*ls_link-tg-dimension = `ACCOUNT`.
*ls_link-sc-dimension = `ACCOUNT`.
*insert ls_link into table lt_link.
*
*ls_link-tg-dimension = `ENTITY`.
*ls_link-sc-dimension = `ENTITY`.
*insert ls_link into table lt_link.
*
*a_in_d0_001->set_key_link( id = `01` io_obj = a_in_i0_001 it_link = lt_link ).
*
*data account type string value ``.
*clear lt_cust_link.
*ls_cust_link-tg-dimension = `ENTITY`.
*ls_cust_link-sc-dimension = `ENTITY`.
*ls_cust_link-sc-object = a_in_i0_001.
*insert ls_cust_link into table lt_cust_link.
*
*clear ls_cust_link.
*ls_cust_link-tg-dimension = `ACCOUNT`.
*get reference of account into ls_cust_link-sc-data.
*
*insert ls_cust_link into table lt_cust_link.
*
*a_in_d0_001->set_key_link( id = `02` io_obj = a_in_i0_001 it_cust_link = lt_cust_link ).
*
*while a_in_i0_001->next_line( ) eq zbd0c_st-found.
**  check a_in_d0_001->next_line( io_key = a_in_i0_001 ) eq zbd0c_st-found.
**  check a_in_d0_001->next_line( id = `01` io_key = a_in_i0_001 ) eq zbd0c_st-found.
*  check a_in_d0_001->next_line( id = `02` ) eq zbd0c_st-found.
*
*
*
*
*
*
*endwhile.

BREAK-POINT.
