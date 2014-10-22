*---------------------------------------------------------------------*
*       MODULE SET_UPDATE_FLAG                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE set_update_flag.                                     "#EC *

  DATA: lb_als TYPE REF TO IF_EX_VIM_ALS_BADI.

  CHECK status-action NE anzeigen AND  "ignore wrong setted requestflags
        status-action NE transportieren. "due to individual F4 modules
  IF x_header-delmdtflag NE space AND
     status-type EQ einstufig AND
     status-mode EQ list_bild.         "only on list screen
* check if dates entered properly
    IF ( <vim_new_begdate> EQ vim_init_date OR
       <vim_enddate_mask> EQ vim_init_date ).
      MESSAGE e127(sv)."Bitte den Gültigkeitsbereich eingrenzen
    ENDIF.
    CLEAR sy-subrc.
    IF status-action EQ kopieren AND vim_special_mode NE vim_delimit.
      READ TABLE vim_copied_indices WITH KEY level = vim_copy_call_level
                                                ex_ix = nextline."#EC *
    ENDIF.
    IF sy-subrc NE 0 OR       "copy mode and entry not yet processed or
       ( status-action EQ hinzufuegen AND <xact> EQ leer ).  "new entry
      neuer = 'J'.
      IF x_header-guidflag <> space.
        PERFORM vim_make_guid using space.
      ENDIF.
      IF x_header-frm_on_new NE space.
        PERFORM (x_header-frm_on_new) IN PROGRAM.           "#EC *
      ENDIF.
      PERFORM check_key.
      neuer = 'N'.
    ENDIF.
  ENDIF.
  IF x_header-bastab NE space AND x_header-texttbexst NE space.
    TRANSLATE <status>-upd_flag USING ' ETX'.
  ELSE.
    <status>-upd_flag = 'X'.
  ENDIF.
* check in non key field entries violate selection conditions
  PERFORM check_nonkey.
* perform ALS if it is enabled
  CALL METHOD cl_exithandler=>get_instance
    EXPORTING
      null_instance_accepted        = seex_false
      exit_name                     = 'VIM_ALS_BADI'
    CHANGING
      instance                      = lb_als
    EXCEPTIONS
      no_reference                  = 1
      no_interface_reference        = 2
      no_exit_interface             = 3
      class_not_implement_interface = 4
      single_exit_multiply_active   = 5
      cast_error                    = 6
      exit_not_existing             = 7
      data_incons_in_exit_managem   = 8
      OTHERS                        = 9.
  IF sy-subrc NE 0.
    EXIT.
  ELSE.
    CALL METHOD lb_als->enable_als
      EXPORTING
        view_name   = x_header-viewname
      IMPORTING
        als_enabled = als_enabled.

    IF als_enabled = 'X' AND x_header-bastab EQ space.
      PERFORM set_als_update_flag.
    ENDIF.
  ENDIF.

ENDMODULE.                    "set_update_flag

*---------------------------------------------------------------------*
*       MODULE DETAIL_EXIT_COMMAND                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE detail_exit_command.                                "#EC *
  PERFORM detail_exit_command.
ENDMODULE.                    "detail_exit_command

*---------------------------------------------------------------------*
*       MODULE LISTE_EXIT_COMMAND                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE liste_exit_command.                                  "#EC *
  PERFORM liste_exit_command.
ENDMODULE.                    "liste_exit_command

*---------------------------------------------------------------------*
*       MODULE LISTE_AFTER_LOOP                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE liste_after_loop.                                   "#EC *
** Table-control !!!
  IF vim_tabctrl_active NE space.
    IF nextline NE <vim_tctrl>-top_line.
      nextline = <vim_tctrl>-top_line.
    ENDIF.
  ENDIF.
** Table-control !!!
  IF destpage NE 0.
    nextline = destpage. CLEAR destpage.
  ENDIF.
* IF TEMPORAL_DELIMITATION_HAPPENED NE SPACE.
  IF vim_special_mode NE vim_upgrade AND
     vim_special_mode NE vim_delimit AND
     temporal_delimitation_happened NE space.
    PERFORM after_temporal_delimitation.
    CLEAR: temporal_delimitation_happened, vim_old_viewkey.
    TRANSLATE vim_no_mainkey_exists USING vim_no_mkey_not_procsd_patt.
  ENDIF.
  IF function IN mark_functions AND mark_extract EQ 0.
    MESSAGE s026(sv).                  "Bitte vorher Einträge markieren
    LEAVE SCREEN.
  ENDIF.
  PERFORM update_status.
  IF vim_single_entry_function EQ 'INS' AND
     vim_single_entry_ins_key_input NE space AND
     status-action EQ hinzufuegen.
    PERFORM vim_single_entry_fill_sellist.
  ENDIF.
  CLEAR: vim_next_screen, vim_leave_screen.
  CASE function.
    WHEN 'ADDR'.
      PERFORM liste_address_maintain.
    WHEN 'AEND'.
      PERFORM anzg_to_aend.
    WHEN 'ALCO'.
      PERFORM selektiere USING transportieren.
    WHEN 'ALMK'.
      PERFORM selektiere USING markiert.
    WHEN 'ALNC'.
      PERFORM selektiere USING space.
    WHEN 'ALOE'.
      PERFORM selektiere USING geloescht.
    WHEN 'ALNW'.
      PERFORM selektiere USING neuer_eintrag.
    WHEN 'ANZG'.
      PERFORM aend_to_anzg.
      vim_next_screen = 0. vim_leave_screen = 'X'.
    WHEN 'ATAB'.
      vim_next_screen = 0. vim_leave_screen = 'X'.
    WHEN 'BACK'.
      IF status-mode EQ list_bild AND status-data EQ gesamtdaten OR
        vim_single_entry_function NE space.
        vim_next_screen = 0. vim_leave_screen = 'X'.
      ELSE.
        PERFORM liste_back.
      ENDIF.
    WHEN 'BCCH'.                       "change fix bc-set fields
      PERFORM vim_chng_fix_flds.
    WHEN 'BCSH'.                        " show fix bc-set fields
      PERFORM vim_bc_show_fix_flds.
    WHEN 'BCON'.
      PERFORM selektiere USING bcset_only. "show only data from bcset
    WHEN 'CMPO'.
      PERFORM upgrade USING 'O'.
    WHEN 'CMPR'.
      PERFORM upgrade USING 'R'.
    WHEN 'COMP'.
      PERFORM upgrade USING space.
    WHEN 'DELE'.
      PERFORM loeschen.
      IF replace_mode NE space.
        <status>-mk_to = mark_total.
        <status>-mk_xt = mark_extract.
        vim_next_screen = 0. vim_leave_screen = 'X'.
      ENDIF.
    WHEN 'DELM'.
      PERFORM delimitation.
    WHEN 'DETM'.                       "UFdetail
      PERFORM detail_markierte.
    WHEN 'DETA'.
      PERFORM detailbild.
    WHEN 'ENDE'.
      vim_next_screen = 0. vim_leave_screen = 'X'.
    WHEN 'EXPA'.
*     PERFORM TIME_DEPENDENT_DISPLAY_MODIF.
      IF x_header-delmdtflag EQ space.
        MESSAGE s001(sv). EXIT.
      ENDIF.
      PERFORM (vim_time_dep_dpl_modif_form) IN PROGRAM.     "#EC *
    WHEN 'FDOC'.                       "HW Functiondocu
      PERFORM show_function_docu.
*    WHEN 'GPRF'.                       "UF Profile
* choose profile
*      CLEAR: <status>-prof_found, vim_pr_records.
*      PERFORM get_profiles USING <status>-prof_found.
    WHEN 'KOPE'.
      counter = 0.
      PERFORM kopiere.
    WHEN 'KOPF'.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN 'LANG'.                       "SW Texttransl
      PERFORM vim_set_languages.
    WHEN 'MKAL'.
      PERFORM markiere_alle USING markiert.
    WHEN 'MKBL'.
      PERFORM markiere_block.
    WHEN 'MKEZ'.
      PERFORM liste_markiere.
    WHEN 'MKLO'.
      PERFORM markiere_alle USING nicht_markiert.
    WHEN 'NEWL'.
      PERFORM hinzufuegen.
    WHEN 'NEXT'.
      PERFORM naechster.
    WHEN 'ORDR'.
      PERFORM order_administration.
    WHEN 'ORGI'.
      PERFORM original_holen.
    WHEN 'POSI'.
      PERFORM popup_positionieren.
    WHEN 'PREV'.
      PERFORM voriger.
    WHEN 'PRMO'.
* 4.6A: obsolete, left for individual status only
      PERFORM list_alv.
    WHEN 'PROT'.
      PERFORM logs_analyse.
    WHEN 'PRST'.
      PERFORM list_alv.
    WHEN 'P+  '.
      PERFORM blaettern.
    WHEN 'P-  '.
      PERFORM blaettern.
    WHEN 'P++ '.
      PERFORM blaettern.
    WHEN 'P-- '.
      PERFORM blaettern.
    WHEN 'REPL'.
      PERFORM replace.
    WHEN 'SAVE'.
      IF status-action EQ hinzufuegen.
*       SORT EXTRACT BY <VIM_EXTRACT_KEY>.  "not nec. anymore
        <status>-firstline = firstline = <status>-cur_line = l = 1.
      ENDIF.
      vim_next_screen = 0. vim_leave_screen = 'X'.
    WHEN 'SCRF'.
      PERFORM vim_sapscript_form_maint.
    WHEN 'SEAR'.
      PERFORM suchen.
    WHEN 'SELU'.
      PERFORM selektiere USING aendern.
*    WHEN 'SPRF'.                       "UF Profile
* show chosen profile
*      PERFORM get_profiles USING <status>-prof_found.
    WHEN 'TEXT'.                       "SW Texttransl
      PERFORM vim_multi_langu_text_maint.
    WHEN 'TREX'.
      MOVE geloescht TO corr_action.
      PERFORM update_corr.
      IF replace_mode NE space.
        <status>-mk_to = mark_total.
        <status>-mk_xt = mark_extract.
        vim_next_screen = 0. vim_leave_screen = 'X'.
      ENDIF.
    WHEN 'TRIN'.
      MOVE hinzufuegen TO corr_action.
      PERFORM update_corr.
      IF replace_mode NE space.
        <status>-mk_to = mark_total.
        <status>-mk_xt = mark_extract.
        vim_next_screen = 0. vim_leave_screen = 'X'.
      ENDIF.
    WHEN 'TRSP'.
      IF x_header-cursetting NE space AND
         x_header-flag EQ vim_transport_denied.
        x_header-flag = x_header-cursetting.
        TRANSLATE x_header-flag USING 'X YX'.
        MODIFY x_header INDEX 1.                            "#EC *
      ENDIF.
      vim_next_screen = 0. vim_leave_screen = 'X'.
    WHEN 'UNDO'.
*     PERFORM LISTE_ZURUECKHOLEN.
      PERFORM zurueckholen.
      IF replace_mode NE space.
        <status>-mk_to = mark_total.
        <status>-mk_xt = mark_extract.
        vim_next_screen = 0. vim_leave_screen = 'X'.
      ENDIF.
    WHEN 'UPRF'.                       "UF Profile
* activate chosen profile
*      PERFORM activate_profile CHANGING <status>-prof_found.
      message s175(SV).
    WHEN '    '.
      IF vim_single_entry_function EQ 'INS' AND
         status-action EQ hinzufuegen.
        PERFORM liste_back.
      ENDIF.
      IF replace_mode NE space.
        vim_next_screen = 0. vim_leave_screen = 'X'.
      ENDIF.
    WHEN OTHERS.
      IF vim_called_by_cluster NE space.
        CALL FUNCTION 'VIEWCLUSTER_NEXT_ACTION'
          IMPORTING
            leave_screen = vim_leave_screen
          CHANGING
            fcode        = function.
        IF vim_leave_screen NE space.
          vim_next_screen = 0.
        ENDIF.
      ENDIF.
  ENDCASE.
  IF vim_leave_screen NE space.
    CLEAR: vim_leave_screen, vim_act_dynp_view.
    SET SCREEN vim_next_screen. LEAVE SCREEN.
  ENDIF.
ENDMODULE.                    "liste_after_loop

*---------------------------------------------------------------------*
*       MODULE LISTE_BEFORE_LOOP                                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE liste_before_loop.                                   "#EC *
  GET CURSOR FIELD f LINE l OFFSET o.
  function = ok_code.
  CLEAR: ok_code, <status>-upd_flag.
  IF vim_special_mode EQ vim_delete.
    SET SCREEN 0. LEAVE SCREEN.
  ENDIF.
* PERFORM READ_TABLE USING FIRSTLINE.
  IF replace_mode EQ space.
*   SET PF-STATUS 'ERRORLIS'.
    PERFORM set_pf_status USING 'ERRORLIS'.
*    CLEAR <STATUS>-UPD_FLAG.
    neuer = 'N'.
    IF vim_called_by_cluster NE space.
      CALL FUNCTION 'VIEWCLUSTER_SET_OKCODE'
        EXPORTING
          ok_code = function.
    ENDIF.
  ENDIF.
ENDMODULE.                    "liste_before_loop

*---------------------------------------------------------------------*
*       MODULE DETAIL_PAI                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE detail_pai.                                          "#EC *
  CLEAR: vim_next_screen, vim_leave_screen.
  IF function EQ 'DETA'.                                    "GKPR - 0001009660
    CLEAR old_nl.                                           "GKPR - 0001009660
  ENDIF.                                                    "GKPR - 0001009660
  function = ok_code.
  PERFORM detail_pai.
  IF vim_leave_screen NE space.
    CLEAR: vim_leave_screen, vim_act_dynp_view.
    SET SCREEN vim_next_screen. LEAVE SCREEN.
  ENDIF.
ENDMODULE.                    "detail_pai

*---------------------------------------------------------------------*
*       MODULE DETAIL_SET_PFSTATUS                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE detail_set_pfstatus.                                 "#EC *
  IF replace_mode EQ space.
*   SET PF-STATUS 'ERROR'.
    PERFORM set_pf_status USING 'ERROR'.
  ENDIF.
  IF x_header-delmdtflag NE space.
    EXPORT ok_code TO MEMORY ID vim_memory_id_2.            "#EC *
  ENDIF.
ENDMODULE.                    "detail_set_pfstatus

*---------------------------------------------------------------------*
*       MODULE LISTE_MARK_CHECKBOX                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE liste_mark_checkbox.                                "#EC *
  CHECK <xact> NE leer.
  CLEAR answer.
  IF vim_marked NE space AND <xmark> NE markiert.
    MOVE: markiert TO <xmark>, markiert TO answer.
    ADD: 1 TO mark_total, 1 TO mark_extract.
  ELSEIF vim_marked EQ space AND <xmark> NE nicht_markiert.
    MOVE: nicht_markiert TO <xmark>, markiert TO answer.
    IF mark_total GT 0.             "HCG must not get negative HW785631
      SUBTRACT: 1 FROM mark_total.
    ENDIF.
    IF mark_extract GT 0.           "HCG Must not get negative HW785631
      SUBTRACT: 1 FROM mark_extract.
    ENDIF.
  ENDIF.
  IF <status>-upd_flag EQ space AND answer NE space.  "only mouse mark
    MOVE nextline TO index.
    READ TABLE total WITH KEY <vim_xextract_key> BINARY SEARCH."#EC *
    PERFORM vorhanden.
  ENDIF.
  CLEAR answer.
ENDMODULE.                    "liste_mark_checkbox

*---------------------------------------------------------------------*
*       MODULE LISTE_INIT_WORKAREA                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE liste_init_workarea.                                 "#EC *
  IF replace_mode NE space.
    IF vim_special_mode EQ vim_upgrade.
      <table2_x> = <vim_xtotal>.
    ELSEIF vim_special_mode EQ vim_replace.
      CLEAR <replace_field>.
    ENDIF.
  ENDIF.
  PERFORM move_extract_to_view_wa.
  MOVE nextline TO exind.
  CLEAR vim_pr_activating.
  IF <xact> = profil_hinzufuegen.      "UFprofiles begin
* Set update flags
    <table2_x> = <initial_x>.
    <xact> = leer.
    vim_pr_activating = 'X'.
    MODIFY extract INDEX sy-stepl.                          "#EC *
    IF x_header-bastab NE space AND x_header-texttbexst NE space.
      <status>-upd_flag = 'E'.
    ELSE.
      <status>-upd_flag = 'X'.
    ENDIF.
  ENDIF.                               "UFprofiles end
  CLEAR: vim_key_alr_checked, vim_keyrange_alr_checked.
ENDMODULE.                    "liste_init_workarea

*---------------------------------------------------------------------*
*       MODULE LISTE_UPDATE_LISTE                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE liste_update_liste.                                  "#EC *
  CHECK status-action NE anzeigen.
  CHECK status-action NE transportieren.
  CHECK status-delete NE geloescht.
  IF ok_code NE 'IGN '.
    IF x_header-ptfrkyexst NE space.
      PERFORM consistency_prt_frky_fields
                                   USING vim_show_consistency_alert.
    ENDIF.
    CASE status-action.                "UFprofile
      WHEN kopieren.                   "UFprofile
        READ TABLE vim_copied_indices WITH KEY level = vim_copy_call_level
                                                     ex_ix = nextline."#EC *
        IF sy-subrc EQ 0.              "entry alr. processed
          <xact> = neuer_eintrag.
          PERFORM update_tab.
        ELSE.
          PERFORM kopiere_eintrag USING <orig_key>.
        ENDIF.
      WHEN OTHERS.
        PERFORM update_tab.
    ENDCASE.
  ELSE.
    PERFORM set_pf_status USING 'ERRORLIS'.
  ENDIF.
  IF replace_mode EQ space.
    CLEAR ok_code.
  ENDIF.
ENDMODULE.                    "liste_update_liste

*---------------------------------------------------------------------*
*       MODULE TEMP_DELIMITATION                                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE temp_delimitation.                                   "#EC *
  DATA: td_addr_safe LIKE adrc-addrnumber.                  "#EC *
  CHECK x_header-delmdtflag NE space.
* set update flag (if begdate not in the set_update_flag-chain)
  CHECK status-action NE anzeigen AND  "ignore wrong set requestflags
        status-action NE transportieren. "due to individual F4 modules
  IF x_header-bastab NE space AND x_header-texttbexst NE space.
    <status>-upd_flag = 'E'.
  ELSE.
    <status>-upd_flag = 'X'.
  ENDIF.
* process delimitation
  vim_begdate_entered = 'X'.
  PERFORM temporal_delimitation.
  IF temporal_delimitation_happened EQ 'X' AND
     x_header-delmdtflag EQ 'B'.
    IF x_header-adrnbrflag = space.
      MOVE: <vim_xtotal_key> TO <f1_x>,
            <vim_begdate> TO <vim_new_begdate>.
    ELSE.
      MOVE: <address_number> TO td_addr_safe,
            <vim_xtotal_key> TO <f1_x>,
            td_addr_safe TO <address_number>,
            <vim_begdate> TO <vim_new_begdate>.
    ENDIF.
  ENDIF.
ENDMODULE.                    "temp_delimitation

*---------------------------------------------------------------------*
*       MODULE CONSISTENCY                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE consistency.                                        "#EC *
  EXIT.
* CHECK STATUS-MODE NE DETAIL_BILD.
* PERFORM CONSISTENCY_PRT_FRKY_FIELDS USING 'X'.
ENDMODULE.                             "consistency

*&---------------------------------------------------------------------*
*&      Module  VCL_HELP_VALUES  INPUT
*&---------------------------------------------------------------------*
* Modul zum Ereignis 'Process On Value-Request' innerhalb der          *
* Viewcluster-Pflege:
* Realisierung von F4 auf ein Feld, dessen Prüftabelle im selben
* Viewcluster gepflegt wird.
*----------------------------------------------------------------------*
MODULE vcl_help_values INPUT.                               "#EC *
  DATA: vcl_event(3) .
  CLEAR: f, vim_object, vim_objfield.
* POV-Module, die an List-Boxen hängen, werden schon zum Zeitpunkt
* CONTROL OUT gerufen. Hier kann das betroffene Feld nicht über
* die Cursor-Position ermittelt werden.
  CALL 'DY_GET_DYNPRO_EVENT' ID 'EVENT' FIELD vcl_event.                "#EC CI_CCALL
  IF sy-subrc = 0 AND vcl_event = 'OUT'.
*   Aufruf zum Zeitpunkt Control Output
    MESSAGE i538(sv) WITH vim_calling_cluster view_name.
    EXIT.
  ENDIF.

  IF status-mode = 'L'.                " Listbild
    GET CURSOR FIELD f LINE l.
  ELSE.                                " Detailbild
    GET CURSOR FIELD f.
  ENDIF.
  SPLIT f AT '-' INTO vim_object vim_objfield.
  IF vim_objfield IS INITIAL.
    MESSAGE s084(sv).
  ELSE.
    CALL FUNCTION 'VIEWCLUSTER_HELP_VALUES_NEW'
      EXPORTING
        object    = vim_object
        fieldname = vim_objfield
      EXCEPTIONS
        OTHERS    = 1.
    IF sy-subrc <> 0.
      MESSAGE s084(sv).
    ENDIF.
  ENDIF.
ENDMODULE.                             " VCL_HELP_VALUES  INPUT
