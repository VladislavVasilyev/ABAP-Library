method if_rspc_execute~execute.

  data
  : lf_success      type uj_flg
  , l_uid           type sysuuid_25
  , lo_config       type ref to cl_ujd_config
  , lo_factory      type ref to cl_ujd_task_factory
  , lo_actor        type ref to zcl_bdch_appl_tech_serv
  , lo_error        type ref to cx_root
  , lr_o__appl_tech type ref to zcl_bd00_appl_tech
  .
  data
  : ld_v__value     type ujd_runparam-value
  , ld_v__appset_id type uj_appset_id
  , ld_v__appl_id   type uj_appl_id
  , ld_v__perc_num  type i
  , ld_f__dropindex
  , ld_f__index
  , ld_f__loaded
  , ld_f__planned
  , ld_f__dbstat
  , ld_v__dump    type i
  .

  call function 'RSSM_UNIQUE_ID'
    importing
      e_uni_idc25 = l_uid.

  e_instance = l_uid.
*  zcl_debug=>stop_program( ).
  try.
      create object lo_config
        exporting
          i_variant      = i_variant
*          i_type         = `ZBDTECHSRV`
          i_jobcount     = i_jobcount
          it_processlist = i_t_processlist
          i_logid        = i_logid
          it_variables   = i_t_variables.

      call method lo_config->init.

      try.
          lo_config->if_ujd_config~get_parameter(
           exporting
             i_parameter = `DUMP`
           importing
             e_parameter_value = ld_v__value ).

        catch: cx_uj_db_error, cx_ujd_datamgr_error.
          clear ld_v__value.
      endtry.

      if ld_v__value = `X`.
        ld_v__dump = 1000 / 0.
      endif.

      try.
          lo_config->if_ujd_config~get_parameter(
           exporting
             i_parameter = `NORUN`
           importing
             e_parameter_value = ld_v__value ).

        catch: cx_uj_db_error, cx_ujd_datamgr_error.
          clear ld_v__value.
      endtry.

      if not ld_v__value = `X`.


        if `PARAMETERS` = `PARAMETERS`.
          lo_config->if_ujd_config~get_parameter(
           exporting
             i_parameter = `APPSET`
           importing
             e_parameter_value = ld_v__value ).

          if ld_v__value cp `$*$`.
            replace all occurrences of `$` in ld_v__value with ``.

            select single low
              from tvarvc
              into ld_v__value
              where name = ld_v__value and
                    type = `P`.
          endif.

          ld_v__appset_id = ld_v__value.

          lo_config->if_ujd_config~get_parameter(
           exporting
             i_parameter = `APPLICATION`
           importing
             e_parameter_value = ld_v__value ).

          if ld_v__value cp `$*$`.
            replace all occurrences of `$` in ld_v__value with ``.

            select single low
              from tvarvc
              into ld_v__value
              where name = ld_v__value and
                    type = `P`.
          endif.

          ld_v__appl_id = ld_v__value.

          try.
              lo_config->if_ujd_config~get_parameter(
               exporting
                 i_parameter = `DBSTAT`
               importing
                 e_parameter_value = ld_v__value ).

              ld_f__dbstat = ld_v__value.

            catch: cx_uj_db_error, cx_ujd_datamgr_error.
          endtry.

          if ld_f__dbstat = abap_true.
            lo_config->if_ujd_config~get_parameter(
               exporting
                 i_parameter = `PERC`
               importing
                 e_parameter_value = ld_v__value ).

            if ld_v__value cp `$*$`.
              replace all occurrences of `$` in ld_v__value with ``.

              select single low
                from tvarvc
                into ld_v__value
                where name = ld_v__value  and
                      type = `P`.
            endif.

            ld_v__perc_num = ld_v__value.

          endif.

          try.
              lo_config->if_ujd_config~get_parameter(
               exporting
                 i_parameter = `DRPINDEX`
               importing
                 e_parameter_value = ld_v__value ).

              ld_f__dropindex = ld_v__value.

            catch: cx_uj_db_error, cx_ujd_datamgr_error.
          endtry.

          try.
              lo_config->if_ujd_config~get_parameter(
               exporting
                 i_parameter = `INDEX`
               importing
                 e_parameter_value = ld_v__value ).

              ld_f__index = ld_v__value.

            catch: cx_uj_db_error, cx_ujd_datamgr_error.
          endtry.

          try.
              lo_config->if_ujd_config~get_parameter(
               exporting
                 i_parameter = `LOADED`
               importing
                 e_parameter_value = ld_v__value ).

              ld_f__loaded = ld_v__value.

            catch: cx_uj_db_error, cx_ujd_datamgr_error.
          endtry.

          try.
              lo_config->if_ujd_config~get_parameter(
               exporting
                 i_parameter = `PLANNED`
               importing
                 e_parameter_value = ld_v__value ).

              ld_f__planned = ld_v__value.

            catch: cx_uj_db_error, cx_ujd_datamgr_error.
          endtry.
        endif.

        create object lr_o__appl_tech
          exporting
            i_appset_id = ld_v__appset_id
            i_appl_id   = ld_v__appl_id.

        case `X`.
          when ld_f__dropindex.
            lr_o__appl_tech->drop_index( ).
          when ld_f__index.
            lr_o__appl_tech->index( ).
          when ld_f__dbstat.
            lr_o__appl_tech->create_dbstat( ld_v__perc_num ).
          when ld_f__loaded.
            lr_o__appl_tech->switch_loaded( ).
          when ld_f__planned.
            lr_o__appl_tech->switch_planned( ).
          when others.
            raise exception type cx_ujd_datamgr_error.
        endcase.

      endif.

      e_state = 'G'.

    catch cx_root into lo_error.

      try.
          while lo_error is not initial.
            message lo_error type 'I'.
            lo_error = lo_error->previous.
          endwhile.

*          call method cl_ujd_custom_type=>set_error_status
*            exporting
*              io_config = lo_config.
*
*          call method cl_ujd_custom_type=>write_exception_log
*            exporting
*              io_exception = lo_error.

        catch cx_root into lo_error.
          e_state = 'R'.
      endtry.

      e_state = 'R'.

  endtry.
endmethod.
