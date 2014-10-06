method download.

  data
  : lr_o__mbr_data           type ref to cl_uja_dim
  , ld_s__worksheet          type zvcst_s__xmlworksheet
  , lr_s__line               type ref to data
  , ld_t__parenth            type zvcst_t__source
  , ld_t__all                type zvcst_t__source
  , ld_v__id                 type zvcst_s__source
  , ld_v__evdiscr            type zvcst_s__source
  , ld_s__sequence           type zvcst_s__sequence
  , ld_t__sequence           type standard table of zvcst_s__sequence
  , ld_v__cnt                type i
  , lr_o__structdescr        type ref to cl_abap_structdescr
  , ld_t__worksheet          type zvcst_t__xmlworksheet
  , ld_v__file_name          type string
  , ld_v__dimension          type uj_dim_name
  , dxml                     type ref to zcl_excel_xml_download.
  .

  field-symbols
  : <ld_s__data>             type any
  , <ld_s__comp>             type abap_compdescr
  , <ld_s__sequence>         type zvcst_s__sequence
  , <ld_t__data>             type any table
  .

  loop at gd_t__dimension into ld_v__dimension.

    create object lr_o__mbr_data
      exporting
        i_appset_id = gd_v__appset_id
        i_dimension = ld_v__dimension.

    call method lr_o__mbr_data->read_mbr_data
      exporting
        if_sort            = abap_true
        if_inc_non_display = abap_false
        if_inc_generate    = abap_false
        if_skip_cache      = abap_true
        if_inc_txt         = abap_true
      importing
        er_data            = ld_s__worksheet-table.


    assign ld_s__worksheet-table->* to <ld_t__data>.
    create data lr_s__line like line of <ld_t__data>.
    lr_o__structdescr    ?= cl_abap_structdescr=>describe_by_data_ref( lr_s__line ).

    clear
    : ld_s__sequence
    , ld_s__worksheet-sequence
    .

    loop at lr_o__structdescr->components assigning <ld_s__comp>.
      ld_s__sequence-field = <ld_s__comp>-name.
      append ld_s__sequence to ld_s__worksheet-sequence.
    endloop.

    sort ld_s__worksheet-sequence by field ascending.

    read table ld_s__worksheet-sequence
         with table key field = `ID`
         assigning <ld_s__sequence>.

    <ld_s__sequence>-sequence = 1.

    read table ld_s__worksheet-sequence
         with table key field = `EVDESCRIPTION`
         assigning <ld_s__sequence>.

    <ld_s__sequence>-sequence = 2.

    ld_v__cnt = 2.
    loop at ld_s__worksheet-sequence assigning <ld_s__sequence>
      where field cp `PARENTH*`.

      find first occurrence of regex `\<PARENTH\d+\>` in <ld_s__sequence>-field.
      if sy-subrc = 0.
        add 1 to ld_v__cnt.
        <ld_s__sequence>-sequence = ld_v__cnt.
      endif.
    endloop.

    loop at ld_s__worksheet-sequence assigning <ld_s__sequence>
        where sequence = 0.
      add 1 to ld_v__cnt.
      <ld_s__sequence>-sequence = ld_v__cnt.
    endloop.

    sort ld_s__worksheet-sequence by sequence ascending.

    ld_s__worksheet-name               = ld_v__dimension.
    ld_s__worksheet-f__filter          = abap_true.
    ld_s__worksheet-f__validtextlength = abap_true.
    ld_s__worksheet-f__splitvertical   = abap_true.

    append ld_s__worksheet to ld_t__worksheet.

    if gd_f__masterfile ne abap_true.
      if ld_t__worksheet is not initial.
        create object dxml.
        dxml->create_xml_workbook( ld_t__worksheet ).

        ld_v__file_name = ld_v__dimension.

        call method dxml->download_on_serv
          exporting
            i_appset_id = gd_v__appset_id
            i_appl_id   = gd_v__appl_id
            i_file_name = ld_v__file_name
            i_folder    = `DIMENSIONS`
            i_user_id   = gr_i__context->ds_user.

        clear ld_t__worksheet.
      endif.
    endif.
  endloop.

    if gd_f__masterfile eq abap_true.
      if ld_t__worksheet is not initial.
        create object dxml.
        dxml->create_xml_workbook( ld_t__worksheet ).

        ld_v__file_name = ld_v__dimension.

        call method dxml->download_on_serv
          exporting
            i_appset_id = gd_v__appset_id
            i_appl_id   = gd_v__appl_id
            i_file_name = `DIMENSIONS`
            i_folder    = `DIMENSIONS`
            i_user_id   = gr_i__context->ds_user.
      endif.
    endif.

endmethod.
