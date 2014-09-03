method READ.

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
  .

  loop at cd_t__reestr
       assigning <ld_s__reestr>.

    loop at zcl_vcs_objects_stack=>cd_t__task_stack
         into ld_s__object-header
         where pgmid = <ld_s__reestr>-system.

      ld_s__type-pgmid   = <ld_s__reestr>-system.
      ld_s__type-object  = ld_s__object-header-object.


      check zcl_vcs_objects_stack=>check_type( ld_s__type ) = abap_true.

      lr_o__object     ?= zcl_vcs_objects_stack=>get_object( ld_s__type ).
      lr_o__handle     ?= lr_o__object->get_handle(  ).
      ld_s__object-type = ld_s__type.

      try.
          create data ld_s__object-xmlsource type handle lr_o__handle.
          assign ld_s__object-xmlsource->* to <ld_s__xmlsource>.

          refresh ld_s__object-txtnodepath.
          call method lr_o__object->read_object
            exporting
              i_s__tadir     = ld_s__object-header
            importing
              e_s__source    = <ld_s__xmlsource>
              e_t__txtsource = ld_s__object-txtnodepath.

          insert ld_s__object into table zcl_vcs_objects_stack=>cd_t__objects_for_download.

        catch zcx_vcs_objects_read into ld_s__error-cx_ref.
          append ld_s__error to cd_t__error_stack.
      endtry.
    endloop.
  endloop.

endmethod.
