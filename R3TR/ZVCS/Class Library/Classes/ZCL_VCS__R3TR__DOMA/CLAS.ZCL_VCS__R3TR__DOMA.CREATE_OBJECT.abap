method create_object.

  data
  : lr_x__call_module_error type ref to zcx_vcs__call_module_error
  , ld_v__name type string
  , ld_s__doma type ty_s__doma
  .

  ld_s__doma = i_r__source.


*--------------------------------------------------------------------*
* CHECK EXISTS
*--------------------------------------------------------------------*
  select count( * ) from dd01l
             where domname eq ld_s__doma-name.
  if sy-subrc eq 0.
    raise exception type zcx_vcs_objects_create__r3tr
      exporting
        textid     = zcx_vcs_objects_create__r3tr=>cx_already_exists
        object     = i_s__tadir-object
        obj_name   = i_s__tadir-obj_name.
  endif.
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* CREATE TYPES TABLE
*--------------------------------------------------------------------*
  try.
      call method zcl_vcs_r3tr___lib__ddif=>ddif_doma_put
        exporting
          name      = ld_s__doma-name
          dd01v_wa  = ld_s__doma-dd01v_wa
          dd07v_tab = ld_s__doma-dd07v_tab.

      call method zcl_vcs_r3tr___lib__ddif=>ddif_ttyp_activate
       exporting
         name              = ld_s__doma-name
*       PRID              = -1
*     IMPORTING
*       RC                =
         .

      concatenate zvcsc_r3tr_type-doma ld_s__doma-name into ld_v__name.

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
      raise exception type zcx_vcs_objects_create  "zcx_vcs_r3tr_objects_create
            exporting obj_name = i_s__tadir-obj_name
                      object = i_s__tadir-object
                      previous = lr_x__call_module_error.
  endtry.

endmethod.
