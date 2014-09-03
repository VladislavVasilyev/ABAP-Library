method free_object.
  data
  : lr_o__int_table type ref to zcl_bd00_int_table
  , lr_o__appl_table type ref to zcl_bd00_appl_table
  .

  field-symbols
  : <ld_s__object_reestr> type ty_s_object_reestr
  , <ld_s__rules_reestr>  type ty_s_rules_reestr
  , <ld_s__class_reg>     type ty_s_class_reg
  .

  me->clear( ). " очистка данных

  " реестр динамических програм
  loop at gd_t__class_reg
       assigning <ld_s__class_reg>
       where main =  me.

    lr_o__int_table ?= <ld_s__class_reg>-class.

    set handler lr_o__int_table->change_fline for me activation ''.
    set handler lr_o__int_table->change_table for me activation ''.
    set handler lr_o__int_table->delete_line  for me activation ''.

    free
    : <ld_s__class_reg>-class
    , <ld_s__class_reg>-main
    .

    <ld_s__class_reg>-f_delete = abap_true.
  endloop.


  " реестр правил
  loop at gd_t__reestr_link
    assigning <ld_s__rules_reestr>.

    read table <ld_s__rules_reestr>-rule_link
         with key object = me
         transporting no fields.

    if sy-subrc = 0.
      read table gd_t__class_reg
            with table key id = <ld_s__rules_reestr>-id
            assigning <ld_s__class_reg>.

      if sy-subrc = 0 and <ld_s__class_reg>-f_delete <> abap_true.
        lr_o__int_table ?= <ld_s__class_reg>-class.

        set handler lr_o__int_table->change_fline for <ld_s__class_reg>-main activation ''.
        set handler lr_o__int_table->change_table for <ld_s__class_reg>-main activation ''.
        set handler lr_o__int_table->delete_line  for <ld_s__class_reg>-main activation ''.

        free
        : <ld_s__class_reg>-class
        , <ld_s__class_reg>-main
        .

        <ld_s__class_reg>-f_delete = abap_true.
      endif.
    endif.


    if <ld_s__rules_reestr>-main = me or <ld_s__rules_reestr>-default = me.

      if <ld_s__rules_reestr>-default is bound.
        set handler lr_o__int_table->change_fline for <ld_s__rules_reestr>-default activation ''.
        set handler lr_o__int_table->change_table for <ld_s__rules_reestr>-default activation ''.
        set handler lr_o__int_table->delete_line  for <ld_s__rules_reestr>-default activation ''.
      endif.

      free
      : <ld_s__rules_reestr>-main
      , <ld_s__rules_reestr>-default
      .

      clear
      : <ld_s__rules_reestr>-mode_add
      , <ld_s__rules_reestr>-f_unique_key
      , <ld_s__rules_reestr>-rule_link
      , <ld_s__rules_reestr>-range
      .
      <ld_s__rules_reestr>-f_delete = abap_true.
    endif.
  endloop.

  free " освобождение внутренних объектов
  : me->gr_o__line
  , me->gr_o__table
  , me->gr_o__model
  , me->gd_s__last_rule
  .

  try .
      lr_o__appl_table ?= me.
      free lr_o__appl_table->gr_o__process_data.
      clear
      : lr_o__appl_table->gd_s__last_read
      .
    catch cx_sy_move_cast_error.
  endtry.

  read table cd_t__object_reestr
       with table key object = me
       assigning <ld_s__object_reestr>.

  me->gd_f__delete = <ld_s__object_reestr>-f_delete = abap_true.

endmethod.
