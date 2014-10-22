method CONSTRUCTOR.

  super->constructor( ).

  data
  : ld_i__nsattribute             type ref to if_ixml_attribute
  , ld_i__element_properties      type ref to if_ixml_element
  , ld_v__value                   type string
  .

  field-symbols
  : <ld_s__worksheet>             type ty_s__worksheet
  .

*--------------------------------------------------------------------*
* Create Header
*--------------------------------------------------------------------*
  " Create root node 'Workbook'
  call method: gd_i__document->create_simple_element
    exporting
      name   = 'Workbook'
      parent = gd_i__document
*      uri  = 'urn:schemas-microsoft-com:office:spreadsheet'
    receiving
      rval   = gr_i__element_root.

  call method gr_i__element_root->set_attribute
    exporting
      name  = 'xmlns'
      value = 'urn:schemas-microsoft-com:office:spreadsheet'.

  call method gd_i__document->create_namespace_decl
    exporting
      name   = 'ss'
      prefix = 'xmlns'
      uri    = 'urn:schemas-microsoft-com:office:spreadsheet'
    receiving
      rval   = ld_i__nsattribute.

  gr_i__element_root->set_attribute_node( ld_i__nsattribute ).

  call method gd_i__document->create_namespace_decl
    exporting
      name   = 'x'
      prefix = 'xmlns'
      uri    = 'urn:schemas-microsoft-com:office:excel'
    receiving
      rval   = ld_i__nsattribute.

  gr_i__element_root->set_attribute_node( ld_i__nsattribute ).

  call method gd_i__document->create_namespace_decl
    exporting
      name   = 'o'
      prefix = 'xmlns'
      uri    = 'urn:schemas-microsoft-com:office:office'
    receiving
      rval   = ld_i__nsattribute.

  gr_i__element_root->set_attribute_node( ld_i__nsattribute ).

  call method gd_i__document->create_namespace_decl
    exporting
      name   = 'html'
      prefix = 'xmlns'
      uri    = 'http://www.w3.org/TR/REC-html40'
    receiving
      rval   = ld_i__nsattribute.

  gr_i__element_root->set_attribute_node( ld_i__nsattribute ).


* Create node for document properties.
  call method gd_i__document->create_simple_element
    exporting
      name   = 'DocumentProperties'
      parent = gr_i__element_root
    receiving
      rval   = ld_i__element_properties.

  ld_v__value = sy-uname.
  call method gd_i__document->create_simple_element
    exporting
      name   = 'Author'
      value  = ld_v__value
      parent = ld_i__element_properties.

  call method gd_i__document->create_simple_element
    exporting
      name   = 'Styles'
      parent = gr_i__element_root
    receiving
      rval   = gr_i__styles.

  create_styles( ).

endmethod.
