***INCLUDE LSVIMTDT .
DATA:
* Tabelle für die DB-Zeilen, Ultra Long
  BEGIN OF EXTRACT_UL OCCURS 0,
        LINE(4096),
      END OF EXTRACT_UL,
* Tabelle für die DB-Zeilen, Very Long
  BEGIN OF EXTRACT_VL OCCURS 0,
        LINE(512),
      END OF EXTRACT_VL,
* Tabelle für die DB-Zeilen, Long
  BEGIN OF EXTRACT_L OCCURS 0,
        LINE(256),
      END OF EXTRACT_L,
* Tabelle für die DB-Zeilen, Middle
  BEGIN OF EXTRACT_M OCCURS 0,
        LINE(128),
      END OF EXTRACT_M,
* Tabelle für die DB-Zeilen, Short
  BEGIN OF EXTRACT_S OCCURS 0,
        LINE(64),
      END OF EXTRACT_S,
* Tabelle für die DB-Zeilen, Very Short
  BEGIN OF EXTRACT_VS OCCURS 0,
        LINE(48),
      END OF EXTRACT_VS,
* Tabelle für die DB-Zeilen, Ultra Short
  BEGIN OF EXTRACT_US OCCURS 0,
        LINE(32),
      END OF EXTRACT_US.

* Table for all entries loaded from database
DATA:
* Tabelle für die DB-Zeilen, Ultra Long
  BEGIN OF TOTAL_UL OCCURS 0,
        LINE(4096),
      END OF TOTAL_UL,
* Tabelle für die DB-Zeilen, Very Long
  BEGIN OF TOTAL_VL OCCURS 0,
        LINE(512),
      END OF TOTAL_VL,
* Tabelle für die DB-Zeilen, Long
  BEGIN OF TOTAL_L OCCURS 0,
        LINE(256),
      END OF TOTAL_L,
* Tabelle für die DB-Zeilen, Middle
  BEGIN OF TOTAL_M OCCURS 0,
        LINE(128),
      END OF TOTAL_M,
* Tabelle für die DB-Zeilen, Short
  BEGIN OF TOTAL_S OCCURS 0,
        LINE(64),
      END OF TOTAL_S,
* Tabelle für die DB-Zeilen, Very Short
  BEGIN OF TOTAL_VS OCCURS 0,
        LINE(48),
      END OF TOTAL_VS,
* Tabelle für die DB-Zeilen, Ultra Short
  BEGIN OF TOTAL_US OCCURS 0,
        LINE(32),
      END OF TOTAL_US.

* Tabelle mit den modifizierten Elementen

DATA: BEGIN OF MOD_ELEM_TAB OCCURS 100,
        LINES(4096),
      END OF MOD_ELEM_TAB.

*ATA: FORBIDDEN_FUNC_NAME_CHARS(10) VALUE '/\$!§%&''##',   "#EC *
*     FORBIDDEN_AREA_NAME_CHARS(10) VALUE '/\$!§%&''##'.   "#EC *
DATA: FORBIDDEN_FUNC_NAME_CHARS(9) VALUE '\$!§%&''##',   "#EC *
      FORBIDDEN_AREA_NAME_CHARS(9) VALUE '\$!§%&''##'.   "#EC *
