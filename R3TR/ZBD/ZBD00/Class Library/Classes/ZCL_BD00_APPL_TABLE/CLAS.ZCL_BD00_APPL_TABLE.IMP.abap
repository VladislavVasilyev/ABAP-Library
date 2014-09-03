*----------------------------------------------------------------------*
*       CLASS lcl_read_data IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
class lcl_process_data implementation.
*--------------------------------------------------------------------*
* CONSTRUCTOR
*--------------------------------------------------------------------*
  method constructor.
    data
    : ld_s__alias_rfc type zbd00_s_alias_rfc
    .

    field-symbols
    : <ld_s__alias>  type zbd00_s_alias
    .

    go_appl_table    ?= io_appl_table.
    go_appl          ?= go_appl_table->gr_o__model->gr_o__application.
    gr_table          = io_appl_table->gr_t__table.
    gf_suppress_zero  = if_suppress_zero.
    gv_table_kind     = go_appl_table->gr_o__model->gd_s__handle-tab-tech_name->table_kind.
    gt_range          = it_range.
    gd_f__invert      = if_invert.

    loop at go_appl_table->gr_o__model->gd_t__bpc_alias
         assigning <ld_s__alias>.

      ld_s__alias_rfc-dimension = <ld_s__alias>-bpc_name-dimension.
      ld_s__alias_rfc-attribute = <ld_s__alias>-bpc_name-attribute.

      ld_s__alias_rfc-alias_dimension = <ld_s__alias>-bpc_alias-dimension.
      ld_s__alias_rfc-alias_attribute = <ld_s__alias>-bpc_alias-attribute.

      append ld_s__alias_rfc to gt_alias.

    endloop.

    get_range( it_range ).

    if iv_packagesize <= 0.
      gv_packagesize = go_appl_table->gr_o__model->gr_o__application->gd_v__package_size.
      if gv_packagesize <= 0.
        gv_packagesize = 50000.
      endif.
    else.
      gv_packagesize = iv_packagesize.
    endif.

    create object go_log.

  endmethod.                    "constructor
*--------------------------------------------------------------------*
* READ_DATA
*--------------------------------------------------------------------*
  method read_data.

    data
    : l_th_sfc                    type rsdri_th_sfc
    , l_th_sfk                    type rsdri_th_sfk
    , l_packagesize               type i
    , l_aggregate                 type rsinfocube
    , l_split_occurred            type rsdr0_split_occurred
    , l_stepuid                   type sysuuid_25
    , lr_s_data                   type ref to data
    , lr_t_data                   type ref to data
    , lr_hashed_data              type ref to data
    , lr_sorted_data              type ref to data
    , lt_dim                      type table of string
    , lv_signeddata               type string
    , lt_signeddata               type zbd0t_ty_t_kf
    , ld_v__lines                 type i
    , ld_v__perc                  type i
    , ld_v__index                 type i
    , ld_f__mode_zero             type rs_bool " true - подавление нулей по нескольким показателям
    , ld_f__skip_delete_zero      type rs_bool
    , ld_s__log_read              type zbd0t_s__log_read
    , ld_f__second_read           type rs_bool
    .

    field-symbols
    : <ls_data>                   type any
    , <ls_coll>                   type any
    , <lt_data>                   type standard table
    , <lt_data_hashed>            type hashed table
    , <lt_data_index>             type index table
    , <lt_data_sorted>            type sorted table
    , <l_signeddata>              type any
    , <ld_s__component>           type abap_compdescr
    , <ld_t__table>               type any table
    .

    if gf_end_of_data = abap_true.
      e_st = zbd0c_end_of_data.
      return.
    endif.

    if read_mode-pack = mode.
      l_packagesize = gv_packagesize.
      add 1 to gv_nr_pack_read.
      ld_s__log_read-nr_pack = gv_nr_pack_read.
    else.
      l_packagesize = ld_s__log_read-nr_pack =  -1.
    endif.

    " write log
    get time stamp field ld_s__log_read-time_start.

    insert lines of
    : go_appl_table->gr_o__model->gd_t__sfc into table l_th_sfc
    , go_appl_table->gr_o__model->gd_t__sfk into table l_th_sfk .

    if lines( go_appl_table->gr_o__model->gd_t__signeddata ) > 1.
      lt_signeddata = go_appl_table->gr_o__model->gd_t__signeddata.
      ld_f__mode_zero = abap_true.
    endif.

    lv_signeddata = go_appl_table->gr_o__model->gd_v__signeddata.

* create standard table
    create data lr_s_data type handle go_appl_table->gr_o__model->gd_s__handle-st-tech_name.
    assign lr_s_data->* to <ls_data>.
    create data lr_t_data like standard table of <ls_data>.
    assign lr_t_data->* to <lt_data>.
*--------------------------------------------------------------------*

* Создание промежуточных таблиц
    case gv_table_kind.
      when cl_abap_tabledescr=>tablekind_std or
           cl_abap_tabledescr=>tablekind_hashed.
        create data lr_hashed_data like hashed table of <ls_data> with unique default key.
      when cl_abap_tabledescr=>tablekind_sorted.
        if go_appl_table->gr_o__model->gd_f__complete_key = abap_false.
          clear lt_dim.
          append lines of go_appl_table->gr_o__model->gd_s__handle-tab-tech_name->key to lt_dim.
          loop at go_appl_table->gr_o__model->gd_s__handle-st-tech_name->components
            assigning <ld_s__component>
            where type_kind = `C`.

            read table lt_dim
                 with table key table_line = <ld_s__component>-name
                 transporting no fields.
            check sy-subrc <> 0.
            append <ld_s__component>-name to lt_dim.
          endloop.
        else.
          append lines of go_appl_table->gr_o__model->gd_s__handle-tab-tech_name->key to lt_dim.
        endif.
        create data lr_sorted_data like sorted table of <ls_data> with unique key (lt_dim).
    endcase.

    assign gr_table->* to <ld_t__table>.

    refresh
    : <lt_data>
    , <ld_t__table>.

    while gf_end_of_data <> abap_true and lines( <lt_data> ) = 0.

      call function 'RSDRI_INFOPROV_READ'
        exporting
          i_infoprov             = go_appl->gd_v__infoprovide
          i_th_sfc               = l_th_sfc
          i_th_sfk               = l_th_sfk
          i_t_range              = gt_range_tech_name
*        i_th_tablesel          =
*        i_t_rtime              =
          i_reference_date       = sy-datum
          i_rollup_only          = rs_c_false
*        i_t_requid             =
*        i_save_in_table        = ' '
*        i_tablename            =
*        i_save_in_file         = ' '
*        i_filename             =
          i_packagesize          = l_packagesize
*        i_maxrows              = 0
*        i_authority_check      = rsdrc_c_authchk-read
*        i_currency_conversion  = 'X'
*        i_use_db_aggregation   = rs_c_true
*        i_use_aggregates       = rs_c_true
*        i_read_ods_delta       = rs_c_false
*        i_caller               = rsdrs_c_caller-rsdri
*        i_debug                = rs_c_false
*         i_clear                = rs_c_true"rs_c_false
        importing
          e_t_data               = <lt_data>
          e_end_of_data          = gf_end_of_data
          e_aggregate            = l_aggregate
          e_split_occurred       = l_split_occurred
          e_t_msg                = gt_message
          e_stepuid              = l_stepuid
        changing
          c_first_call           = gf_first_call
        exceptions
          illegal_input          = 1
          illegal_input_sfc      = 2
          illegal_input_sfk      = 3
          illegal_input_range    = 4
          illegal_input_tablesel = 5
          no_authorization       = 6
          illegal_download       = 7
          illegal_tablename      = 8
          trans_no_write_mode    = 9
          inherited_error        = 10
          x_message              = 11
          others                 = 12.

      if sy-subrc <> 0.
*         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ld_s__log_read-status = sy-subrc.
        return.
      endif.

      ld_v__lines = lines( <lt_data> ).

      check ld_v__lines > 0.

      if ld_f__second_read = abap_true.
        add ld_v__lines to ld_s__log_read-num_rec.
      else.
        ld_s__log_read-num_rec = ld_v__lines.
      endif.

      e_st = zbd0c_read_pack.

*--------------------------------------------------------------------*
* АГРЕГАЦИЯ И ПОДАВЛЕНИЕ НУЛЕЙ
*--------------------------------------------------------------------*
      case gv_table_kind.
        when cl_abap_tabledescr=>tablekind_std.
          assign lr_hashed_data->* to <lt_data_hashed>.
        when cl_abap_tabledescr=>tablekind_sorted.
          assign lr_sorted_data->* to <lt_data_sorted>.
        when cl_abap_tabledescr=>tablekind_hashed.
          assign gr_table->* to <lt_data_hashed>.
      endcase.

      loop at <lt_data>
           assigning <ls_data>.

        " Инвентирование
        if gd_f__invert = abap_true and ld_f__mode_zero = abap_false.
          assign component lv_signeddata of structure <ls_data> to <l_signeddata>.
          multiply <l_signeddata> by -1.
        endif.

        if gf_suppress_zero = abap_true.
          if ld_f__mode_zero = abap_false.
            assign component lv_signeddata of structure <ls_data> to <l_signeddata>.
            if <l_signeddata> = 0.
              delete <lt_data>.
              continue.
            endif.
          else.
            clear ld_f__skip_delete_zero.
            loop at lt_signeddata into lv_signeddata.
              assign component lv_signeddata of structure <ls_data> to <l_signeddata>.
              if <l_signeddata> <> 0.
                ld_f__skip_delete_zero = abap_true.
                exit.
              endif.
            endloop.
            if ld_f__skip_delete_zero = abap_false.
              delete <lt_data>.
              continue.
            endif.
          endif.
        endif.

        case gv_table_kind.
          when cl_abap_tabledescr=>tablekind_std or
               cl_abap_tabledescr=>tablekind_hashed.
            collect <ls_data> into <lt_data_hashed> assigning <ls_coll>.
          when cl_abap_tabledescr=>tablekind_sorted.
            collect <ls_data> into <lt_data_sorted> assigning <ls_coll>.
            ld_v__index = sy-tabix.
        endcase.

        delete <lt_data>.
        if gf_suppress_zero = abap_true.
          if ld_f__mode_zero = abap_false.
            assign component lv_signeddata of structure <ls_coll> to <l_signeddata>.
            if <l_signeddata> = 0.
              case gv_table_kind.
                when cl_abap_tabledescr=>tablekind_std or
                     cl_abap_tabledescr=>tablekind_hashed.
                  delete table <lt_data_hashed> from <ls_coll>.
                when cl_abap_tabledescr=>tablekind_sorted.
                  delete <lt_data_sorted> index ld_v__index.
              endcase.
            endif.
          else.
            clear ld_f__skip_delete_zero.
            loop at lt_signeddata into lv_signeddata.
              assign component lv_signeddata of structure <ls_coll> to <l_signeddata>.
              if <l_signeddata> <> 0.
                ld_f__skip_delete_zero = abap_true.
                exit.
              endif.
            endloop.
            if ld_f__skip_delete_zero = abap_false.
              case gv_table_kind.
                when cl_abap_tabledescr=>tablekind_std or
                     cl_abap_tabledescr=>tablekind_hashed.
                  delete table <lt_data_hashed> from <ls_coll>.
                when cl_abap_tabledescr=>tablekind_sorted.
                  delete <lt_data_sorted> index ld_v__index.
              endcase.
            endif.
          endif.
        endif.
      endloop.

      case gv_table_kind.
        when cl_abap_tabledescr=>tablekind_std or
             cl_abap_tabledescr=>tablekind_hashed.
          ld_v__lines = lines( <lt_data_hashed> ).
        when cl_abap_tabledescr=>tablekind_sorted.
          ld_v__lines = lines( <lt_data_sorted> ).
      endcase.

      ld_s__log_read-sup_rec = ld_v__lines.

*--------------------------------------------------------------------*
      if l_packagesize <> -1.
        ld_v__perc = ( ld_v__lines * 100 ) / l_packagesize.

        if ld_v__perc < 30 and gf_end_of_data <> abap_true.
          ld_f__second_read = abap_true.
          continue.
        else.
          ld_f__second_read = abap_false.
        endif.
      endif.

* Выход из цикла
      check gf_end_of_data = abap_true or ld_v__lines > 0.
      exit.
    endwhile.

*--------------------------------------------------------------------*
* ВСТАВКА
    case gv_table_kind.
      when cl_abap_tabledescr=>tablekind_std.
        assign gr_table->*               to <lt_data_index>.
        check <lt_data_hashed> is assigned.
        append lines of <lt_data_hashed> to <lt_data_index>.
        clear <lt_data_hashed>.

      when cl_abap_tabledescr=>tablekind_sorted.
        assign gr_table->* to <lt_data_index>.
        check <lt_data_sorted> is assigned.
        append lines of <lt_data_sorted> to <lt_data_index>.
        clear <lt_data_sorted>.

      when cl_abap_tabledescr=>tablekind_hashed.
    endcase.

    " write log
    get time stamp field ld_s__log_read-time_end.

    go_log->set_read( ld_s__log_read ).

  endmethod.                    "read_data
*--------------------------------------------------------------------*
* READ_DATA_SRFC
*--------------------------------------------------------------------*
  method read_data_srfc.
    type-pools: rsdrc.

    data
    : g_t_rfcdata       type rsdri_t_rfcdata
    , g_t_field         type rsdp0_t_field
    , l_aggregate       type rsinfocube
    , l_rfcdata_uc      type xstring
    , l_split_occurred  type rsdr0_split_occurred
    , l_stepuid         type sysuuid_25
    .

    field-symbols
    : <lt_data>         type any table
    .

    assign gr_table->* to <lt_data>.

    call function 'ZBD00_RFC_INFOPROV_READ'
      destination `BACK`
      exporting
        i_infoprov             = go_appl->gd_v__infoprovide
        i_reference_date       = sy-datum
        i_save_in_table        = rs_c_false
        i_save_in_file         = rs_c_false
        i_authority_check      = rsdrc_c_authchk-read
      importing
        e_end_of_data          = e_eod
        e_aggregate            = l_aggregate
        e_rfcdata_uc           = l_rfcdata_uc
        e_split_occurred       = l_split_occurred
        e_stepuid              = l_stepuid
      tables
        i_t_sfc                = go_appl_table->gr_o__model->gd_t__sfc
        i_t_sfk                = go_appl_table->gr_o__model->gd_t__sfk
        i_t_range              = gt_range_tech_name
        e_t_rfcdata            = g_t_rfcdata
        e_t_field              = g_t_field
      exceptions
        illegal_input          = 1
        illegal_input_sfc      = 2
        illegal_input_sfk      = 3
        illegal_input_range    = 4
        illegal_input_tablesel = 5
        no_authorization       = 6
        generation_error       = 8
        illegal_download       = 9
        illegal_tablename      = 10
        data_overflow          = 12
        communication_failure  = 13
        system_failure         = 14
        resource_failure       = 15
        others                 = 17.

  endmethod.                    "srfc_read_data
*--------------------------------------------------------------------*
* READ_DATA_ARFC
*--------------------------------------------------------------------*
  method read_data_arfc.
    type-pools
    : rsdrc
    .

    data
    : task type zbd0t_ty_name_rfc_task
    .

    task = zcl_bd00_rfc_task=>get_task_run( i_appset_id = go_appl->gd_v__appset_id
                                            i_appl_id   = go_appl->gd_v__appl_id
                                            mode        = zcl_bd00_rfc_task=>cs-rfc_read ).

    call function 'ZBD00_RFC_BPC_READ'
      starting new task task
      destination in group 'parallel_generators'
      calling read_data_arfc_receive on end of task
      exporting
        i_appset_id           = go_appl->gd_v__appset_id
        i_appl_id             = go_appl->gd_v__appl_id
        i_reference_date      = sy-datum
        i_save_in_table       = rs_c_false
        i_save_in_file        = rs_c_false
        i_authority_check     = rsdrc_c_authchk-read
        i_rollup_only         = rs_c_false
        i_suppress_zero       = gf_suppress_zero
        i_type_table          = go_appl_table->gr_o__model->gd_v__type_pk
      tables
        i_t_dim_list          = go_appl_table->gr_o__model->gd_t__dim_list
        i_t_range             = gt_range_tech_name
        i_t_alias             = gt_alias
      exceptions
        communication_failure = 1
        system_failure        = 2
        resource_failure      = 3.

    if sy-subrc <> 0.
      raise exception type zcx_bd00_read_data.
    endif.

    gf_arfc_read = abap_true.

    set handler me->recieve_arfc for go_appl_table  activation 'X'.

  endmethod.                    "read_data_arfc
*--------------------------------------------------------------------*
* READ_DATA_ARFC_RECEIVE
*--------------------------------------------------------------------*
  method read_data_arfc_receive.
    data
    : g_t_rfcdata           type rsdri_t_rfcdata
    , g_t_field             type rsdp0_t_field
    , l_aggregate           type rsinfocube
    , l_rfcdata_uc          type xstring
    , l_split_occurred      type rsdr0_split_occurred
    , l_stepuid             type sysuuid_25
    , ld_s__log_read        type zbd0t_s__log_read
    .

    field-symbols
    : <lt_data>             type any table
    .

    ld_s__log_read-nr_pack = -1.

    assign gr_table->* to <lt_data>.

    receive results from function 'ZBD00_RFC_BPC_READ'
      importing
*        e_end_of_data          = e_eod
        e_aggregate            = l_aggregate
        e_rfcdata_uc           = l_rfcdata_uc
        e_split_occurred       = l_split_occurred
        e_stepuid              = l_stepuid
        e_time_start           = ld_s__log_read-time_start
        e_time_end             = ld_s__log_read-time_end
        e_num_rec              = ld_s__log_read-num_rec
        e_sup_rec              = ld_s__log_read-sup_rec
      tables
        e_t_rfcdata            = g_t_rfcdata
        e_t_field              = g_t_field

      exceptions
        illegal_input          = 1
        illegal_input_sfc      = 2
        illegal_input_sfk      = 3
        illegal_input_range    = 4
        illegal_input_tablesel = 5
        no_authorization       = 6
        generation_error       = 8
        illegal_download       = 9
        illegal_tablename      = 10
        data_overflow          = 12
        others                 = 13.

    if sy-subrc <> 0.
      ld_s__log_read-status = sy-subrc.
    endif.

    call function 'ZBD00_DATA_UNWRAP'
      exporting
        i_t_rfcdata = g_t_rfcdata
      changing
        c_t_data    = <lt_data>.

    gf_arfc_read = abap_false.

    data task type zcl_bd00_rfc_task=>ty_name_rfc_task.
    task = ld_s__log_read-rfc_task = p_task.

    zcl_bd00_rfc_task=>set_task_free( task ).

    go_log->set_read( ld_s__log_read ).

  endmethod.                    "rfc_receive_read
*--------------------------------------------------------------------*
* GET_RANGE
*--------------------------------------------------------------------*
  method get_range.
    data
        : ls_range like line of gt_range_tech_name
        .

    field-symbols
        : <ls_range> like line of it_range
        , <ls_dimension> type zbd00_s_dimn
        .

    loop at it_range
         assigning <ls_range>.

      read table go_appl_table->gr_o__model->gr_o__application->gd_t__dimensions
           with table key dimension = <ls_range>-dimension
                          attribute = <ls_range>-attribute
           assigning <ls_dimension>.

      ls_range-chanm  = <ls_dimension>-tech_name.
      ls_range-sign   = <ls_range>-sign.
      ls_range-compop = <ls_range>-option.
      ls_range-low    = <ls_range>-low.
      ls_range-high   = <ls_range>-high.

      insert ls_range into table gt_range_tech_name.

    endloop.
  endmethod.                    "get_range
*--------------------------------------------------------------------*
* WRITE_DATA_ARFC_RECEIVE
*--------------------------------------------------------------------*
  method write_data_arfc_receive.
    data
    : task                type zcl_bd00_rfc_task=>ty_name_rfc_task
    , et_message          type uj0_t_message
    , es_status_records   type ujr_s_status_records
    , ld_s__log_write     type zbd0t_s__log_write
    .

    task = ld_s__log_write-rfc_task = p_task.

    read table go_log->gd_t__open_write
         with key rfc_task = task
         into ld_s__log_write.

    delete go_log->gd_t__open_write where rfc_task = task.

    receive results from function 'ZBD00_RFC_BPC_WRITE'
      importing
        et_message             = ld_s__log_write-message
        es_status_records      = ld_s__log_write-status_records
        e_time_end             = ld_s__log_write-time_end
       exceptions
         error_write_back    = 1
         error_static_check  = 2
         x_message = 3.


    go_log->set_write( ld_s__log_write ).

    zcl_bd00_rfc_task=>set_task_free( task ).
  endmethod.                    "write_data_arfc_receive
*--------------------------------------------------------------------*
* GENERATE_DATA
*--------------------------------------------------------------------*
  method  generate_data.

    data
    : ld_t__dimlist     type table of uj_dim_name
    , ld_t__attr_list	  type uja_t_attr_name
    , ld_t__dim_list    type zbd00_t_ch_key
    , lt_rules_field    type zbd0t_ty_t_rule_field
    , ls_rules_field    type zbd0t_ty_s_rule_field
    , ld_t__sel	        type uj0_t_sel
    , ld_t__sel_mbr	    type uja_t_dim_member
    , lr_t__std_data    type ref to data
    , lr_o__mbr_data    type ref to cl_uja_dim
    , ld_t__hier_list	  type uja_t_hier_name
    , ld_s__range       type uj0_s_sel
    , ld_s__table       type ty_custom_appl
    , ld_s__log_read    type zbd0t_s__log_read
    , l_packagesize     type i
    , l_dim_log         type zbd0t_s__log_dimension
    .

    field-symbols
    : <ld_t__dimension> type zbd00_st_ch_key
    , <ld_s__dimension> type zbd00_s_ch_key
    , <ld_s__dimlist>   type uj_dim_name
    , <ld_s__bpcalias>  type zbd00_s_alias
    , <ld_t__table>     type any table
    .

    if gf_end_of_data = abap_true.
      e_st = zbd0c_end_of_data.
      return.
    endif.

    " write log
    get time stamp field ld_s__log_read-time_start.

    if read_mode-pack = mode.
      l_packagesize = gv_packagesize.
      add 1 to gv_nr_pack_read.
      ld_s__log_read-nr_pack = gv_nr_pack_read.
    else.
      l_packagesize = ld_s__log_read-nr_pack =  -1.
    endif.

    if gd_t__cust_appl is initial.

      assign go_appl_table->gr_o__model->gd_t__dim_list to <ld_t__dimension>.

      loop at           <ld_t__dimension> " dimension
           assigning    <ld_s__dimension>.
        append <ld_s__dimension>-dimension to ld_t__dimlist.
      endloop.

      sort by ld_t__dimlist ascending.
      delete adjacent duplicates from ld_t__dimlist.

      loop at           ld_t__dimlist        " dimension
            assigning    <ld_s__dimlist>.

        loop at           <ld_t__dimension> " dimension
             assigning    <ld_s__dimension>
             where        dimension = <ld_s__dimlist>.

          insert <ld_s__dimension> into table ld_t__dim_list.

          if <ld_s__dimension>-attribute is not initial.
            append <ld_s__dimension>-attribute to ld_t__attr_list.
          endif.
        endloop.

        loop at        gt_range
             into      ld_s__range
             where     dimension = <ld_s__dimlist>.
          append ld_s__range to ld_t__sel.
        endloop.


        ld_s__table-object ?= zcl_bd00_appl_table=>get_dimension(
                                i_appset_id   = go_appl->gd_v__appset_id
                                i_dimension   = <ld_s__dimlist>
                                it_attr_list  = ld_t__attr_list
                                it_range      = ld_t__sel
                                it_alias      = go_appl_table->gr_o__model->gd_t__bpc_alias ).

        ld_s__table-object->next_pack( zbd0c_read_mode-gendim ).

        l_dim_log-dimension = <ld_s__dimlist>.

        call method ld_s__table-object->get_log
          importing
            e_t__read = l_dim_log-log.

        append l_dim_log to go_log->gd_t__read_dim.

        loop at <ld_t__dimension> " dimension
             assigning <ld_s__dimension>
                 where dimension         = <ld_s__dimlist>.

          read table go_appl_table->gr_o__model->gd_t__bpc_alias
               with key bpc_name-dimension = <ld_s__dimension>-dimension
                        bpc_name-attribute = <ld_s__dimension>-attribute
                        assigning <ld_s__bpcalias>.

          if sy-subrc = 0.
            ls_rules_field-tg-dimension  = <ld_s__bpcalias>-bpc_alias-dimension.
            ls_rules_field-tg-attribute  = <ld_s__bpcalias>-bpc_alias-attribute.
            ls_rules_field-sc-dimension  = <ld_s__bpcalias>-bpc_alias-dimension.
            ls_rules_field-sc-attribute  = <ld_s__bpcalias>-bpc_alias-attribute.
          else.
            ls_rules_field-tg-dimension  = <ld_s__dimension>-dimension.
            ls_rules_field-tg-attribute  = <ld_s__dimension>-attribute.
            ls_rules_field-sc-dimension  = <ld_s__dimension>-dimension.
            ls_rules_field-sc-attribute  = <ld_s__dimension>-attribute.
          endif.

          ls_rules_field-sc-object    ?= ld_s__table-object.

          insert ls_rules_field into table lt_rules_field.

        endloop.

        insert ld_s__table into table gd_t__cust_appl.

        clear
        : ld_t__sel
        , ld_t__attr_list
        , ld_t__sel_mbr
        , ld_t__dim_list.

      endloop.

      gd_v__rule_assign = go_appl_table->set_rule_assign( it_field = lt_rules_field i_mode_add = zbd0c_mode_add_line-collect ).

    endif.

    assign gr_table->* to <ld_t__table>.
    refresh <ld_t__table>.

    call method generate
      exporting
        next_pack   = gd_f__gen_init
        packagesize = l_packagesize
      importing
        eod         = gf_end_of_data.

    if <ld_t__table> is initial.
      e_st = zbd0c_not_found.
    else.
      e_st = zbd0c_read_pack.
    endif.

    " write log
    ld_s__log_read-num_rec = ld_s__log_read-sup_rec = lines( <ld_t__table> ).
    get time stamp field ld_s__log_read-time_end.
    go_log->set_read( ld_s__log_read ).
    gd_f__gen_init = abap_true.

  endmethod.                    "generate_data
*--------------------------------------------------------------------*
* LOOP
*--------------------------------------------------------------------*
  method loop.

    data
    : ld_v__index             type i
    , ld_v__init_next_pack    type rs_bool
    .

    field-symbols
    : <ld_s__table>     type ty_custom_appl
    , <ld_t__table>     type any table.
    .

    ld_v__index = 1 + index.

    if next_pack = abap_true.
      ld_v__init_next_pack = abap_true.
    else.
      ld_v__init_next_pack = abap_false.
    endif.

    if ld_v__index > lines( gd_t__cust_appl ).
      go_appl_table->rule_assign( gd_v__rule_assign ).
      e_pack = abap_false.
      assign gr_table->* to <ld_t__table>.
      check lines( <ld_t__table> ) = packagesize.
      e_pack = abap_true.
    else.

      if lines( gd_t__cust_appl ) = ld_v__index.
        ld_v__init_next_pack = abap_false.
      endif.

      read table gd_t__cust_appl
           index ld_v__index
           assigning <ld_s__table>.

      while next_line( f_read = ld_v__init_next_pack object = <ld_s__table>-object ) eq zbd0c_found.
        e_pack = abap_false.
        if loop( index = ld_v__index packagesize = packagesize next_pack = ld_v__init_next_pack ) = abap_true.
          e_pack = abap_true.
          exit.
        endif.
        ld_v__init_next_pack = abap_false.
      endwhile.

      if e_pack = abap_false.
        <ld_s__table>-object->reset_index( ).
      endif.
    endif.

  endmethod.                    "loop
*--------------------------------------------------------------------*
* GENERATE
*--------------------------------------------------------------------*
  method generate.

    data
    : ld_v__init_next_pack type rs_bool
    .

    field-symbols
    : <ld_s__table>     type ty_custom_appl
    .

    if next_pack = abap_true.
      ld_v__init_next_pack = abap_true.
    else.
      ld_v__init_next_pack = abap_false.
    endif.

    read table      gd_t__cust_appl
         index      1
         assigning <ld_s__table>.

    while next_line( f_read = ld_v__init_next_pack object = <ld_s__table>-object ) eq zbd0c_found.

      if loop( index = 1 packagesize = packagesize next_pack = ld_v__init_next_pack ) = abap_true.
        return.
      endif.
      ld_v__init_next_pack = abap_false.
    endwhile.

    <ld_s__table>-object->reset_index( ).

    eod = abap_true.

  endmethod.                    "generate
*--------------------------------------------------------------------*
* NEXT_LINE
*--------------------------------------------------------------------*
  method next_line.

    if f_read = abap_false.
      e_st = object->next_line( ).
    else.
      e_st = zbd0c_found.
    endif.

  endmethod.                    "next_line
*--------------------------------------------------------------------*
* GENERATE_DIMENSION
*--------------------------------------------------------------------*
  method generate_dimension.

    data
    : ld_t__dimlist         type table of uj_dim_name
    , ld_t__attr_list	      type uja_t_attr_name
    , ld_t__sel	            type uj0_t_sel
    , lr_t__std_data        type ref to data
    , lr_o__mbr_data        type ref to cl_uja_dim
    , ld_t__hier_list	      type uja_t_hier_name
    , ld_s__range           type uj0_s_sel
    , lr_o__line            type ref to data
    , lr_t__hashtable       type ref to data
    , ld_v__comp            type string
    , ld_s__log_read        type zbd0t_s__log_read
    .

    field-symbols
    : <ld_t__dimension>     type zbd00_st_ch_key
    , <ld_s__dimension>     type zbd00_s_ch_key
    , <ld_t__model_dim>     type zcl_bd00_model=>ty_t_dim_list
    , <ld_s__model_dim>     type zcl_bd00_model=>ty_s_dim_list
    , <ld_t__dim>           type index table
    , <ld_s__dim>           type any
    , <ld_t__table>         type any table
    , <ld_t__hashtable>     type hashed table
    , <ld_s__line>          type any
    , <ld_v__source>        type any
    , <ld_v__target>        type any
    , <ld_s__bpcalias>      type zbd00_s_alias
    .

    if gf_end_of_data = abap_true.
      e_st = zbd0c_end_of_data.
      return.
    endif.

    get time stamp field ld_s__log_read-time_start.

    assign go_appl_table->gr_o__model->gd_t__dim_list     to <ld_t__dimension>.
    assign go_appl_table->gr_o__model->gr_t__dimension->* to <ld_t__model_dim>.

    assign gr_table->* to <ld_t__table>.

    create data lr_o__line like line of <ld_t__table>.
    assign lr_o__line->*   to <ld_s__line>.

    create data lr_t__hashtable like hashed table of <ld_s__line> with unique default key.

    assign lr_t__hashtable->* to <ld_t__hashtable>.


    loop at          <ld_t__dimension> " dimension
        assigning    <ld_s__dimension>.

      if <ld_s__dimension>-attribute is not initial.
        append <ld_s__dimension>-attribute to ld_t__attr_list.
      endif.

    endloop.

    loop at        gt_range
         into      ld_s__range.

      if ld_s__range-attribute is initial.
        ld_s__range-attribute = uja00_cs_attr-id.
      endif.

      append ld_s__range to ld_t__sel.
    endloop.

    if ld_t__attr_list is initial.
      append  uja00_cs_attr-calc to ld_t__attr_list.
    endif.

    create object lr_o__mbr_data
      exporting
        i_appset_id = go_appl->gd_v__appset_id
        i_dimension = go_appl->gd_v__dimension.


    call method lr_o__mbr_data->read_mbr_data
      exporting
        it_attr_list       = ld_t__attr_list
        it_sel             = ld_t__sel
*          it_sel_mbr         = ld_t__sel_mbr
        it_hier_list       = ld_t__hier_list
*          if_tech_name       = abap_true
        if_only_base       = abap_true
        if_sort            = abap_true
        if_inc_non_display = abap_false
        if_inc_generate    = abap_false
        if_skip_cache      = abap_true
      importing
        er_data            = lr_t__std_data.

    assign lr_t__std_data->* to <ld_t__dim>.
    ld_s__log_read-num_rec = lines( <ld_t__dim> ).

    loop at <ld_t__dim> assigning <ld_s__dim>.
      loop at    <ld_t__model_dim> assigning <ld_s__model_dim>
           where type = zcl_bd00_application=>cs_dm or type = zcl_bd00_application=>cs_an.

        read table go_appl_table->gr_o__model->gd_t__bpc_alias
             with key bpc_alias-dimension = <ld_s__model_dim>-dimension
                      bpc_alias-attribute = <ld_s__model_dim>-attribute
              assigning <ld_s__bpcalias>.

        if sy-subrc = 0.
          if <ld_s__bpcalias>-bpc_name-attribute is initial.
            ld_v__comp = uja00_cs_attr-id.
          else.
            ld_v__comp = <ld_s__bpcalias>-bpc_name-attribute.
          endif.
        else.
          case <ld_s__model_dim>-type.
            when zcl_bd00_application=>cs_dm.
              ld_v__comp = uja00_cs_attr-id.
            when zcl_bd00_application=>cs_an.
              ld_v__comp = <ld_s__model_dim>-attribute.
          endcase.
        endif.

        assign component <ld_s__model_dim>-tech_alias of structure <ld_s__line> to <ld_v__target>.
        assign component ld_v__comp                   of structure <ld_s__dim>  to <ld_v__source>.
        <ld_v__target> = <ld_v__source>.

      endloop.
      collect <ld_s__line> into <ld_t__hashtable>. "<ld_t__table>.
    endloop.

    insert lines of <ld_t__hashtable> into table <ld_t__table>.
    ld_s__log_read-sup_rec = lines( <ld_t__table> ).

    clear
    : ld_t__sel
    , ld_t__attr_list
    .

    free
    : lr_t__std_data
    , lr_t__hashtable
    .

    if <ld_t__table> is initial.
      e_st = zbd0c_not_found.
    else.
      e_st = zbd0c_read_pack.
    endif.

    gf_end_of_data = abap_true.

    get time stamp field ld_s__log_read-time_end.
    go_log->set_read( ld_s__log_read ).

  endmethod.                    "generate_dimension
*--------------------------------------------------------------------*
* WRITE_DATA_ARFC
*--------------------------------------------------------------------*
  method write_data_arfc.
    data
    : lt_rfcdata        type rsdri_t_rfcdata
    , lt_field          type rsdp0_t_field
    , task              type zbd0t_ty_name_rfc_task
    , ld_v__cnt_buf     type i
    , ld_v__cnt         type i
    , ld_v__packsize    type i
    , l_string          type string
    , ld_s__log_write   type zbd0t_s__log_write
    .

    field-symbols
    : <lt_data>     type any table
    , <ls_data>     type any
    .

    get time stamp field ld_s__log_write-time_start.

    assign gr_table->* to <lt_data>.
    ld_v__packsize = go_appl_table->gr_o__model->gr_o__application->gd_v__package_size.

    check lines( <lt_data> ) > 0.

    if lines( <lt_data> ) > ld_v__packsize.
      loop at <lt_data>
           assigning <ls_data>.

        add 1 to
        : ld_v__cnt_buf
        , ld_v__cnt
        .

        call function 'ZBD00_DATA_WRAP_LINE'
          exporting
            i_s_data         = <ls_data>
            i_unicode_result = rs_c_false
          changing
            e_t_outdata      = lt_rfcdata.


        check ld_v__cnt_buf = ld_v__packsize or
              ld_v__cnt     = lines( <lt_data> ).

        get time stamp field ld_s__log_write-time_start.

        task = zcl_bd00_rfc_task=>get_task_run( i_appset_id = go_appl->gd_v__appset_id
                                                i_appl_id   = go_appl->gd_v__appl_id
                                                mode        = zcl_bd00_rfc_task=>cs-rfc_write ).

        ld_s__log_write-rfc_task = task.
        add 1 to gv_nr_pack_write.
        ld_s__log_write-nr_pack = gv_nr_pack_write.
        append ld_s__log_write to go_log->gd_t__open_write.

        call function 'ZBD00_RFC_BPC_WRITE'
          starting new task task
          destination in group 'parallel_generators'
          calling write_data_arfc_receive on end of task
            exporting
              i_appset_id           = go_appl->gd_v__appset_id
              i_appl_id             = go_appl->gd_v__appl_id
              i_mode                = i_mode
*        c_log_ses             = i_log_ses
*        c_nr_pack             = i_nr_pack
            tables
              i_t_rfcdata           = lt_rfcdata
              i_t_field             = lt_field
            exceptions
              communication_failure = 1
              system_failure        = 2
              resource_failure      = 3.

        clear
        : ld_v__cnt_buf
        , lt_rfcdata
        .

        if sy-subrc ne 0.
          "error
          exit.
        endif.
      endloop.

    else.
      call function 'ZBD00_DATA_WRAP'
        exporting
          i_t_data         = <lt_data>
          i_unicode_result = rs_c_false
        importing
          e_t_outdata      = lt_rfcdata.


      task = zcl_bd00_rfc_task=>get_task_run( i_appset_id = go_appl->gd_v__appset_id
                                              i_appl_id   = go_appl->gd_v__appl_id
                                              mode        = zcl_bd00_rfc_task=>cs-rfc_write ).

      ld_s__log_write-rfc_task = task.
      add 1 to gv_nr_pack_write.
      ld_s__log_write-nr_pack = gv_nr_pack_write.
      append ld_s__log_write to go_log->gd_t__open_write.


      call function 'ZBD00_RFC_BPC_WRITE'
        starting new task task
        destination in group 'parallel_generators'
        calling write_data_arfc_receive on end of task
          exporting
            i_appset_id           = go_appl->gd_v__appset_id
            i_appl_id             = go_appl->gd_v__appl_id
            i_mode                = i_mode
*        c_log_ses             = i_log_ses
*        c_nr_pack             = i_nr_pack
          tables
            i_t_rfcdata           = lt_rfcdata
            i_t_field             = lt_field
          exceptions
            communication_failure = 1
            system_failure        = 2
            resource_failure      = 3.


      if sy-subrc = 0.
        exit.
      endif.
    endif.

  endmethod.                    "write_data_arfc
*--------------------------------------------------------------------*
* RECIEVE_ARFC
*--------------------------------------------------------------------*
  method recieve_arfc.

    wait until gf_arfc_read = abap_false.

    set handler me->recieve_arfc for go_appl_table  activation ''.

    go_appl_table->reset_index( ).

  endmethod.                    "recieve_arfc
endclass.                    "lcl_read_data IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS lcl_log IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
class lcl_log implementation.

  method set_read.

    append read to gd_t__read.

  endmethod.                    "set_read

  method set_read_dim.

*    append read to gd_t__read_dim.

  endmethod.                    "set_read

  method set_write.

    append write to gd_t__write.

  endmethod.                    "set_WRITE

endclass.                    "lcl_log IMPLEMENTATION
