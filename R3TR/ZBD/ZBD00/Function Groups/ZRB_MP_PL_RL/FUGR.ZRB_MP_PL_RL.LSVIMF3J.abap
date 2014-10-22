*---------------------------------------------------------------------*
*       FORM CHECK_UPD                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM CHECK_UPD.
  data: leave.
  CHECK STATUS-ACTION NE ANZEIGEN.
  IF <STATUS>-UPD_FLAG EQ SPACE.
    IF STATUS-ACTION EQ TRANSPORTIEREN.
      MOVE <STATUS>-KEYTBMODFD TO <STATUS>-UPD_FLAG.
    ELSE.
      LOOP AT TOTAL.
*       CHECK <ACTION> NE NEUER_GELOESCHT AND <ACTION> NE ORIGINAL.
        CHECK <ACTION> NE ORIGINAL.
        MOVE 'X' TO <STATUS>-UPD_FLAG.
        EXIT.
      ENDLOOP.
      IF <STATUS>-UPD_FLAG EQ SPACE AND X_HEADER-BASTAB NE SPACE AND
         X_HEADER-TEXTTBEXST NE SPACE.
        LOOP AT TOTAL.
*         CHECK <ACTION_TEXT> NE NEUER_GELOESCHT AND
          CHECK <ACTION_TEXT> NE ORIGINAL.
          MOVE 'X' TO <STATUS>-UPD_FLAG.
          EXIT.
        ENDLOOP.
      ENDIF.
      IF <STATUS>-UPD_FLAG EQ SPACE AND X_HEADER-TEXTTBEXST <> SPACE.
        PERFORM VIM_CHECK_UPD_TEXTTAB. "SW Texttransl
      ENDIF.
      IF <STATUS>-UPD_FLAG EQ SPACE AND X_HEADER-ADRNBRFLAG EQ 'N'.
        DESCRIBE TABLE VIM_ADDRESSES_TO_SAVE.
        IF SY-TFILL GT 0.
          MOVE 'X' TO <STATUS>-UPD_FLAG.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
  IF X_HEADER-FRM_AF_CHK NE SPACE AND STATUS-ACTION NE TRANSPORTIEREN.
    PERFORM (X_HEADER-FRM_AF_CHK) IN PROGRAM (SY-REPID).
  ENDIF.
  if <status>-upd_flag = space and vim_called_by_cluster = space and
   ( function = back OR function = end ).
    perform vim_add_img_notices_pai using 'E'
                                    changing leave.
    if leave = space.
      clear function.
    endif.
  endif.
  MOVE 'X' TO <STATUS>-UPD_CHECKD.
ENDFORM.
