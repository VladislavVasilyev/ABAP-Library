method drop_index.
*CL_RSSM_DROPINDEX
  data: l_t_msg_proc  type rs_t_msg.
  data: l_subrc_proc  type sysubrc.
  data: l_subrc       type sysubrc.

  perform drop_indexes_from_cube in program saplrsm1
          using    gr_o__application->gd_v__infoprovide
                   'X'
                   rs_c_true
                   ''
          changing l_t_msg_proc
                   l_subrc_proc.
  if l_subrc_proc <> 0.
    raise exception type zcx_bd00_appl_tech
      exporting textid = zcx_bd00_appl_tech=>cx_drpindex_erorr
                gd_v__appset_id = gr_o__application->gd_v__appset_id
                gd_v__appl_id = gr_o__application->gd_v__appl_id.
  endif.

endmethod.
