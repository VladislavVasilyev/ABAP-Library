function zbd00_rfc_bpc_read .
*"----------------------------------------------------------------------
*"*"Локальный интерфейс:
*"  IMPORTING
*"     VALUE(I_REFERENCE_DATE) TYPE  RSDRI_REFDATE DEFAULT SY-DATUM
*"     VALUE(I_SAVE_IN_FILE) TYPE  RSDRI_SAVE_IN_FILE DEFAULT SPACE
*"     VALUE(I_FILENAME) TYPE  RSDRI_FILENAME OPTIONAL
*"     VALUE(I_AUTHORITY_CHECK) TYPE  RSDRI_AUTHCHK DEFAULT
*"       RSDRC_C_AUTHCHK-READ
*"     VALUE(I_CURRENCY_CONVERSION) TYPE  RSDR0_CURR_CONV DEFAULT 'X'
*"     VALUE(I_S_RFCMODE) TYPE  RSDP0_S_RFCMODE OPTIONAL
*"     VALUE(I_MAXROWS) TYPE  I DEFAULT 0
*"     VALUE(I_USE_DB_AGGREGATION) TYPE  RS_BOOL DEFAULT RS_C_TRUE
*"     VALUE(I_USE_AGGREGATES) TYPE  RS_BOOL DEFAULT RS_C_TRUE
*"     VALUE(I_ROLLUP_ONLY) TYPE  RS_BOOL DEFAULT RS_C_TRUE
*"     VALUE(I_READ_ODS_DELTA) TYPE  RS_BOOL DEFAULT RS_C_FALSE
*"     VALUE(I_RESULTTYPE) TYPE  RSDRI_RESULTTYPE DEFAULT SPACE
*"     VALUE(I_DEBUG) TYPE  RS_BOOL DEFAULT RS_C_FALSE
*"     VALUE(I_APPSET_ID) TYPE  UJ_APPSET_ID
*"     VALUE(I_APPL_ID) TYPE  UJ_APPL_ID
*"     VALUE(I_SAVE_IN_TABLE) TYPE  RSDRI_SAVE_IN_TABLE DEFAULT SPACE
*"     VALUE(I_TABLENAME) TYPE  RSDRI_TABLENAME OPTIONAL
*"     VALUE(I_SUPPRESS_ZERO) TYPE  RS_BOOL OPTIONAL
*"     VALUE(I_TYPE_TABLE) TYPE  ZBD00_TYPE_APPL_TABLE OPTIONAL
*"     VALUE(I_OUTUC) TYPE  RS_BOOL DEFAULT RS_C_FALSE
*"  EXPORTING
*"     VALUE(E_END_OF_DATA) TYPE  RS_BOOL
*"     VALUE(E_AGGREGATE) TYPE  RSINFOCUBE
*"     VALUE(E_RFCDATA_UC) TYPE  XSTRING
*"     VALUE(E_SPLIT_OCCURRED) TYPE  RSDR0_SPLIT_OCCURRED
*"     VALUE(E_STEPUID) TYPE  SYSUUID_25
*"     VALUE(E_TIME_START) TYPE  TZNTSTMPL
*"     VALUE(E_TIME_END) TYPE  TZNTSTMPL
*"     VALUE(E_NUM_REC) TYPE  I
*"     VALUE(E_SUP_REC) TYPE  I
*"  TABLES
*"      I_T_RANGE TYPE  RSDRI_T_RANGE OPTIONAL
*"      I_T_TABLESEL TYPE  RSDRI_T_SELT OPTIONAL
*"      I_T_RTIME TYPE  RSDRI_T_RTIME OPTIONAL
*"      I_T_REQUID TYPE  RSDR0_T_REQUID OPTIONAL
*"      E_T_RFCDATA TYPE  RSDRI_T_RFCDATA OPTIONAL
*"      E_T_RFCDATAV TYPE  RSDRI_T_RFCDATAV OPTIONAL
*"      E_T_FIELD TYPE  RSDP0_T_FIELD OPTIONAL
*"      I_T_DIM_LIST TYPE  ZBD00_ST_CH_KEY OPTIONAL
*"      I_T_ALIAS TYPE  ZBD00_T_ALIAS_RFC OPTIONAL
*"  EXCEPTIONS
*"      ILLEGAL_INPUT
*"      ILLEGAL_INPUT_SFC
*"      ILLEGAL_INPUT_SFK
*"      ILLEGAL_INPUT_RANGE
*"      ILLEGAL_INPUT_TABLESEL
*"      NO_AUTHORIZATION
*"      ILLEGAL_DOWNLOAD
*"      ILLEGAL_TABLENAME
*"      TRANS_NO_WRITE_MODE
*"      X_MESSAGE
*"      ILLEGAL_RESULTTYPE
*"----------------------------------------------------------------------
  data
  : l_th_sfc            type rsdri_th_sfc
  , l_th_sfk            type rsdri_th_sfk
  , l_th_tablesel       type rsdri_th_selt
  , l_repid             like sy-repid
  , l_resulttp          type rsdri_resulttype
  , l_out               type rs_bool
  , l_outv              type rs_bool
  , l_outu              type rs_bool
  , l_r_root            type ref to cx_root
  , lr_t_data           type ref to data
  , lr_aggr_data        type ref to data
  , l_with_statistics   type rs_bool
  , gr_o__model         type ref to zcl_bd00_model
  , lt_dim_list	        type zbd00_t_ch_key
  , lt_dim              type table of string
  , lr_hashed_data      type ref to data
  , lr_sorted_data      type ref to data
  , ld_v__table_kind    type abap_tablekind
  , lv_signeddata       type string
  , ld_t__alias         type zbd00_t_alias
  , ld_s__alias         type zbd00_s_alias
  , ld_v__index         type i
  .

  data
  : lr_std_data         type ref to data
  , lr_srd_data         type ref to data
  , ls_data             type ref to data
  .

  field-symbols
  : <lt_data>           type standard table
  , <lt_srd_data>       type sorted table
  , <ld_s__alias_rfc>   type zbd00_s_alias_rfc
  , <ls_data>           type any
  , <ls_sfc>            type rsdri_s_sfc
  , <ld_s__component>   type abap_compdescr
  , <lt_data_hashed>    type hashed table
  , <lt_data_sorted>    type sorted table
  , <l_signeddata>      type  any
  , <ls_coll>           type any
  .

  get time stamp field e_time_start.

  clear: e_t_field[], e_aggregate, e_rfcdata_uc.

*  perform determine_statistics(saplrsdri)
*            using    i_infoprov
*            changing l_with_statistics.
*
*  if l_with_statistics = rs_c_true.
*    data: l_s_sfk  type rsdri_s_sfk.
*    l_th_sfk          = l_th_sfk.
*    l_s_sfk-kyfnm     = '1ROWCOUNT' .
*    l_s_sfk-kyfalias  = '1ROWCOUNT' .
*    l_s_sfk-aggr      = 'CNT'.
*    insert l_s_sfk into table l_th_sfk.
*    assign l_th_sfk to <l_th_sfk>.
*  endif.
  loop at i_t_alias
       assigning <ld_s__alias_rfc>.
    ld_s__alias-bpc_name-dimension  = <ld_s__alias_rfc>-dimension.
    ld_s__alias-bpc_name-attribute  = <ld_s__alias_rfc>-attribute.
    ld_s__alias-bpc_alias-dimension = <ld_s__alias_rfc>-alias_dimension.
    ld_s__alias-bpc_alias-attribute = <ld_s__alias_rfc>-alias_attribute.
    insert ld_s__alias into table ld_t__alias.
  endloop.

  lt_dim_list = i_t_dim_list[].

  try.
      gr_o__model ?= zcl_bd00_model=>get_model( it_dim_list = lt_dim_list
                                                i_appset_id = i_appset_id
                                                i_appl_id   = i_appl_id
                                                i_type_pk   = i_type_table
                                                it_alias    = ld_t__alias ).

    catch zcx_bd00_create_obj.
      raise illegal_input.
  endtry.


  ld_v__table_kind = gr_o__model->gd_s__handle-tab-tech_name->table_kind.

* derive SFC and SFK for RFC
  if i_save_in_table = rsdrc_c_save_table-ini and ld_t__alias is initial.
    try.
        perform derive_sfc_sfk_rfc in program saplrsdri
          tables   gr_o__model->gd_t__sfc
                   gr_o__model->gd_t__sfk
          changing l_th_sfc
                   l_th_sfk.
      catch cx_rsdrc_illegal_input_sfc into l_r_root.
        call function 'RS_EXCEPTION_TO_SYMSG'
          exporting
            i_r_exception = l_r_root.
        raise illegal_input_sfc.
      catch cx_rsdrc_illegal_input_sfk into l_r_root.
        call function 'RS_EXCEPTION_TO_SYMSG'
          exporting
            i_r_exception = l_r_root.
        raise illegal_input_sfk.
    endtry.
  else.
    l_th_sfc = gr_o__model->gd_t__sfc.
    l_th_sfk = gr_o__model->gd_t__sfk.
  endif.

  lv_signeddata = gr_o__model->gd_v__signeddata.

* create standard table
  create data ls_data type handle gr_o__model->gd_s__handle-st-tech_name.
  assign ls_data->* to <ls_data>.
  create data lr_std_data like standard table of <ls_data> with non-unique default key.
  assign lr_std_data->* to <lt_data>.

* создание промежуточной таблицы
  case ld_v__table_kind.
    when cl_abap_tabledescr=>tablekind_std or
         cl_abap_tabledescr=>tablekind_hashed.
      create data lr_hashed_data like hashed table of <ls_data> with unique default key.
    when cl_abap_tabledescr=>tablekind_sorted.
      if gr_o__model->gd_f__complete_key = abap_false.
        clear lt_dim.
        append lines of gr_o__model->gd_s__handle-tab-tech_name->key to lt_dim.
        loop at gr_o__model->gd_s__handle-st-tech_name->components
          assigning <ld_s__component>
          where type_kind = `C`.

          read table lt_dim
               with table key table_line = <ld_s__component>-name
               transporting no fields.
          check sy-subrc <> 0.
          append <ld_s__component>-name to lt_dim.
        endloop.
      else.
        append lines of gr_o__model->gd_s__handle-tab-tech_name->key to lt_dim.
      endif.
      create data lr_sorted_data like sorted table of <ls_data> with unique key (lt_dim).
  endcase.

* initialize TABLESEL
  l_th_tablesel = i_t_tablesel[].

* check way in which result is returned
  if i_resulttype <> space and
     i_resulttype <> 'V'   and
     i_resulttype <> 'U'.
    raise illegal_resulttype.
  endif.

  l_resulttp = i_resulttype.
  if i_save_in_file  <> rsdrc_c_save_file-ini or
     i_save_in_table <> rsdrc_c_save_table-ini.
    l_resulttp = space.
  endif.

* determine the requested return structure
  if e_t_rfcdata is requested and l_resulttp = space.
    clear e_t_rfcdata[].
    l_out = rs_c_true.
  endif.

  if e_t_rfcdatav is requested and l_resulttp = 'V'.
    clear e_t_rfcdatav[].
    l_outv = rs_c_true.

    try.
        perform add_units_to_sfc in program saplrsdri
          using    l_th_sfk
          changing l_th_sfc.
      catch cx_rsdrc_illegal_input_sfk into l_r_root.
        call function 'RS_EXCEPTION_TO_SYMSG'
          exporting
            i_r_exception = l_r_root.
        raise illegal_input_sfk.
    endtry.
  endif.

  if e_rfcdata_uc is requested and l_resulttp = 'U'.
    clear e_rfcdata_uc.
    l_outu = rs_c_true.
  endif.

  if not i_s_rfcmode is initial.
    clear e_t_rfcdata[].
    l_out  = rs_c_true.
    l_outv = rs_c_false.
  endif.

  check l_out           =  rs_c_true             or
        l_outv          =  rs_c_true             or
        l_outu          =  rs_c_true             or
        i_save_in_file  <> rsdrc_c_save_file-ini or
        i_save_in_table <> rsdrc_c_save_table-ini.

*--------------------------------------------------------------------*
* READ DATA
*--------------------------------------------------------------------*
  data
  : l_split             type rs_bool
  , l_message(50)       type c
  , l_first_call        type rs_bool
  .

  l_first_call     = rs_c_true.
  e_end_of_data    = rs_c_false.
  e_split_occurred = rs_c_false.

  perform set_field_info(saplrsdri)
    using    <lt_data>
    changing e_t_field[].

*--------------------------------------------------------------------*
* Read data
*--------------------------------------------------------------------*
  while e_end_of_data = rs_c_false.
    call function 'RSDRI_INFOPROV_READ'
      exporting
        i_infoprov             = gr_o__model->gr_o__application->gd_v__infoprovide
        i_th_sfc               = l_th_sfc
        i_th_sfk               = l_th_sfk
        i_t_range              = i_t_range[]
        i_th_tablesel          = l_th_tablesel
        i_t_rtime              = i_t_rtime[]
        i_reference_date       = i_reference_date
        i_save_in_table        = i_save_in_table
        i_tablename            = i_tablename
        i_save_in_file         = i_save_in_file
        i_filename             = i_filename
        i_packagesize          = -1
        i_maxrows              = i_maxrows
        i_authority_check      = i_authority_check
        i_currency_conversion  = i_currency_conversion
        i_use_aggregates       = i_use_aggregates
        i_rollup_only          = i_rollup_only
        i_read_ods_delta       = i_read_ods_delta
        i_use_db_aggregation   = i_use_db_aggregation
        i_t_requid             = i_t_requid[]
        i_debug                = i_debug
      importing
        e_t_data               = <lt_data>
        e_end_of_data          = e_end_of_data
        e_aggregate            = e_aggregate
        e_split_occurred       = l_split
        e_stepuid              = e_stepuid
      changing
        c_first_call           = l_first_call
      exceptions
        illegal_input          = 1
        illegal_input_sfc      = 2
        illegal_input_sfk      = 3
        illegal_input_range    = 4
        illegal_input_tablesel = 5
        no_authorization       = 6
        illegal_download       = 8
        illegal_tablename      = 11
        trans_no_write_mode    = 12
        x_message              = 9
        others                 = 10.

    case sy-subrc.
      when 0.
        if l_split = rs_c_true.
          e_split_occurred = rs_c_true.
        endif.
      when 1. raise     illegal_input             .
      when 2. raise     illegal_input_sfc         .
      when 3. raise     illegal_input_sfk         .
      when 4. raise     illegal_input_range       .
      when 5. raise     illegal_input_tablesel    .
      when 6. raise     no_authorization          .
      when 8. raise     illegal_download          .
      when 11.raise     illegal_tablename         .
      when 12.raise     trans_no_write_mode       .
      when others.raise x_message                 .
    endcase.

    e_num_rec = lines( <lt_data> ).

*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
* Aggregate
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
* АГРЕГАЦИЯ И ПОДАВЛЕНИЕ НУЛЕЙ
    case ld_v__table_kind.
      when cl_abap_tabledescr=>tablekind_std or
           cl_abap_tabledescr=>tablekind_hashed.
        assign lr_hashed_data->* to <lt_data_hashed>.
      when cl_abap_tabledescr=>tablekind_sorted.
        assign lr_sorted_data->* to <lt_data_sorted>.
    endcase.

    loop at <lt_data>
         assigning <ls_data>.

      if i_suppress_zero = abap_true.
        assign component lv_signeddata of structure <ls_data> to <l_signeddata>.
        if <l_signeddata> = 0.
          delete <lt_data>.
          continue.
        endif.
      endif.

      case ld_v__table_kind.
        when cl_abap_tabledescr=>tablekind_std or
             cl_abap_tabledescr=>tablekind_hashed.
          collect <ls_data> into <lt_data_hashed> assigning <ls_coll>.
        when cl_abap_tabledescr=>tablekind_sorted.
          collect <ls_data> into <lt_data_sorted> assigning <ls_coll>.
          ld_v__index = sy-tabix.
      endcase.

      delete <lt_data>.
      if i_suppress_zero = abap_true.
        assign component lv_signeddata of structure <ls_coll> to <l_signeddata>.
        if <l_signeddata> = 0.

          case ld_v__table_kind.
            when cl_abap_tabledescr=>tablekind_std or
                 cl_abap_tabledescr=>tablekind_hashed.
              delete table <lt_data_hashed> from <ls_coll>.
            when cl_abap_tabledescr=>tablekind_sorted.
              delete <lt_data_sorted> index ld_v__index.
          endcase.
        endif.
      endif.
    endloop.
  endwhile.


  case ld_v__table_kind.
    when cl_abap_tabledescr=>tablekind_std or
         cl_abap_tabledescr=>tablekind_hashed.

      e_sup_rec = lines( <lt_data_hashed> ).


      if i_outuc = rs_c_true.
        call function 'ZBD00_DATA_WRAP'
          exporting
            i_t_data         = <lt_data_hashed>
            i_unicode_result = rs_c_true
          importing
            e_outdata_uc     = e_rfcdata_uc.
      else.
        call function 'ZBD00_DATA_WRAP'
          exporting
            i_t_data         = <lt_data_hashed>
            i_unicode_result = rs_c_false
          importing
            e_t_outdata      = e_t_rfcdata[].
      endif.


    when cl_abap_tabledescr=>tablekind_sorted.

      e_sup_rec = lines( <lt_data_sorted> ).

      if i_outuc = rs_c_true.
        call function 'ZBD00_DATA_WRAP'
          exporting
            i_t_data         = <lt_data_sorted>
            i_unicode_result = rs_c_true
          importing
            e_outdata_uc     = e_rfcdata_uc.
      else.
        call function 'ZBD00_DATA_WRAP'
          exporting
            i_t_data         = <lt_data_sorted>
            i_unicode_result = rs_c_false
          importing
            e_t_outdata      = e_t_rfcdata[].
      endif.

  endcase.

  get time stamp field e_time_end.










*    data l_rsadmin type rsadmin.
*    if i_use_db_aggregation = rs_c_true and l_split = rs_c_true.
*
*      select single * into l_rsadmin from rsadmin
*      where
*        object = 'RSDRI_READ_RFC_DOES_AGGREGATE'.
*
*      if sy-subrc = 0 and l_rsadmin-value = rs_c_true.
*
*
*        call function 'RSDRI_AGGREGATE_DATA'
*          exporting
*            i_infoprov          = gr_o__model->go_appl->gv_infoprovide
*            i_th_sfc            = l_th_sfc
*            i_th_sfk            = <l_th_sfk>
*          changing
*            c_t_data            = <lt_aggr_data>
*          exceptions
*            illegal_input_sfc   = 1
*            illegal_input_sfk   = 2
*            illegal_input_other = 3
*            x_message           = 4
*            others              = 5.
*
*        if sy-subrc <> 0.
*          raise x_message.
*        endif.
*
*      endif.
*
*    endif.
*    if l_out  = rs_c_true.
*      call function 'ZBD00_DATA_WRAP'
*        exporting
*          i_t_data         = <lt_srd_data>
*          i_unicode_result = rs_c_false
*        importing
*          e_t_outdata      = e_t_rfcdata[].
*      if not i_s_rfcmode is initial.
*        call function i_s_rfcmode-rfc_receiver
*          destination 'BACK'
*          exporting
*            i_id                  = i_s_rfcmode-id
*            i_end_of_data         = e_end_of_data
*          tables
*            i_t_rfcdata           = e_t_rfcdata[]
*            i_t_field             = e_t_field[]
*          exceptions
*            communication_failure = 1  message l_message
*            system_failure        = 2  message l_message
*            others                = 3.
*        if sy-subrc <> 0.
*          raise x_message.
*        endif.
*      endif.
*    endif.
*    if l_outv = rs_c_true.
*      call function 'RSDRI_DATA_WRAP_V'
*        exporting
*          i_t_data      = <lt_data>
*          i_th_sfc      = l_th_sfc
*          i_th_sfk      = l_th_sfk
*        importing
*          e_t_outdatav  = e_t_rfcdatav[]
*        exceptions
*          data_overflow = 1
*          others        = 2.
*      case sy-subrc.
*        when 0.
*        when 1.
*          raise data_overflow.
*        when others.
*          raise x_message.
*      endcase.
*    endif.
*    if i_outu = rs_c_true.
*      call function 'RSDRI_DATA_WRAP'
*        exporting
*          i_t_data         = l_t_data
*          i_unicode_result = rs_c_true
*        importing
*          e_outdata_uc     = e_rfcout_uc.
*      if not i_s_rfcmode is initial.
*        call function i_s_rfcmode-rfc_receiver
*          destination 'BACK'
*          exporting
*            i_id                  = i_s_rfcmode-id
*            i_end_of_data         = e_eod
*            i_rfcdata_uc          = e_rfcout_uc
*          exceptions
*            communication_failure = 1  message l_message
*            system_failure        = 2  message l_message
*            others                = 3.
*        if sy-subrc <> 0.
*          raise x_message.
*        endif.
*      endif.
*    endif.
*endwhile.
** get the generated read report
*  perform get_report in program saplrsdri
*    using    i_infoprov
*             i_debug
*    changing l_repid.
*
** call form in read report
*  perform infoprov_read_rsdri in program (l_repid)
*    using    i_infoprov
*             l_th_sfc
*             l_th_sfk
*             i_t_range[]
*             l_th_tablesel
*             i_t_rtime[]
*             i_reference_date
*             i_save_in_table
*             i_tablename
*             i_save_in_file
*             i_filename
*             i_use_aggregates
*             i_read_ods_delta
*             i_authority_check
*             i_rollup_only
*             i_currency_conversion
*             l_out
*             l_outv
*             l_outu
*             i_t_requid[]
*             i_s_rfcmode
*             i_maxrows
*             i_use_db_aggregation
*             i_debug
*    changing e_end_of_data
*             e_t_rfcdata[]
*             e_t_rfcdatav[]
*             e_rfcdata_uc
*             e_t_field[]
*             e_aggregate
*             e_split_occurred
*             e_stepuid.
endfunction.
