method create_object.

  data
  : lr_x__call_module_error type ref to zcx_vcs__call_module_error
  , ld_v__name  type string
  , ld_s__prog  type ty_s__prog
  .

  field-symbols
  : <ld_s__dynpro>    type ty_s__dynpro
  .

  ld_s__prog = i_r__source.

  try.
      " Create program
      call method create_program
        exporting
          i_s__prog  = ld_s__prog
          i_s__tadir = i_s__tadir.

      " Create textpool
      insert textpool ld_s__prog-name from ld_s__prog-textpool-textpool
              language i_s__tadir-masterlang.


      " Create DynPRO
      loop at ld_s__prog-dynpros
           assigning <ld_s__dynpro> .
        call method zcl_vcs_r3tr___dynpro=>create
          exporting
            i_s__dynpro = <ld_s__dynpro>.
      endloop.

    catch zcx_vcs__call_module_error into lr_x__call_module_error.
      raise exception type zcx_vcs_objects_create__r3tr
        exporting
          previous = lr_x__call_module_error
          object   = i_s__tadir-object
          obj_name = i_s__tadir-obj_name.
  endtry.

endmethod.
