method read_objects.

  data
  : ld_s__doc_content     type ty_s__content
  , ld_v__docname         type uj_docname
  , ld_s__source          type zvcst_s__download
  .

  field-symbols
  : <ld_s__dimension>     type uja_dimension
  , <ld_s__xml>           type ty_s__dimn
  .

  loop at gd_t__dimension assigning <ld_s__dimension>.

    create data ld_s__source-xmlsource type ty_s__dimn.
    assign ld_s__source-xmlsource->* to <ld_s__xml>.

    move-corresponding <ld_s__dimension> to <ld_s__xml>-uja_dimension.

    " чтение контента
    concatenate `\ROOT\WEBFOLDERS\` <ld_s__xml>-uja_dimension-appset_id `\ADMINAPP\` <ld_s__xml>-uja_dimension-dimension `.XLS` into ld_v__docname.

    select single *
      from ujf_doc
      into corresponding fields of <ld_s__xml>-ujf_doc
      where appset = <ld_s__xml>-uja_dimension-appset_id
        and docname = ld_v__docname.

    call function 'SCMS_XSTRING_TO_BINARY'
      exporting
        buffer        = <ld_s__xml>-ujf_doc-doc_content
      importing
        output_length = ld_s__doc_content-file_length
      tables
        binary_tab    = ld_s__doc_content-content.

    clear <ld_s__xml>-ujf_doc-doc_content.

    concatenate `DIMN.` <ld_s__xml>-uja_dimension-dimension `.XLS` into ld_s__doc_content-filename.
    <ld_s__xml>-content = ld_s__doc_content-filename.

    ld_s__doc_content-appset    = <ld_s__xml>-uja_dimension-appset_id.
    ld_s__doc_content-dimension = <ld_s__xml>-uja_dimension-dimension.

    ld_s__source-header-appset    = <ld_s__xml>-uja_dimension-appset_id.
    ld_s__source-header-pgmid     = ld_s__source-type-pgmid   = `BPCS`.
    ld_s__source-header-object    = ld_s__source-type-object  = `DIMN`.
    ld_s__source-header-obj_name  = <ld_s__xml>-uja_dimension-dimension.

    append ld_s__doc_content to gd_t__content.
    append ld_s__source to gd_t__source.

  endloop.

endmethod.
