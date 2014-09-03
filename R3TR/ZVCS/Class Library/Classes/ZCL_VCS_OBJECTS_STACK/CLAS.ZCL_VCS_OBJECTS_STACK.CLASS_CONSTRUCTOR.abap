method class_constructor.

  data
  : lr_o__vcs_object      type ref to zcl_vcs_objects_stack
  , lr_o__descclass       type ref to cl_abap_classdescr
  , lr_o__desctype        type ref to cl_abap_typedescr
  , ld_v__clsname         type c length 30
  , ld_v__tyobject        type string
  , ld_v__tysource        type string
  , ld_v__pgmid           type pgmid
  , ld_s__stack          type zvcst_s__objects_stack
  .


  " create reestr object
  select  clsname
    from  vseoextend
    into  ld_v__clsname
    where refclsname = `ZCL_VCS_OBJECTS_STACK`.

      create object lr_o__vcs_object type (ld_v__clsname).

      check sy-subrc = 0.

      " set objects
      call method lr_o__vcs_object->get_type_object
        importing
          type     = ld_s__stack-type
          tysource = ld_v__tysource.

*----------------------------------------------------------------------*
*       CLASS ?=  CL_ABAP_CLASSD
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
      lr_o__descclass ?= cl_abap_classdescr=>describe_by_object_ref( lr_o__vcs_object ).

      call method lr_o__descclass->get_type(
            exporting p_name = ld_v__tysource
            receiving p_descr_ref = lr_o__desctype
            exceptions others = 1 ).

      ld_s__stack-object ?= lr_o__vcs_object.

      lr_o__vcs_object->gd_v__tyobject        = ld_v__tyobject.
      lr_o__vcs_object->gr_o__sourcehandle   ?= lr_o__desctype.

      insert ld_s__stack into table cd_t__stack.

  endselect.

endmethod.
