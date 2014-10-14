method create_container.

  field-symbols
  : <ld_s__reestr> type ty_s__reestr
  .

  read table cd_t__table_for
       assigning <ld_s__reestr>
       with table key
            tablename = tablename
            script = cd_v__current_script.

  if sy-subrc = 0.

        container ?= <ld_s__reestr>-container.

  else.
    read table cd_t__table_reestr
         assigning <ld_s__reestr>
         with table key
              tablename = tablename
              script = cd_v__current_script.

    <ld_s__reestr>-container->create_table( f_master = f_master package_size = package_size ).

    container ?= <ld_s__reestr>-container.

    insert <ld_s__reestr> into table cd_t__table_for.

  endif.

endmethod.
