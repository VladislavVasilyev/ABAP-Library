*---------------------------------------------------------------------*
*       FORM SET_POSITION_INFO                                        *
*---------------------------------------------------------------------*
* fill position info                                                  *
*---------------------------------------------------------------------*
* SPI_POSITION      ---> current position                             *
* SPI_ENTRIES       ---> total number of entries                      *
* VIM_POSITION_INFO <--- (global) string filled with position info    *
*---------------------------------------------------------------------*
FORM SET_POSITION_INFO USING VALUE(SPI_POSITION) TYPE I
                             VALUE(SPI_ENTRIES) TYPE I.
  DATA: HF1 TYPE I, HF2 TYPE I, HF3 TYPE I,
        P_VIM_POSITION_INFO_LEN TYPE I.

  MOVE VIM_POSITION_INFO_MASK TO VIM_POSITION_INFO.
  HF1 = VIM_POSITION_INFO_LG1 + 1.
  IF SPI_ENTRIES EQ 0.
    HF3 = 0.
  ELSE.
    HF3 = SPI_POSITION.
  ENDIF.
  WRITE HF3 TO
    VIM_POSITION_INFO+HF1(VIM_POSITION_INFO_LG3) NO-SIGN.
  HF1 = VIM_POSITION_INFO_LG1 + VIM_POSITION_INFO_LG2
                                    + VIM_POSITION_INFO_LG3 + 3.
  WRITE SPI_ENTRIES TO
    VIM_POSITION_INFO+HF1(VIM_POSITION_INFO_LG3) NO-SIGN.
  DO.
    CONDENSE VIM_POSITION_INFO.
* XB 585898B
* call methode to caculat the visible length of vim_position_info
    CALL METHOD cl_scp_linebreak_util=>get_visual_stringlength
      EXPORTING
        im_string               = VIM_POSITION_INFO
        IM_LANGU                = SY-LANGU
      IMPORTING
        EX_POS_VIS              = P_VIM_POSITION_INFO_LEN
*      EXCEPTIONS
*        INVALID_TEXT_ENVIROMENT = 1
*        others                  = 2
        .
    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

*    HF2 = VIM_POSITION_INFO_LEN - STRLEN( VIM_POSITION_INFO ).
    HF2 = VIM_POSITION_INFO_LEN - P_VIM_POSITION_INFO_LEN.
* XB 585898E
    IF HF2 GT 0.
      SHIFT VIM_POSITION_INFO RIGHT BY HF2 PLACES.
    ENDIF.
    IF HF2 GE 0. EXIT. ENDIF.
    HF1 = STRLEN( SVIM_TEXT_028 ).
    REPLACE SVIM_TEXT_028 LENGTH HF1 WITH '/' INTO VIM_POSITION_INFO.
    IF SY-SUBRC NE 0.
      HF1 = STRLEN( SVIM_TEXT_027 ) + HF2 - 1.
      IF HF1 GT 0.
        WRITE '.' TO VIM_POSITION_INFO+HF1(1).
        ADD 1 TO HF1. HF2 = - HF2.
        WRITE '          ' TO VIM_POSITION_INFO+HF1(HF2).
      ELSE.
        EXIT.
      ENDIF.
    ENDIF.
  ENDDO.
ENDFORM.                               "set_position_info
