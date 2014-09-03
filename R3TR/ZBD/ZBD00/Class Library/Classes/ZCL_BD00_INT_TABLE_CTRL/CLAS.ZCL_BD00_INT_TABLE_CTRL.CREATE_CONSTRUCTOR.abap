method create_constructor.
  data
  : ls_string type string
  .

  field-symbols
  : <ls_object_reestr> type ty_s_object_reestr
  .

  mac__append_to_itab et_definition
  :`methods`
  ,`: constructor`
  ,`  importing it_reestr     type ty_t_object_reestr`
  ,`            it_rule_link  type zcl_bd00_appl_ctrl=>ty_s_rules_reestr`
  ,`            it_range      type zbd0t_ty_t_range_kf optional.          `
  .

* CONSTRUCTOR присвоение объектов
  mac__append_to_itab et_implementatiom
  :`method constructor.`
  ,`call method    super->constructor`
  ,`     exporting it_rule_link = it_rule_link.`
  ,`field-symbols <ls_reestr> like line of it_reestr.`
  ,`loop at it_reestr assigning <ls_reestr>.`
  ,`case <ls_reestr>-name.`
  .

  loop at it_object_reestr
    assigning <ls_object_reestr>.

    if <ls_object_reestr>-object is bound.
      concatenate
      :`when ` ```` <ls_object_reestr>-name ```` `. ` into ls_string
      , ls_string <ls_object_reestr>-name ` ?= <ls_reestr>-object.` into ls_string.
      .
    elseif <ls_object_reestr>-data is bound.
      concatenate
      :`when ` ```` <ls_object_reestr>-name ```` `. ` into ls_string
      , ls_string <ls_object_reestr>-name ` ?= <ls_reestr>-data.` into ls_string.
      .
    endif.

    append ls_string to et_implementatiom.
  endloop.

  mac__append_to_itab et_implementatiom
  :`endcase.`
  ,`endloop.`
  ,`gt_range = it_range.`
  ,`endmethod.`
  .

endmethod.
