*&---------------------------------------------------------------------*
*& Report  ZBD00_TEST
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZBD00_APPL_DEMO.

DEFINE MAC__APPEND_TO_DIM_LIST.
  LS_DIM_LIST-DIMENSION   = &1.
  LS_DIM_LIST-ATTRIBUTE   = &2.
  LS_DIM_LIST-F_KEY       = &3.
  LS_DIM_LIST-ORDERBY     = &4.
  INSERT LS_DIM_LIST INTO TABLE LT_DIM_LIST.
END-OF-DEFINITION.
DEFINE MAC__APPEND_TO_RANGE.
  LS_RANGE-DIMENSION  = &1.
  LS_RANGE-ATTRIBUTE  = &2.
  LS_RANGE-SIGN       = &3.
  LS_RANGE-OPTION     = &4.
  LS_RANGE-LOW        = &5.
  LS_RANGE-HIGH       = &6.
  APPEND LS_RANGE TO LT_RANGE.
END-OF-DEFINITION.
TYPE-POOLS ZBD0C.

DATA K TYPE UJ_KEYFIGURE VALUE 1.
DATA C TYPE C LENGTH 20 VALUE `sdf`.
DATA R TYPE REF TO DATA.
DATA LO_DATA_DESCR          TYPE REF TO CL_ABAP_ELEMDESCR.

GET REFERENCE OF C INTO R.
FIELD-SYMBOLS: <R> TYPE C.

LO_DATA_DESCR ?= CL_ABAP_ELEMDESCR=>DESCRIBE_BY_DATA_REF( R ).

ASSIGN C TO <R>.

BREAK-POINT.
RETURN.
*--------------------------------------------------------------------*
* Создание контейнера

DATA GO_GROSSMARGIN_00 TYPE REF TO ZCL_BD00_APPL_TABLE.
DATA GO_GROSSMARGIN_01 TYPE REF TO ZCL_BD00_APPL_TABLE.
DATA GO_GROSSMARGIN_02 TYPE REF TO ZCL_BD00_APPL_TABLE.

* ZCL_BD00_APPL_TABLE является основным классом, предназначенным для
* работы с данными приложении BPC.

* Входные параметры конструктора
* 1.    I_APPSET_ID    - имя набора приложений
* 2.    I_APPL_ID      - имя приложения

DATA LV_APPSET_ID TYPE UJ_APPSET_ID.
DATA LV_APPL_ID   TYPE UJ_APPL_ID.

*--------------------------------------------------------------------*
* 3.    IT_RANGE       - таблица ограничения данных. Тип uj0_t_sel
*       ╠═ DIMENSION   - имя измерения
*       ╠═ ATTRIBUTE   - имя атрибута
*       ╠═ SIGN        - include/exclude
*       ╠═ OPTION      - оператор сравнения
*       ╠═ LOW         - нижняя граница
*       ╚═ HIGH        - верхняя граница
*   Если IT_RANGE не определена ограничения будут сняты, и выгрузятся все данные
* приложения

DATA LS_RANGE TYPE UJ0_S_SEL.
DATA LT_RANGE TYPE UJ0_T_SEL.

*--------------------------------------------------------------------*
*4.    IT_DIM_LIST    - список полей для извлечения
*      ╠═ DIMENSION   - имя измерения
*      ╠═ ATTRIBUTE   - имя атрибута
*      ╠═ ORDERBY     - порядок группировки начиная с 1
*      ╚═ F_KEY       - признак ключа
*   Если IT_DIM_LIST не определена, набор полей для извлечения будет содержать
* только измерения и показатель

DATA LS_DIM_LIST    TYPE ZBD00_S_CH_KEY.
DATA LT_DIM_LIST    TYPE ZBD00_T_CH_KEY.

*--------------------------------------------------------------------*
*5.    I_TYPE_PK      - тип таблицы
*      ╠═ zbd0c_ty_tab-std_non_unique_df
*      ╠═ zbd0c_ty_tab-srd_non_unique_df
*      ╠═ zbd0c_ty_tab-srd_unique_df
*      ╠═ zbd0c_ty_tab-srd_non_unique
*      ╚═ zbd0c_ty_tab-srd_unique
* Если I_TYPE_PK не определен то тип таблицы будет стандарный

DATA LV_TYPE_PK TYPE ZBD00_TYPE_APPL_TABLE.

*--------------------------------------------------------------------*
*       IT_SK_DIM_LIST - не использовать
*--------------------------------------------------------------------*


*--------------------------------------------------------------------*
* Создание объектов:
*--------------------------------------------------------------------*
* Инициализация входных переменных

*lv_appset_id = `BUDGET_2014`.
*lv_appl_id   = `GROSSMARGIN`.
*
** lt_range
*mac__append_to_range
*   : `PRODUCT` `GROUP`      'I' 'EQ' 'CAT1L' ``
*   , `TIME`    ``           'I' 'CP' `2014.++N` ``
*   .
*
** lt_dim_list
*mac__append_to_dim_list
*   : `ACCOUNT`    ``        abap_true  1
*   , `ENTITY`     ``        abap_true  2
*   , `TIME`       ``        abap_true  3
*   , `SCENARIO`   ``        abap_true  4
*   , `PRODUCT`    ``        abap_true  5
*   , `PRODUCT`    `GROUP`   abap_true  6
*   , `CURRENCY`   ``        abap_true  7
*   .
*
*create object go_grossmargin_00
*  exporting
*    i_appset_id = lv_appset_id
*    i_appl_id   = lv_appl_id
*    it_range    = lt_range
*    it_dim_list = lt_dim_list
**    i_type_pk   = стандартная таблица
*    .
*
*create object go_grossmargin_01
*  exporting
*    i_appset_id = lv_appset_id
*    i_appl_id   = lv_appl_id
*    it_range    = lt_range
*    it_dim_list = lt_dim_list
*    i_type_pk   = zbd0c_ty_tab-has_unique_dk.
*
*
*create object go_grossmargin_02
*  exporting
*    i_appset_id = lv_appset_id
*    i_appl_id   = lv_appl_id
*    it_range    = lt_range
**    it_dim_list = lt_dim_list
**    i_type_pk   = zbd0c_ty_tab-srd_non_unique_dk
*    .
*
*data lt_rules_field  type zbd0t_ty_t_rule_field.
*data ls_rules_field  type zbd0t_ty_s_rule_field.
*
*ls_rules_field-tg-dimension = `PRODUCT`.
*ls_rules_field-sc-object ?=  go_grossmargin_00.
*ls_rules_field-sc-dimension = `ENTITY`.
*insert ls_rules_field into table lt_rules_field.
*
*clear ls_rules_field.
*ls_rules_field-tg-dimension = `CURRENCY`.
**ls_rules_field-sc-object = .
**ls_rules_field-sc-dimension = `CURRENCY`.
*ls_rules_field-sc-const = `LC`.
*
*insert ls_rules_field into table lt_rules_field.
*
*data ls_rules       type zbd0t_ty_s_rule_math.
*data ls_operand     type zbd0t_ty_s_math_operand.
*
*
*ls_rules-exp = `A`.
*
*ls_operand-object = go_grossmargin_00.
*ls_operand-var    = `A`.
*
*insert ls_operand into table ls_rules-operand.
*
*ls_operand-object = go_grossmargin_01.
*ls_operand-var    = `B`.
*
*insert ls_operand into table ls_rules-operand.
*
*
*ls_operand-object = go_grossmargin_01.
*ls_operand-var    = `C`.
*
*insert ls_operand into table ls_rules-operand.
*
*break-point.
*go_grossmargin_02->set_rule( id = `01` rules_field = lt_rules_field rules_math = ls_rules ).
*go_grossmargin_02->set_rule( id = `02` default_object = go_grossmargin_02 ).
**--------------------------------------------------------------------*
**--------------------------------------------------------------------*
*data lt_const type zbd0t_ty_t_constant.
*data ls_const type zbd0t_ty_s_constant.
*
*ls_const-dimension  = `ACCOUNT`.
*ls_const-const      = `A_CM_IO_001`.
*insert ls_const into table lt_const.
*ls_const-dimension  = `ENTITY`.
*ls_const-const      = `A`.
*insert ls_const into table lt_const.
*
*
*go_grossmargin_02->set_const( it_const = lt_const ).
*
*
*
**--------------------------------------------------------------------*
** Извлечение данных
**--------------------------------------------------------------------*
** Для извлечения данных служит метод NEXT_PACK
**     Входные параметры:
**         MODE -
**         ╠═ zbd0c_read_mode-arfc
**         ╠═ zbd0c_read_mode-full
**         ╚═ zbd0c_read_mode-pack
*
*
** Извлечение всех данных
*go_grossmargin_01->next_pack( zbd0c_read_mode-full ).
*
** Извлечение данных по блокам
*while go_grossmargin_00->next_pack( zbd0c_read_mode-pack ) ne abap_true.
*  while abap_true ne go_grossmargin_00->next_line(  ).
*
*    go_grossmargin_01->next_line( io_key = go_grossmargin_00 ).
*
*    go_grossmargin_02->rule( `01` ).
*    go_grossmargin_02->rule( `02` ).
*
**    go_grossmargin_02->rule_field( operand1 = go_grossmargin_00 operand2 = go_grossmargin_01 ).
*    go_grossmargin_02->add_line( ).
**    go_grossmargin_02->math( operand1 = go_grossmargin_00 operand2 = go_grossmargin_01 operation = 'ADD').
*    go_grossmargin_02->add_line( ).
*
*
**    data copy type ref to zcl_bd00_appl_line.
**    copy = go_grossmargin_00->get_copy( ).
**
**    check abap_false = go_grossmargin_01->next_line( copy ).
***    copy->math( operand = go_grossmargin1 operation = `ADD`).
***
**    go_grossmargin_01->next_line( go_grossmargin_00 ).
**
**    go_grossmargin_01->get_ch( dimension = `TIME`).
***
**
**
***      go_grossmargin->math( operand = go_grossmargin1->go_rline operation = `ADD` ).
**
**    exit.
*  endwhile.
*
*  go_grossmargin_02->write_back( ).
*
*
*endwhile.
*--------------------------------------------------------------------*
