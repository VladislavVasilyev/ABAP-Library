method switch_icube_trans_batch.

  call function 'RSSM_SWITCH_ICUBE_TRANS_BATCH'
    exporting
      i_infocube                 = gr_o__application->gd_v__infoprovide
      i_no_dialog                = 'X'
      i_switch                   = i_switch
    exceptions
      can_not_switch             = 1
      no_transactional_cube      = 2
      cube_not_exist             = 3
      not_allowed                = 4
      no_active_cube             = 5
      internal_error             = 6
      still_loading              = 7
      yellow_red_requests_exists = 8
      others                     = 9.

endmethod.
