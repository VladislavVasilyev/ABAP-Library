method read_objects_choose.

  data
  : ld_t__dimension       type standard table of ty_s__dimension
  , ld_s__choose          type ty_s__checkobj_dimn
  , ld_t__choose          type standard table of ty_s__checkobj_dimn
  , ld_s_function         type svalp
  , ld_t__functions       type standard table of svalp
  , ld_v__index           type i
  , ld_s__gdim            type uja_dimension
  .

  field-symbols
  : <ld_s__dimension>     type ty_s__dimension
  , <ld_s__choose>        type ty_s__checkobj_dimn
  .


  check cd_f__dimn = abap_true.

  select *
    from uja_dimension
    into corresponding fields of table ld_t__dimension
    where appset_id in cd_r__appset_id
      and dimension in cd_r__dimension.

  loop at ld_t__dimension assigning <ld_s__dimension>.
    ld_s__choose-index = <ld_s__dimension>-index = sy-tabix.
    ld_s__choose-type            = `DIMN`.
    ld_s__choose-component       = `BPCS`.
    ld_s__choose-appset          = <ld_s__dimension>-appset_id.
    ld_s__choose-dimension       = <ld_s__dimension>-dimension.

    append ld_s__choose to ld_t__choose.
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
      table_name                   = `ZVCS_ST__BPCSDIMN`
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
    delete ld_t__dimension where index = ld_v__index.

  endloop.

  loop at ld_t__dimension assigning <ld_s__dimension>.

    move-corresponding <ld_s__dimension> to ld_s__gdim.
    append ld_s__gdim to gd_t__dimension.

  endloop.

endmethod.
