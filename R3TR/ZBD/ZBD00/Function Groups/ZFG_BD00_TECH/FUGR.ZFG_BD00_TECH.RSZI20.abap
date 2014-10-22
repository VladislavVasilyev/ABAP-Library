*----------------------------------------------------------------------*
*   INCLUDE RZI20                                                     *
*----------------------------------------------------------------------*

* attribute structure for time log
TYPES:
     RSZ_S_TIMELOG         LIKE RSTSTP.

* complex structure for a select option
TYPES:
     BEGIN OF RSZ_SX_SELECT,
       SIGN          LIKE RSZRANGE-SIGN,
       OPT           LIKE RSZRANGE-OPT,
       LOW           LIKE RSZRANGE-LOW,
       HIGH          LIKE RSZRANGE-HIGH,
     END OF RSZ_SX_SELECT.

* complex table for select options
TYPES:
     RSZ_TX_SELECT          TYPE RSZ_SX_SELECT   OCCURS 0.

* complex structure for select options for a characteristic
TYPES:
     BEGIN OF RSZ_SX_CHAR_SELECT,
       CHAR              LIKE RSDCHA,
       SORT              LIKE RSZSELECT-SORT,
*      husage            LIKE rszselect-husage,
*      hclass            LIKE rszselect-hclass,
*      hienm             LIKE rszselect-hienm,
*      hnode             LIKE rszselect-hnode,
*      type              LIKE rszselect-type,
       SELECT            TYPE RSZ_TX_SELECT,
     END OF RSZ_SX_CHAR_SELECT.

* complex table for selectoptions for a number of characteristics
TYPES:
     RSZ_TX_CHAR_SELECT    TYPE RSZ_SX_CHAR_SELECT OCCURS 0.
