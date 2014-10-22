method read_objects.

  data
  : ld_s__doc_content     type ty_s__content
  , ld_s__source          type ty_s__source
  .

  field-symbols
  : <ld_s__xml>           type ty_s__xltp
  , <ld_s__xml1>          type ty_s__xltp
  .

  loop at gd_t__xltp assigning <ld_s__xml> .

    select    single *
      from    ujf_doctree
      into    corresponding fields of <ld_s__xml>-doc_tree
      where   appset   = <ld_s__xml>-appset
       and    docname  = <ld_s__xml>-docname.

    call function 'SCMS_XSTRING_TO_BINARY'
      exporting
        buffer        = <ld_s__xml>-doc_content
      importing
        output_length = ld_s__doc_content-file_length
      tables
        binary_tab    = ld_s__doc_content-content.

    clear
    : <ld_s__xml>-doc_content.

    ld_s__source-source-header-appset         = <ld_s__xml>-appset.
    ld_s__source-source-header-application    = <ld_s__xml>-application.
    ld_s__source-source-header-pgmid          = ld_s__source-source-type-pgmid   = zvcsc_bpc.
    ld_s__source-source-header-object         = ld_s__source-source-type-object  = zvcsc_bpc_type-excl.
    ld_s__source-source-header-obj_name       = <ld_s__xml>-filename.

    create data ld_s__source-source-xmlsource type ty_s__xltp.
    assign ld_s__source-source-xmlsource->* to <ld_s__xml1>.
    <ld_s__xml1> = <ld_s__xml>.

    ld_s__source-content = ld_s__doc_content.
    append ld_s__source      to gd_t__source_excl.

  endloop.

endmethod.
