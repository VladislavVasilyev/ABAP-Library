*---------------------------------------------------------------------*
*       FORM VIM_CK_APPEND_WHERETAB                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM VIM_CK_APPEND_WHERETAB TABLES VCAW_WHERETAB STRUCTURE VIMWHERETB
* Changed - Parameter passed by reference - ACHACHADI - Message 0120061532 0003423301 2008
                            USING LINE TYPE VIM_CK_SELCOND.
DATA: BEGIN OF HF, F1(1) TYPE C, F2 LIKE VIMSELLIST-VALUE, F3(1) TYPE C,
                  END OF HF.
DATA: len TYPE i,l_line(134) TYPE c.
CONSTANTS: wheretab_length TYPE i VALUE 72.
  CHECK NOT LINE IS INITIAL.
  IF LINE-VALUE EQ SPACE.
    HF = ''' '''.
  ELSE.
    CONCATENATE: LINE-HK1
                 LINE-VALUE
                 LINE-HK2
      INTO HF.
  ENDIF.
  CONCATENATE: LINE-FIELD
               LINE-OPERATOR
               HF
               LINE-AND
    INTO VCAW_WHERETAB SEPARATED BY SPACE.
  IF SY-SUBRC EQ 0.
    APPEND VCAW_WHERETAB.
  ELSE.
    CONCATENATE: LINE-FIELD
                 LINE-OPERATOR
      INTO VCAW_WHERETAB SEPARATED BY SPACE.
    APPEND VCAW_WHERETAB.
    CONCATENATE: HF
                 LINE-AND
      INTO l_line SEPARATED BY SPACE.
    vcaw_wheretab = l_line.
    APPEND vcaw_wheretab.
    len = strlen( l_line ).
    IF len > wheretab_length.
      CLEAR vcaw_wheretab.
      vcaw_wheretab = l_line+wheretab_length.
      APPEND vcaw_wheretab.
    ENDIF.
    IF line-and <> space.
      vcaw_wheretab = line-and.
        APPEND VCAW_WHERETAB.
    ENDIF.
  ENDIF.
ENDFORM.                               "vim_ck_append_wheretab
