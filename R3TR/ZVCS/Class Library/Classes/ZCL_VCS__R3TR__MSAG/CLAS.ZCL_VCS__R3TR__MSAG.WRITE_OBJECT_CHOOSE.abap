method WRITE_OBJECT_CHOOSE.
  data
  : begin of ld_s__header
    , header type zvcst_s__tadir
  , end of ld_s__header
  .

  data
  : lr_o__upload        type ref to zcl_vcs_r3tr___upload
  , ld_s__choose        type ty_s__checkobj_r3tr
  , ld_t__choose        type ty_t__checkobj_r3tr
  , ld_s_function       type svalp
  , ld_t__functions     type standard table of svalp
  , ld_v__index         type i
  , ld_s__upload        type ty_s__upload
  .

  field-symbols
  : <ld_s__upload_file> like line of gd_t__upload_file
  , <ld_s__choose>      type ty_s__checkobj_r3tr
  , <ld_s__msag>        type ty_s__msag
  .

  loop at gd_t__upload_file assigning <ld_s__upload_file>.

    create data ld_s__upload-source type ty_s__msag.
    assign ld_s__upload-source->* to <ld_s__msag> .

    ld_s__choose-index = ld_s__upload-tadir-index = sy-tabix.

    create object lr_o__upload
      exporting
        i_v__filename = <ld_s__upload_file>.

    call method lr_o__upload->upload
      importing
        e__xmlsource = <ld_s__msag>
        e_s__header  = ld_s__header.

    ld_s__choose-clsname = ld_s__header-header-object.
    ld_s__choose-cmpname = ld_s__header-header-obj_name.
    ld_s__choose-sconame = ld_s__header-header-devclass.
    append ld_s__choose to ld_t__choose.

    move-corresponding ld_s__header-header to ld_s__upload-tadir.
    append ld_s__upload to gd_t__upload.

  endloop.

  check lines( ld_t__choose ) > 0.

  move
  : 'OK'            to ld_s_function-func_name
  , sy-cprog        to ld_s_function-prog_name
  , i_v__form_name  to ld_s_function-form_name.

  append ld_s_function to ld_t__functions.

  call function 'POPUP_GET_SELECTION_FROM_LIST'
    exporting
      display_only                 = 'X'
      table_name                   = 'SEOSCOKEY'
      title_bar                    = 'Selection'
    tables
      list                         = ld_t__choose
      functions                    = ld_t__functions
    exceptions
      no_tablefields_in_dictionary = 1
      no_table_structure           = 2
      no_title_bar                 = 3
      others                       = 4.

  if sy-subrc <> 0.
*    message id sy-msgid type 'E' number sy-msgno
*            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

  loop at ld_t__choose assigning <ld_s__choose>.

    check <ld_s__choose>-checkbox <> abap_true.
    ld_v__index = <ld_s__choose>-index.
    delete gd_t__upload where tadir-index = ld_v__index.

  endloop.
endmethod.
