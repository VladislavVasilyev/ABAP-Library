method CREATE_OBJECT.

  data
  : ld_v__name              type sobj_name
  , lr_x__call_module_error type ref to zcx_vcs__call_module_error
  .

  field-symbols
  : <ld_s__ttyp>            type ty_s__ttyp
  .
return.
  assign i_r__source->* to <ld_s__ttyp>.

*--------------------------------------------------------------------*
* CHECK EXISTS
*--------------------------------------------------------------------*
  select count( * ) from dd40l
         where typename eq <ld_s__ttyp>-name.

  if sy-subrc = 0. " check
    ld_v__name = <ld_s__ttyp>-name.
*    raise exception type zcx_vcs_objects_create__r3tr
*          exporting textid = zcx_vcs_objects_create__r3tr=>cx_already_exists
*                    obj_name = i_s__tadir-obj_name
*                    object = i_s__tadir-object.
  endif.
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* CREATE TYPES TABLE
*--------------------------------------------------------------------*
  try.
      call method zcl_vcs_r3tr___lib__ddif=>ddif_ttyp_put
        exporting
          name      = <ld_s__ttyp>-name
          dd40v_wa  = <ld_s__ttyp>-dd40v_wa
          dd42v_tab = <ld_s__ttyp>-dd42v_tab.

      call method zcl_vcs_r3tr___lib__ddif=>ddif_ttyp_activate
       exporting
         name              = <ld_s__ttyp>-name
*       PRID              = -1
*     IMPORTING
*       RC                =
         .

      concatenate 'TTYP' <ld_s__ttyp>-name into ld_v__name.

      call method zcl_vcs_r3tr___tech=>rs_corr_insert
        exporting
          object          = ld_v__name
          object_class    = 'DICT'
          mode            = 'I'
          devclass        = i_s__tadir-devclass
          author          = i_s__tadir-author
          master_language = i_s__tadir-masterlang
          genflag         = i_s__tadir-genflag
          suppress_dialog = 'X'.
*      GLOBAL_LOCK                    = ' '
*      KORRNUM                        = 'BP0K910870'
*      USE_KORRNUM_IMMEDIATEDLY       = 'BP0K910870'
*      PROGRAM                        =
*      OBJECT_CLASS_SUPPORTS_MA       = ' '
*      EXTEND                         = ' '
*      MOD_LANGU                      = ' '
*     IMPORTING
*      DEVCLASS                       =
*      KORRNUM                        =
*      ORDERNUM                       =
*      NEW_CORR_ENTRY                 =
*      AUTHOR                         =
*      TRANSPORT_KEY                  =
*      NEW_EXTEND                     =

    catch zcx_vcs__call_module_error into lr_x__call_module_error.
*      raise exception type zcx_vcs_objects_create__r3tr
*            exporting obj_name = i_s__tadir-obj_name
*                      object = i_s__tadir-object
*                      previous = lr_x__call_module_error.
  endtry.

endmethod.
