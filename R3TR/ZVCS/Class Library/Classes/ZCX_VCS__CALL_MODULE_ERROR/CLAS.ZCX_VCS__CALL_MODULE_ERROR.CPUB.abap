class ZCX_VCS__CALL_MODULE_ERROR definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

*"* public components of class ZCX_VCS__CALL_MODULE_ERROR
*"* do not include other source files here!!!
public section.

  interfaces IF_T100_MESSAGE .

  constants:
    begin of ZCX_VCS__CALL_MODULE_ERROR,
      msgid type symsgid value 'ZMCL_VCS',
      msgno type symsgno value '009',
      attr1 type scx_attrname value 'MODULE',
      attr2 type scx_attrname value 'EXCEPTION',
      attr3 type scx_attrname value 'ERROR_MESSAGE',
      attr4 type scx_attrname value '',
    end of ZCX_VCS__CALL_MODULE_ERROR .
  constants:
    begin of CX_ERROR_MESSAGE,
      msgid type symsgid value 'ZMCL_VCS',
      msgno type symsgno value '010',
      attr1 type scx_attrname value 'MODULE',
      attr2 type scx_attrname value 'ERROR_MESSAGE',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of CX_ERROR_MESSAGE .
  data MODULE type STRING .
  data ERROR_MESSAGE type STRING .
  constants:
    begin of exc.
    constants not_edited type string value 'NOT_EDITED'.    "#EC NOTEXT
    constants class_not_existing type string value 'CLASS_NOT_EXISTING'. "#EC NOTEXT
    constants not_existing type string value 'NOT_EXISTING'. "#EC NOTEXT
    constants others type string value 'OTHERS'.            "#EC NOTEXT
    constants is_interface type string value 'IS_INTERFACE'. "#EC NOTEXT
    constants model_only type string value 'MODEL_ONLY'.    "#EC NOTEXT
    constants comp_not_existing type string value 'COMP_NOT_EXISTING'. "#EC NOTEXT
    constants deleted type string value 'DELETED'.          "#EC NOTEXT
    constants is_event type string value 'IS_EVENT'.        "#EC NOTEXT
    constants is_class type string value 'IS_CLASS'.        "#EC NOTEXT
    constants is_type type string value 'IS_TYPE'.          "#EC NOTEXT
    constants is_attribute type string value 'IS_ATTRIBUTE'. "#EC NOTEXT
    constants no_method type string value 'NO_METHOD'.      "#EC NOTEXT
    constants enqueue_table_full type string value 'ENQUEUE_TABLE_FULL'. "#EC NOTEXT
    constants include_enqueued type string value 'INCLUDE_ENQUEUED'. "#EC NOTEXT
    constants include_readerror type string value 'INCLUDE_READERROR'. "#EC NOTEXT
    constants include_writeerror type string value 'INCLUDE_WRITEERROR'. "#EC NOTEXT
    constants method_not_existing type string value 'METHOD_NOT_EXISTING'. "#EC NOTEXT
    constants version_not_existing type string value 'VERSION_NOT_EXISTING'. "#EC NOTEXT
    constants inactive_delete type string value 'INACTIVE_DELETE'. "#EC NOTEXT
    constants inactive_new type string value 'INACTIVE_NEW'. "#EC NOTEXT
    constants illegal_input type string value 'ILLEGAL_INPUT'. "#EC NOTEXT
    constants function_not_found type string value 'FUNCTION_NOT_FOUND'. "#EC NOTEXT
    constants invalid_name type string value 'INVALID_NAME'. "#EC NOTEXT
    constants no_program type string value 'NO_PROGRAM'.    "#EC NOTEXT
    constants delimeter_error type string value 'DELIMETER_ERROR'. "#EC NOTEXT
    constants illegal_line_width type string value 'ILLEGAL_LINE_WIDTH'. "#EC NOTEXT
    constants not_convertable type string value 'NOT_CONVERTABLE'. "#EC NOTEXT
    constants not_scanable type string value 'NOT_SCANABLE'. "#EC NOTEXT
    constants cancelled type string value `CANCELLED`.
    constants not_found type string value `NOT_FOUND`.
    constants permission_error type string value `PERMISSION_ERROR`.
    constants put_failure type string value `PUT_FAILURE`.
    constants put_refused type string value `PUT_REFUSED`.


    constants end of exc .
  constants:
    begin of mod.
    constants seo_class_get_include_source type string value `SEO_CLASS_GET_INCLUDE_SOURCE`.
    constants seo_class_get_method_includes type string value `SEO_CLASS_GET_METHOD_INCLUDES`.
    constants seo_class_get_type_source  type string value `SEOCLASS_GET_TYPE_SOURCE`.
    constants seo_class_typeinfo_get type string value `SEO_CLASS_TYPEINFO_GET`.
    constants ddif_doma_get type string value `DDIF_DOMA_GET`.
    constants ddif_dtel_get type string value `DDIF_DTEL_GET`.
    constants ddif_shlp_get type string value `DDIF_SHLP_GET`.
    constants ddif_tabl_get type string value `DDIF_TABL_GET`.
    constants ddif_ttyp_get type string value `DDIF_TTYP_GET`.
    constants ddif_type_get type string value `DDIF_TYPE_GET`.
    constants ddif_view_get type string value `DDIF_VIEW_GET`.
    constants ddif_ttyp_activate type string value `DDIF_TTYP_ACTIVATE`.
    constants seo_exception_read_all type string value `SEO_EXCEPTION_READ_ALL`.
    constants seo_method_get type string value `SEO_METHOD_GET`.
    constants seo_method_get_detail type string value `SEO_METHOD_GET_DETAIL`.
    constants seo_method_get_source type string value `SEO_METHOD_GET_SOURCE`.
    constants seo_parameter_read_all type string value `SEO_PARAMETER_READ_ALL`.
    constants seo_interface_typeinfo_get type string value `SEO_INTERFACE_TYPEINFO_GET`.
    constants pretty_printer type string value `PRETTY_PRINTER`.
    constants read_source type string value `READ_SOURCE`.
    constants rpy_functionmodule_read type string value `RPY_FUNCTIONMODULE_READ`.
    constants rpy_dynpro_read  type string value `RPY_DYNPRO_READ`.
    constants rpy_program_read  type string value `RPY_PROGRAM_READ`.
    constants rs_get_all_includes type string value `RS_GET_ALL_INCLUDES`.
    constants rs_progname_split type string value `RS_PROGNAME_SPLIT`.
    constants seo_section_get_source type string value `SEO_SECTION_GET_SOURCE`.
    constants seo_type_get type string value `SEO_TYPE_GET`.
    constants abap_source_format type string value `ABAP_SOURCE_FORMAT`.
    constants message_classes_get_info type string value `MESSAGE_CLASSES_GET_INFO`.
    constants ddif_ttyp_put type string value `DDIF_TTYP_PUT`.
    constants end of mod .
  data EXCEPTION type STRING .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !MODULE type STRING optional
      !ERROR_MESSAGE type STRING optional
      !EXCEPTION type STRING optional .
