method read_objects.

  data
  : ld_s__doc_content     type ty_s__content
  , ld_v__docname         type uj_docname
  , ld_s__source          type zvcst_s__download
  , lr_o__mbr_data        type ref to cl_uja_dim
  , ld_t__worksheet  type zvcst_t__xmlworksheet
  , ld_s__worksheet  type zvcst_s__xmlworksheet
  .

  field-symbols
  : <ld_s__dimension>     type uja_dimension
  , <ld_s__xml>           type ty_s__dimn
  .
return.
  loop at gd_t__dimension assigning <ld_s__dimension>.

    create data ld_s__source-xmlsource type ty_s__dimn.
    assign ld_s__source-xmlsource->* to <ld_s__xml>.
*
    move-corresponding <ld_s__dimension> to <ld_s__xml>-uja_dimension.
*
*    " чтение контента
*    concatenate `\ROOT\WEBFOLDERS\` <ld_s__xml>-uja_dimension-appset_id `\ADMINAPP\` <ld_s__xml>-uja_dimension-dimension `.XLS` into ld_v__docname.
*
*    select single *
*      from ujf_doc
*      into corresponding fields of <ld_s__xml>-ujf_doc
*      where appset = <ld_s__xml>-uja_dimension-appset_id
*        and docname = ld_v__docname.
*
*    call function 'SCMS_XSTRING_TO_BINARY'
*      exporting
*        buffer        = <ld_s__xml>-ujf_doc-doc_content
*      importing
*        output_length = ld_s__doc_content-file_length
*      tables
*        binary_tab    = ld_s__doc_content-content.
*
*    clear <ld_s__xml>-ujf_doc-doc_content.
*
*    concatenate `DIMN.` <ld_s__xml>-uja_dimension-dimension `.XLS` into ld_s__doc_content-filename.
*    <ld_s__xml>-content = ld_s__doc_content-filename.
*
*    ld_s__doc_content-appset    = <ld_s__xml>-uja_dimension-appset_id.
*    ld_s__doc_content-dimension = <ld_s__xml>-uja_dimension-dimension.
*
*    ld_s__source-header-appset    = <ld_s__xml>-uja_dimension-appset_id.
*    ld_s__source-header-pgmid     = ld_s__source-type-pgmid   = `BPCS`.
*    ld_s__source-header-object    = ld_s__source-type-object  = `DIMN`.
*    ld_s__source-header-obj_name  = <ld_s__xml>-uja_dimension-dimension.
*
*    append ld_s__doc_content to gd_t__content.
*    append ld_s__source to gd_t__source.

    data lo_uj_context type ref to if_uj_context.
    data gd_s__user_id  type  uj0_s_user.


    gd_s__user_id-user_id = `X5`.

    call method cl_uj_context=>set_cur_context
      exporting
        i_appset_id   = <ld_s__xml>-uja_dimension-appset_id
      is_user       = gd_s__user_id
*      i_appl_id     = gv_appl_id
          .

    lo_uj_context ?= cl_uj_context=>get_cur_context( ).
    lo_uj_context->switch_to_srvadmin( ).


    create object lr_o__mbr_data
      exporting
        i_appset_id = <ld_s__xml>-uja_dimension-appset_id
        i_dimension = <ld_s__xml>-uja_dimension-dimension.


    call method lr_o__mbr_data->read_mbr_data
      exporting
*        it_attr_list       = ld_t__attr_list
*        it_sel             = ld_t__sel
*          it_sel_mbr         = ld_t__sel_mbr
*        it_hier_list       = ld_t__hier_list
*          if_tech_name       = abap_true
*        if_only_base       = abap_true
        if_sort            = abap_true
        if_inc_non_display = abap_false
        if_inc_generate    = abap_false
        if_skip_cache      = abap_true
        if_inc_txt = abap_true
      importing
        er_data            = ld_s__worksheet-table.

    ld_s__worksheet-name = <ld_s__xml>-uja_dimension-dimension.

    append ld_s__worksheet to ld_t__worksheet.

  endloop.
*
*  data xml type ref to zcl_excel_xml_download.
*  create object xml.
*  xml->create_xml_workbook( ld_t__worksheet ).
*  xml->download( `ASD` ).

endmethod.
