class ZCX_RB_LOGISTICS definition
  public
  inheriting from CX_STATIC_CHECK
  final
  create public .

*"* public components of class ZCX_RB_LOGISTICS
*"* do not include other source files here!!!
public section.

  interfaces IF_T100_MESSAGE .

  constants:
    begin of EX_PAR_METHOD,
      msgid type symsgid value 'ZMX_RB_LOGISTICS',
      msgno type symsgno value '000',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_PAR_METHOD .
  constants:
    begin of EX_CAL_METHOD,
      msgid type symsgid value 'ZMX_RB_LOGISTICS',
      msgno type symsgno value '001',
      attr1 type scx_attrname value 'ARG1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_CAL_METHOD .
  constants:
    begin of INFO,
      msgid type symsgid value 'ZMX_RB_LOGISTICS',
      msgno type symsgno value '002',
      attr1 type scx_attrname value 'ARG1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of INFO .
  constants:
    begin of EX_RUN_METHOD,
      msgid type symsgid value 'ZMX_RB_LOGISTICS',
      msgno type symsgno value '003',
      attr1 type scx_attrname value 'ARG1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_RUN_METHOD .
  constants:
    begin of EX_RUN_BADI,
      msgid type symsgid value 'ZMX_RB_LOGISTICS',
      msgno type symsgno value '004',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_RUN_BADI .
  constants:
    begin of EX_NORUN_USER,
      msgid type symsgid value 'ZMX_RB_LOGISTICS',
      msgno type symsgno value '005',
      attr1 type scx_attrname value 'ARG1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_NORUN_USER .
  data ARG1 type STRING .
  data ARG2 type STRING .
  data ARG3 type STRING .
  data ARG4 type STRING .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !ARG1 type STRING optional
      !ARG2 type STRING optional
      !ARG3 type STRING optional
      !ARG4 type STRING optional .
