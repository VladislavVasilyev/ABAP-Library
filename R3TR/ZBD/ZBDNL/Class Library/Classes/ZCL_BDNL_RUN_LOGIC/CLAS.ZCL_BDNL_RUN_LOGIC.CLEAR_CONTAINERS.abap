method CLEAR_CONTAINERS.

  data
  : ld_v__cnt               type i
  , ld_v__packsize          type i
  , ld_v__packsize_str      type string
  , ld_v__packstart         type tzntstmpl
  , ld_v__packend           type tzntstmpl
  , ld_v__duration          type string
  , ld_v__nr_pack           type string
  , ld_t__clear             type zcl_bdnl_container=>ty_t__reestr
  , lr_o__container         type ref to zcl_bdnl_container
  .

  field-symbols
  : <ld_s__stack>           type zcl_bdnl_container=>ty_s__reestr
  .

  ld_t__clear = zcl_bdnl_container=>get_container_clear( ).

  loop     at ld_t__clear
    assigning <ld_s__stack>.

    lr_o__container = zcl_bdnl_container=>create_container( <ld_s__stack>-tablename ).

    clear ld_v__cnt.
    message s047(zbdnl) with
      lr_o__container->gr_o__container->gr_o__model->gr_o__application->gd_v__appset_id
      lr_o__container->gr_o__container->gr_o__model->gr_o__application->gd_v__appl_id.

    while lr_o__container->gr_o__container->next_pack( zbd0c_read_mode-pack ) eq zbd0c_read_pack .
      " LOG PROCESS
      add 1 to ld_v__cnt.
      get time stamp field ld_v__packstart.
      ld_v__packsize = lr_o__container->gr_o__container->get_packsize( ).
      ld_v__packsize_str = get_nr_pack( i_v__nr_pack = ld_v__packsize i_v__size = 8 ).

      lr_o__container->gr_o__container->write_back( ).
      lr_o__container->gr_o__container->clear( ).

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

    zcl_bd00_rfc_task=>wait_end_all_task( ). " ожидание завершения всех RFC
    message s049(zbdnl).
  endloop.

  zcl_bd00_rfc_task=>wait_end_all_task( ). " ожидание завершения всех RFC

endmethod.
