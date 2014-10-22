*---------------------------------------------------------------------*
*       FORM LOGICAL_UNDELETE_TOTAL                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM logical_undelete_total USING value(cur_index) TYPE i.
  CASE <action>.
    WHEN neuer_geloescht.
      <action> = neuer_eintrag.
    WHEN geloescht.
      <action> = original.
    WHEN update_geloescht.
      <action> = aendern.
  ENDCASE.
*  perform vim_bc_logs_maintain using zurueckholen
*                                           x_header
*                                     changing vim_bc_entry_list.
  IF x_header-bastab NE space AND x_header-texttbexst NE space.
    CASE <action_text>.
      WHEN neuer_geloescht.
        <action_text>         = neuer_eintrag.
      WHEN geloescht.
        <action_text>         = original.
      WHEN update_geloescht.
        <action_text>         = aendern.
      WHEN dummy_geloescht.
        <action_text>         = original.
        <vim_xtotal_text> = <text_initial_x>.
*        <TOTAL_TEXT> = <TEXT_INITIAL>.
    ENDCASE.
  ENDIF.
  <mark> = nicht_markiert.
  MODIFY total INDEX cur_index.
ENDFORM.                               "logical_undelete_total
