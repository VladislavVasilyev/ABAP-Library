method check_wait_free_tasks.

  data
  : ld_v__max_tasks    type i
  , ld_v__free_tasks   type i
  .


  if cd_f__init ne abap_true. "инициализация
    do.
      call function 'SPBT_INITIALIZE' " инициализировать RFC
        exporting
          group_name                     = 'parallel_generators'
        importing
          max_pbt_wps                    = ld_v__max_tasks
          free_pbt_wps                   = ld_v__free_tasks
        exceptions
          invalid_group_name             = 1
          internal_error                 = 2
          pbt_env_already_initialized    = 3
          currently_no_resources_avail   = 4
          no_pbt_resources_found         = 5
          cant_init_different_pbt_groups = 6
          others                         = 7.

      if sy-subrc = 0 or sy-subrc = 3.
        cd_f__init = abap_true.
        exit.
      else.
        wait up to 15 seconds.
      endif.
    enddo.
  endif.

  do.
    call function 'SPBT_GET_CURR_RESOURCE_INFO' " проверить количество свободных задач
      importing
        max_pbt_wps                 = ld_v__max_tasks
        free_pbt_wps                = ld_v__free_tasks
      exceptions
        internal_error              = 1
        pbt_env_not_initialized_yet = 2
        others                      = 3.

    if nr_res_free_task > ld_v__free_tasks.
      wait
      : until nr_max_tasks = nr_free_tasks
      , up to 15 seconds.
      continue.
    else.
      exit.
    endif.
  enddo.

endmethod.
