method next_pack.
*╔═══════════════════════════════════════════════════════════════════╗
*║ Режимы работы:                                                    ║
*║                                                                   ║
*║ 1. zbd0c_read_mode-arfc - чтение полного скоупа через ARFC        ║
*║                           первый запуск активирует RFC, второй    ║
*║                           вызов  ожидание окончания работы        ║
*║                                                                   ║
*║ 2. zbd0c_read_mode-full - чтение полного скоупа напрямую          ║
*║                                                                   ║
*║ 3. zbd0c_read_mode-pack - чтение данных попакетно через курсор,   ║
*║                           этот режим открывает курсор и делает    ║
*║                           невозможным использование режима FULL,  ║
*║                           и запись данных обратно в приложение    ║
*║                           напрямую                                ║
*╠═══════════════════════════════════════════════════════════════════╣
  case mode.
    when zbd0c_read_mode-arfc.
      gr_o__process_data->read_data_arfc( ).
    when zbd0c_read_mode-srfc.
      e_st = gr_o__process_data->read_data_srfc( ).
    when zbd0c_read_mode-full.
      e_st = gr_o__process_data->read_data( lcl_process_data=>read_mode-full ).
    when zbd0c_read_mode-pack.
      e_st = gr_o__process_data->read_data( lcl_process_data=>read_mode-pack ).
    when zbd0c_read_mode-genfull.
      e_st = gr_o__process_data->generate_data( lcl_process_data=>read_mode-full ).
    when zbd0c_read_mode-genpack.
      e_st = gr_o__process_data->generate_data( lcl_process_data=>read_mode-pack ).
    when zbd0c_read_mode-gendim.
      e_st = gr_o__process_data->generate_dimension( ).
  endcase.

  check mode = zbd0c_read_mode-pack     or
        mode = zbd0c_read_mode-full     or
        mode = zbd0c_read_mode-srfc     or
        mode = zbd0c_read_mode-genpack  or
        mode = zbd0c_read_mode-genfull  or
        mode = zbd0c_read_mode-gendim.

  raise event ev_change_table.
*╚═══════════════════════════════════════════════════════════════════╝

endmethod.
