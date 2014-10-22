*&--------------------------------------------------------------------*
*&      Form VIM_APPEND_GLOBAL_TABLE                                  *
*&--------------------------------------------------------------------*
* set global field value (for external call)                          *
*&--------------------------------------------------------------------*
FORM VIM_APPEND_GLOBAL_TABLE USING VALUE(NAME_OF_TABLE) TYPE C
                                   VALUE(BASE_TABLE) LIKE TVDIR-FLAG
                                   VALUE(TABLEN) LIKE VIMDESC-TABLEN
                                   VALUE(ENTRY_TO_APPEND)
                                   VALUE(ACT_FLAG) LIKE TVDIR-FLAG
                                   VALUE(MRK_FLAG) LIKE TVDIR-FLAG
                                   VALUE(TXTACT_FLAG) LIKE TVDIR-FLAG
                                   VAGT_RETURN LIKE SY-SUBRC.
  DATA: WA(4096) TYPE C, DUM TYPE I.
  FIELD-SYMBOLS: <TABLE> TYPE TABLE, <ENTRY>.
  ASSIGN (NAME_OF_TABLE) TO <TABLE>.
  IF SY-SUBRC EQ 0.
    WA = ENTRY_TO_APPEND.
    WA+TABLEN(1) = ACT_FLAG. DUM = TABLEN + 1.
    WA+DUM(1) = MRK_FLAG. ADD 1 TO DUM.
    IF BASE_TABLE NE SPACE.
      WA+DUM(1) = TXTACT_FLAG. ADD 1 TO DUM.
    ENDIF.
    ASSIGN WA(DUM) TO <ENTRY>.
    APPEND <ENTRY> TO <TABLE>.
  ENDIF.
  VAGT_RETURN = SY-SUBRC.
ENDFORM.                               "vim_append_globall_table
