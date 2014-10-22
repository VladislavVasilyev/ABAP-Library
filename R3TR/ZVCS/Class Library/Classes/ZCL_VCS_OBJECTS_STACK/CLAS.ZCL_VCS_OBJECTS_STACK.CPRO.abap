*"* protected components of class ZCL_VCS_OBJECTS_STACK
*"* do not include other source files here!!!
protected section.

  class zcl_vcs_r3tr___upload definition load .
  data gd_t__upload_file type zcl_vcs_r3tr___upload=>ty_t__filelist .

  data gd_t__tadir type standard table of zvcst_s__tadir with non-unique default key.
  data gd_t__source type zvcst_t__download.
  data gd_t__upload type ty_t__upload.

  methods write_object_choose
  abstract
    importing
      !i_v__form_name type form_name .
  methods read_objects_choose
  abstract
    importing
      !i_v__form_name type form_name .
  methods read_objects
  abstract .
  methods get_type
  final
    returning
      value(type) type string .
  methods get_handle
  final
    returning
      value(handle) type ref to cl_abap_datadescr .
  methods download
  abstract
    importing
      !i_v__path type string .
  methods create_path
  abstract
    importing
      !i_s__path type zvcst_s__path
      !i_s__dir type any
    exporting
      !e_v__path type string
      !e_v__xmlname type string
      !e_v__mastername type string
      !e_v__extsrcname type string .
  methods create_object
  abstract
    importing
      !i_r__source type any optional
      !i_s__tadir type zvcst_s__tadir optional
    raising
      zcx_vcs_objects_create .
  methods crosssources
  abstract
    importing
      !i_s__tadir type zvcst_s__tadir
    exporting
      !e_t__tadir type zvcst_t__tadir .
  methods get_type_object
  abstract
    exporting
      !type type zvcst_s__object
      !tysource type string .
  methods read_object
  abstract
    importing
      !i_s__tadir type zvcst_s__tadir
    exporting
      !e_t__txtsource type zvcst_t__source_path
      !e_s__source type any
    raising
      zcx_vcs_objects_read .
