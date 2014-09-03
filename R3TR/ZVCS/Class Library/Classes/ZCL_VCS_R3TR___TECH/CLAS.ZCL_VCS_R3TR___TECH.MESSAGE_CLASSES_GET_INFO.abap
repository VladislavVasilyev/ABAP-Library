method message_classes_get_info.

  refresh e_t__class.

  select sprsl msgnr text
    from t100
    into corresponding fields of table e_t__class
    where arbgb = i_v__messageclassname.

  if sy-subrc <> 0.
    raise exception type zcx_vcs__call_module_error
    exporting textid = zcx_vcs__call_module_error=>CX_ERROR_MESSAGE
              error_message = `Class message not found`
              module    = zcx_vcs__call_module_error=>mod-message_classes_get_info.
  endif.

endmethod.
