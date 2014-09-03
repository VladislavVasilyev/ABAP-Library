method master_download.

  zcl_vcs_objects=>crosssources( ).
  zcl_vcs_objects=>choose( i_v__form_name ).
  zcl_vcs_objects=>read( ).
  zcl_vcs_objects=>paths( ).
  zcl_vcs_objects=>download( ).
  zcl_vcs_objects=>write_msg_error( ).
  zcl_vcs_objects=>write_msg_read( ).

endmethod.
