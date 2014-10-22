function zbd00_data_unwrap .
*"----------------------------------------------------------------------
*"*"Локальный интерфейс:
*"  IMPORTING
*"     REFERENCE(I_T_RFCDATA) TYPE  RSDRI_T_RFCDATA OPTIONAL
*"     REFERENCE(I_RFCDATA_UC) TYPE  XSTRING OPTIONAL
*"     REFERENCE(I_T_RFCDATA250) TYPE  BAPI6116TDA OPTIONAL
*"     VALUE(I_PACKAGED) TYPE  RS_BOOL DEFAULT RS_C_FALSE
*"  CHANGING
*"     REFERENCE(C_T_DATA) TYPE  ANY TABLE OPTIONAL
*"     REFERENCE(C_TX_DATA) TYPE  STANDARD TABLE OPTIONAL
*"  EXCEPTIONS
*"      CONVERSION_ERROR
*"----------------------------------------------------------------------

  field-symbols: <l_t_data>   type any table.

* set <L_T_DATA>
  if i_packaged = rs_c_false.
    assign c_t_data to <l_t_data>.
  else.
    assign local copy of initial line of c_tx_data to <l_t_data>.
  endif.

* unwrap
  if not i_t_rfcdata is initial.


    perform data_unwrap_std
      using    i_t_rfcdata
      changing <l_t_data>.
  endif.

  IF NOT i_rfcdata_uc IS INITIAL.
    PERFORM data_unwrap_uc
      USING    i_rfcdata_uc
      CHANGING <l_t_data>.
  ENDIF.
*
*  IF NOT i_t_rfcdata250 IS INITIAL.
*    PERFORM data_unwrap_std_250
*      USING     i_t_rfcdata250
*      CHANGING  <l_t_data>.
*  ENDIF.
*
** package
*  IF i_packaged = rs_c_true.
*    IF NOT <l_t_data> IS INITIAL.
*      APPEND <l_t_data> TO c_tx_data.
*    ENDIF.
*  ENDIF.

endfunction.
