method create_dyn_rule.

  data
  : ld_t__method                       type ty_t_string
  , ld_t__code                         type ty_t_string
  , ld_t__global_types_and_data        type ty_t_string
  , ld_t__constructor_impl             type ty_t_string
  , ld_t__constructor_defn             type ty_t_string
  , ld_t__rule_link                    type zcl_bd00_appl_ctrl=>ty_s_rules_reestr
  .

* правило линковки
  ld_t__rule_link   = zcl_bd00_appl_ctrl=>get_key_link( id ) .

* реестр объектов
  et_object_reestr =
    get_reestr_object( it_link = ld_t__rule_link ).

* глобальные переменные
  create_global_td(
  exporting
     it_object_reestr = et_object_reestr
  receiving
     et_code          = ld_t__global_types_and_data ).

* метод конструктора
  create_constructor(
  exporting
    it_object_reestr  = et_object_reestr
  importing
    et_definition     = ld_t__constructor_defn
    et_implementatiom = ld_t__constructor_impl ).

* метод реализующий правило присвоения
  ld_t__method = create_code_assign_link( it_rule_link     = ld_t__rule_link
                                          it_object_reestr = et_object_reestr ).


*╔═══════════════════════════════════════════════════════════════════╗
*║ Формирование текста программы                                     ║
*╠═══════════════════════════════════════════════════════════════════╣
  mac__append_to_itab ld_t__code
  :`program.`
  ,`class dyn definition inheriting from zcl_bd00_int_table final create public.`
  ,`public section.`
  ,`type-pools: abap, zbd0c, zbd0t.`
  ,`methods next redefinition.`
  ,`methods add  redefinition.`
  ,`methods rule redefinition.`
  ,` `
  .

  append lines of
  : ld_t__global_types_and_data  to ld_t__code
  , ld_t__constructor_defn       to ld_t__code
  .

  mac__append_to_itab ld_t__code
  :`endclass.`
  ,` `
  ,`class dyn implementation.`
  ,`method  add.  endmethod.`
  ,`method  next. endmethod.`
  .

  append lines of
  : ld_t__constructor_impl           to ld_t__code
  , ld_t__method                     to ld_t__code.

  mac__append_to_itab ld_t__code
  :`endclass.`.
*╚═══════════════════════════════════════════════════════════════════╝


*╔═══════════════════════════════════════════════════════════════════╗
*║ Генерация программы                                               ║
*╠═══════════════════════════════════════════════════════════════════╣
  data
  : mess   type string
  , prog   type string
  , lin    type i
  .

  if prog is initial.
    generate subroutine pool ld_t__code name prog message mess line lin.
    concatenate `\PROGRAM=` prog `\CLASS=DYN` into class.
  endif.
*╚═══════════════════════════════════════════════════════════════════╝
endmethod.
