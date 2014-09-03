*"* use this source file for any macro definitions you need
*"* in the implementation part of the class
DEFINE mac__run.

  field-symbols
  : <ld_s__reeestr> type ty_s__reestr.

  loop at cd_t__reestr
      assigning <ld_s__reeestr>.
    call method <ld_s__reeestr>-object->&1.
  endloop.

END-OF-DEFINITION.
