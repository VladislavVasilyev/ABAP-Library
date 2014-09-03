method UPLOAD.

  data
  : ld_t__filelist      type zcl_vcs_r3tr___upload=>ty_t__filelist
  , ld_t__tadir         type zvcst_t__tadir
  , lr_o__upload        type ref to zcl_vcs_r3tr___upload
  , ld_v__typeobj       type trobjtype
  , lr_o__object        type ref to zcl_vcs_objects_stack
  , ld_s__upload        type zvcst_s__upload
  , ld_s__task_stack    type zvcst_s__tadir
  , ld_s__type          type zvcst_s__object
  , lr_s__handle        type ref to cl_abap_datadescr
  , lr_s__source        type ref to data
  .

  field-symbols
  : <ld_s__filelist>    type line of zcl_vcs_r3tr___upload=>ty_t__filelist
*  , <ld_t__vcs_objects> type ref to zcl_vcs_objects_stack
  .

  field-symbols
  : <ld_s__source>        type any
  , <header>              type any
  .

  call method
  : zcl_vcs_r3tr___upload=>searchfiles
      exporting i_v__dir      = i_v__directory
                i_v__regex    = `.XML$`
      receiving e_t__filelist = ld_t__filelist
  .

  loop at ld_t__filelist assigning <ld_s__filelist>.

    create object lr_o__upload
      exporting
        i_v__filename = <ld_s__filelist>.

    ld_s__type = lr_o__upload->get_typeobj( ).

    check zcl_vcs_objects_stack=>check_type( ld_s__type ) = abap_true.

    lr_o__object ?= zcl_vcs_objects_stack=>get_object( ld_s__type ).
    lr_s__handle ?= lr_o__object->get_handle( ).

    create data lr_s__source type handle lr_s__handle.
    assign lr_s__source->*   to <ld_s__source>.

*--------------------------------------------------------------------*
    data
    : begin of ld_s__header
      , header type zvcst_s__tadir
    , end of ld_s__header
    .

    call method lr_o__upload->upload
      importing
        e__xmlsource = <ld_s__source>
        e_s__header  = ld_s__header.

    ld_s__upload-TYPE      = ld_s__type.
    ld_s__upload-xmlsource = lr_s__source.
    ld_s__upload-header    = ld_s__header-header.

    insert ld_s__upload into table zcl_vcs_objects_stack=>cd_t__objects_for_upload.
    insert ld_s__header-header into table zcl_vcs_objects_stack=>cd_t__task_stack.

  endloop.

endmethod.
