function zbd00_data_wrap_line .
*"----------------------------------------------------------------------
*"*"Локальный интерфейс:
*"  IMPORTING
*"     VALUE(I_UNICODE_RESULT) TYPE  RS_BOOL DEFAULT RS_C_FALSE
*"     VALUE(I_COMPRESS) TYPE  RS_BOOL DEFAULT RS_C_TRUE
*"     VALUE(I_RESULT250) TYPE  RS_BOOL DEFAULT RS_C_FALSE
*"     REFERENCE(I_S_DATA) TYPE  ANY
*"  EXPORTING
*"     REFERENCE(E_OUTDATA_UC) TYPE  XSTRING
*"     REFERENCE(E_T_OUTDATA250) TYPE  BAPI6116TDA
*"  CHANGING
*"     REFERENCE(E_T_OUTDATA) TYPE  RSDRI_T_RFCDATA
*"  EXCEPTIONS
*"      CONVERSION_ERROR
*"----------------------------------------------------------------------

  data: l_string     type string.

  field-symbols: <l_s_data>  type any.


* initialize
*  clear: e_t_outdata, e_outdata_uc, e_t_outdata250.

* convert into standard format
  if i_unicode_result = rs_c_false and i_result250 = rs_c_false.
      clear l_string.

       call method cl_abap_container_utilities=>fill_container_c
        exporting
          im_value     = i_s_data
        importing
          ex_container = l_string.

      perform wrap_str_to_c255
        using    l_string
        changing e_t_outdata.

*    perform data_wrap_std
*      using    i_t_data
*      changing e_t_outdata.
  endif.

* convert into unicode format
  if i_unicode_result = rs_c_true.
*    PERFORM data_wrap_uc
*      USING    i_t_data
*               i_compress
*      CHANGING e_outdata_uc.
  endif.

* convert into BAPI format
  if i_result250 = rs_c_true.
*    PERFORM data_wrap_250
*      USING    i_t_data
*      CHANGING e_t_outdata250.
  endif.

endfunction.
