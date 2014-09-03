method dbstat.
  type-pools rsmpc.

  data: l_s_sele      type rsmpc_s_sele.
  data: l_t_msg_proc  type rs_t_msg.
  data: l_error_proc.
  data: l_s_msg       type rs_s_msg.


  if perc_num > 100.
    l_s_sele-perc_num = `100`.
  elseif perc_num < 0.
    l_s_sele-perc_num = `10`.
  else.
    l_s_sele-perc_num = perc_num.
  endif.

  call function 'RSSM_PROCESS_DBSTAT'
    exporting
      i_cube            = gr_o__application->gd_v__infoprovide
      i_rnr             = space
      i_s_sele          = l_s_sele
*      i_parent_batch_id = i_batchid
    importing
      e_t_msg           = l_t_msg_proc
      e_error           = l_error_proc.


  if not l_error_proc is initial.
     raise exception type zcx_bd00_appl_tech
      exporting textid = zcx_bd00_appl_tech=>cx_dbstat_erorr
                gd_v__appset_id = gr_o__application->gd_v__appset_id
                gd_v__appl_id = gr_o__application->gd_v__appl_id.
  endif.

endmethod.
