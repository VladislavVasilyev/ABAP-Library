*----------------------------------------------------------------------*
***INCLUDE LSVIMF5C .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  VIM_SET_OC
*&---------------------------------------------------------------------*
*       Called from external to create reference to organisation
*       criterion
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM vim_set_oc USING value(p_obj)
                       TYPE REF TO cl_viewfields_org_crit.

  clear vim_oc_inst.
  check not p_obj is initial.
  vim_oc_inst = p_obj.
ENDFORM.                               " VIM_SET_GLOBAL_OBJECT

