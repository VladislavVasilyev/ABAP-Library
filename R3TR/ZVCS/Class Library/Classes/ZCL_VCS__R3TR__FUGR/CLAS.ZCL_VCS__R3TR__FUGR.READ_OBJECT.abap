method READ_OBJECT.

  data
  : lr_x__call_module_error type ref to zcx_vcs__call_module_error
  , ld_s__fgroup type ty_s__fgroup
  .

  move i_s__tadir-obj_name      to ld_s__fgroup-area.

  try.
      call method collect_fmodules
        exporting
          area         = ld_s__fgroup-area
        importing
          e_t__fmodule = ld_s__fgroup-fmodules.

      call method collect_funcarea
        exporting
          area          = ld_s__fgroup-area
        importing
          e_t__includes = ld_s__fgroup-includes.

      call method collect_dynpro
        exporting
          area        = ld_s__fgroup-area
        importing
          e_t__dynpro = ld_s__fgroup-dynpros.

    catch zcx_vcs__call_module_error into lr_x__call_module_error.
      raise exception type zcx_vcs_objects_read__r3tr
           exporting obj_name = i_s__tadir-obj_name
                     object   = i_s__tadir-object
                     previous = lr_x__call_module_error.
  endtry.

**********************************************************************
* Save TXT
**********************************************************************
      data ld_s__txtsource type zvcst_s__source_path.

      ld_s__txtsource-pathnode = `/FMODULES/item/SOURCE`.
      ld_s__txtsource-pathname = `/FMODULES/item/FUNCNAME`.
      append  ld_s__txtsource to e_t__txtsource.

      ld_s__txtsource-pathnode = `/INCLUDES/item/SOURCE`.
      ld_s__txtsource-pathname = `/INCLDES/item/INCLUDE`.
      append  ld_s__txtsource to e_t__txtsource.

**********************************************************************

  e_s__source = ld_s__fgroup.

endmethod.
