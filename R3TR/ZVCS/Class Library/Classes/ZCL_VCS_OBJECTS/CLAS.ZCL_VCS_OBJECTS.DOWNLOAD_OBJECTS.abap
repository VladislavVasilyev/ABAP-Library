method download_objects.

  data
  : ld_s__object            type zvcst_s__download
  , ld_s__error             type ty_s__error_stack
  , lr_o__object            type ref to zcl_vcs_objects_stack
  , lr_o__handle            type ref to cl_abap_datadescr
  , ld_s__type              type zvcst_s__object
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
    call method lr_o__object->download( `c:\log1`).

  endloop.
endmethod.
