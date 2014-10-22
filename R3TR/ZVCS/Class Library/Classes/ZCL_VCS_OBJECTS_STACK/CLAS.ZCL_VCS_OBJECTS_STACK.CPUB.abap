*----------------------------------------------------------------------*
*       CLASS ZCL_VCS_OBJECTS_STACK  DEFINITIO
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
class zcl_vcs_objects_stack definition
  public
  abstract
  create public

  global friends zcl_vcs_objects .

*"* public components of class ZCL_VCS_OBJECTS_STACK
*"* do not include other source files here!!!
  public section.
    type-pools zvcsc .
    type-pools zvcst .

    constants cs_time_zone type ttzz-tzone value 'RUS03'.   "#EC NOTEXT
    class-data cd_r__appset_id type zvcst_t__appset .
    class-data cd_r__appl_id type zvcst_t__application .
    class-data cd_r__dimension type zvcst_t__dimension .
    class-data cd_f__lgf  type rs_bool.
    class-data cd_f__pack	type rs_bool.
    class-data cd_f__xltp	type rs_bool.
    class-data cd_f__dimn	type rs_bool.
    class-data cd_t__object	type zvcst_t__r3tr_obj.

    types: begin of ty_s__tadir.
    include type tadir.
    types tabclass type tabclass.
    types:  index type i,
    end of ty_s__tadir.

    types ty_t__tadir type standard table of ty_s__tadir with non-unique default key.

    types: begin of ty_s__upload
           , source type ref to data
           , tadir type ty_s__tadir
           , end of ty_s__upload.

    types ty_t__upload  type standard table of ty_s__upload with non-unique default key.

    types: begin of ty_s__checkobj_r3tr.
    include type seoscokey.
    types: checkbox(1) type  c
           , index(4) type c
           , end of ty_s__checkobj_r3tr.

    types ty_t__checkobj_r3tr type standard table of ty_s__checkobj_r3tr with non-unique default key.


    class-methods check_type
      importing
        !type type zvcst_s__object
      returning
        value(check) type rs_bool .
    class-methods class_constructor .
