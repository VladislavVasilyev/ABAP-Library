*"* use this source file for any macro definitions you need
*"* in the implementation part of the class
define mac__module.

  move &1 to gd_v__module.

end-of-definition.
define mac__module_raise.
  if sy-subrc = &2.
    clear gd_v__err_message.
    if sy-msgid is not initial and sy-msgty is not initial.
      message id sy-msgid type sy-msgty number sy-msgno
      with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 into gd_v__err_message.
    endif.

    gd_v__module = '&1'.
    gd_v__message = '&3'.

    translate
    : gd_v__module to upper case
    , gd_v__message to upper case
    .

    raise exception type zcx_vcs__call_module_error
    exporting exception = gd_v__message
              module    = gd_v__module
              error_message = gd_v__err_message.
  endif.
end-of-definition.
define mac__raise_message.
  raise exception type zcx_vcs__call_module_error
        exporting textid        = zcx_vcs__call_module_error=>cx_error_message
                  error_message = &2
                  module        = zcx_vcs__call_module_error=>mod-&1.
end-of-definition.
