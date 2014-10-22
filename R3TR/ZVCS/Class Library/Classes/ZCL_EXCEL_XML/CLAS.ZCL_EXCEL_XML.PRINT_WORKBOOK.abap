method print_workbook.

  data
  : lr_i__xmlnode         type ref to if_ixml_node
  , ld_t__row             type ty_t__row
  , lr_s__table           type ref to data
  , lr_s__struct          type ref to data
  , ld_v__cnt             type i
  , indent                type i
  , ld_s__worksheet       type zvcst_s__xmlworksheet
  , ld_f__create          type rs_bool
  , ld_t__comp            type cl_abap_structdescr=>component_table
  , ld_s__comp            like line of ld_t__comp
  , lr_o__structdescr     type ref to cl_abap_structdescr
  .

  field-symbols
  : <ld_s__worksheet>     type ty_s__worksheet
  , <ld_s__xmlworksheet>  type zvcst_s__xmlworksheet
  , <ld_t__table>         type standard table
  , <ld_s__table>         type any
  , <ld_v__value>         type any
  , <ld_s__struct>        type any
  , <ld_s__row>           type ty_s__row

  .

  loop at gd_t__worksheet assigning <ld_s__worksheet>.
    lr_i__xmlnode = <ld_s__worksheet>-node->get_first_child( ).

    read table i_t__worksheet
         with key name = <ld_s__worksheet>-name
         assigning <ld_s__xmlworksheet>.

    if sy-subrc = 0.
      if <ld_s__xmlworksheet>-table is bound.
        assign <ld_s__xmlworksheet>-table->* to <ld_t__table>.
      else.
        ld_f__create = abap_true.
      endif.
    elseif i_t__worksheet is initial.
      ld_f__create = abap_true.
      ld_s__worksheet-name = <ld_s__worksheet>-name.
      insert ld_s__worksheet into table i_t__worksheet assigning <ld_s__xmlworksheet>.
    else.
      continue.
    endif.

    clear
    : ld_v__cnt
    , gd_t__header
    , gd_f__header_init
    , ld_t__comp
    .

    do.
      if lr_i__xmlnode is not initial.
        if lr_i__xmlnode->get_name( ) = `Row`.
          add 1 to ld_v__cnt.
          ld_t__row = get_row( lr_i__xmlnode ).

          if gd_f__first_header = abap_true and ld_v__cnt = 1.
            gd_f__header_init = abap_true.
            gd_t__header      = ld_t__row.

            loop at gd_t__header assigning <ld_s__row>.
              translate <ld_s__row>-value to upper case.
            endloop.

            if ld_f__create = abap_true.
              loop at ld_t__row assigning <ld_s__row>.
                ld_s__comp-name = <ld_s__row>-value.
                ld_s__comp-type ?= cl_abap_datadescr=>describe_by_name( `STRING` ).
                append ld_s__comp to ld_t__comp.
              endloop.

              lr_o__structdescr ?= cl_abap_structdescr=>create( ld_t__comp ).

              create data lr_s__struct type handle lr_o__structdescr.
              assign lr_s__struct->* to <ld_s__struct>.
              create data <ld_s__xmlworksheet>-table like standard table of <ld_s__struct>.
              assign <ld_s__xmlworksheet>-table->* to <ld_t__table>.
            endif.
          endif.

          if ld_v__cnt ne 1.
            append initial line to <ld_t__table> assigning <ld_s__table>.
            loop at ld_t__row  assigning <ld_s__row>.
              assign component <ld_s__row>-name of structure <ld_s__table> to <ld_v__value>.
              <ld_v__value> = <ld_s__row>-value.
            endloop.
          endif.
        endif.
      endif.

      lr_i__xmlnode = lr_i__xmlnode->get_next( ).
      if lr_i__xmlnode is initial.
        exit.
      endif.
    enddo.

  endloop.

endmethod.
