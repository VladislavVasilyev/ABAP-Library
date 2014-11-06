method set_variable.

  field-symbols
  : <ld_s__variable>          type zbnlt_s__variable
  .

  read table gd_t__variable
       assigning <ld_s__variable>
       with key var = name.

  if sy-subrc = 0.
    <ld_s__variable>-val = value.
  endif.


endmethod.
