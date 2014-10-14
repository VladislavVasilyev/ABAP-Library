FUNCTION ZBD00_RSDRI_INFOPROV_READ_RFC .
*"----------------------------------------------------------------------
*"*"Локальный интерфейс:
*"  IMPORTING
*"     VALUE(I_INFOPROV) TYPE  RSINFOPROV
*"     VALUE(I_REFERENCE_DATE) TYPE  RSDRI_REFDATE DEFAULT SY-DATUM
*"     VALUE(I_ROLLUP_ONLY) TYPE  RS_BOOL DEFAULT RS_C_TRUE
*"     VALUE(I_SAVE_IN_TABLE) TYPE  RSDRI_SAVE_IN_TABLE DEFAULT SPACE
*"     VALUE(I_TABLENAME) TYPE  RSDRI_TABLENAME OPTIONAL
*"     VALUE(I_SAVE_IN_FILE) TYPE  RSDRI_SAVE_IN_FILE DEFAULT SPACE
*"     VALUE(I_FILENAME) TYPE  RSDRI_FILENAME OPTIONAL
*"     VALUE(I_PACKAGESIZE) TYPE  I DEFAULT 1000
*"     VALUE(I_MAXROWS) TYPE  I DEFAULT 0
*"     VALUE(I_AUTHORITY_CHECK) TYPE  RSDRI_AUTHCHK DEFAULT
*"       RSDRC_C_AUTHCHK-READ
*"     VALUE(I_CURRENCY_CONVERSION) TYPE  RSDR0_CURR_CONV DEFAULT 'X'
*"     VALUE(I_USE_DB_AGGREGATION) TYPE  RS_BOOL DEFAULT RS_C_TRUE
*"     VALUE(I_USE_AGGREGATES) TYPE  RS_BOOL DEFAULT RS_C_TRUE
*"     VALUE(I_READ_ODS_DELTA) TYPE  RSDRI_CHANGELOG_EXTRACTION DEFAULT
*"       RS_C_FALSE
*"     VALUE(I_DEBUG) TYPE  RS_BOOL DEFAULT RS_C_FALSE
*"     VALUE(I_RESULTTYPE) TYPE  RSDRI_RESULTTYPE DEFAULT SPACE
*"     VALUE(I_S_RFCMODE) TYPE  RSDP0_S_RFCMODE OPTIONAL
*"  EXPORTING
*"     VALUE(E_END_OF_DATA) TYPE  RS_BOOL
*"     VALUE(E_AGGREGATE) TYPE  RSINFOCUBE
*"     VALUE(E_SPLIT_OCCURRED) TYPE  RSDR0_SPLIT_OCCURRED
*"     VALUE(E_STEPUID) TYPE  SYSUUID_25
*"     VALUE(E_RFCDATA_UC) TYPE  XSTRING
*"  TABLES
*"      I_T_SFC TYPE  RSDRI_T_SFC
*"      I_T_SFK TYPE  RSDRI_T_SFK
*"      I_T_RANGE TYPE  RSDRI_T_RANGE OPTIONAL
*"      I_T_TABLESEL TYPE  RSDRI_T_SELT OPTIONAL
*"      I_T_RTIME TYPE  RSDRI_T_RTIME OPTIONAL
*"      I_T_REQUID TYPE  RSDR0_T_REQUID OPTIONAL
*"      E_T_RFCDATA TYPE  RSDRI_T_RFCDATA OPTIONAL
*"      E_T_RFCDATAV TYPE  RSDRI_T_RFCDATAV OPTIONAL
*"      E_T_FIELD TYPE  RSDP0_T_FIELD OPTIONAL
*"  CHANGING
*"     VALUE(C_FIRST_CALL) TYPE  RS_BOOL OPTIONAL
*"  EXCEPTIONS
*"      ILLEGAL_INPUT
*"      ILLEGAL_INPUT_SFC
*"      ILLEGAL_INPUT_SFK
*"      ILLEGAL_INPUT_RANGE
*"      ILLEGAL_INPUT_TABLESEL
*"      NO_AUTHORIZATION
*"      ILLEGAL_DOWNLOAD
*"      ILLEGAL_TABLENAME
*"      TRANS_NO_WRITE_MODE
*"      INHERITED_ERROR
*"      X_MESSAGE
*"----------------------------------------------------------------------
****  DATA:
****    l_subrc         LIKE sy-subrc,
****    l_s_msg         TYPE rs_s_msg,
****    g_infoprov      TYPE rsinfoprov,
****    g_multiprov     TYPE rsinfoprov,
****    i_th_sfc        type rsdri_th_sfc,
****    i_th_sfk        type rsdri_th_sfk,
****    i_th_tablesel   type rsdri_th_selt,
****    E_T_DATA  type standard table ,
****        value( E_END_OF_DATA )  type RS_BOOL
****        value( E_AGGREGATE )  type RSINFOCUBE
****        value( E_SPLIT_OCCURRED )	type RSDR0_SPLIT_OCCURRED
****        E_T_MSG	type RS_T_MSG
****        value( E_STEPUID )  type SYSUUID_25
****
****
****
****  STATICS: s_r_infoprov   TYPE REF TO cl_rsdri_infoprov.
****
****
****  IF s_r_infoprov is not initial AND c_first_call = rs_c_true.
*****   nested call of RSDRI_INFOPROV_READ
****    MESSAGE E882(DBMAN) raising ILLEGAL_INPUT.
****  ENDIF.
****
***** initialize an infoprov object on the initial call
****  IF s_r_infoprov IS INITIAL OR c_first_call = rs_c_true.
****
****    CREATE OBJECT s_r_infoprov
****      EXPORTING
****        i_infoprov    = i_infoprov
****      EXCEPTIONS
****        illegal_input = 1
****        others        = 2.
****
****    if sy-subrc <> 0.
****      l_s_msg-msgty = sy-msgty.
****      l_s_msg-msgno = sy-msgno.
****      l_s_msg-msgid = sy-msgid.
****      l_s_msg-msgv1 = sy-msgv1.
****      l_s_msg-msgv2 = sy-msgv2.
****      l_s_msg-msgv3 = sy-msgv3.
****      l_s_msg-msgv4 = sy-msgv4.
*****      append l_s_msg to e_t_msg.
****
****      MESSAGE id sy-msgid TYPE sy-msgty number sy-msgno
****        WITH sy-msgv2 sy-msgv2 sy-msgv3 sy-msgv4
****        RAISING illegal_input.
****    endif.
****
****    c_first_call = rs_c_false.
****    g_infoprov = i_infoprov.
****    IF s_r_infoprov->get_iprotype( ) = rsd_c_cubetype-multi_ic.
****      g_multiprov = i_infoprov.
****    ENDIF.
****  ENDIF.
****
***** read data
****  CALL METHOD s_r_infoprov->read
****    EXPORTING
****      i_th_sfc               = i_th_sfc
****      i_th_sfk               = i_th_sfk
****      i_t_range              = i_t_range[]
****      i_th_tablesel          = i_th_tablesel
****      i_t_rtime              = i_t_rtime[]
****      i_reference_date       = i_reference_date
****      i_t_requid             = i_t_requid[]
****      i_save_in_table        = i_save_in_table
****      i_tablename            = i_tablename
****      i_save_in_file         = i_save_in_file
****      i_filename             = i_filename
****      i_packagesize          = i_packagesize
****      i_maxrows              = i_maxrows
****      i_authority_check      = i_authority_check
****      i_currency_conversion  = i_currency_conversion
****      i_use_db_aggregation   = i_use_db_aggregation
****      i_use_aggregates       = i_use_aggregates
****      i_rollup_only          = i_rollup_only
****      i_read_ods_delta       = i_read_ods_delta
*****      i_caller               = i_caller
****      i_debug                = i_debug
****    IMPORTING
****      e_t_data               = e_t_data
****      e_end_of_data          = e_end_of_data
****      e_aggregate            = e_aggregate
****      e_split_occurred       = e_split_occurred
****      e_t_msg                = e_t_msg
****      e_stepuid              = e_stepuid
****    EXCEPTIONS
****      illegal_download       = 1
****      illegal_input          = 2
****      illegal_input_range    = 3
****      illegal_input_sfc      = 4
****      illegal_input_sfk      = 5
****      illegal_input_tablesel = 6
****      illegal_tablename      = 7
****      inherited_error        = 8
****      no_authorization       = 9
****      trans_no_write_mode    = 10
****      x_message              = 11.
****
****  l_subrc = sy-subrc.
****
****  if l_subrc <> 0.
****    clear s_r_infoprov.
****  endif.
****
****  CASE l_subrc.
****    WHEN 0.
****    WHEN 1. RAISE illegal_download.
****    WHEN 2. RAISE illegal_input.
****    WHEN 3. RAISE illegal_input_range.
****    WHEN 4. RAISE illegal_input_sfc.
****    WHEN 5. RAISE illegal_input_sfk.
****    WHEN 6. RAISE illegal_input_tablesel.
****    WHEN 7. RAISE illegal_tablename.
****    WHEN 9. RAISE no_authorization.
****    WHEN 10. RAISE trans_no_write_mode.
****    WHEN OTHERS. RAISE x_message.
****  ENDCASE.
****
***** end-of-data
****  IF e_end_of_data = rs_c_true.
****    CLEAR: s_r_infoprov, g_infoprov, g_multiprov.
****  ENDIF.

ENDFUNCTION.
