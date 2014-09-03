method get_object.

  field-symbols
  : <ld_s__object> type zvcst_s__objects_stack
  .

  read table cd_t__stack
     with table key type = type
     assigning <ld_s__object>.

  if sy-subrc = 0.
    ref ?= <ld_s__object>-object.
  else.
    free ref .
  endif.

endmethod.
