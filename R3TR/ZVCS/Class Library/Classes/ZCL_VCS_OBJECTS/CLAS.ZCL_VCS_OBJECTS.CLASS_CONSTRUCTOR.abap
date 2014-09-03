method class_constructor.

  data
  : lr_o__vcs_object      type ref to zcl_vcs_objects
  , lr_o__descclass       type ref to cl_abap_classdescr
  , lr_o__desctype        type ref to cl_abap_typedescr
  , ld_v__clsname         type c length 30
  , ld_v__tyobject        type string
  , ld_v__tysource        type string
  , ld_s__reestr          type ty_s__reestr
  .

  " create reestr object
  ld_s__reestr-system = zvcsc_r3tr.
  insert ld_s__reestr into table cd_t__reestr.

  ld_s__reestr-system = zvcsc_bpc.
  insert ld_s__reestr into table cd_t__reestr.

endmethod.
