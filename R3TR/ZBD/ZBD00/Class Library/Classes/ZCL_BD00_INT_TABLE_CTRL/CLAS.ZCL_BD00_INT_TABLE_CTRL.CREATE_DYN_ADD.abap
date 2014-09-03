method create_dyn_add.

  data
  : lt_types_struct        type ty_t_string
  , lt_types_struct_add    type ty_t_string
  , lt_types_table         type ty_t_string
  , lt_method              type ty_t_string
  , lt_code                type ty_t_string
  , mess                   type string
  , prog                   type string
  , lin                    type i
  .

  get_code_types_struct( exporting io_model = io_tg->gr_o__model
                                   name     = cs_ty_struct
                         importing code     = lt_types_struct ).

  get_code_types_struct( exporting io_model = io_line->gr_o__model
                                   name     = cs_ty_struct_rel
                         importing code     = lt_types_struct_add ).

  get_code_types_table(  exporting name     = cs_ty_table
                                   io_model = io_tg->gr_o__model
                                   name_ty  = cs_ty_struct
                         importing code     = lt_types_table ).

  get_code_add_line(     exporting io_tg    = io_tg
                                   io_line  = io_line
                         importing code     = lt_method ).


*╔═══════════════════════════════════════════════════════════════════╗
*║ Формирование текста программы                                     ║
*╠═══════════════════════════════════════════════════════════════════╣
  mac__append_to_itab lt_code
    :`program.`
    ,`class dyn definition inheriting from zcl_bd00_int_table`
    ,`  final`
    ,`  create public.`
    ,`  public section.`
    ,`  type-pools: abap, zbd0c.`
    ,`  methods add redefinition.`
    ,`  methods next redefinition.`
    .

  append lines of lt_types_struct       to lt_code.
  append lines of lt_types_struct_add   to lt_code.
  append lines of lt_types_table        to lt_code.

  mac__append_to_itab lt_code
    :`  methods`
    ,`   : constructor`
    ,`           importing io_tg      type ref to zcl_bd00_appl_ctrl`
    ,`                     io_line    type ref to zcl_bd00_appl_ctrl.`
    ,`  private section.`
    ,`  data lr_result   type ref to ty_line.`
    ,`  data ls_key      type ty_line.`
    ,`  data gr_table    type ref to ty_table.`
    ,`endclass.`
    .

  mac__append_to_itab lt_code
    :`class dyn implementation.`
    ,`  method constructor.`
    ,`   call method super->constructor`
    ,`        exporting io_tg   = io_tg `
    ,`                  io_line = io_line`
    ,`                  mode    = method-add.`
    ,`   field-symbols`
    ,`     : <table> type ty_table.`
    ,`   assign`
    ,`     : gref_table->* to <table>.`
    ,`   get reference of <table> into gr_table.`
    ,`  endmethod.`
    ,` method next. endmethod.`
    .

  append lines of lt_method to lt_code.

  mac__append_to_itab lt_code
    :`endclass.`
    .
*╚═══════════════════════════════════════════════════════════════════╝


*╔═══════════════════════════════════════════════════════════════════╗
*║ Генерация программы                                               ║
*╠═══════════════════════════════════════════════════════════════════╣
  if prog is initial.
    generate subroutine pool lt_code name prog message mess line lin.
    concatenate `\PROGRAM=` prog `\CLASS=DYN` into class.
  endif.
*╚═══════════════════════════════════════════════════════════════════╝
endmethod.
