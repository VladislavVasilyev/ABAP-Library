method convert_time.

**********************************************************************
* Преобразует время в параметре START в литеру формата
*   [T. 00:00:00]
* Разницу между END и START в литеру формата
*   [P. 00h 00m 00s]
* результат содержит конкатенацию двух форматов
**********************************************************************
  constants
   : time_zone                type ttzz-tzone value 'RUS03'
   .

  data
   :  time                    type string
   ,  data_start              type string
   ,  time_start              type string
   ,  time_h                  type string
   ,  time_m                  type string
   ,  time_s                  type string
   ,  time_ms                 type string
   ,  minute_on               type rs_bool
   ,  i                       type i
   ,  offset                  type i
   .


**********************************************************************
* Расчет времени старта
**********************************************************************
  convert time stamp i_v__start time zone time_zone  into date data_start.
  concatenate data_start+0(4) `.` data_start+4(2) `.` data_start+6(2) into e_v__data_start.

  convert time stamp i_v__start time zone time_zone  into time time_start.
  concatenate time_start+0(2) `:` time_start+2(2) `:` time_start+4 into e_v__time_start.
*--------------------------------------------------------------------*

**********************************************************************
* Расчет разницы между END и START
**********************************************************************
  check i_v__end > 0 and i_v__start > 0.
  time = cl_abap_tstmp=>subtract( tstmp1 = i_v__end
                                  tstmp2 = i_v__start ).

  time_ms = time.
  find `.` in time_ms match offset offset.
  add 1 to offset.
  time_ms = time_ms+offset(3).

  time_h   = trunc( time / 3600 ).
  time     = abs( time - time_h * 3600 ). " остаток минут

  time_m   = trunc( time / 60 ).
  time     = abs( time - time_m * 60 ).   " остаток секунд

  time_s   = trunc( time ).

  if time_h > 0.
    condense time_h no-gaps.
    concatenate `  ` time_h `h` into time_h.
    i = strlen( time_h ) - 3.
    time_h = time_h+i(3).
    minute_on = abap_true.
  else.
    time_h = `   `.
  endif.

  if time_m > 0 or minute_on = abap_true.
    condense time_m no-gaps.
    concatenate `  ` time_m `m` into time_m.
    i = strlen( time_m ) - 3.
    time_m = time_m+i(3).
  else.
    time_m = `   `.
  endif.

  if time_s > 0.
    condense time_s no-gaps.
    concatenate `  ` time_s `s` into time_s.
    i = strlen( time_s ) - 3.
    time_s = time_s+i(3).
  else.
    time_s = `   `.
  endif.

  e_v__delta_time = `HHh MMm SSs MMMms`.

  replace 'HHh'   in e_v__delta_time with time_h.
  replace 'MMm'   in e_v__delta_time with time_m.
  replace 'SSs'   in e_v__delta_time with time_s.
  replace 'MMM'   in e_v__delta_time with time_ms.

endmethod.
