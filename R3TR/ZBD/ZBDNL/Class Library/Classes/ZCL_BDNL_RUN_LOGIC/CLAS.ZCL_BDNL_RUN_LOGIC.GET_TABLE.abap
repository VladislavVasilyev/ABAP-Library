method get_table.


  field-symbols
  : <ld_s__stack>           type zbnlt_s__stack_container
  .

  read table gd_t__for_containers
     with key tablename = i_v__tablename
     reference into e_s__table.

*  check sy-subrc <> 0.
*
*  loop at gd_t__containers reference into e_s__table
*       where tablename = i_v__tablename
*         and turn <= gd_v__turn.
*
*    exit.
*
*  endloop.

endmethod.
