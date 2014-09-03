method skip_eq.

  data
  : skip_val  type string
  , tskip_val type table of string
  , val       type string
  .

  skip_val = i02.
  val      = i01.
  condense skip_val no-gaps.
  split skip_val at `,` into table tskip_val.

  read table tskip_val
       with key table_line = val
       transporting no fields.

  if sy-subrc = 0.
    raise exception type zcx_bdnl_skip_assign.
  else.
    e = i01.
  endif.



endmethod.
