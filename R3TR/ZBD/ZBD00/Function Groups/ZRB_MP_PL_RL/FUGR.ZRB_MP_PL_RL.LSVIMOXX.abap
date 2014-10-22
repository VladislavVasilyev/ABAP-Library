*---------------------------------------------------------------------*
*       MODULE DETAIL_INIT           OUTPUT                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE detail_init OUTPUT.                                                  "#EC *
  IF vim_called_by_cluster <> space.                        "SW CTRL ..
    PERFORM vim_vcldocking_control.
  ENDIF.                               ".. SW CTRL
  PERFORM vim_add_img_notices_pbo USING x_header-detail.
  PERFORM detail_init.
  IF ( replace_mode NE space AND
   neuer NE 'X' )         "no error in CHECK_KEY for timedep. objects
   OR vim_pr_activating <> space.                           "UF profile
    SUPPRESS DIALOG.
  ENDIF.
  PERFORM vim_modify_detail_screen.
ENDMODULE.                    "detail_init OUTPUT

*---------------------------------------------------------------------*
*       MODULE VIM_MODIF_DETAIL         OUTPUT                        *
*---------------------------------------------------------------------*
* Modifikation der Screen-Attribute für Tabstrip-Screens              *
*---------------------------------------------------------------------*
MODULE vim_modif_detail OUTPUT.                                               "#EC *
  PERFORM vim_modify_detail_screen.
ENDMODULE.                    "vim_modif_detail OUTPUT

*---------------------------------------------------------------------*
*       MODULE LISTE_SHOW_LISTE OUTPUT                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE liste_show_liste OUTPUT.                                                 "#EC *

** Table-control !!!   "bis der Fehler behoben ist
  IF vim_tabctrl_active NE space.
    IF <vim_tctrl>-current_line GT maxlines AND  "no more entries
       <xact> NE leer.                 "in EXTRACT and no new entry
      EXIT FROM STEP-LOOP.
    ENDIF.
  ENDIF.
** Table-control !!!
  looplines = sy-loopc.
  IF l GT looplines.
    counter = ( l - firstline ) DIV looplines + 1.
    DO counter TIMES.
      firstline = firstline + looplines - 1.
    ENDDO.
    MOVE firstline TO <status>-firstline.
    <status>-cur_line = l = l - firstline + 1.
    SET CURSOR FIELD f LINE l OFFSET o.
  ENDIF.
  IF vim_special_mode NE vim_upgrade AND
     status-action EQ hinzufuegen AND maxlines EQ 0 AND sy-stepl EQ 1.
    DESCRIBE TABLE extract.
    IF sy-tfill GT looplines.
      sy-tfill = looplines + 1.
      LOOP AT extract FROM sy-tfill.
        DELETE extract.
      ENDLOOP.
      nbr_of_added_dummy_entries = looplines.
    ENDIF.
  ENDIF.
* dataset locked by key-specific synchronizer lock?
  IF vim_sync_keyspec_check NE space.
    perform check_sync_key_lock using ' '
                                changing vim_sync_key_lock.
  ENDIF.
* dataset from BC-set? --> get field parameters
  CLEAR vim_set_from_bc_pbo.
  IF replace_mode = space AND status-action = aendern
   AND vim_bc_chng_allowed = space.  "fix field changeability forced
    READ TABLE vim_bc_entry_list INTO vim_bc_entry_list_wa
     WITH TABLE KEY viewname = x_header-maintview           "HCG 9/04
     keys = <vim_xextract_key>.
    IF sy-subrc = 0.
      vim_set_from_bc_pbo = 'X'.
    ENDIF.
  ENDIF.
  IF replace_mode NE space OR vim_special_mode EQ vim_delete."aro
    IF sy-stepl GT 1.
      EXIT FROM STEP-LOOP.
    ELSE.
      MOVE <vim_xtotal> TO <table2_x>.
    ENDIF.
  ENDIF.                                                    "aro
  index = exind = nextline.
  IF status-action EQ kopieren AND status-type EQ einstufig.
    READ TABLE vim_copied_indices WITH KEY level = vim_copy_call_level
                                           ex_ix = nextline.
    IF sy-subrc EQ 0.                  "entry already copied
      READ TABLE total INDEX vim_copied_indices-ix.
      extract = total. neuer = 'N'.
    ELSE.
      neuer = 'J'.
    ENDIF.
  ENDIF.
  PERFORM move_extract_to_view_wa.
  IF vim_special_mode EQ vim_delimit.
    MOVE vim_sval_tab-value TO <vim_new_begdate>.
  ENDIF.
  IF status-action EQ hinzufuegen AND status-type EQ einstufig AND
     neuer NE 'J' AND <xact> EQ leer.
    neuer = 'J'.
  ENDIF.
  IF <xmark> EQ markiert.
    MOVE 'X' TO vim_marked.
  ENDIF.
  LOOP AT SCREEN.
    CLEAR vim_modify_screen.
    SPLIT screen-name AT '-' INTO vim_object vim_objfield.
    IF ( status-action EQ anzeigen OR status-action EQ transportieren OR
            status-delete EQ geloescht ) AND screen-name NE 'VIM_MARKED'.
      screen-input = '0'. vim_modify_screen = 'X'.
    ELSEIF status-action EQ kopieren AND screen-name NE 'VIM_MARKED' AND
           screen-group1 NE 'KEY' AND function NE 'DELM'.   "864431
      screen-request = 1. vim_modify_screen = 'X'.
    ELSE.
      IF screen-group1 EQ 'KEY'.
        IF vim_tabctrl_active NE space AND screen-input EQ '0'.
          READ TABLE <vim_tctrl>-cols INTO vim_tc_cols
                                       WITH KEY
                                            screen-name = screen-name
                                       TRANSPORTING screen-required.
          IF sy-subrc EQ 0 AND
             screen-required NE vim_tc_cols-screen-required.
            screen-required = vim_tc_cols-screen-required.
            vim_modify_screen = 'X'.
          ENDIF.
        ENDIF.
        IF screen-required NE 0 AND screen-input NE '0'.
          screen-input = '0'. vim_modify_screen = 'X'.
        ENDIF.
        IF vim_single_entry_function EQ 'INS'.
          screen-request = 1. vim_modify_screen = 'X'.
        ENDIF.
* int. mess. 1757218/1999: no foreign-key check with copy
        IF status-action = kopieren.
          screen-request = 1. vim_modify_screen = 'X'.
        ENDIF.
* int. mess. 1757218/1999: no foreign-key check with copy: end
      ENDIF.
*     IF NEUER EQ 'J' OR STATUS-ACTION EQ KOPIEREN.
      IF neuer EQ 'J'.
        IF vim_special_mode NE vim_delimit AND
           screen-group1 EQ 'KEY' AND
           ( vim_single_entry_function NE 'INS' OR
               vim_single_entry_ins_key_input NE space ) AND
           ( x_header-existency NE 'M' OR
             screen-name EQ vim_enddate_name ).
          ADD 1 TO pos.
          IF pos EQ 1.
            SET CURSOR FIELD screen-name LINE sy-stepl.
          ENDIF.
          screen-input = '1'. vim_modify_screen = 'X'.
        ENDIF.
        IF screen-name EQ 'VIM_MARKED'.
          screen-input = '0'. vim_modify_screen = 'X'.
        ELSE.
          IF <xact> = profil_hinzufuegen.
            READ TABLE vim_pr_fields_wa-fields WITH TABLE KEY
             fieldname = vim_objfield TRANSPORTING NO FIELDS.
            IF sy-subrc = 0.
              screen-request = 1. vim_modify_screen = 'X'.
            ENDIF.
          ENDIF.
          IF vim_special_mode EQ vim_upgrade AND function NE 'DELE'.
            IF <status>-prof_found = vim_pr_into_view "UFprofiles begin
             AND status-action = hinzufuegen AND screen-group1 = 'KEY'.
              PERFORM set_profile_key_attributes USING vim_objfield
                                                 CHANGING screen-input
                                                      vim_modify_screen.
            ENDIF.                     "UFprofiles end
            screen-request = 1. vim_modify_screen = 'X'.
          ENDIF.
        ENDIF.
      ELSE.
        IF x_header-delmdtflag NE space AND
           x_header-existency EQ 'U' AND
           screen-name EQ vim_begdate_name.
          screen-input = '0'. vim_modify_screen = 'X'.
        ENDIF.
        IF f EQ space AND screen-name NE 'VIM_MARKED' AND
           screen-input EQ '1'.
          SET CURSOR FIELD screen-name LINE l.
          f = screen-name.
        ENDIF.
        IF replace_mode NE space.
          CASE vim_special_mode.
            WHEN vim_replace.
              IF screen-name EQ sel_field_for_replace_l.
                screen-request = 1. vim_modify_screen = 'X'.
              ENDIF.
            WHEN vim_upgrade.
              IF NOT function IN exted_functions AND
                 screen-name NE 'VIM_MARKED'.
                screen-request = 1. vim_modify_screen = 'X'.
              ENDIF.
              screen-input = '1'. vim_modify_screen = 'X'.
          ENDCASE.
        ELSE.
          IF vim_special_mode EQ vim_delete.
            screen-input = '0'. vim_modify_screen = 'X'.
          ENDIF.
* Dataset locked by key-specific synchronizer lock?
          IF vim_sync_key_lock NE space AND screen-group1 <> 'KEY' AND
                                            screen-name NE 'VIM_MARKED'.
            screen-input = 0.
            vim_modify_screen  = 'X'.
          ENDIF.
          IF vim_set_from_bc_pbo <> space AND screen-group1 <> 'KEY'.
* Dataset comes from BC-set -> check field parameter
            PERFORM vim_bc_logs_use USING    vim_objfield
                                             vim_bc_entry_list_wa
                                    CHANGING screen
                                             vim_modify_screen.
          ENDIF.
        ENDIF.                         "replace_mode <> space
      ENDIF.                           "neuer = 'J'
    ENDIF.                             "update mode
    IF <xmark> EQ markiert AND screen-name NE 'VIM_MARKED'.
      screen-intensified = 1. vim_modify_screen = 'X'.
    ENDIF.
    IF vim_special_mode EQ vim_delimit AND
       screen-name EQ vim_begdate_name.
      screen-request = 1. vim_modify_screen = 'X'.
    ENDIF.
*   IF X_HEADER-RDONLYFLAG = 'X' AND                      "Subviews ..
*      X_HEADER-MAINTVIEW <> X_HEADER-VIEWNAME.
    IF vim_objfield <> space AND vim_object = x_header-maintview.
      LOOP AT x_namtab WHERE viewfield = vim_objfield AND
                          ( texttabfld = space OR keyflag = space ).
        IF x_namtab-readonly = vim_hidden.
          screen-active = '0'. vim_modify_screen = 'X'.
        ELSEIF x_namtab-readonly = rdonly.
          screen-input = '0'. vim_modify_screen = 'X'.
        ENDIF.
        EXIT.
      ENDLOOP.
    ENDIF.
*   ENDIF.                                                  ".. Subviews
    IF vim_modify_screen = 'X'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
  IF vim_special_mode EQ vim_delete.
    SET CURSOR FIELD f LINE 1 OFFSET o. "Always just 1 line in TC
  ENDIF.
  IF status-action EQ kopieren.
    neuer = 'N'.
  ENDIF.
ENDMODULE.                    "liste_show_liste OUTPUT

*---------------------------------------------------------------------*
*       MODULE LISTE_INITIALISIEREN OUTPUT                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE liste_initialisieren OUTPUT.                                     "#EC *
  IF vim_called_by_cluster <> space.                        "SW CTRL ..
    PERFORM vim_vcldocking_control.
  ENDIF.                               ".. SW CTRL
  status-mode = list_bild.
  title-mode  = list_bild.
  firstline = nextline.
  aktuell = firstline.
  vim_act_dynp_view = x_header-viewname.
  PERFORM vim_add_img_notices_pbo USING x_header-liste.
  IF vim_special_mode EQ vim_direct_upgrade.
    SUPPRESS DIALOG.
    ok_code = function = 'CMPR'.
    EXIT.
  ENDIF.
  CLEAR <status>-mark_only.                                 "ufdetail
  IF replace_mode NE space OR vim_special_mode EQ vim_delete.
    PERFORM set_title USING title <name>.
    IF vim_special_mode NE vim_delete. SUPPRESS DIALOG. ENDIF.
    PERFORM set_pf_status USING 'REPLACE'.
    MOVE <table1> TO <vim_total_struc>.
*    MOVE <table1> TO total.
    IF x_header-bastab NE space AND x_header-texttbexst NE space.
      MOVE <table1_text> TO <vim_tot_txt_struc>.
    ENDIF.
** Table-control !!!
    IF vim_tabctrl_active NE space.
      IF status-action EQ hinzufuegen.
        <vim_tctrl>-lines = maxlines + nbr_of_added_dummy_entries.
      ELSE.
        <vim_tctrl>-lines = maxlines.
      ENDIF.
      <vim_tctrl>-top_line = firstline.
      LOOP AT <vim_tctrl>-cols INTO vim_tc_cols
                               WHERE screen-active EQ 0.
        vim_tc_cols-vislength = 0.
        MODIFY <vim_tctrl>-cols FROM vim_tc_cols.
      ENDLOOP.
    ENDIF.
    EXIT.
  ENDIF.
  IF mark_extract GT 0.
    status-mark = markiert.
  ELSE.
    status-mark = nicht_markiert.
  ENDIF.
  IF maxlines EQ 0.
    IF status-action NE hinzufuegen
    OR status-type NE einstufig.
      PERFORM fill_extract.
    ELSE.                                                   "aro
      title-data = auswahldaten.                            "aro
    ENDIF.                                                  "aro
    status-delete = nicht_geloescht.
    PERFORM vim_send_sv005_or_sv766 USING '766'
                                          'RESET'.
  ELSEIF maxlines = 1 AND function <> 'UEBE'.
* Viewcluster: jump into single screen also if view is chosen for
* the 2nd time
    PERFORM vim_maintain_single_set.         "UFint2329966/2000
* Notlösung Sortproblem Hinzufügen Anfang
  ELSE.
    PERFORM vim_send_sv005_or_sv766 USING '766'
                                          'RESET'.
    IF status-action EQ hinzufuegen.
      pos = 1.
      LOOP AT extract.
        CHECK <xact> NE leer.
        IF sy-tabix NE pos.
          DELETE extract.
          INSERT extract INDEX pos.
        ENDIF.
        ADD 1 TO pos.
      ENDLOOP.
    ENDIF.
* Notlösung Sortproblem Hinzufügen Ende
  ENDIF.
  maximal = maxlines.
** Table-control !!!
  IF vim_tabctrl_active NE space.
    IF status-action EQ hinzufuegen.
      <vim_tctrl>-lines = maxlines + nbr_of_added_dummy_entries.
    ELSE.
      <vim_tctrl>-lines = maxlines.
    ENDIF.
    <vim_tctrl>-top_line = firstline.
    LOOP AT <vim_tctrl>-cols INTO vim_tc_cols
*                            WHERE SCREEN-INVISIBLE EQ 1
*                              OR  SCREEN-ACTIVE EQ 0.
                             WHERE screen-active EQ 0.
      vim_tc_cols-vislength = 0.
      MODIFY <vim_tctrl>-cols FROM vim_tc_cols.
    ENDLOOP.
* Notlösung Markierbarkeit beim Hinzufügen bzw. Kopieren
*   IF STATUS-ACTION EQ HINZUFUEGEN OR STATUS-ACTION EQ KOPIEREN.
*     <VIM_TCTRL>-LINE_SEL_MODE = 0.
*   ELSE.
**    <VIM_TCTRL>-LINE_SEL_MODE = 2.
*     <VIM_TCTRL>-LINE_SEL_MODE = <STATUS>-L_SEL_MODE.
*   ENDIF.
  ELSE.                                "Subviews ..
    LOOP AT SCREEN.
      SPLIT screen-name AT '-' INTO vim_object vim_objfield.
      IF vim_objfield <> space AND vim_object = x_header-maintview.
        LOOP AT x_namtab WHERE viewfield = vim_objfield AND
                            ( texttabfld = space OR keyflag = space ).
          IF x_namtab-readonly = vim_hidden.
            screen-active = '0'. MODIFY SCREEN.
          ELSEIF x_namtab-readonly = rdonly.
            screen-input = '0'. MODIFY SCREEN.
          ENDIF.
          EXIT.
        ENDLOOP.
      ENDIF.
    ENDLOOP.                           ".. Subviews
  ENDIF.
** Table-control !!!
  PERFORM set_position_info USING firstline maxlines.
  pos = maxlines - firstline + 1.
  IF l GT pos.
    l = 1.
  ENDIF.
  pos = 0.                                                  "aro
* Change for Cust. Msg.620095 2008 DUTTAN/24.09.2008
  IF f EQ space AND fcode EQ edit AND x_header-subsetflag EQ space.
    LOOP AT SCREEN.
      split screen-name at '-' into vim_object vim_objfield.
      read table x_namtab with key viewfield = vim_objfield.
      if sy-subrc = 0.
        if screen-input = 0.
          continue.
        else.
          if vim_object = x_header-viewname.
            f = screen-name.
            exit.
          endif.
        endif.
      endif.
* END OF CHANGE.
    ENDLOOP.
  ENDIF.
  SET CURSOR FIELD f LINE l OFFSET o.
  PERFORM set_pf_status USING status.
  PERFORM set_title USING title <name>.
* Notlösung Batch-Input Anfang
  IF maxlines EQ 0.
    LOOP AT SCREEN.
      CHECK screen-name EQ 'VIM_POSI_PUSH'.
      screen-input = 0.
      MODIFY SCREEN.
      EXIT.
    ENDLOOP.
  ENDIF.
* Notlösung Batch-Input Ende
  IF status-action EQ kopieren OR vim_single_entry_function NE space.
    LOOP AT SCREEN.
      CHECK screen-name EQ 'VIM_POSI_PUSH'.
      screen-active = 0.
      MODIFY SCREEN.
      EXIT.
    ENDLOOP.
  ENDIF.
* Fill cache in sync function for key-specific synchronizer locks?
  IF vim_sync_keyspec_check NE space.
    perform check_sync_key_lock using 'X'
                                changing vim_sync_key_lock.
  ENDIF.
ENDMODULE.                    "liste_initialisieren OUTPUT

*---------------------------------------------------------------------*
*       MODULE FILL_SUBSTFLDS OUTPUT                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE fill_substflds OUTPUT.                                               "#EC *
  CHECK x_header-subsetflag NE space.
  PERFORM fill_subsetfields.
ENDMODULE.                    "fill_substflds OUTPUT

*---------------------------------------------------------------------*
*       MODULE LISTE_DEACTIVATE OUTPUT                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE liste_deactivate OUTPUT.                                         "#EC *
  CHECK <xact> NE leer AND status-action NE kopieren.
  LOOP AT SCREEN.
    CHECK screen-group2 EQ 'EZN' .
    IF x_header-ptfrkyexst EQ space.
      MOVE screen-name TO f.
      SHIFT f UP TO '-'. SHIFT f.
      LOOP AT x_namtab WHERE keyflag EQ space  "ignore keyfields
                         AND viewfield EQ f.
        MOVE 'X' TO x_namtab-prtfrkyfld.
        MOVE 'X' TO x_header-ptfrkyexst.
        MODIFY x_namtab.
      ENDLOOP.
    ENDIF.
    CHECK sy-stepl NE 1 AND
    <vim_f1_beforex> EQ <vim_mkey_beforex> AND
    ( vim_mkey_after_exists EQ space OR
      <vim_f1_afterx> EQ <vim_mkey_afterx> ).
*    <vim_f1_before> eq <vim_mkey_before> and
*    ( vim_mkey_after_exists eq space or
*      <vim_f1_after> eq <vim_mkey_after> ).
    screen-active = 0.
    MODIFY SCREEN.
  ENDLOOP.
  MODIFY x_header INDEX 1.
  IF vim_no_mainkey_exists EQ vim_no_mkey_not_procsd OR
    <vim_f1_beforex> NE <vim_mkey_beforex> OR
    ( vim_mkey_after_exists NE space AND
      <vim_f1_afterx> NE <vim_mkey_afterx> ).
*     <vim_f1_before> ne <vim_mkey_before> or
*     ( vim_mkey_after_exists ne space and
*       <vim_f1_after> ne <vim_mkey_after> ).
    <vim_h_mkey>(x_header-keylen) = <f1_x>.
*    vim_mainkey = <f1>.
    TRANSLATE vim_no_mainkey_exists USING vim_no_mkey_procsd_patt.
  ENDIF.
ENDMODULE.                             "liste_deactivate.

*---------------------------------------------------------------------*
*       MODULE VIM_SUPPRESS_LISTE OUTPUT                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE vim_suppress_liste OUTPUT.                                     "#EC *
  CHECK vim_special_mode <> vim_direct_upgrade AND
        function NE space AND function NE 'ANZG' AND
        function NE 'AEND' AND "function NE 'ABR ' AND
        NOT ( vim_called_by_cluster NE space AND
             ( function CP 'DET*' OR  function CP '%_*' ) ).
  SUPPRESS DIALOG.
  ok_code = back.
ENDMODULE.                             "vim_suppres_liste
