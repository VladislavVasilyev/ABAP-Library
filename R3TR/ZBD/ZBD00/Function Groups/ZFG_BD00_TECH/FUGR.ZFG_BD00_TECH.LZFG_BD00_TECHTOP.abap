FUNCTION-POOL ZFG_BD00_TECH.                "MESSAGE-ID ..

type-pools: rs, rsd, rsdrc, abap, zbd0c, zbd0t, rsdrs.

types:

begin of gt_s_component.
include type abap_compdescr.
types:
position  type i,
showfl    type rs_bool,
unitfl    type rs_bool,
unitcomp  type i,
unitfixed type rsdri_s_rfcdatav-unit,
iobjnm    type rsiobjnm,
end of gt_s_component,

gt_t_component   type standard table of gt_s_component
                      with default key initial size 10,

* buffer for unwrapping
gt_buffer(8192) type c.
