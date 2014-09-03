method rpy_functionmodule_read.

  mac__module `RPY_FUNCTIONMODULE_READ`.

  data
  : include type trdir-name
  , zeilen type sy-tabix
  , ld_s__tfdir type tfdir
  , ld_s__funct type funct
  , ld_s__tftit type tftit
  , ld_s__docu type funct
  , ld_t__docu like standard table of ld_s__docu with non-unique default key
  , oref type ref to cx_root
  , error_message type string
  .

  field-symbols
  : <ld_s__documentation> like line of documentation
  , <ld_s__docu>          type funct
  .

  select single area
       from enlfdir into area
       where funcname = functionname.

    if sy-subrc ne 0.
      raise exception type zcx_vcs__call_module_error
      exporting textid = zcx_vcs__call_module_error=>cx_error_message
                error_message = `Cant read ENLFDIR table`
                module = gd_v__module.
  endif.

* ec 2.12.2003 Sonderzeichenprüfung korrigiert

  if functionname  ca '\$!§%&'''.                           "#EC *
    mac__module_raise RPY_FUNCTIONMODULE_READ sy-subrc invalid_name.
  endif.

  if functionname ca '-'.
    if functionname np '*-TEXTH# ' and
       functionname np '*-TEXTL# '.
      mac__module_raise RPY_FUNCTIONMODULE_READ sy-subrc invalid_name.
    endif.
  endif.
  if functionname ca '.'.
    mac__module_raise RPY_FUNCTIONMODULE_READ sy-subrc invalid_name.
  endif.

  select single * from tfdir into ld_s__tfdir  where funcname = functionname.
  if sy-subrc ne 0.
    mac__module_raise RPY_FUNCTIONMODULE_READ sy-subrc function_not_found.
  endif.

call function 'FUNCTION_INCLUDE_CONCATENATE'
        CHANGING
          program                  = ld_s__tfdir-pname
          complete_area            = function_pool
        EXCEPTIONS
          not_enough_input         = 1
          no_function_pool         = 2
          delimiter_wrong_position = 3
          others                   = 4.

  remote_call = ld_s__tfdir-fmode.
  update_task = ld_s__tfdir-utask.
* Interface ermitteln
  perform fu_import_interface_fupararef in program sapms38l
                            tables import_parameter
                                   changing_parameter
                                   export_parameter
                                   tables_parameter
                                   exception_list
                                   documentation
                            using  functionname
                            changing global_flag.
* Report einlesen
call function 'FUNCTION_INCLUDE_CONCATENATE'
        EXPORTING
          include_number = ld_s__tfdir-include
        IMPORTING
          include        = include
        CHANGING
          program        = ld_s__tfdir-pname
        EXCEPTIONS
          others         = 0.
*ec 19. März 2004
  try.
      read report include into source.
    catch cx_root into oref.
      if oref is bound.
        message e180(fl) with text-001 into error_message.
        raise exception type zcx_vcs__call_module_error
        exporting textid = zcx_vcs__call_module_error=>cx_error_message
                  error_message = error_message
                  module = gd_v__module.
      endif.
  endtry.

* Dokumentation holen
  describe table documentation lines zeilen.
  if zeilen ne 0.
    select * from funct into table ld_t__docu
               where spras     =   sy-langu
               and   funcname  =   functionname.
    loop at documentation
         assigning <ld_s__documentation>.
      zeilen = sy-tabix.
      read table ld_t__docu with key parameter = <ld_s__documentation>-parameter
                                     kind     = <ld_s__documentation>-kind
                            assigning <ld_s__docu>.
      if sy-subrc = 0.
        move <ld_s__docu>-stext to <ld_s__documentation>-stext.
        modify documentation from <ld_s__documentation> index zeilen.
      endif.
    endloop.
    loop at documentation assigning <ld_s__documentation> where stext is initial.
      select * from funct into corresponding fields of ld_s__funct where spras = 'E'
                             and funcname = functionname
*                               and version =  documentation-version
                             and kind     = <ld_s__documentation>-kind
                             and parameter = <ld_s__documentation>-parameter

        .
        move ld_s__funct-stext to <ld_s__documentation>-stext.
        modify documentation from <ld_s__documentation> index sy-tabix.
      endselect.
    endloop.

  endif.
  select single * from  tftit into corresponding fields of ld_s__tftit
         where  spras       = sy-langu
         and    funcname    = functionname.
  if sy-subrc = 0.
    short_text = ld_s__tftit-stext.
  else.
    select single * from  tftit into corresponding fields of ld_s__tftit
           where  spras       = 'E'
           and    funcname    = functionname.
    if sy-subrc = 0.
      short_text = ld_s__tftit-stext.
    else.
      clear short_text.
    endif.
  endif.
endmethod.
