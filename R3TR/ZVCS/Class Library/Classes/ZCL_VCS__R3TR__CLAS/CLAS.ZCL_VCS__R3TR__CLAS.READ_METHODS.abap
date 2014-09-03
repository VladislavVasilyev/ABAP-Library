method READ_METHODS.

  data
  : ld_s__method type line of ty_s__ooclass-methods.

  field-symbols
  : <ld_s__method> type line of seoo_methods_r.

  loop at i_t__methods
       assigning <ld_s__method>
       where alias ne `X`.

* refresh
    free ld_s__method.

* uebergabe
    ld_s__method-method         = <ld_s__method>.
    ld_s__method-cmpkey-clsname = <ld_s__method>-clsname.
    ld_s__method-cmpkey-cmpname = <ld_s__method>-cmpname.

* Source
    if <ld_s__method>-mtdabstrct ne abap_true.

      call method read_method_source
        exporting
          method  = <ld_s__method>
        importing
          source  = ld_s__method-source
        changing
          incname = ld_s__method-incname.
    endif.

* Parameters
    call method read_method_params
      exporting
        method     = <ld_s__method>
      importing
        parameters = ld_s__method-parameters.

* Detailed
    call method read_method_detail
      exporting
        method         = <ld_s__method>
      changing
        method_details = ld_s__method-method_details.

* Exception
    call method read_method_exceptions
      exporting
        method            = ld_s__method
      changing
        method_exceptions = ld_s__method-exceptions.

    append ld_s__method to e_t__methods.

  endloop.
endmethod.
