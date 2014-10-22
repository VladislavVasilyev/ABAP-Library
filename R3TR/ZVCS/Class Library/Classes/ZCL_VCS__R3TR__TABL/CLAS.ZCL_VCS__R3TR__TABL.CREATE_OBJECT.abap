method CREATE_OBJECT.

  data
  : lr_x__call_module_error type ref to zcx_vcs__call_module_error
  , ld_v__name type string.

  field-symbols
  : <ld_s__tabl>      type ty_s__tabl
  .
return.
  assign i_r__source->* to <ld_s__tabl>.

*--------------------------------------------------------------------*
* CHECK EXISTS
*--------------------------------------------------------------------*
  select count( * ) from dd02l
             where tabname eq <ld_s__tabl>-name
             and ( tabclass eq zvcsc_tabclass_type-inttab
             or    tabclass eq zvcsc_tabclass_type-transp ).

  if sy-subrc = 0.
*    raise exception type zcx_vcs_objects_create__r3tr
*          exporting textid = zcx_vcs_objects_create__r3tr=>cx_already_exists
*                    obj_name = i_s__tadir-obj_name
*                    object = i_s__tadir-object.
  endif.
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* CREATE TABLE
*--------------------------------------------------------------------*
  try.
      call method zcl_vcs_r3tr___lib__ddif=>ddif_tabl_put
        exporting
          name      = <ld_s__tabl>-name
          dd02v_wa  = <ld_s__tabl>-dd02v_wa
          dd09l_wa  = <ld_s__tabl>-dd09l_wa
          dd03p_tab = <ld_s__tabl>-dd03p_tab
          dd05m_tab = <ld_s__tabl>-dd05m_tab
          dd08v_tab = <ld_s__tabl>-dd08v_tab
          dd35v_tab = <ld_s__tabl>-dd35v_tab
          dd36m_tab = <ld_s__tabl>-dd36m_tab.

      call method zcl_vcs_r3tr___lib__ddif=>ddif_tabl_activate
        exporting
          name = <ld_s__tabl>-name.

      concatenate zvcsc_r3tr_type-tabl <ld_s__tabl>-name into ld_v__name.

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
