method WRITE_OBJECT_CHOOSE.

  data
  : begin of ld_s__header
    , header type zvcst_s__tadir
  , end of ld_s__header
  .

  data
  : begin of ld_s__sclo_index
    , index type i
    . include type ty_s__sclo.
  data end of ld_s__sclo_index.

  data
  : lr_o__upload        type ref to zcl_vcs_r3tr___upload
  , ld_s__sclo          type ty_s__sclo
  , ld_s__choose        type ty_s__checkobj_sclo
  , ld_t__choose        type standard table of ty_s__checkobj_sclo
*  , ld_t__dimension     type standard table of ty_s__dimension
*  , ld_s__dimension     type ty_s__dimension
  , ld_s_function       type svalp
  , ld_t__functions     type standard table of svalp
  , ld_v__index         type i
  , ld_t__sclo          like standard table of ld_s__sclo_index
  .

  field-symbols
  : <ld_s__upload_file> like line of gd_t__upload_file
  , <ld_s__choose>      type ty_s__checkobj_sclo
  .

  loop at gd_t__upload_file assigning <ld_s__upload_file>.

    ld_s__choose-index = ld_s__sclo_index-index = sy-tabix.



    create object lr_o__upload
      exporting
        i_v__filename = <ld_s__upload_file>.

    call method lr_o__upload->upload
      importing
        e__xmlsource = ld_s__sclo
        e_s__header  = ld_s__header.

*    ld_s__choose-index = <ld_s__dimension>-index = sy-tabix.
    ld_s__choose-type            = `SCLO`.
    ld_s__choose-component       = `BPCS`.
    ld_s__choose-appset          = ld_s__header-header-appset.
    ld_s__choose-application     = ld_s__header-header-application.
    ld_s__choose-template        = ld_s__sclo-filename = ld_s__header-header-obj_name.

    append ld_s__choose to ld_t__choose.

    move-corresponding ld_s__sclo to ld_s__sclo_index.


*    concatenate <ld_s__upload_file>-path ld_s__sclo_index-content into ld_s__sclo_index-content.

    append ld_s__sclo_index to ld_t__sclo .

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
      table_name                   = `ZVCS_ST__BPCSSCLO`
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
    message id sy-msgid type 'E' number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

  loop at ld_t__choose assigning <ld_s__choose>.

    check <ld_s__choose>-checkbox <> abap_true.
    ld_v__index = <ld_s__choose>-index.
    delete ld_t__sclo where index = ld_v__index.

  endloop.

  loop at ld_t__sclo into ld_s__sclo_index.

    move-corresponding ld_s__sclo_index to  ld_s__sclo.
    append  ld_s__sclo to gd_t__sclo.

  endloop.

endmethod.
