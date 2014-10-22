*"* protected components of class ZCL_VCS__R3TR__DOMA
*"* do not include other source files here!!!
protected section.

  data gd_t__doma type standard table of ty_s__doma with non-unique default key.

  methods CREATE_OBJECT
    redefinition .
  methods CREATE_PATH
    redefinition .
  methods CROSSSOURCES
    redefinition .
  methods DOWNLOAD
    redefinition .
  methods GET_TYPE_OBJECT
    redefinition .
  methods READ_OBJECT
    redefinition .
  methods READ_OBJECTS_CHOOSE
    redefinition .
  methods WRITE_OBJECT_CHOOSE
    redefinition .
  methods READ_OBJECTS
    redefinition .
