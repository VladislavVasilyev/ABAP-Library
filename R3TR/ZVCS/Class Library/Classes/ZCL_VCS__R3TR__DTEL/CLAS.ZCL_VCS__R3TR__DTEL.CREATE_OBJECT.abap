method CREATE_OBJECT.

  data
   : lr_x__call_module_error type ref to zcx_vcs__call_module_error
   , ld_v__name type string
   , ld_s__dtel type ty_s__dtel
   .

  ld_s__dtel  = i_r__source.


*--------------------------------------------------------------------*
* CHECK EXISTS
*--------------------------------------------------------------------*
  select count( * ) from dd04l
             where rollname eq ld_s__dtel-name.
  if sy-subrc eq 0.
    raise exception type zcx_vcs_objects_create__r3tr
          exporting textid = zcx_vcs_objects_create__r3tr=>cx_already_exists
                    obj_name = i_s__tadir-obj_name
                    object = i_s__tadir-object.
  endif.
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* CREATE TYPES TABLE
*--------------------------------------------------------------------*
  try.
      call method zcl_vcs_r3tr___lib__ddif=>ddif_dtel_put
        exporting
          name     = ld_s__dtel-name
          dd04v_wa = ld_s__dtel-dd04v_wa.

      call method zcl_vcs_r3tr___lib__ddif=>ddif_dtel_activate
       exporting
         name              = ld_s__dtel-name
*       PRID              = -1
*     IMPORTING
*       RC                =
         .

      concatenate zvcsc_r3tr_type-dtel ld_s__dtel-name into ld_v__name.

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
      raise exception type zcx_vcs_objects_create__r3tr
            exporting obj_name = i_s__tadir-obj_name
                      object = i_s__tadir-object
                      previous = lr_x__call_module_error.
  endtry.


endmethod.
