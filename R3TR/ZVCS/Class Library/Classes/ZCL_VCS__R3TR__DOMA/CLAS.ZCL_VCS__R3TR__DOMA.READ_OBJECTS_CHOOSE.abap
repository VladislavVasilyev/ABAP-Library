method READ_OBJECTS_CHOOSE.

  data
  : ld_tr__doma        type range of tadir-obj_name
  , ld_tr__devc        type range of tadir-devclass
  , ld_sr__devc        like line of ld_tr__devc
  , ld_s__tadir        type zvcst_s__tadir
  , ld_t__tadir        type ty_t__tadir
  , ld_v__devclass     type tdevc-devclass
  , ld_s__choose       type ty_s__checkobj_r3tr
  , ld_t__choose       type ty_t__checkobj_r3tr
  , ld_s_function      type svalp
  , ld_t__functions    type standard table of svalp
  , ld_v__index        type i
  .

  field-symbols
  : <ld_s__object>     type zvcst_s__r3tr_obj
  , <ld_s__rclas>      like line of ld_tr__doma
  , <ld_s__tadir>      type ty_s__tadir
  , <ld_s__choose>     type ty_s__checkobj_r3tr

  .

  loop at cd_t__object assigning <ld_s__object>
       where type = `DEVC`
          or type = `DOMA`.

    case <ld_s__object>-type.
      when `DEVC`.
        loop at <ld_s__object>-obj_range assigning <ld_s__rclas>.
          ld_sr__devc-sign   = `I`.
          ld_sr__devc-option = `EQ`.
          ld_sr__devc-low = <ld_s__rclas>-low.
          append ld_sr__devc to ld_tr__devc.
        endloop.
      when `DOMA`.
        ld_tr__doma = <ld_s__object>-obj_range.
    endcase.

  endloop.

  check ld_tr__doma is not initial or ld_tr__devc is not initial.

  select *
    from  tadir
    into  corresponding fields of table ld_t__tadir
    where pgmid    = zvcsc_r3tr
      and object   = zvcsc_r3tr_type-doma
      and obj_name in ld_tr__doma
      and devclass in ld_tr__devc
      and delflag ne abap_true.


  loop at ld_t__tadir assigning <ld_s__tadir>.
    <ld_s__tadir>-index = ld_s__choose-index = sy-tabix.

          ld_s__choose-clsname = <ld_s__tadir>-object.
          ld_s__choose-cmpname = <ld_s__tadir>-obj_name.
          ld_s__choose-sconame = <ld_s__tadir>-devclass.
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
    message id sy-msgid type 'E' number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

  loop at ld_t__choose assigning <ld_s__choose>.

    check <ld_s__choose>-checkbox <> abap_true.
    ld_v__index = <ld_s__choose>-index.
    delete ld_t__tadir where index = ld_v__index.

  endloop.

  loop at ld_t__tadir assigning <ld_s__tadir>.

    move-corresponding <ld_s__tadir> to  ld_s__tadir.
    append  ld_s__tadir to gd_t__tadir.

  endloop.

endmethod.
