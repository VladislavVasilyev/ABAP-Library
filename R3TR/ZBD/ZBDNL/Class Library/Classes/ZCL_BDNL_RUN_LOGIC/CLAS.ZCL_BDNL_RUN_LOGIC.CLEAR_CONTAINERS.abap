method clear_containers.

  data
  : ld_v__rule_id           type zbd0t_id_rules
  , ld_s__math              type zbd0t_ty_s_rule_math
  , ld_s__operand           type zbd0t_ty_s_math_operand
  , ld_v__str               type string
  , lr_s__containers        type ref to zbnlt_s__containers
  , ld_v__cnt               type i
  , ld_v__packsize          type i
  , ld_v__packsize_str      type string
  , ld_v__packstart         type tzntstmpl
  , ld_v__packend           type tzntstmpl
  , ld_v__duration          type string
  , ld_v__nr_pack           type string

  .

  field-symbols
  : <ld_s__stack>           type zbnlt_s__stack_container
  , <ld_s__containers>      type zbnlt_s__containers
  .

  loop     at gd_s__stack-containers
    assigning <ld_s__stack>
        where turn = gd_v__turn
          and command = zblnc_keyword-clear.

    add 1 to gd_v__cnt_clear.
    concatenate zblnc_keyword-clear `-` gd_v__cnt_clear into  <ld_s__stack>-tablename .

    lr_s__containers = create_container( i_v__tablename = <ld_s__stack>-tablename ).
    assign lr_s__containers->* to <ld_s__containers>.

    clear ld_v__cnt.
    message s047(zbdnl) with
      <ld_s__containers>-object->gr_o__model->gr_o__application->gd_v__appset_id
      <ld_s__containers>-object->gr_o__model->gr_o__application->gd_v__appl_id.

    while <ld_s__containers>-object->next_pack( zbd0c_read_mode-pack ) eq zbd0c_read_pack .
      " LOG PROCESS
      add 1 to ld_v__cnt.
      get time stamp field ld_v__packstart.
      ld_v__packsize = <ld_s__containers>-object->get_packsize( ).
      ld_v__packsize_str = get_nr_pack( i_v__nr_pack = ld_v__packsize i_v__size = 8 ).

      <ld_s__containers>-object->write_back( ).
      <ld_s__containers>-object->clear( ).

      " Log
      get time stamp field ld_v__packend.
      call method convert_time
        exporting
          i_v__start      = ld_v__packstart
          i_v__end        = ld_v__packend
        importing
          e_v__delta_time = ld_v__duration.

      ld_v__nr_pack = get_nr_pack(  i_v__nr_pack = ld_v__cnt i_v__size = 4 ).

      message s030(zbdnl) with ld_v__nr_pack ld_v__packsize_str ld_v__duration.

    endwhile.
    message s049(zbdnl).
  endloop.

  zcl_bd00_rfc_task=>wait_end_all_task( ). " ожидание завершения всех RFC

endmethod.
