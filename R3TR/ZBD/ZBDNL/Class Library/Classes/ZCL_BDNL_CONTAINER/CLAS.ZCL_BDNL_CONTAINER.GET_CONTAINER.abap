method get_container.

  field-symbols
  : <ld_s__reestr> type ty_s__reestr
  .

  free container.

  read table cd_t__table_reestr
       assigning <ld_s__reestr>
       with table key
            tablename = tablename
            script = cd_v__current_script.

  if sy-subrc = 0.

    container ?= <ld_s__reestr>-container.

  endif.

endmethod.
