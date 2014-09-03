method get_tabclass.

  data
  : ld_v__tabclass type tabclass
  .

  clear tabclass.

  select single object
         from tadir
         into ld_v__tabclass
         where object = zvcsc_r3tr_type-tabl
           and delflag <> `X`.

  if sy-subrc = 0.
    select single tabclass
           from dd02l
           into tabclass
           where tabname = obj_name.
  endif.

endmethod.
