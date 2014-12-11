method create_dyn_read.

  data
  : ld_t__method                       type ty_t_string
  , ld_t__code                         type ty_t_string
  , ld_t__global_types_and_data        type ty_t_string
  , ld_t__constructor_impl             type ty_t_string
  , ld_t__constructor_defn             type ty_t_string
  , ld_t__rule_link                    type zcl_bd00_appl_ctrl=>ty_s_rules_reestr
  , line                               type string
  , ld_v__classname                    type string
  , ld_v__definition                   type string
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

* метод реализующий поиск строки
  if ld_t__rule_link-f_unique_key = abap_true and lines( ld_t__rule_link-rule_link_or ) = 0.
    ld_t__method = create_code_unique_key( it_rule_link     = ld_t__rule_link
                                           it_object_reestr = et_object_reestr ).
  else.
    ld_t__method = create_code_non_unique_key( it_rule_link     = ld_t__rule_link
                                            it_object_reestr = et_object_reestr ).
  endif.


  if i_f__36 = abap_true.
    ld_v__classname = id.
    concatenate `DYN_` ld_v__classname into ld_v__classname.
    condense ld_v__classname no-gaps.

    concatenate `class ` ld_v__classname ` definition inheriting from zcl_bd00_int_table final create public.`
    into ld_v__definition.

    mac__append_to_itab ld_t__code
    : ld_v__definition
    .
  else.
    mac__append_to_itab ld_t__code
    :`program.`
    , `class dyn definition inheriting from zcl_bd00_int_table final create public.`
    .
  endif.

*╔═══════════════════════════════════════════════════════════════════╗
*║ Формирование текста программы                                     ║
*╠═══════════════════════════════════════════════════════════════════╣
  mac__append_to_itab ld_t__code
  :`public section.`
  ,`type-pools: abap, zbd0c, zbd0t.`
  ,`methods next redefinition.`
  ,`methods add  redefinition.`
  ,`methods rule redefinition.`,` `
  .

  append lines of
  : ld_t__global_types_and_data  to ld_t__code
  , ld_t__constructor_defn to ld_t__code
  .

  mac__append_to_itab ld_t__code
  :`endclass.`
  .


  if i_f__36 = abap_true.
    concatenate `class ` ld_v__classname ` implementation.` into ld_v__definition.

    mac__append_to_itab ld_t__code
    : ld_v__definition
    .
  else.
    mac__append_to_itab ld_t__code
    :`class dyn implementation.`
    .
  endif.


  mac__append_to_itab ld_t__code
  :`method  add. endmethod.`
  ,`method rule. endmethod.`
  .

  append lines of
  : ld_t__constructor_impl to ld_t__code
  , ld_t__method                     to ld_t__code.

  mac__append_to_itab ld_t__code
  :`endclass.`.
*╚═══════════════════════════════════════════════════════════════════╝


*╔═══════════════════════════════════════════════════════════════════╗
*║ Генерация программы                                               ║
*╠═══════════════════════════════════════════════════════════════════╣
  if i_f__36 = abap_true.
    append lines of ld_t__code to cd_t__code.
    concatenate  `\CLASS=` ld_v__classname into class.
  else.

    data
    : mess   type string
    , prog   type string
    , lin    type i
    .

    if prog is initial.
      generate subroutine pool ld_t__code name prog message mess line lin.

      if sy-subrc <> 0.
        read table ld_t__code index lin into line.

        raise exception type zcx_bd00_create_rule
          exporting message = mess
                    line    = line.
      endif.

      concatenate `\PROGRAM=` prog `\CLASS=DYN` into class.
    endif.
  endif.
*╚═══════════════════════════════════════════════════════════════════╝

endmethod.
