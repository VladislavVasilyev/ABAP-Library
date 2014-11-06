method constructor.

  " create xml factory
  gd_i__ixml ?= cl_ixml=>create( ).

  " Creating the dom object model __
  gd_i__document = gd_i__ixml->create_document( ).

endmethod.
