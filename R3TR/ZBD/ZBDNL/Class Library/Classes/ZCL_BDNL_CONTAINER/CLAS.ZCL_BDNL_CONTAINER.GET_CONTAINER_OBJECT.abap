method get_container_object.

  field-symbols
  : <ld_s__reestr> type ty_s__reestr
  .

  free container.

  read table cd_t__table_reestr
       assigning <ld_s__reestr>
       with key container->gr_o__container = object.

  if sy-subrc = 0.

    container = <ld_s__reestr>-container.

  endif.

endmethod.
