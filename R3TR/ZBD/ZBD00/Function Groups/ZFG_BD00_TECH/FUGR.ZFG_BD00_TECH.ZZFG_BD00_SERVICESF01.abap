*&---------------------------------------------------------------------*
*&  Include           ZZFG_BD00_SERVICESF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  wrap_str_to_c255
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_STRING  text
*      <--P_E_T_OUTDATA  text
*----------------------------------------------------------------------*
form wrap_str_to_c255
  using    i_string      type string
  changing c_t_rfcdata   type rsdri_t_rfcdata.

  data: l_s_rfcdata   type rsdri_s_rfcdata,
        l_strlen      type i,
        l_linelen     type i,
        l_rest        type i,
        l_offset      type i,
        l_cont        type c.

* determine length of destination line
  describe field l_s_rfcdata-line length l_linelen in character mode.

* determine length of the string
  l_rest = strlen( i_string ).

* initialize offset
  l_offset = 0.

* loop over the length of a table line
  while l_rest > 0.

    if l_rest > l_linelen. "remainder does not fit into 1 line
      l_strlen = l_linelen.
      l_cont   = 'X'.
    else.                  "remainder does fit into 1 line
      l_strlen = l_rest.
      l_cont   = space.
    endif.

    clear l_s_rfcdata.
    l_s_rfcdata-line = i_string+l_offset(l_strlen).
    l_s_rfcdata-cont = l_cont.

    append l_s_rfcdata to c_t_rfcdata.

    l_offset = l_offset + l_linelen.
    l_rest   = l_rest   - l_linelen.

  endwhile.

endform.                    " wrap_str_to_c255

*---------------------------------------------------------------------*
*  FORM wrap_str_to_c250
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
*  -->  I_STRING
*  -->  C_T_RFCDATA
*---------------------------------------------------------------------*
form wrap_str_to_c250
  using    i_string      type string
  changing c_t_rfcdata   type bapi6116tda.

  data: l_s_rfcdata   type bapi6116da,
        l_strlen      type i,
        l_linelen     type i,
        l_rest        type i,
        l_offset      type i,
        l_cont        type c.

* determine length of destination line
  describe field l_s_rfcdata-data length l_linelen in character mode.

* determine length of the string
  l_rest = strlen( i_string ).

* initialize offset
  l_offset = 0.

* loop over the length of a table line
  while l_rest > 0.

    if l_rest > l_linelen. "remainder does not fit into 1 line
      l_strlen = l_linelen.
      l_cont   = 'X'.
    else.                  "remainder does fit into 1 line
      l_strlen = l_rest.
      l_cont   = space.
    endif.

    clear l_s_rfcdata.
    l_s_rfcdata-data         = i_string+l_offset(l_strlen).
    l_s_rfcdata-continuation = l_cont.

    append l_s_rfcdata to c_t_rfcdata.

    l_offset = l_offset + l_linelen.
    l_rest   = l_rest   - l_linelen.

  endwhile.

endform.                    " wrap_str_to_c250
*&---------------------------------------------------------------------*
*&      Form  unwrap_c255_to_str
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_T_RFCDATA  text
*      <--P_L_STRING  text
*----------------------------------------------------------------------*
form unwrap_c255_to_str
  using    i_t_rfcdata   type rsdri_t_rfcdata
  changing e_string      type string.

  constants: l_c_length   type i value 255.

  data: l_buffer     type gt_buffer,
        l_offset     type i.

  field-symbols: <l_s_rfcdata>  type rsdri_s_rfcdata,
                 <l_buffer>     type gt_buffer.

* initialize
  clear: e_string.

* have <L_BUFFER> pointing to L_BUFFER
  assign l_buffer to <l_buffer>.

* concatenate all line into string
  loop at i_t_rfcdata assigning <l_s_rfcdata>.
    <l_buffer>+l_offset(l_c_length) = <l_s_rfcdata>-line.
    l_offset = l_offset + l_c_length.
  endloop.

* type cast
  e_string = l_buffer.

endform.                    " unwrap_c255_to_str
*&---------------------------------------------------------------------*
*&      Form  data_wrap_std
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_T_DATA  text
*      <--P_E_T_OUTDATA  text
*----------------------------------------------------------------------*
form data_wrap_std
  using    i_t_data     type any table
  changing e_t_outdata  type rsdri_t_rfcdata.

  data: l_string     type string.

  field-symbols: <l_s_data>  type any.

* initialize
  clear e_t_outdata.

* loop over I_T_DATA and wrap each line
  loop at i_t_data assigning <l_s_data>.

    clear: l_string.

    call method cl_abap_container_utilities=>fill_container_c
      exporting
        im_value     = <l_s_data>
      importing
        ex_container = l_string.

    perform wrap_str_to_c255
      using    l_string
      changing e_t_outdata.

  endloop.

endform.                    " data_wrap_std
*&---------------------------------------------------------------------*
*&      Form  data_wrap_uc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_T_DATA  text
*      <--P_E_OUTDATA_UC  text
*----------------------------------------------------------------------*
form data_wrap_uc
  using    i_t_data      type any table
           i_compress    type rs_bool
  changing e_outdata_uc  type xstring.

  if i_compress = rs_c_true.
    export rsdri = i_t_data
      to data buffer e_outdata_uc
      compression on.
  else.
    export rsdri = i_t_data
      to data buffer e_outdata_uc
      compression off.
  endif.

*  IF sy-subrc <> 0.
*    RAISE conversion_error.
*  ENDIF.

endform.                    " data_wrap_uc

*---------------------------------------------------------------------*
*  FORM data_wrap_250
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
*  -->  I_T_DATA
*  -->  E_T_OUTDATA250
*---------------------------------------------------------------------*
form data_wrap_250
  using    i_t_data        type standard table
  changing e_t_outdata250  type bapi6116tda.

  data: l_string     type string.

  field-symbols: <l_s_data>  type any.

* initialize
  clear e_t_outdata250.

* loop over I_T_DATA and wrap each line
  loop at i_t_data assigning <l_s_data>.

    clear: l_string.

    call method cl_abap_container_utilities=>fill_container_c
      exporting
        im_value     = <l_s_data>
      importing
        ex_container = l_string.

    perform wrap_str_to_c250
      using    l_string
      changing e_t_outdata250.

  endloop.

endform.                    " data_wrap_250
*&---------------------------------------------------------------------*
*&      Form  data_unwrap_std
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_T_RFCDATA  text
*      <--P_C_T_DATA  text
*----------------------------------------------------------------------*
form data_unwrap_std
  using    i_t_rfcdata    type rsdri_t_rfcdata
  changing c_t_data       type any table.

  field-symbols: <l_s_data>     type any,
                 <l_s_rfcdata>  type rsdri_s_rfcdata,
                 <l_ts_data>    type standard table,
                 <l_to_data>    type sorted table,
                 <l_th_data>    type hashed table.

  data: l_string    type string,
        l_t_rfcdata type rsdri_t_rfcdata,
        l_type_table   type abap_tablekind
        .

* dynamically create a WA-line for C_T_DATA
  assign local copy of initial line of c_t_data to <l_s_data>.

  data lr_t_descr_data   type ref to cl_abap_tabledescr.
  lr_t_descr_data ?= cl_abap_tabledescr=>describe_by_data( c_t_data ).

  case lr_t_descr_data->table_kind.
    when cl_abap_tabledescr=>tablekind_std.
      assign c_t_data to <l_ts_data>.
    when cl_abap_tabledescr=>tablekind_hashed.
      assign c_t_data to <l_th_data>.
    when cl_abap_tabledescr=>tablekind_sorted.
      assign c_t_data to <l_to_data>.
  endcase.

* loop over I_T_DATA and wrap each line
  loop at i_t_rfcdata assigning <l_s_rfcdata>.

    append <l_s_rfcdata> to l_t_rfcdata.

*   --- one record is complete
    if <l_s_rfcdata>-cont <> 'X'.

      perform unwrap_c255_to_str
        using    l_t_rfcdata
        changing l_string.

      clear: l_t_rfcdata,
             <l_s_data>.

      call method cl_abap_container_utilities=>read_container_c
        exporting
          im_container = l_string
        importing
          ex_value     = <l_s_data>.

      case lr_t_descr_data->table_kind.
        when cl_abap_tabledescr=>tablekind_std.
          append <l_s_data>  to <l_ts_data>.
        when cl_abap_tabledescr=>tablekind_hashed.
          insert <l_s_data> into table <l_th_data>.
        when cl_abap_tabledescr=>tablekind_sorted.
          append <l_s_data> to <l_to_data>.
      endcase.
    endif.
  endloop.

endform.                    " data_unwrap_std
*&---------------------------------------------------------------------*
*&      Form  data_unwrap_uc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_RFCDATA_UC  text
*      <--P_C_T_DATA  text
*----------------------------------------------------------------------*
form data_unwrap_uc
  using    i_rfcdata_uc    type xstring
  changing c_t_data        type any table.

  field-symbols
  : <l_t_data>     type standard table
  , <l_s_data>     type any
  , <l_ts_data>    type standard table
  , <l_to_data>    type sorted table
  , <l_th_data>    type hashed table.

  data
  : lr_t_descr_data   type ref to cl_abap_tabledescr
  , lr_t__data        type ref to data
  , lr_s__data        type ref to data
  .

  lr_t_descr_data ?= cl_abap_tabledescr=>describe_by_data( c_t_data ).

  case lr_t_descr_data->table_kind.
    when cl_abap_tabledescr=>tablekind_std.
      assign c_t_data to <l_ts_data>.
    when cl_abap_tabledescr=>tablekind_hashed.
      assign c_t_data to <l_th_data>.
    when cl_abap_tabledescr=>tablekind_sorted.
      assign c_t_data to <l_to_data>.
  endcase.


* non-initial C_T_DATA ----------------------------------------------
  if not c_t_data is initial.

*   dynamically create a copy of C_T_DATA
    assign local copy of c_t_data to <l_t_data>.

*   re-convert
    import rsdri = <l_t_data>
      from data buffer i_rfcdata_uc.

    if sy-subrc <> 0.
      raise conversion_error.
    endif.

*   append lines
    case lr_t_descr_data->table_kind.
      when cl_abap_tabledescr=>tablekind_std.
        append lines of <l_t_data>  to <l_ts_data>.
      when cl_abap_tabledescr=>tablekind_hashed.
        insert lines of <l_t_data> into table <l_th_data>.
      when cl_abap_tabledescr=>tablekind_sorted.
        append lines of <l_t_data> to <l_to_data>.
    endcase.
    clear <l_t_data>.

* initial C_T_DATA --------------------------------------------------
  else.

    create data lr_s__data like line of c_t_data.
    assign lr_s__data->* to <l_s_data>.
    create data lr_t__data like standard table of <l_s_data> with non-unique default key.
    assign lr_t__data->* to <l_t_data>.


*   re-convert
    import rsdri =  <l_t_data> "c_t_data
      from data buffer i_rfcdata_uc.

    if sy-subrc <> 0.
      raise conversion_error.
    endif.

    case lr_t_descr_data->table_kind.
      when cl_abap_tabledescr=>tablekind_std.
        append lines of <l_t_data>  to <l_ts_data>.
      when cl_abap_tabledescr=>tablekind_hashed.
        insert lines of <l_t_data> into table <l_th_data>.
      when cl_abap_tabledescr=>tablekind_sorted.
        append lines of <l_t_data> to <l_to_data>.
    endcase.
    clear <l_t_data>.

  endif.

endform.                    " data_unwrap_uc

*&---------------------------------------------------------------------*
*&      Form  data_unwrap_std_250
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_T_RFCDATA  text
*      <--P_C_T_DATA  text
*----------------------------------------------------------------------*
form data_unwrap_std_250
  using    i_t_rfcdata    type bapi6116tda
  changing c_t_data       type standard table.

  field-symbols: <l_s_data>     type any,
                 <l_s_rfcdata>  type bapi6116da.

  data: l_string    type string,
        l_t_rfcdata type bapi6116tda.



* dynamically create a WA-line for C_T_DATA
  assign local copy of initial line of c_t_data to <l_s_data>.

* loop over I_T_DATA and wrap each line
  loop at i_t_rfcdata assigning <l_s_rfcdata>.

    append <l_s_rfcdata> to l_t_rfcdata.

*   --- one record is complete
    if <l_s_rfcdata>-continuation ne rs_c_true.

      perform unwrap_c250_to_str
        using    l_t_rfcdata
        changing l_string.

      clear: l_t_rfcdata,
             <l_s_data>.

      call method cl_abap_container_utilities=>read_container_c
        exporting
          im_container = l_string
        importing
          ex_value     = <l_s_data>.

      append <l_s_data> to c_t_data.

    endif.

  endloop.

endform.                    " data_unwrap_std_250
*---------------------------------------------------------------------*
*  FORM unwrap_c250_to_str
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
*  -->  I_T_RFCDATA
*  -->  E_STRING
*---------------------------------------------------------------------*
form unwrap_c250_to_str
  using    i_t_rfcdata   type bapi6116tda
  changing e_string      type string.

  data: buffer       type gt_buffer.
  data: offset       type i.
  field-symbols: <l_s_rfcdata>  type bapi6116da,
                 <l_string>     type gt_buffer.


* initialize
  clear: e_string, buffer, offset.
  assign buffer to <l_string>.

* concatenate all line into string
  loop at i_t_rfcdata assigning <l_s_rfcdata>.
*    CONCATENATE e_string <l_s_rfcdata>-data INTO e_string.
    <l_string>+offset(250) = <l_s_rfcdata>-data.
    add 250 to offset.
  endloop.

* Make sure the trailer gets not chopped off
  <l_string>+offset(1) = 'X'.

  e_string = buffer.

endform.                    " unwrap_c250_to_str
*&---------------------------------------------------------------------*
*&      Form  RELATE_KYFS_WITH_UNITS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_L_T_COMPONENT  text
*----------------------------------------------------------------------*
form relate_kyfs_with_units
  changing c_t_component   type gt_t_component.

  field-symbols: <l_s_component>  type gt_s_component.

  data: l_s_iobj  type rsd_s_iobj,
        l_s_kyf   type rsd_s_kyf,
        l_s_unit  type gt_s_component.

  loop at c_t_component assigning <l_s_component>.

*   --- get information on the component
    call function 'RSD_IOBJ_GET'
      exporting
        i_iobjnm        = <l_s_component>-name
        i_objvers       = rs_c_objvers-active
        i_bypass_buffer = rs_c_false
      importing
        e_s_iobj        = l_s_iobj
        e_s_kyf         = l_s_kyf
      exceptions
        iobj_not_found  = 1
        others          = 0.

*    --- If this infoobject is not found then the underlying data
*    --- structure's components are obviously not infoobject names.
*    --- Therefore the component cannot be related to a unit and
*    --- the form can be left.
    if sy-subrc <> 0.
*     exit.
      continue.        "because of navigational attributes ...
    endif.

*   --- no key figure -> nothing to do
    if l_s_iobj-iobjtp <> rsd_c_objtp-keyfigure.
      <l_s_component>-unitcomp = 0.
      continue.
    endif.

*   --- fixed unit/currency?
    if not l_s_kyf-fixcuky is initial.
      <l_s_component>-unitcomp  = -1.
      <l_s_component>-unitfixed = l_s_kyf-fixcuky.
      continue.
    elseif not l_s_kyf-fixunit is initial.
      <l_s_component>-unitcomp  = -1.
      <l_s_component>-unitfixed = l_s_kyf-fixunit.
      continue.
    endif.

*   --- empty unit -> go on with next component
    if l_s_kyf-uninm is initial.
      clear: <l_s_component>-unitcomp,
             <l_s_component>-unitfixed.
    endif.

*   --- find related unit/currency component
    clear <l_s_component>-unitfixed.

    read table c_t_component with key name = l_s_kyf-uninm
      into l_s_unit
      transporting position.

    if sy-subrc <= 2.
      <l_s_component>-unitcomp = l_s_unit-position.
    else.
      <l_s_component>-unitcomp = 0.
    endif.

  endloop.

endform.                               " RELATE_KYFS_WITH_UNITS
*&---------------------------------------------------------------------*
*&      Form  REMOVE_IRRELEVANT_COMPONENTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      --> I_TH_SFC      list of characteristics
*      --> I_TH_SFK      list of key figures
*      <-> C_T_COMPONENT components of data structure
*----------------------------------------------------------------------*
form remove_irrelevant_components
  using    i_th_sfc      type rsdri_th_sfc
           i_th_sfk      type rsdri_th_sfk
  changing c_t_component type gt_t_component
           e_relevant    type i.

  field-symbols: <l_s_component>   type gt_s_component,
                 <l_s_sfc>         type rsdri_s_sfc,
                 <l_s_sfk>         type rsdri_s_sfk.

  data: l_unitfl  type rs_bool.

* initialize
  describe table c_t_component lines e_relevant.

* SFC and SFK initial -> use all components
  check not i_th_sfc is initial and not i_th_sfk is initial.

* check if a component appears in either SFC or SFK;
* remove all components that don't (except units)
  loop at c_t_component assigning <l_s_component>.

*   --- check if component is a unit/currency
    perform check_iobj_properties in program saplrsdrc_seldr
      using    <l_s_component>-name
      changing l_unitfl.
    if l_unitfl = rs_c_true.
      e_relevant = e_relevant - 1.
      <l_s_component>-showfl = rs_c_false.
      continue.
    endif.

*   --- check if component is in SFC
    read table i_th_sfc
      with key chaalias = <l_s_component>-name              "#EC *
      assigning <l_s_sfc>.
    if sy-subrc <= 2.
      <l_s_component>-iobjnm = <l_s_sfc>-chanm.
      continue.
    endif.

*   --- check if component is in SFK
    read table i_th_sfk
      with key kyfalias = <l_s_component>-name              "#EC *
      assigning <l_s_sfk>.
    if sy-subrc <= 2.
      <l_s_component>-iobjnm = <l_s_sfk>-kyfnm.
      continue.
    endif.

*   --- component is in neither SFC nor SFK -> remove it
    e_relevant = e_relevant - 1.
    <l_s_component>-showfl = rs_c_false.
  endloop.

endform.                               " REMOVE_IRRELEVANT_COMPONENTS
