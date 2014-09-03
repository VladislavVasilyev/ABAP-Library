method master_upload.

  zcl_vcs_objects=>upload( i_v__directory ).
  zcl_vcs_objects=>choose( i_v__form_name = i_v__form_name i_f__upload = `X` ).
  zcl_vcs_objects=>create(  ).
  zcl_vcs_objects=>write_msg_error( ).
  zcl_vcs_objects=>write_msg_create(  ).

endmethod.
