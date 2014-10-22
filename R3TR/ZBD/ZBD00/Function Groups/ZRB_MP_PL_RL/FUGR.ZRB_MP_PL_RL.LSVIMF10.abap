*&--------------------------------------------------------------------*
*&      Form  LISTE_EXIT_COMMAND                                      *
*&--------------------------------------------------------------------*
* handle exit commands on list screen                                 *
*&--------------------------------------------------------------------*
FORM LISTE_EXIT_COMMAND.
  CASE OK_CODE.
    WHEN 'ABR '.
      FUNCTION = OK_CODE.
      CLEAR OK_CODE.
      CASE VIM_SPECIAL_MODE.
        WHEN VIM_REPLACE.
          CLEAR VIM_ACT_DYNP_VIEW. SET SCREEN 0. LEAVE SCREEN.
        WHEN VIM_DELETE.                                "#EC *
          SET SCREEN 0. LEAVE SCREEN.
        WHEN VIM_UPGRADE.
*         CLEAR: VIM_SPECIAL_MODE, MAXLINES. LEAVE SCREEN.
          CLEAR VIM_ACT_DYNP_VIEW. NEUER = 'N'.
          SET SCREEN 0. LEAVE SCREEN.
        WHEN OTHERS.
          PERFORM LISTE_ABBRECHEN.
      ENDCASE.
    WHEN 'IGN '.
      CASE VIM_SPECIAL_MODE.
        WHEN VIM_REPLACE.
          CLEAR VIM_ACT_DYNP_VIEW. SET SCREEN 0. LEAVE SCREEN.
        WHEN VIM_DELETE.
          SET SCREEN 0. LEAVE SCREEN.
*       WHEN VIM_UPGRADE.  "impossible
*         CLEAR OK_CODE. LEAVE SCREEN.
        WHEN VIM_UPGRADE.
          CLEAR VIM_ACT_DYNP_VIEW. NEUER = 'N'.
          SET SCREEN 0. LEAVE SCREEN.
        WHEN OTHERS.
          LOOP AT SCREEN.
            SCREEN-ACTIVE = 0.
            MODIFY SCREEN.
          ENDLOOP.
      ENDCASE.
      NEUER = 'N'.
      CLEAR <STATUS>-UPD_FLAG.
  ENDCASE.
ENDFORM.                               "liste_exit_command.
