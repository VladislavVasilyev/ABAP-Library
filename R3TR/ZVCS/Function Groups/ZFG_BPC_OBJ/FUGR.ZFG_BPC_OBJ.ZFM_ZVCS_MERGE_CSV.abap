function zfm_zvcs_merge_csv.
*"----------------------------------------------------------------------
*"*"Локальный интерфейс:
*"  IMPORTING
*"     REFERENCE(I_APPSET_ID) TYPE  UJ_APPSET_ID
*"     REFERENCE(I_DIMENSION) TYPE  UJ_DIM_NAME
*"     REFERENCE(I_DATA) TYPE REF TO  DATA
*"----------------------------------------------------------------------
  define mbr_seq>.
    assign component uja00_cs_attr-mbr_seq of structure &1 to <any>.
    <any> = &2.
  end-of-definition.
  define rowflag>.
    assign component uja00_cs_attr-rowflag of structure &1 to <any>.
    <any> = &2.
  end-of-definition.
  define id>.
    assign component `ID` of structure &1 to <any>.
    <any> = &2.
  end-of-definition.

  data
  : lr_t__olddim            type ref to data
  , lr_s__olddim            type ref to data
  , lr_o__mbr_data          type ref to cl_uja_dim
  , ld_v__old_id            type string
  , ld_s__mbr_attr          type uj0_s_itab
  , ld_s__mbr_seq           type uj0_s_itab
  , ld_s__hier              type uj0_s_itab
  , ld_t__attr_list         type uja_t_attr
  , lr_o__structdescr       type ref to cl_abap_structdescr
  , lr_o__newstructdescr    type ref to cl_abap_structdescr
  , ld_t__comp_attr         type cl_abap_structdescr=>component_table
  , ld_t__comp_hier         type cl_abap_structdescr=>component_table
  , ld_t__comp_seq          type cl_abap_structdescr=>component_table
  , lr_s__comp_attr         type ref to data
  , lr_s__comp_hier         type ref to data
  , lr_s__comp_seq          type ref to data
  , ld_s__comp              like line of ld_t__comp_seq
  , ld_v__oldseq            type i
  , ld_v__newseq            type i
  , ld_f__attr_mod          type rs_bool
  , ld_f__hier_mod          type rs_bool
  , lr_s__dim               type ref to data
  .

  field-symbols
  : <ld_t__olddim>          type standard table
  , <ld_s__olddim>          type any
  , <ld_v__elem>            type any
  , <ld_t__dim>             type standard table
  , <ld_s__dim>             type any
  , <ld_v__old_id>          type any
  , <ld_s__comp>            type abap_compdescr
  , <ld_s__newcomp>         type abap_compdescr
  , <ld_t__attr>            type standard table
  , <ld_t__hier>            type standard table
  , <ld_t__seq>             type standard table
  , <ld_s__attr>            type any
  , <ld_s__initline>        type any
  , <ld_s__hier>            type any
  , <ld_s__seq>             type any
  , <any>                   type any
  , <ld_v__field>           type string
  , <ld_v__oldelement>      type any
  , <ld_v__newelement>      type any

  .

  assign i_data->* to <ld_t__dim>.

  create data lr_s__dim like line of <ld_t__dim>.
  assign lr_s__dim->* to <ld_s__dim>.


  create object lr_o__mbr_data
    exporting
      i_appset_id = i_appset_id
      i_dimension = i_dimension.

  call method lr_o__mbr_data->read_mbr_data
    exporting
      if_sort            = abap_true
      if_inc_non_display = abap_false
      if_inc_generate    = abap_false
      if_skip_cache      = abap_true
      if_inc_txt         = abap_true
    importing
      er_data            = lr_t__olddim.

*--------------------------------------------------------------------*
*
*--------------------------------------------------------------------*
  assign lr_t__olddim->* to <ld_t__olddim>.
  create data lr_s__olddim like line of <ld_t__olddim>.
  assign lr_s__olddim->* to <ld_s__olddim>.

  lr_o__structdescr    ?= cl_abap_structdescr=>describe_by_data_ref( lr_s__olddim ).
  lr_o__newstructdescr ?= cl_abap_structdescr=>describe_by_data( <ld_s__dim> ).

  loop at lr_o__newstructdescr->components assigning <ld_s__newcomp>.

    read table lr_o__structdescr->components
         with key name = <ld_s__newcomp>-name
         assigning <ld_s__comp>.

    if sy-subrc = 0.
*--------------------------------------------------------------------*
*    describe struct oldstruct
*--------------------------------------------------------------------*
      assign component <ld_s__comp>-name of structure <ld_s__olddim> to <ld_v__elem>.
      ld_s__comp-name = <ld_s__comp>-name.
      ld_s__comp-type ?= cl_abap_datadescr=>describe_by_data( <ld_v__elem> ).
*--------------------------------------------------------------------*

      append <ld_s__comp>-name to ld_s__mbr_attr-t_field_name.
      append ld_s__comp to ld_t__comp_attr.

      if <ld_s__comp>-name = `ID`.
        append <ld_s__comp>-name to
        : ld_s__hier-t_field_name
        , ld_s__mbr_seq-t_field_name
        .

        append ld_s__comp to: ld_t__comp_hier, ld_t__comp_seq.

      endif.

      find first occurrence of regex `\<PARENTH\d+\>` in <ld_s__comp>-name.

      if sy-subrc = 0.
        append <ld_s__comp>-name to ld_s__hier-t_field_name.
        append ld_s__comp to ld_t__comp_hier.
      endif.
    else.
      find first occurrence of regex `\<PARENTH\d+\>` in <ld_s__newcomp>-name.
      if sy-subrc = 0.
        ld_s__comp-type ?= cl_abap_elemdescr=>get_c( 20 ).
        ld_s__comp-name = <ld_s__newcomp>-name.
        append <ld_s__newcomp>-name to:  ld_s__hier-t_field_name, ld_s__mbr_attr-t_field_name.
        append ld_s__comp to: ld_t__comp_hier, ld_t__comp_attr.
      endif.
    endif.
  endloop.

  ld_s__comp-name = uja00_cs_attr-mbr_seq.
  ld_s__comp-type ?= cl_abap_datadescr=>describe_by_name( `/B28/OIMBRSEQ` ).

  append uja00_cs_attr-mbr_seq to
  : ld_s__mbr_attr-t_field_name
  , ld_s__mbr_seq-t_field_name.

  append ld_s__comp to: ld_t__comp_seq, ld_t__comp_attr.

  ld_s__comp-name = uja00_cs_attr-rowflag.
  ld_s__comp-type ?= cl_abap_datadescr=>describe_by_name( `UJ_ACTION` ).

* uj00_cs_action

  append uja00_cs_attr-rowflag to
  : ld_s__mbr_attr-t_field_name
  , ld_s__hier-t_field_name
  .

  append ld_s__comp to: ld_t__comp_hier, ld_t__comp_attr.

  lr_o__structdescr ?= cl_abap_structdescr=>create( ld_t__comp_attr ).
  create data lr_s__comp_attr type handle lr_o__structdescr.
  assign lr_s__comp_attr->* to <ld_s__attr>.
  create data ld_s__mbr_attr-content like standard table of <ld_s__attr>.
  assign ld_s__mbr_attr-content->* to <ld_t__attr>.


  lr_o__structdescr ?= cl_abap_structdescr=>create( ld_t__comp_hier ).
  create data lr_s__comp_hier type handle lr_o__structdescr.
  assign lr_s__comp_hier->* to <ld_s__hier>.
  create data ld_s__hier-content like standard table of <ld_s__hier>.
  assign ld_s__hier-content->* to <ld_t__hier>.

  lr_o__structdescr ?= cl_abap_structdescr=>create( ld_t__comp_seq ).
  create data lr_s__comp_seq type handle lr_o__structdescr.
  assign  lr_s__comp_seq->* to <ld_s__seq>.
  create data ld_s__mbr_seq-content like standard table of <ld_s__seq>.
  assign ld_s__mbr_seq-content->* to <ld_t__seq>.

*--------------------------------------------------------------------*
* Создание дельта таблицы со всеми записями
*--------------------------------------------------------------------*
  loop at <ld_t__dim> assigning <ld_s__dim>.

    clear
    : <ld_s__attr>
    , <ld_s__hier>
    , <ld_s__seq>
    .

    mbr_seq> <ld_s__attr> sy-tabix.
    mbr_seq> <ld_s__seq>  sy-tabix.
    rowflag> <ld_s__attr> uj00_cs_action-insert.
    rowflag> <ld_s__hier> uj00_cs_action-insert.

    move-corresponding <ld_s__dim> to <ld_s__attr>.
    move-corresponding <ld_s__dim> to <ld_s__hier>.
    move-corresponding <ld_s__dim> to <ld_s__seq>.

    append <ld_s__attr> to <ld_t__attr>.
    append <ld_s__hier> to <ld_t__hier>.
    append <ld_s__seq>  to <ld_t__seq>.

  endloop.
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* Сравнение старых измерений с дельта таблицами
*--------------------------------------------------------------------*

  assign lr_t__olddim->* to <ld_t__olddim>.

  loop at <ld_t__olddim> reference into lr_s__olddim. " поиск записей для удаления и изменения
    ld_v__oldseq = sy-tabix.

    assign lr_s__olddim->('ID') to <ld_v__old_id>.

    read table <ld_t__attr>
         with key ('ID') = <ld_v__old_id>
         assigning <ld_s__attr>.

    ld_v__newseq = sy-tabix.

    if sy-subrc ne 0. " если запись удалена
      append initial line to <ld_t__attr> assigning <ld_s__initline>.
      id>      <ld_s__initline> <ld_v__old_id>.
      rowflag> <ld_s__initline> uj00_cs_action-delete.
    else.

      assign lr_s__olddim->* to <ld_s__olddim>.

*--------------------------------------------------------------------*
* Check ATTRIBUTES
*--------------------------------------------------------------------*
      ld_f__attr_mod = abap_false.

      loop at ld_s__mbr_attr-t_field_name assigning <ld_v__field>.

        find first occurrence of regex `\<PARENTH\d+\>` in <ld_v__field>.
        check sy-subrc ne 0.

        assign component <ld_v__field> of structure <ld_s__attr> to <ld_v__newelement>.
        check sy-subrc = 0.

        assign lr_s__olddim->(<ld_v__field>) to <ld_v__oldelement>.
        check sy-subrc = 0.

        if <ld_v__oldelement> ne <ld_v__newelement>.
          rowflag> <ld_s__attr> uj00_cs_action-modify.
          ld_f__attr_mod = abap_true.
          exit.
        endif.
      endloop.

      " если атрибуты не были изменены, то удаляем из дельта таблицы
      if ld_f__attr_mod = abap_false.
        delete <ld_t__attr> index ld_v__newseq.
      endif.
*--------------------------------------------------------------------*


*--------------------------------------------------------------------*
* Check Hierarhy
*--------------------------------------------------------------------*
      read table <ld_t__hier>
           with key ('ID') = <ld_v__old_id>
           assigning <ld_s__hier>.

      ld_v__newseq = sy-tabix.

      if sy-subrc = 0.
        ld_f__hier_mod = abap_false.

        loop at ld_s__hier-t_field_name assigning <ld_v__field> where
          table_line <> uja00_cs_attr-rowflag.

          assign component <ld_v__field> of structure <ld_s__hier> to <ld_v__newelement>.
          check sy-subrc = 0.

          assign lr_s__olddim->(<ld_v__field>) to <ld_v__oldelement>.
          if sy-subrc = 0.

            if <ld_v__oldelement> ne <ld_v__newelement>.
              rowflag> <ld_s__hier> uj00_cs_action-modify.
              ld_f__hier_mod = abap_true.
              exit.
            endif.
          else.
            if <ld_v__newelement> is not initial.
              rowflag> <ld_s__hier> uj00_cs_action-modify.
              ld_f__hier_mod = abap_true.
              exit.
            endif.
          endif.
        endloop.

        " если атрибуты не были изменены, то удаляем из дельта таблицы
        if ld_f__hier_mod = abap_false.
          delete <ld_t__hier> index ld_v__newseq.
        endif.
      endif.
*--------------------------------------------------------------------*


*--------------------------------------------------------------------*
* Check SEQ
*--------------------------------------------------------------------*
      read table <ld_t__seq>
           with key ('ID') = <ld_v__old_id>
           assigning <ld_s__seq>.

      ld_v__newseq = sy-tabix.

      if sy-subrc = 0.
        assign component uja00_cs_attr-mbr_seq of structure <ld_s__seq> to <ld_v__newelement>.

        if <ld_v__newelement> = ld_v__oldseq.
          delete <ld_t__seq> index ld_v__newseq.
        endif.
      endif.
    endif.
*--------------------------------------------------------------------*

  endloop.



*--------------------------------------------------------------------*
* Convert itab to CSV
*--------------------------------------------------------------------*
  types
  : begin of ty_s__str
  , cp  type string
  , end of ty_s__str
  .

  data
  : ld_t__strtab             type standard table of string
  , ld_s__strtab             type string
  , ld_s__str2xstr           type string
  , ld_s__xstring            type xstring
  , ld_v__length             type i
  , ld_t__content            type standard table of x255 with non-unique default key
  , ld_v__deltaproperty      type ujf_doc-doc_content
  , ld_v__deltasequence      type ujf_doc-doc_content
  , ld_v__deltahierarchy     type ujf_doc-doc_content
  , ld_v__xml                type ujf_doc-doc_content
  .

*--------------------------------------------------------------------*
* ATTRIBUTES
*--------------------------------------------------------------------*
  loop at ld_s__mbr_attr-t_field_name assigning <ld_v__field>.
    if sy-tabix = 1.
      ld_s__strtab = <ld_v__field>.
    else.
      concatenate ld_s__strtab <ld_v__field> into ld_s__strtab separated by cl_abap_char_utilities=>horizontal_tab.
    endif.
  endloop.

  append ld_s__strtab to ld_t__strtab.

  loop at <ld_t__attr> assigning <ld_s__attr>.
    loop at ld_s__mbr_attr-t_field_name assigning <ld_v__field>.

      assign component <ld_v__field> of structure <ld_s__attr> to <ld_v__elem>.

      if sy-tabix = 1.
        ld_s__strtab = <ld_v__elem>.
      else.
        concatenate ld_s__strtab <ld_v__elem> into ld_s__strtab separated by cl_abap_char_utilities=>horizontal_tab.
      endif.

    endloop.

    append ld_s__strtab to ld_t__strtab.

  endloop.

  loop at ld_t__strtab into ld_s__strtab.
    if sy-tabix = 1.
      ld_s__str2xstr = ld_s__strtab.
    else.
      concatenate ld_s__str2xstr ld_s__strtab into ld_s__str2xstr separated by cl_abap_char_utilities=>cr_lf.
    endif.
  endloop.

  call function 'SCMS_STRING_TO_XSTRING'
    exporting
      text           = ld_s__str2xstr
*       MIMETYPE       = ' '
     encoding       = '4103'
     importing
       buffer         = ld_v__deltaproperty.

  clear
  : ld_s__str2xstr
  , ld_t__strtab
  , ld_s__strtab
  .


*--------------------------------------------------------------------*
* HIERARCHY
*--------------------------------------------------------------------*
  loop at ld_s__hier-t_field_name assigning <ld_v__field>.
    if sy-tabix = 1.
      ld_s__strtab = <ld_v__field>.
    else.
      concatenate ld_s__strtab <ld_v__field> into ld_s__strtab separated by cl_abap_char_utilities=>horizontal_tab.
    endif.
  endloop.

  append ld_s__strtab to ld_t__strtab.

  loop at <ld_t__hier> assigning <ld_s__hier>.
    loop at ld_s__hier-t_field_name assigning <ld_v__field>.

      assign component <ld_v__field> of structure <ld_s__hier> to <ld_v__elem>.

      if sy-tabix = 1.
        ld_s__strtab = <ld_v__elem>.
      else.
        concatenate ld_s__strtab <ld_v__elem> into ld_s__strtab separated by cl_abap_char_utilities=>horizontal_tab.
      endif.

    endloop.

    append ld_s__strtab to ld_t__strtab.

  endloop.

  loop at ld_t__strtab into ld_s__strtab.
    if sy-tabix = 1.
      ld_s__str2xstr = ld_s__strtab.
    else.
      concatenate ld_s__str2xstr ld_s__strtab into ld_s__str2xstr separated by cl_abap_char_utilities=>cr_lf.
    endif.
  endloop.

  call function 'SCMS_STRING_TO_XSTRING'
    exporting
      text           = ld_s__str2xstr
*       MIMETYPE       = ' '
     encoding       = '4103'
     importing
       buffer         = ld_v__deltahierarchy.

  clear
  : ld_s__str2xstr
  , ld_t__strtab
  , ld_s__strtab
  .

*--------------------------------------------------------------------*
* SEQUENCE
*--------------------------------------------------------------------*
  loop at ld_s__mbr_seq-t_field_name assigning <ld_v__field>.
    if sy-tabix = 1.
      ld_s__strtab = <ld_v__field>.
    else.
      concatenate ld_s__strtab <ld_v__field> into ld_s__strtab separated by cl_abap_char_utilities=>horizontal_tab.
    endif.
  endloop.

  append ld_s__strtab to ld_t__strtab.

  loop at <ld_t__seq> assigning <ld_s__seq>.
    loop at ld_s__mbr_seq-t_field_name assigning <ld_v__field>.

      assign component <ld_v__field> of structure <ld_s__seq> to <ld_v__elem>.

      if sy-tabix = 1.
        ld_s__strtab = <ld_v__elem>.
      else.
        concatenate ld_s__strtab <ld_v__elem> into ld_s__strtab separated by cl_abap_char_utilities=>horizontal_tab.
      endif.

    endloop.

    append ld_s__strtab to ld_t__strtab.

  endloop.

  loop at ld_t__strtab into ld_s__strtab.
    if sy-tabix = 1.
      ld_s__str2xstr = ld_s__strtab.
    else.
      concatenate ld_s__str2xstr ld_s__strtab into ld_s__str2xstr separated by cl_abap_char_utilities=>cr_lf.
    endif.
  endloop.

  call function 'SCMS_STRING_TO_XSTRING'
    exporting
      text           = ld_s__str2xstr
*       MIMETYPE       = ' '
     encoding       = '4103'
     importing
       buffer         = ld_v__deltasequence .

  clear
  : ld_s__str2xstr
  , ld_t__strtab
  , ld_s__strtab
  .


*--------------------------------------------------------------------*
* Save
*--------------------------------------------------------------------*
  data lr_o__dim type ref to cl_uja_dim.

  create object lr_o__dim
    exporting
      i_appset_id = i_appset_id
      i_dimension = i_dimension.

  call method lr_o__dim->if_uja_dim_data~read_md2xml
    importing
      e_xml = ld_v__xml.

  call method lr_o__dim->save_dim_files
    exporting
      i_xml           = ld_v__xml
      i_delta_member  = ld_v__deltaproperty
      i_delta_hier    = ld_v__deltahierarchy
      i_delta_mbr_seq = ld_v__deltasequence.

  call function 'DB_COMMIT'.

endfunction.
