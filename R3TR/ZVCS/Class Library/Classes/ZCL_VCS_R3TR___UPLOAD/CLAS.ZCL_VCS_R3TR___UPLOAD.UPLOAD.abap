method upload.

  call method gr_o__xmldoc->get_data
    changing
      dataobject = e__xmlsource.

  call method gr_o__xmldoc->get_data
    changing
      dataobject = e_s__header.

endmethod.
