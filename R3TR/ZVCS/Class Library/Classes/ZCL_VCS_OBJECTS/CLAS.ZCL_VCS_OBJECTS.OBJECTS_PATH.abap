method objects_path.

  data
  : ld_s__object            type zvcst_s__download
  , ld_s__error             type ty_s__error_stack
  , lr_o__object            type ref to zcl_vcs_objects_stack
  , lr_o__handle            type ref to cl_abap_datadescr
  , ld_s__type              type zvcst_s__object
  , ld_s__header            type zvcst_s__tadir
  .

  field-symbols
  : <ld_s__reestr>          type ty_s__reestr
  , <ld_s__xmlsource>       type any
  , <ld_s__stack>           like line of zcl_vcs_objects_stack=>cd_t__stack
  .


  loop at zcl_vcs_objects_stack=>cd_t__stack assigning <ld_s__stack>.

    lr_o__object     ?= zcl_vcs_objects_stack=>get_object( <ld_s__stack>-type ).
    lr_o__handle     ?= lr_o__object->get_handle(  ).
    ld_s__object-type = ld_s__type.

    create data ld_s__object-xmlsource type handle lr_o__handle.
    assign ld_s__object-xmlsource->* to <ld_s__xmlsource>.

    refresh ld_s__object-txtnodepath.
    call method lr_o__object->create_path
      exporting
        i_s__dir  = ld_s__header
        i_s__path = cd_v__path.

  endloop.

*    importing
*      e_v__path       = <ld_s__download_object>-path
*      e_v__mastername = <ld_s__download_object>-mastername
*      e_v__xmlname    = <ld_s__download_object>-xmlname
*      e_v__extsrcname = <ld_s__download_object>-extsrcname.

endmethod.
