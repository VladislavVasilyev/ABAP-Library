method create_container____________nv.

  data
  : ld_s__containers            type zbnlt_s__containers
  , ld_v__packagesize           type i
  , ld_v__infocube              type rsinfoprov
  , ld_t__attrlist              type uja_t_attr_name
  , ld_f__supresszero           type rs_bool
  , lr_o__container             type ref to zcl_bdnl_container
  , ld_s__container             type ty_s__current_for
  .

  field-symbols
  : <ld_s__stack>               type zbnlt_s__stack_container
  , <ld_s__stack1>              type zbnlt_s__container
  , <ld_s__master>              type zbnlt_s__stack_container
  , <ld_s__containers>          type zbnlt_s__containers
  , <ld_s__dimlist>             type zbd00_s_ch_key
  .


*  read table gd_s__stack-containers1
*     with key  tablename = i_v__tablename
*     assigning <ld_s__stack1>.
*
*  ld_s__container-container ?= <ld_s__stack1>-container.
*  ld_s__container-container->set_packagesize( ld_v__packagesize ).
*  lr_o__container->create_table( ).
*
*  append ld_s__container to gd_t__for_containers1.
*
*
*
*
*  return.
*  read table gd_t__for_containers
*        with key tablename = i_v__tablename
*        reference into e_s__table.
*
*  if sy-subrc = 0.
*    return.
*  else.
*
*    read table gd_t__containers
*         with key tablename = i_v__tablename
*                  script    = gd_v__script
*         assigning <ld_s__containers>.
*
*    if sy-subrc = 0.
*      if i_s__for-tablename = i_v__tablename. " if master table
*        if <ld_s__containers>-read_mode = zbd0c_read_mode-full or
*           <ld_s__containers>-read_mode = zbd0c_read_mode-arfc.
*          if i_s__for-packagesize = -1.
*            ld_s__containers = <ld_s__containers>.
**            ld_s__containers-mode = zblnc_keyword-master.
*
*            " необходимо сбросить индекс
*            ld_s__containers-object->reset_index( ).
*            append ld_s__containers to gd_t__for_containers reference into e_s__table.
*            return.
*          endif.
*        endif.
*      else. " not master table
*
*      endif.
*    endif.
*  endif.
*
*  read table gd_s__stack-containers
*       with key  tablename = i_v__tablename
*       assigning <ld_s__stack>.
*
*  ld_s__containers-tablename  = <ld_s__stack>-tablename.
*  ld_s__containers-command    = <ld_s__stack>-command.
*  ld_s__containers-turn       = <ld_s__stack>-turn.
*  ld_s__containers-type_table = <ld_s__stack>-type_table.
*  ld_s__containers-script     = gd_v__script.
*  ld_s__containers-read_mode  = zbd0c_read_mode-arfc.
*  ld_v__packagesize           = -1.
*
**---> new stack
*  read table gd_s__stack-containers1
*       with key  tablename = i_v__tablename
*       assigning <ld_s__stack1>.
*  lr_o__container ?= <ld_s__stack1>-container.
**---< new stack
*
*
*  " master table
*  if i_s__for-tablename = i_v__tablename.
*    if i_s__for-packagesize = -1.
*      ld_s__containers-read_mode = zbd0c_read_mode-full.
*      if <ld_s__stack>-appl_id = zblnc_keyword-generate.
*        ld_s__containers-read_mode = zbd0c_read_mode-genfull.
*      endif.
*    else.
*      ld_s__containers-read_mode = zbd0c_read_mode-pack.
*      if <ld_s__stack>-appl_id = zblnc_keyword-generate.
*        ld_s__containers-read_mode = zbd0c_read_mode-genpack.
*      endif.
*    endif.
*    ld_v__packagesize = i_s__for-packagesize.
*  endif.
*
*  case <ld_s__stack>-command.
*
*    when zblnc_keyword-select.
*
*      if i_s__for-tablename = i_v__tablename.
*        ld_s__containers-log_turn = 2.
*      else.
*        ld_s__containers-log_turn = 1.
*      endif.
*
*      lr_o__container->set_packagesize( ld_v__packagesize ).
*      ld_s__containers-object ?= lr_o__container->create_table( ).
*      ld_s__containers-container ?= lr_o__container.
*
*      if <ld_s__stack>-appset_id eq zblnc_keyword-bp.
*      else.
*        if <ld_s__stack>-appl_id is not initial.
*        elseif <ld_s__stack>-dimension is not initial.
*          ld_s__containers-read_mode = zbd0c_read_mode-gendim.
*        endif.
*      endif.
*
*    when zblnc_keyword-ctable.
*      ld_s__containers-log_turn = 4.
*
*      if <ld_s__stack>-appl_id = zblnc_keyword-custom.
*
*
*      else.
*        create object ld_s__containers-object
*          exporting
*            i_appset_id = <ld_s__stack>-appset_id
*            i_appl_id   = <ld_s__stack>-appl_id
*            i_type_pk   = <ld_s__stack>-tech_type_table
*            it_dim_list = <ld_s__stack>-dim_list
*            it_const    = <ld_s__stack>-const.
*      endif.
*
*      ld_s__containers-init = abap_true.
*      ld_s__containers-read_mode = zbd0c_read_mode-full.
*
*    when zblnc_keyword-tablefordown.
*      ld_s__containers-log_turn = 5.
*
*      ld_s__containers-object ?= lr_o__container->create_table( ).
*      ld_s__containers-container ?= lr_o__container.
**      ld_s__containers-init = abap_true.
*
*      if i_s__for-packagesize = -1.
*        ld_s__containers-read_mode = zbd0c_read_mode-full.
*      else.
*        ld_s__containers-read_mode = zbd0c_read_mode-pack.
*      endif.
*
*    when zblnc_keyword-clear.
*      ld_s__containers-log_turn = 0.
*
*      create object ld_s__containers-object
*        exporting
*          i_appset_id = <ld_s__stack>-appset_id
*          i_appl_id   = <ld_s__stack>-appl_id
*          i_type_pk   = zbd0c_ty_tab-has_unique_dk
*          it_range    = <ld_s__stack>-range
*          if_invert   = abap_true.
*
*    when others.
*      return.
*  endcase.
*
*  append ld_s__containers to gd_t__containers reference into e_s__table.
*
*  if i_s__for is supplied.
*    append ld_s__containers to gd_t__for_containers.
*  endif.

endmethod.
