method free_all_object.

  field-symbols
  : <ld_s__object_reestr> type ty_s_object_reestr
  .

  zcl_bd00_rfc_task=>wait_end_all_task( ). " завершение RFC

  loop at cd_t__object_reestr
      assigning <ld_s__object_reestr>.
    <ld_s__object_reestr>-object->free_object( ). " очистка таблиц
  endloop.

endmethod.
