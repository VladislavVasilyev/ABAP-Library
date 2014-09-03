method DOWNLOAD.

  data
  : ld_t__message_download type zcl_vcs___xml_txt=>ty_t__download .
  .

  field-symbols
  : <ld_s__object_for_download>  type zvcst_s__download
  .

  loop at zcl_vcs_objects_stack=>cd_t__objects_for_download
       assigning <ld_s__object_for_download>.

    check sy-subrc = 0.

    call method zcl_vcs___xml_txt=>download
      exporting
        i_s__source  = <ld_s__object_for_download>
      importing
        e_t__message = ld_t__message_download.

    append lines of ld_t__message_download to cd_t__message_download.

  endloop.

endmethod.
