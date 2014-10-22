method create_worksheet.

  data
  : ld_i__element_properties    type ref to if_ixml_element
  , ld_v__value                 type string
  , ld_o__xmldoc                type ref to cl_xml_document
  , ld_v__retcode               type sysubrc
  , lr_i__worksheet             type ref to if_ixml_element
  , lr_i__table                 type ref to if_ixml_element
  , lr_i__names                 type ref to if_ixml_element
  , lr_i__namedrange            type ref to if_ixml_element
  , lr_i__namedcell             type ref to if_ixml_element
  , lr_i__worksheetoptions      type ref to if_ixml_element
  , lr_i__autofilter            type ref to if_ixml_element
  , lr_i__datavalidation        type ref to if_ixml_element
  , lr_i__element               type ref to if_ixml_element
  , lr_i__row                   type ref to if_ixml_element
  , lr_i__cell                  type ref to if_ixml_element
  , lr_i__data                  type ref to if_ixml_element
  , lr_o__struct                type ref to cl_abap_structdescr
  , lr_s__line                  type ref to data
  , ld_v__type                  type string
  , ld_t__comp                  type abap_compdescr_tab
  , ld_t__sequence              type zvcst_t__sequence
  , ld_v__columncount           type string
  , ld_v__rowcount              type string
  , ld_v__str                   type string
  , ld_v__cnt                   type i
  , ld_v__numfield              type i
  , ld_v__len                   type p length 4 decimals 2
  , ld_v__lencomp               type p length 4 decimals 2
  .

  field-symbols
  : <ld_t__table>               type any table
  , <ld_s__table>               type any
  , <ld_s__comp>                type  abap_compdescr
  , <ld_v__elem>                type any
  , <ld_s__sequence>            type zvcst_s__sequence

  .

  assign i_s__worksheet-table->* to <ld_t__table>.

  create data lr_s__line like line of <ld_t__table>.
  lr_o__struct ?= cl_abap_structdescr=>describe_by_data_ref( lr_s__line ).

  if i_s__worksheet-sequence is not initial.
    ld_t__sequence = i_s__worksheet-sequence.
    sort ld_t__sequence by sequence field ascending.
    loop at ld_t__sequence assigning <ld_s__sequence>.
      read table lr_o__struct->components
           with table key name = <ld_s__sequence>-field
           assigning <ld_s__comp>.

      if sy-subrc = 0.
        append <ld_s__comp> to ld_t__comp.
      endif.

    endloop.
  else.
    loop at lr_o__struct->components assigning <ld_s__comp>.
      append <ld_s__comp> to ld_t__comp.
    endloop.
  endif.

  ld_v__columncount = lines( ld_t__comp ).
  ld_v__rowcount = lines( <ld_t__table> ) + 1.

  condense ld_v__columncount no-gaps.
  condense ld_v__rowcount no-gaps.

* Create Worksheet
  set_simp_el> lr_i__worksheet `Worksheet` `` gr_i__element_root.
  set_attr_ns>      lr_i__worksheet `ss` `Name`    i_s__worksheet-name.

  if i_s__worksheet-f__filter = abap_true.
    concatenate `=` i_s__worksheet-name `!` `R1C1:R1C` ld_v__columncount into ld_v__str.
    set_simp_el> lr_i__names      `Names`      `` lr_i__worksheet.
    set_simp_el> lr_i__namedrange `NamedRange` `` lr_i__names.
    set_attr_ns> lr_i__namedrange
    : `ss` `Name`       `_FilterDatabase`
    , `ss` `RefersTo`   ld_v__str
    , `ss` `Hidden`     `1`.
  endif.


  call method gd_i__document->create_simple_element
    exporting
      name   = 'Table'
      parent = lr_i__worksheet
    receiving
      rval   = lr_i__table.

  set_attr_ns> lr_i__table
  : `ss` 'ExpandedColumnCount'  ld_v__columncount
  , `ss` 'ExpandedRowCount'     ld_v__rowcount
  , `x`  'FullColumns'          '1'
  , `x`  'FullRows'             '1'
  , 'ss' 'DefaultRowHeight'     '15'.


  if i_s__worksheet-f__filter = abap_true.
    set_simp_el>  lr_i__worksheetoptions `WorksheetOptions` `` lr_i__worksheet.
    set_attr_ns>  lr_i__worksheetoptions `` `xmlns`         `urn:schemas-microsoft-com:office:excel`.
    set_simp_el>  lr_i__element          `Unsynced`         ``      lr_i__worksheetoptions.
    set_simp_el>  lr_i__element          `Selected`         ``      lr_i__worksheetoptions.
    set_simp_el>  lr_i__element          `FreezePanes`      ``      lr_i__worksheetoptions.
    set_simp_el>  lr_i__element          `FrozenNoSplit`    ``      lr_i__worksheetoptions.
    set_simp_el>  lr_i__element          `SplitHorizontal`  `1`     lr_i__worksheetoptions.
    set_simp_el>  lr_i__element          `TopRowBottomPane` `1`     lr_i__worksheetoptions.
    if i_s__worksheet-f__splitvertical = abap_true.
      set_simp_el>  lr_i__element         `SplitVertical`    `1`     lr_i__worksheetoptions.
      set_simp_el>  lr_i__element         `LeftColumnRightPane` `1`  lr_i__worksheetoptions.
    endif.
    set_simp_el>  lr_i__element          `ActivePane`       `0`     lr_i__worksheetoptions.
    set_simp_el>  lr_i__element          `ProtectObjects`   `False` lr_i__worksheetoptions.
    set_simp_el>  lr_i__element          `ProtectScenarios` `False` lr_i__worksheetoptions.

    concatenate `R1C1:R1C` ld_v__columncount into ld_v__str.
    set_simp_el> lr_i__autofilter  `AutoFilter` `` lr_i__worksheet.
    set_attr_ns>
    : lr_i__autofilter  `` `xmlns` `urn:schemas-microsoft-com:office:excel`
    , lr_i__autofilter  `x` `Range` ld_v__str.
  endif.

  loop at ld_t__comp assigning <ld_s__comp>.
    set_simp_el> lr_i__element  `Column` `` lr_i__table.

    ld_v__len = strlen( <ld_s__comp>-name ).

    ld_v__len = ld_v__len * '8.2'.
    ld_v__lencomp = ( <ld_s__comp>-length / 2  + 5 ) * 5.

    if ld_v__len > ld_v__lencomp.
      ld_v__value = ld_v__len.
    else.
      ld_v__value = ld_v__lencomp.
    endif.
    condense ld_v__value no-gaps.
    set_attr_ns> lr_i__element `ss` `Width` ld_v__value.
  endloop.

  " Печать Шапки
  set_simp_el> lr_i__row `Row` `` lr_i__table.
  set_attr_ns>      lr_i__row `ss` 'AutoFitHeight' `0`.




  loop at ld_t__comp assigning <ld_s__comp>.
    add 1 to ld_v__cnt.
    ld_v__value           = <ld_s__comp>-name.

    set_simp_el> lr_i__cell `Cell` `` lr_i__row.
    set_attr_ns> lr_i__cell `ss`  'StyleID' 'Header'.
    set_simp_el> lr_i__data `Data` ld_v__value lr_i__cell.
    set_attr_ns> lr_i__data `ss` `Type` `String`.

    if i_s__worksheet-f__filter = abap_true.
      set_simp_el>     lr_i__namedcell  `NamedCell` `` lr_i__cell.
      set_attr_ns>          lr_i__namedcell  `ss` `Name` `_FilterDatabase`.
    endif.

    if i_s__worksheet-f__validtextlength = abap_true and <ld_s__comp>-type_kind = cl_abap_structdescr=>typekind_char.
      set_simp_el> lr_i__datavalidation `DataValidation` `` lr_i__worksheet.
      set_attr_ns> lr_i__datavalidation `` `xmlns` `urn:schemas-microsoft-com:office:excel`.

      ld_v__value = ld_v__cnt.
      concatenate `C` ld_v__value into ld_v__value.
      set_simp_el> lr_i__element        `Range` ld_v__value  lr_i__datavalidation.
      set_simp_el> lr_i__element        `Type` `TextLength`  lr_i__datavalidation.
      set_simp_el> lr_i__element        `Qualifier` `LessOrEqual`  lr_i__datavalidation.

      ld_v__value = <ld_s__comp>-length / 2.

      set_simp_el> lr_i__element        `Value` ld_v__value  lr_i__datavalidation.
    endif.

  endloop.


  " Печать таблицы
  loop at <ld_t__table> assigning <ld_s__table>.

    set_simp_el> lr_i__row `Row` `` lr_i__table.
    set_attr_ns>      lr_i__row `ss` 'AutoFitHeight' `0`.

    loop at ld_t__comp assigning <ld_s__comp>.
      ld_v__numfield = sy-tabix.

      assign component <ld_s__comp>-name of structure <ld_s__table> to <ld_v__elem>.
      check sy-subrc is initial.

      set_simp_el> lr_i__cell `Cell` `` lr_i__row.

      case <ld_s__comp>-type_kind.
        when 'I' or 'P' or 'F' or 'N'.
          ld_v__type = 'Number'.
          ld_v__value = <ld_v__elem>.
          condense ld_v__value no-gaps.
        when 'D' or 'T'.
          ld_v__type = 'String'.
*          write <ld_v__elem> to ld_v__text.
          ld_v__value = <ld_v__elem>. "ld_v__text.
        when others.
*          l_value = <field>.    "Without conversion exit
*          write <field> to l_text.
*          shift l_text left deleting leading space.
          ld_v__value = <ld_v__elem>.
          ld_v__type = 'String'.
      endcase.

      if i_s__worksheet-f__splitvertical = abap_true and ld_v__numfield = 1.
        set_attr_ns> lr_i__cell `ss` `StyleID` `Firstcolumn`.
      endif.

      set_simp_el> lr_i__data `Data` ld_v__value lr_i__cell.
      set_attr_ns>      lr_i__data `ss` `Type` ld_v__type.
    endloop.
  endloop.


endmethod.
