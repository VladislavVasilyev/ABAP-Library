method read_objects.

  data
  : ld_s__tadir	            type zvcst_s__tadir
  , ld_s__source            type zvcst_s__download
  , lr_o__handle            type ref to cl_abap_datadescr
  .

  field-symbols
  : <ld_s__tadir>   type zvcst_s__tadir
  , <ld_s__xmlsource>       type any
  .

  loop at  gd_t__tadir assigning <ld_s__tadir>.
    move-corresponding <ld_s__tadir> to ld_s__tadir.

    ld_s__source-header = ld_s__tadir.
    ld_s__source-type-pgmid   = zvcsc_r3tr.
    ld_s__source-type-object  = zvcsc_r3tr_type-doma.

    lr_o__handle = get_handle( ).

    create data ld_s__source-xmlsource type handle lr_o__handle.
    assign ld_s__source-xmlsource->* to <ld_s__xmlsource>.

    call method read_object
      exporting
        i_s__tadir     = ld_s__tadir
      importing
        e_t__txtsource = ld_s__source-txtnodepath
        e_s__source    = <ld_s__xmlsource>.

    insert ld_s__source into table gd_t__source.

  endloop.
endmethod.
