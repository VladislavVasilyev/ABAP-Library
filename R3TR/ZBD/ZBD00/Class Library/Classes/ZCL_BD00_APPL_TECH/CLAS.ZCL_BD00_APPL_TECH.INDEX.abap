method index.
* CL_RSSM_INDEX
  data: l_t_msg_proc  type rs_t_msg.
  data: l_error.
  data: l_error_proc.

  call function 'RSSM_PROCESS_INDEX'
    exporting
      i_cube            = gr_o__application->gd_v__infoprovide
*      i_parent_batch_id = i_batchid
    importing
      e_t_msg           = l_t_msg_proc
      e_error           = l_error_proc.

  if not l_error_proc is initial.
     raise exception type zcx_bd00_appl_tech
      exporting textid = zcx_bd00_appl_tech=>cx_index_erorr
                gd_v__appset_id = gr_o__application->gd_v__appset_id
                gd_v__appl_id = gr_o__application->gd_v__appl_id.
  endif.

endmethod.
