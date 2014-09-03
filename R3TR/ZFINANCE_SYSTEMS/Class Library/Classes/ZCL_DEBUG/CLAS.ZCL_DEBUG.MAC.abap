*"* use this source file for any macro definitions you need
*"* in the implementation part of the class
DEFINE mac__subtract_time.
  data
        : lv_time     type timestampl
        , exit        type tzntstmpl
        , i           type i value 0
        .

  get time stamp field lv_time.
  i = i + 1.
  if i > 1000.
    exit = cl_abap_tstmp=>subtract(
      tstmp1 = lv_time
      tstmp2 = time ).
    i = 0.
  endif.
END-OF-DEFINITION.
