*&---------------------------------------------------------------------*
*& Report  ZPR_CVS_TEST
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZPR_VCS_TEST.

*data zcl_vcs__process type ref to zcl_vcs_r3tr_process .
*data cx type ref to cx_root.
*data ttadir type standard table of tadir.
*data: flag_popup_abg.
*
*create object zcl_vcs__process .
*
*data text1 type string.
*
*select *
*  from tadir
*  into table ttadir where
*      pgmid    = `R3TR`  and
*      obj_name = `ZIF_VCS_R3TR_PROCESS1` and
*      object   = `INTF` "and
**     devclass = `ZVCS`
*  .
*
*break-point.
*
*try.
*    data
*    : i_t__object type  zvcst_t__r3tr_obj
*    , i_s__object type  zvcst_s__r3tr_obj
*    , i_s__path   type  zvcst_s__path
*    .
*    i_s__object-pgid = `R3TR`.
*    i_s__object-name = `ZVCS`.
*    i_s__ob = `DEVC`.
*    append i_s__object to i_t__object.
*
*    i_s__object-name = `ZCL_BD00_APPLICATION`.
*    i_s__object-type = `CLAS`.
*    append i_s__object to i_t__object.
*
*    i_s__object-name = `ZBD00_MODE_ADD_LINE`.
*    i_s__object-type = `DTEL`.
*    append i_s__object to i_t__object.
*
*    i_s__path-path = `C:\temp\`.
*    i_s__path-f_sys = `X`.
*    i_s__path-f_pac = `X`.
*    i_s__path-f_dir = `X`.
*    i_s__path-f_ele = `X`.
*
*    zcl_vcs_r3tr_objects=>set_task_download( i_t__bject = i_t__object i_s__path = i_s__path ).
*
*
*    zcl_vcs__process->master_download( i_t__object = i_t__object
*                                       i_s__path   = i_s__path
*                                      ).
*
*
*
*  catch zcx_vcs__call_module_error into cx.
*
*    text1 = cx->get_text( ).
**  write
*    break-point.
*endtry.
*
**zcl_vcs__process->download( i_v__path = `C:\temp\` ).
*
*return.
*
**zcl_vcs__process->upload( i_v__directory = `C:\temp\` ).
*
**zcl_vcs__process->create( ).
*
**zcl_vcs__process->write_message( ).
*
*
*
*form auswahl_download
*tables selection structure shvalue.
*
** Funktion wird dynamisch aufgerufen
*  move space to flag_popup_abg.
*
*endform.                    "auswahl_download
