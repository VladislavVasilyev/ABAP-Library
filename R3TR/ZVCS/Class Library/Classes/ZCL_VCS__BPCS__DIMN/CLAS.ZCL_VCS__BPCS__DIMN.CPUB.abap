class ZCL_VCS__BPCS__DIMN definition
  public
  inheriting from ZCL_VCS_OBJECTS_STACK
  final
  create public .

*"* public components of class ZCL_VCS__BPCS__DIMN
*"* do not include other source files here!!!
public section.

  types:
    begin of ty_s__content
             , filename       type string
             , appset         type uj_appset_id
             , dimension      type uj_dim_name
             , content        type standard table of x255 with non-unique default key
             , file_length    type i
             , path           type string
             , end of ty_s__content .
  types:
    begin of ty_s__dimn
             , uja_dimension  type uja_dimension
             , ujf_doc        type ujf_doc
             , content        type string
             , end of ty_s__dimn .
  types:
    begin of ty_s__checkobj_dimn.
    include type zvcs_st__bpcsdimn.
    types: checkbox(1) type  c
           , index(4) type c
           , end of ty_s__checkobj_dimn .


             types: begin of ty_s__dimension.
  include type uja_dimension.
  types: index type i.
  types: end of ty_s__dimension.
