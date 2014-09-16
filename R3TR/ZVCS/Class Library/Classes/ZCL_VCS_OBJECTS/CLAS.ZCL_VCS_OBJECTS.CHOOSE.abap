method choose.

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

    if i_f__upload = abap_false.


      lr_o__object     ?= zcl_vcs_objects_stack=>get_object( <ld_s__stack>-type ).
      lr_o__handle     ?= lr_o__object->get_handle(  ).
      ld_s__object-type = ld_s__type.

      create data ld_s__object-xmlsource type handle lr_o__handle.
      assign ld_s__object-xmlsource->* to <ld_s__xmlsource>.

      refresh ld_s__object-txtnodepath.
      call method lr_o__object->read_objects_choose
        exporting
          i_v__form_name = i_v__form_name.



    else.
      lr_o__object     ?= zcl_vcs_objects_stack=>get_object( <ld_s__stack>-type ).

      call method lr_o__object->write_object_choose
        exporting
          i_v__form_name = i_v__form_name.
    endif.
  endloop.
*
*
*
*  loop at cd_t__reestr
*       assigning <ld_s__reestr>.
*
*    loop at zcl_vcs_objects_stack=>cd_t__task_stack
*         into ld_s__object-header
*         where pgmid = <ld_s__reestr>-system.
*
*      ld_s__type-pgmid   = <ld_s__reestr>-system.
*      ld_s__type-object  = ld_s__object-header-object.
*
*
*      check zcl_vcs_objects_stack=>check_type( ld_s__type ) = abap_true.
*
*      lr_o__object     ?= zcl_vcs_objects_stack=>get_object( ld_s__type ).
*      lr_o__handle     ?= lr_o__object->get_handle(  ).
*      ld_s__object-type = ld_s__type.
*
*      try.
*          create data ld_s__object-xmlsource type handle lr_o__handle.
*          assign ld_s__object-xmlsource->* to <ld_s__xmlsource>.
*
*          refresh ld_s__object-txtnodepath.
*          call method lr_o__object->read_objects_choose
*            exporting
*              i_v__form_name = i_v__form_name.
***              i_s__tadir     = ld_s__object-header
**            importing
**              e_s__source    = <ld_s__xmlsource>
**              e_t__txtsource = ld_s__object-txtnodepath.
*
**          insert ld_s__object into table zcl_vcs_objects_stack=>cd_t__objects_for_download.
*
*        catch zcx_vcs_objects_read into ld_s__error-cx_ref.
*          append ld_s__error to cd_t__error_stack.
*      endtry.
*    endloop.
*  endloop.





*  return.

*  types: begin of ty_s__checkobj_r3tr.
*  include type seoscokey.
*  types: checkbox(1) type  c
*         , index(4) type c
*         , end of ty_s__checkobj_r3tr.
*
*
*  types: begin of ty_s__checkobj_bpc.
*  include type zvcs_st__bpcdir.
*  types: checkbox(1) type  c
*         , index(4) type c
*         , end of ty_s__checkobj_bpc.
*
*
*  data
*  : ld_s__seldir             type ty_s__checkobj_r3tr
*  , ld_t__seltadir           type standard table of ty_s__checkobj_r3tr
*  , ld_t__selbpcdir          type standard table of ty_s__checkobj_bpc
*  , ld_s__selbpcdir          type ty_s__checkobj_bpc
*  , functions                type standard table of svalp
*  , w_function               like line of functions
*  , ld_v__index              type i
*  , ld_v__selname            type help_info-tabname
*  , ld_s__type               type zvcst_s__object
*  .
*
*  field-symbols
*  : <ld_s__bpcdir>           type zvcst_s__tadir
*  , <ld_s__tadir>            type zvcst_s__tadir
*  , <ld_s__uploadobj>        type zvcst_s__r3tr_objupload
*  , <ld_s__task_stack>       type zvcst_s__tadir
*  , <ld_t__seltable>         type standard table
*  , <ld_s__seltable>         type any
*  , <ld_v__index>            type clike
*  , <ld_f__check>            type clike
*  , <ld_s__reestr>           type  ty_s__reestr
*  , <ld_s__upload>           type zvcst_s__upload
*  .
*
*  if not zcl_vcs_objects_stack=>cd_t__task_stack is initial.
*
*    move
*    : 'OK'            to w_function-func_name
*    , sy-cprog        to w_function-prog_name
*    , i_v__form_name  to w_function-form_name.
*    append w_function to functions.
*
*    loop at zcl_vcs_objects_stack=>cd_t__task_stack
*         assigning <ld_s__task_stack>.
*
*      <ld_s__task_stack>-id = ld_v__index = sy-tabix.
*
*      ld_s__type-pgmid  = <ld_s__task_stack>-pgmid.
*      ld_s__type-object = <ld_s__task_stack>-object.
*
*
*      if not zcl_vcs_objects_stack=>check_type( ld_s__type ) = abap_true.
*        delete zcl_vcs_objects_stack=>cd_t__task_stack.
*        continue.
*      endif.
*
*      case <ld_s__task_stack>-pgmid.
*        when zvcsc_bpc.
*
*          ld_s__selbpcdir-index       = ld_v__index.
*          ld_s__selbpcdir-type        = <ld_s__task_stack>-object.
*          ld_s__selbpcdir-component   = <ld_s__task_stack>-obj_name.
*          ld_s__selbpcdir-appset      = <ld_s__task_stack>-appset.
*          ld_s__selbpcdir-application = <ld_s__task_stack>-application.
*          append ld_s__selbpcdir to ld_t__selbpcdir.
*          sort  ld_t__selbpcdir.
*
*        when zvcsc_r3tr.
*
*          ld_s__seldir-index = ld_v__index.
*          ld_s__seldir-clsname = <ld_s__task_stack>-object.
*          ld_s__seldir-cmpname = <ld_s__task_stack>-obj_name.
*          ld_s__seldir-sconame = <ld_s__task_stack>-devclass.
*          append ld_s__seldir to ld_t__seltadir.
*
*      endcase.
*    endloop.
*
*    loop at cd_t__reestr
*        assigning <ld_s__reestr>.
*      case <ld_s__reestr>-system.
*        when zvcsc_bpc.
*          ld_v__selname = 'ZVCS_ST__BPCDIR'.
*          assign ld_t__selbpcdir to <ld_t__seltable>.
*        when zvcsc_r3tr.
*          ld_v__selname = 'SEOSCOKEY'.
*          assign ld_t__seltadir  to <ld_t__seltable>.
*      endcase.
*
*      check lines( <ld_t__seltable> ) > 0.
*
*      cd_f__popup = abap_true.
*      call function 'POPUP_GET_SELECTION_FROM_LIST'
*        exporting
*          display_only                 = 'X'
*          table_name                   = ld_v__selname
*          title_bar                    = 'Selection'
*        tables
*          list                         = <ld_t__seltable>
*          functions                    = functions
*        exceptions
*          no_tablefields_in_dictionary = 1
*          no_table_structure           = 2
*          no_title_bar                 = 3
*          others                       = 4.
*
*      if sy-subrc <> 0.
*        message id sy-msgid type 'E' number sy-msgno
*                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*      endif.
*
*      if cd_f__popup ne space.
*        free
*        : ld_t__seltadir
**      , cd_t__bpcdir
*        .
*        message s000(38) with 'Canceled'.
*      endif.
*
*
*      loop at <ld_t__seltable>
*           assigning <ld_s__seltable>.
*
*        assign component `CHECKBOX` of structure <ld_s__seltable> to <ld_f__check>.
*        assign component `INDEX`    of structure <ld_s__seltable> to <ld_v__index>.
*
*        if <ld_f__check> <> abap_true.
*          ld_v__index = <ld_v__index>.
*          delete zcl_vcs_objects_stack=>cd_t__task_stack where id = ld_v__index.
*        endif.
*      endloop.
*    endloop.
*  endif.
*
*  check i_f__upload = abap_true.
*
*  loop at zcl_vcs_objects_stack=>cd_t__objects_for_upload
*      assigning <ld_s__upload>.
*
*    read table zcl_vcs_objects_stack=>cd_t__task_stack with key
*                              PGMID      = <ld_s__upload>-TYPE-pgmid
*                              object     = <ld_s__upload>-TYPE-object
*                              obj_name   = <ld_s__upload>-header-obj_name
*                              transporting no fields .
*
*    check sy-subrc <> 0.
*    delete zcl_vcs_objects_stack=>cd_t__objects_for_upload.
*  endloop.
endmethod.
