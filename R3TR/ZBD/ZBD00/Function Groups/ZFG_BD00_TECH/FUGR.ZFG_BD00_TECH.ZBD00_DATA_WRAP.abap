FUNCTION ZBD00_DATA_WRAP .
*"----------------------------------------------------------------------
*"*"Локальный интерфейс:
*"  IMPORTING
*"     REFERENCE(I_T_DATA) TYPE  ANY TABLE
*"     VALUE(I_UNICODE_RESULT) TYPE  RS_BOOL DEFAULT RS_C_FALSE
*"     VALUE(I_COMPRESS) TYPE  RS_BOOL DEFAULT RS_C_TRUE
*"     VALUE(I_RESULT250) TYPE  RS_BOOL DEFAULT RS_C_FALSE
*"  EXPORTING
*"     REFERENCE(E_T_OUTDATA) TYPE  RSDRI_T_RFCDATA
*"     REFERENCE(E_OUTDATA_UC) TYPE  XSTRING
*"     REFERENCE(E_T_OUTDATA250) TYPE  BAPI6116TDA
*"  EXCEPTIONS
*"      CONVERSION_ERROR
*"----------------------------------------------------------------------

* initialize
  CLEAR: e_t_outdata, e_outdata_uc, e_t_outdata250.

* convert into standard format
  IF i_unicode_result = rs_c_false AND i_result250 = rs_c_false.
    PERFORM data_wrap_std
      USING    i_t_data
      CHANGING e_t_outdata.
  ENDIF.

* convert into unicode format
  IF i_unicode_result = rs_c_true.
    PERFORM data_wrap_uc
      USING    i_t_data
               i_compress
      CHANGING e_outdata_uc.
  ENDIF.

* convert into BAPI format
  IF i_result250 = rs_c_true.
    PERFORM data_wrap_250
      USING    i_t_data
      CHANGING e_t_outdata250.
  ENDIF.

ENDFUNCTION.
