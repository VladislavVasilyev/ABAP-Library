*"* protected components of class ZCL_VCS__BPCS__DIMN
*"* do not include other source files here!!!
protected section.

  data:
    gd_t__dimension       type standard table of uja_dimension .
  data:
    gd_t__source          type standard table of zvcst_s__download .
  data:
    gd_t__xml             type standard table of ty_s__dimn with non-unique default key .
  data:
    gd_t__content         type standard table of ty_s__content .

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
  methods READ_OBJECTS
    redefinition .
  methods READ_OBJECTS_CHOOSE
    redefinition .
  methods WRITE_OBJECT_CHOOSE
    redefinition .
