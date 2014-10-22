method PRINT_LOG_FOR_TABLE.

  constants
  : cs_read               type string value `READ: `
  , cs_write              type string value `WRITE:`
  , cs_skip               type string value `SKIP: `
  , cs_tab                type string value `      `
  , cs_space              type string value `  `
  .

  data
  : ld_t__log_read        type zbd0t_t__log_read
  , ld_s__log_read        type zbd0t_s__log_read
  , ld_t__log_read_dim    type zbd0t_t__log_dimension
  , ld_t__log_write       type zbd0t_t__log_write
  , ld_t__actual_rows	    type zbd0t_t__log_actual
  , ld_v__start_date      type string
  , ld_v__start_time      type string
  , ld_v__delta_time      type string
  , ld_v__message         type string
  , ld_v__appset_id       type uj_appset_id
  , ld_v__appl_id         type uj_appl_id
  , ld_v__dimension       type uj_dim_name
  , ld_v__infoprovide     type rsinfoprov
  , ld_v__nr_pack         type string
  , ld_v__nr_rows         type string
  , ld_v__time            type string
  , ld_v__str             type string
  , ld_v__len             type i
  , ld_f__wcmessage       type rs_bool
  , ld_f__wemessage       type rs_bool
  , ld_s__log             type zcl_bdnl_container=>ty_s__log
  , ld_s__log1            type zcl_bdnl_container=>ty_s__log
  , ld_v__savescript      type string
  , ld_v__saveturn        type string
  , ld_v__turn            type string
  .

  field-symbols

*  ld_s__log    type zbnlt_s__containers
  : <ld_s__log_read>      type zbd0t_s__log_read
  , <ld_s__log_write>     type zbd0t_s__log_write
  , <ld_s__message>       type uj0_s_message
  , <ld_s__log_read_dim>  type zbd0t_s__log_dimension
  , <ld_s__actual_rows>   type zbd0t_s__log_actual
  .

  clear ld_v__savescript.

  loop at zcl_bdnl_container=>cd_t__log into ld_s__log.

    if ld_v__savescript <> ld_s__log-script.
      print> ` ` .
      print> `=========================================================================` .
      concatenate `Script ` ld_s__log-script into ld_v__message.
      print> ld_v__message.
      ld_v__savescript = ld_s__log-script.
      clear ld_v__saveturn.
      print> `*-----------------------------------------------------------------------*` .
    endif.

    ld_v__turn = ld_s__log-n_turn.
    ld_v__str = ld_s__log-n_for.

    concatenate ld_v__turn `.` ld_v__str into ld_v__turn.

    if ld_v__saveturn <> ld_v__turn.

      read table zcl_bdnl_container=>cd_t__log
           into ld_s__log1
           with key n_script = ld_s__log-n_script
                    n_turn   = ld_s__log-n_turn
                    n_for    = ld_s__log-n_for
                    f_master = abap_true.
      if sy-subrc = 0.
        print> ` `.
        concatenate `Loop through the table ` ld_s__log1-tablename `.` into ld_v__message.
        ld_v__saveturn = ld_v__turn.
        if ld_s__log1-skip_rows is not initial.
          ld_v__str = cs_skip.

          " Количество записей
          ld_s__log_read-num_rec = ld_s__log_read-sup_rec  = ld_s__log1-skip_rows.
          ld_v__nr_rows = get_nr_rows( i_s__read = ld_s__log_read ).

          concatenate ld_v__message `Skip` ld_v__nr_rows into ld_v__message separated by cs_space.
        endif.
        print> ld_v__message.
      endif.
    endif.


    if ld_s__log-table is initial.
      print> `*-----------------------------------------------------------------------*` .
      concatenate `Table ` ld_s__log-tablename ` has already been created previously.`    into ld_v__message.
      print> ld_v__message.
      continue.
    endif.

    clear
    : ld_t__log_read
    , ld_t__log_write
    , ld_f__wcmessage
    , ld_f__wemessage
    .

    ld_v__appset_id   = ld_s__log-table->gr_o__model->gr_o__application->gd_v__appset_id.
    ld_v__appl_id     = ld_s__log-table->gr_o__model->gr_o__application->gd_v__appl_id.
    ld_v__dimension   = ld_s__log-table->gr_o__model->gr_o__application->gd_v__dimension.
    ld_v__infoprovide = ld_s__log-table->gr_o__model->gr_o__application->gd_v__infoprovide.

    call method ld_s__log-table->get_log
      importing
        e_t__read        = ld_t__log_read
        e_t__write       = ld_t__log_write
        e_t__read_dim    = ld_t__log_read_dim
        e_t__actual_rows = ld_t__actual_rows.

    check ld_t__log_read is not initial or ld_t__log_write is not initial or ld_t__actual_rows is not initial.

    print> `*-----------------------------------------------------------------------*` .

    case ld_s__log-command.

      when zblnc_keyword-select.
        if  ld_v__appset_id is not initial.
          if ld_v__appl_id is not initial.
            concatenate `TABLE ` ld_s__log-tablename ` FOR ` ld_v__appset_id `~` ld_v__appl_id   into ld_v__message.
          elseif ld_v__dimension is not initial.
            concatenate `TABLE ` ld_s__log-tablename ` FOR ` ld_v__appset_id `~` ld_v__dimension into ld_v__message.
          else.
            concatenate `TABLE ` ld_s__log-tablename ` FOR ` ld_v__appset_id into ld_v__message.
          endif.
        elseif ld_v__infoprovide is not initial.
          concatenate `TABLE ` ld_s__log-tablename ` FOR ` sy-sysid `~` ld_v__infoprovide into ld_v__message.
        endif.
      when zblnc_keyword-tablefordown or zblnc_keyword-ctable.
        concatenate `TABLE ` ld_s__log-tablename ` FOR ` ld_v__appset_id `~` ld_v__appl_id into ld_v__message.
      when zblnc_keyword-clear.
        concatenate `CLEAR ` ld_v__appset_id `~` ld_v__appl_id into ld_v__message.
    endcase.

    print> ld_v__message.

    if ld_t__log_read_dim is not initial.
      print> `---` .
      print> `READ DIMENSIONS:`.
      loop at ld_t__log_read_dim assigning <ld_s__log_read_dim>.
        loop at <ld_s__log_read_dim>-log assigning <ld_s__log_read>.

          concatenate <ld_s__log_read_dim>-dimension `                     ` into ld_v__str.

          ld_v__str = ld_v__str(14).

          " Количество записей
          ld_v__nr_rows = get_nr_rows( i_s__read = <ld_s__log_read> ).

          " Время
          ld_v__time = get_time( i_v__start      = <ld_s__log_read>-time_start
                                 i_v__end        = <ld_s__log_read>-time_end ).

          concatenate ld_v__str ld_v__nr_rows ld_v__time into ld_v__message separated by cs_space.
          print> ld_v__message.

        endloop.
      endloop.
      print> `---`.
    endif.

    loop at ld_t__log_read assigning <ld_s__log_read>.
      if sy-tabix = 1.
        ld_v__str = cs_read.
      else.
        ld_v__str = cs_tab.
      endif.

      " WARNING
      case ld_s__log-command.
        when zblnc_keyword-select.
          if ld_f__wemessage = abap_false.
            if <ld_s__log_read>-num_rec is initial and lines( ld_t__log_read ) = 1 .
              e_f__warning = abap_true.

              concatenate `The table ` `"` ld_s__log-tablename `"` ` does not contain any data.` into ld_v__message.
              call method cl_ujd_utility=>write_long_message
                exporting
                  i_message  = ld_v__message
                changing
                  ct_message = gt_message.

              ld_f__wemessage = abap_true.
            endif.
          endif.
      endcase.

      " Номер пакета
      ld_v__nr_pack = get_nr_pack( <ld_s__log_read>-nr_pack ).

      " Количество записей
      ld_v__nr_rows = get_nr_rows( i_s__read = <ld_s__log_read> ).

      " Время
      ld_v__time = get_time( i_v__start      = <ld_s__log_read>-time_start
                             i_v__end        = <ld_s__log_read>-time_end ).

      concatenate ld_v__str ld_v__nr_pack  ld_v__nr_rows ld_v__time <ld_s__log_read>-rfc_task into ld_v__message separated by cs_space.
      print> ld_v__message.
    endloop.

    loop at ld_t__log_write assigning <ld_s__log_write>.
      if sy-tabix = 1.
        ld_v__str = cs_write.
      else.
        ld_v__str = cs_tab.
      endif.

      " WARNING
      case ld_s__log-command.
        when zblnc_keyword-tablefordown.
          if ld_f__wcmessage = abap_false.
            if <ld_s__log_write>-status_records-nr_fail is not initial.
              e_f__warning = abap_true.

              concatenate `In the process of writing data from table ` `"` ld_s__log-tablename `",` ` error records entries.` into ld_v__message.
              call method cl_ujd_utility=>write_long_message
                exporting
                  i_message  = ld_v__message
                changing
                  ct_message = gt_message.

              ld_f__wcmessage = abap_true.

            endif.
          endif.
      endcase.

      " Номер пакета
      ld_v__nr_pack = get_nr_pack( <ld_s__log_write>-nr_pack ).

      " Количество записей
      ld_v__nr_rows = get_nr_rows( i_s__write = <ld_s__log_write> i_v__size = 7 ).

      " Время
      ld_v__time = get_time( i_v__start      = <ld_s__log_write>-time_start
                             i_v__end        = <ld_s__log_write>-time_end ).

      concatenate ld_v__str ld_v__nr_pack ld_v__nr_rows ld_v__time <ld_s__log_write>-rfc_task  into ld_v__message separated by cs_space.

      print> ld_v__message.

      if <ld_s__log_write>-status_records-nr_fail is not initial.
        ld_v__str = get_space_text( 6 ).
        loop at <ld_s__log_write>-message assigning <ld_s__message>.
          concatenate cs_tab ld_v__str <ld_s__message>-message into ld_v__message separated by cs_space.
          print> ld_v__message.
        endloop.
      endif.

    endloop.

    loop at ld_t__actual_rows assigning <ld_s__actual_rows>
      where nr_pack = ld_s__log-n_actual.

      ld_v__str = cs_tab.
      ld_v__nr_pack = get_nr_pack( <ld_s__actual_rows>-nr_pack ).

      " Количество записей
      ld_s__log_read-num_rec = ld_s__log_read-sup_rec  = <ld_s__actual_rows>-num_rec.
      ld_v__nr_rows = get_nr_rows( i_s__read = ld_s__log_read ).

      concatenate ld_v__str ld_v__nr_pack ld_v__nr_rows into ld_v__message separated by cs_space.
      print> ld_v__message.
    endloop.
  endloop.

  print> `=========================================================================`.

  cl_ujk_logger=>save_log( i_v__path ).

endmethod.
