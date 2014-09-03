method DDIF_TYPE_GET.

  data: ld_v__name(30) type c.

  concatenate '%_C' name into ld_v__name.
  read report ld_v__name into source state state.
  if sy-subrc ne 0.
    mac__module_raise ddif_type_get
    : sy-subrc not_existing
    .
  endif.

* Texte
  select * from ddtypet into table texts
           where typegroup = name.

endmethod.
