method get_container_clear.

  field-symbols
  : <ld_s__reestr> type ty_s__reestr
  .

  free container.

  loop at cd_t__table_reestr
       assigning <ld_s__reestr>
       where script = cd_v__current_script
         and container->gd_v__command = zblnc_keyword-clear
         and container->gd_v__turn = cd_v__n_turn.

    if sy-subrc = 0.
      insert <ld_s__reestr> into table container.
    endif.

  endloop.

endmethod.
