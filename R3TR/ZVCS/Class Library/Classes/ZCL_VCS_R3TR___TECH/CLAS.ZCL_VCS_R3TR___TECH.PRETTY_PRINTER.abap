method pretty_printer.

  call function 'PRETTY_PRINTER'
    exporting
      inctoo                  = inctoo
    importing
      indentation_maybe_wrong = indentation_maybe_wrong
    tables
      ntext                   = ntext
      otext                   = otext
    exceptions
      enqueue_table_full      = 1
      include_enqueued        = 2
      include_readerror       = 3
      include_writeerror      = 4
      others                  = 5.

  mac__module_raise pretty_printer
  : 1 enqueue_table_full
  , 2 include_enqueued
  , 3 include_readerror
  , 4 include_writeerror
  , 5 others
  .

endmethod.
