method create.

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
    call method lr_o__object->create_object( ).

  endloop.












**  data
**  : lr_o__object    type ref to zcl_vcs_objects_stack
**  , ld_s__type      type zvcst_s__object
**  , ld_s__error     type ty_s__error_stack
**  , ld_s__message   type ty_s__create
**  .
**
**  field-symbols
**  : <ld_s__object> type zvcst_s__upload
**  , <ld_s__source> type any
**  .

**  loop at zcl_vcs_objects_stack=>cd_t__stack assigning <ld_s__stack>.
**
**    lr_o__object     ?= zcl_vcs_objects_stack=>get_object( <ld_s__stack>-type ).
**    lr_o__handle     ?= lr_o__object->get_handle(  ).
**    ld_s__object-type = ld_s__type.
**
**    create data ld_s__object-xmlsource type handle lr_o__handle.
**    assign ld_s__object-xmlsource->* to <ld_s__xmlsource>.
**
**    refresh ld_s__object-txtnodepath.
**    call method lr_o__object->download( `c:\log1`).
**
**  endloop.



*  loop at zcl_vcs_objects_stack=>cd_t__objects_for_upload
*       assigning <ld_s__object>.
*
*    check zcl_vcs_objects_stack=>check_type( <ld_s__object>-type ) = abap_true.
*    lr_o__object ?= zcl_vcs_objects_stack=>get_object( <ld_s__object>-type ).
*
*    assign <ld_s__object>-xmlsource->* to <ld_s__source>.
*
*    try.
*        call method lr_o__object->create_object
*          exporting
*            i_r__source = <ld_s__source>
*            i_s__tadir  = <ld_s__object>-header.
*
*        ld_s__message-pgmid = <ld_s__object>-header-pgmid.
*        ld_s__message-type  = <ld_s__object>-header-object.
*        ld_s__message-name  = <ld_s__object>-header-obj_name.
*
*        append ld_s__message to cd_t__message_create.
*
*      catch zcx_vcs_objects_create into ld_s__error-cx_ref.
*        append ld_s__error to cd_t__error_stack.
*    endtry.
*
*  endloop.

endmethod.
