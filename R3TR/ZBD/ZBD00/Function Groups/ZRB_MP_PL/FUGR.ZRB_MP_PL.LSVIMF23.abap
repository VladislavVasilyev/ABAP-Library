*---------------------------------------------------------------------*
*       FORM ORIGINAL_HOLEN                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM original_holen.
  DATA: count1 TYPE i, count2 TYPE i, count3 TYPE i, sum TYPE i,
        texttab_mod(1) TYPE c.         "SW Texttransl
  IF status-action NE aendern OR status-delete EQ geloescht.
    MESSAGE i001(sv).
    EXIT.
  ENDIF.
  IF status-mode EQ list_bild.
    LOOP AT extract.
      CLEAR texttab_mod.
      CHECK <xmark> EQ markiert.
      ADD 1 TO count1.
      IF x_header-texttbexst <> space. "SW Texttransl
        PERFORM vim_texttab_modif_for_key CHANGING texttab_mod.
      ENDIF.
      IF x_header-bastab NE space AND x_header-texttbexst NE space.
        CHECK <xact> EQ neuer_eintrag OR ( <xact> EQ original AND
              <xact_text> EQ original  AND texttab_mod EQ space ).
      ELSE.
        CHECK <xact> EQ neuer_eintrag OR ( <xact> EQ original
                                     AND texttab_mod EQ space ).
      ENDIF.
      IF <xact> EQ neuer_eintrag.
        ADD 1 TO count2.
      ELSE.
        ADD 1 TO count3.
      ENDIF.
    ENDLOOP.
  ELSE.
    ADD 1 TO count1.
    CASE <xact>.
      WHEN neuer_eintrag.
        ADD 1 TO count2.
      WHEN original.
        CLEAR texttab_mod.
        IF x_header-texttbexst <> space.              "SW Texttransl
          PERFORM vim_texttab_modif_for_key CHANGING texttab_mod.
        ENDIF.
        IF x_header-bastab NE space AND x_header-texttbexst NE space.
*          IF sy-datar EQ space AND <table1> EQ <extract_enti> AND
          IF sy-datar EQ space AND <table1> EQ <vim_extract_struc>
           AND <table1_xtext> EQ <vim_xextract_text>
           AND texttab_mod EQ space.
            ADD 1 TO count3.
          ENDIF.
        ELSE.
*          IF sy-datar EQ space AND <table1> EQ <table2>
          IF sy-datar EQ space AND <table1> EQ <vim_extract_struc>
                               AND texttab_mod EQ space.
            ADD 1 TO count3.
          ENDIF.
        ENDIF.
    ENDCASE.
  ENDIF.
  sum = count2 + count3.
  IF count1 EQ 0.
    MESSAGE s056(sv).
  ELSEIF count1 EQ count2.
    IF count1 EQ 1.
      MESSAGE s057(sv).
      IF status-mode EQ detail_bild.
        CLEAR function.
      ENDIF.
    ELSE.
      MESSAGE s058(sv).
    ENDIF.
  ELSEIF count1 EQ count3.
    IF count1 EQ 1.
      MESSAGE s059(sv).
    ELSE.
      MESSAGE s060(sv).
    ENDIF.
  ELSEIF count1 EQ sum.
    MESSAGE s061(sv) WITH count3 count2.
  ELSE.
    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
         EXPORTING
              titel     = svim_text_010
              textline1 = svim_text_009
              textline2 = svim_text_011
         IMPORTING
              answer    = answer.
    IF answer EQ 'J'.
      IF status-mode EQ list_bild.
        function = 'ORGL'.
      ELSE.
        IF <xact> NE original OR texttab_mod NE space.
          function = 'ORGD'.
        ELSE.
          answer = 'N'.
        ENDIF.
      ENDIF.
      IF answer = 'J'.
*       SET SCREEN 0. LEAVE SCREEN.
        vim_next_screen = 0. vim_leave_screen = 'X'.
      ENDIF.
    ELSE.
      CLEAR function.
    ENDIF.
  ENDIF.
ENDFORM.
