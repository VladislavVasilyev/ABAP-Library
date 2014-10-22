*"* protected components of class ZCL_VCS__BPCS__XLTP
*"* do not include other source files here!!!
protected section.

  data:
    gd_t__xltp type standard table of ty_s__xltp with non-unique default key .

  data gd_t__source_excl type standard table of ty_s__source with non-unique default key.

  methods create_object
    redefinition .
  methods create_path
    redefinition .
  methods crosssources
    redefinition .
  methods download
    redefinition .
  methods get_type_object
    redefinition .
  methods read_object
    redefinition .
  methods read_objects
    redefinition .
  methods read_objects_choose
    redefinition .
  methods write_object_choose
    redefinition .
