class ZCX_UJD_RUN_PACKAGE definition
  public
  inheriting from CX_STATIC_CHECK
  final
  create public .

*"* public components of class ZCX_UJD_RUN_PACKAGE
*"* do not include other source files here!!!
public section.

  interfaces IF_T100_MESSAGE .

  constants:
    begin of EX_RP_INVALID_APPSET,
      msgid type symsgid value 'ZBPC_RUN_PACK',
      msgno type symsgno value '006',
      attr1 type scx_attrname value 'I_APPSET_ID',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_RP_INVALID_APPSET .
  constants:
    begin of EX_RP_INVALID_APPL,
      msgid type symsgid value 'ZBPC_RUN_PACK',
      msgno type symsgno value '007',
      attr1 type scx_attrname value 'I_APPL_ID',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_RP_INVALID_APPL .
  constants:
    begin of EX_RP_INVALID_APPSET_INPUT,
      msgid type symsgid value 'ZBPC_RUN_PACK',
      msgno type symsgno value '004',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_RP_INVALID_APPSET_INPUT .
  constants:
    begin of EX_RP_INVALID_APPL_INPUT,
      msgid type symsgid value 'ZBPC_RUN_PACK',
      msgno type symsgno value '005',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_RP_INVALID_APPL_INPUT .
  constants:
    begin of EX_RP_INVALID_INPUT,
      msgid type symsgid value 'ZBPC_RUN_PACK',
      msgno type symsgno value '008',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_RP_INVALID_INPUT .
  constants:
    begin of EX_RP_READ_FAIL_SO10,
      msgid type symsgid value 'ZBPC_RUN_PACK',
      msgno type symsgno value '009',
      attr1 type scx_attrname value 'ARG1',
      attr2 type scx_attrname value 'ARG2',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_RP_READ_FAIL_SO10 .
  constants:
    begin of EX_RP_FAIL_GET_PARAM,
      msgid type symsgid value 'ZBPC_RUN_PACK',
      msgno type symsgno value '010',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_RP_FAIL_GET_PARAM .
  constants:
    begin of EX_RP_INVALID_PACKAGE,
      msgid type symsgid value 'ZBPC_RUN_PACK',
      msgno type symsgno value '011',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_RP_INVALID_PACKAGE .
  constants:
    begin of EX_RP_INVALID_PARAM,
      msgid type symsgid value 'ZBPC_RUN_PACK',
      msgno type symsgno value '012',
      attr1 type scx_attrname value 'ARG1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_RP_INVALID_PARAM .
  constants:
    begin of EX_RP_INVALID_SELECTION,
      msgid type symsgid value 'ZBPC_RUN_PACK',
      msgno type symsgno value '015',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_RP_INVALID_SELECTION .
  constants:
    begin of EX_RP_INVALID_PAR_VAL,
      msgid type symsgid value 'ZBPC_RUN_PACK',
      msgno type symsgno value '013',
      attr1 type scx_attrname value 'ARG1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_RP_INVALID_PAR_VAL .
  constants:
    begin of EX_RP_INVALID_TIME_ID,
      msgid type symsgid value 'ZBPC_RUN_PACK',
      msgno type symsgno value '016',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_RP_INVALID_TIME_ID .
  constants:
    begin of EX_RP_INVALID_VALUE,
      msgid type symsgid value 'ZBPC_RUN_PACK',
      msgno type symsgno value '017',
      attr1 type scx_attrname value 'ARG1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_RP_INVALID_VALUE .
  constants:
    begin of EX_RP_INVALID_VAL_STAVARV,
      msgid type symsgid value 'ZBPC_RUN_PACK',
      msgno type symsgno value '018',
      attr1 type scx_attrname value 'ARG1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_RP_INVALID_VAL_STAVARV .
  constants:
    begin of EX_RP_INVALID_GET_RT_INFO,
      msgid type symsgid value 'ZBPC_RUN_PACK',
      msgno type symsgno value '019',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_RP_INVALID_GET_RT_INFO .
  constants:
    begin of EX_RP_INVALID_GET_ST_PACK,
      msgid type symsgid value 'ZBPC_RUN_PACK',
      msgno type symsgno value '020',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_RP_INVALID_GET_ST_PACK .
  constants:
    begin of EX_RP_INVALID_GET_ST_PACK_ERR,
      msgid type symsgid value 'ZBPC_RUN_PACK',
      msgno type symsgno value '021',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_RP_INVALID_GET_ST_PACK_ERR .
  constants:
    begin of EX_RP_INVALID_GET_VAR,
      msgid type symsgid value 'ZBPC_RUN_PACK',
      msgno type symsgno value '022',
      attr1 type scx_attrname value 'ARG1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_RP_INVALID_GET_VAR .
  constants:
    begin of EX_RP_INVALID_OBJ_IF_FOR_APPL,
      msgid type symsgid value 'ZBPC_RUN_PACK',
      msgno type symsgno value '004',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_RP_INVALID_OBJ_IF_FOR_APPL .
  constants:
    begin of EX_RP_INVALID_IN_PACK_PARAM,
      msgid type symsgid value 'ZBPC_RUN_PACK',
      msgno type symsgno value '024',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_RP_INVALID_IN_PACK_PARAM .
  constants:
    begin of EX_RP_INVALID_PROMPT,
      msgid type symsgid value 'ZBPC_RUN_PACK',
      msgno type symsgno value '025',
      attr1 type scx_attrname value 'ARG1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_RP_INVALID_PROMPT .
  constants:
    begin of EX_RP_INVALID_CALL_BADI,
      msgid type symsgid value 'ZBPC_RUN_PACK',
      msgno type symsgno value '027',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_RP_INVALID_CALL_BADI .
  constants:
    begin of EX_RP_INVALID_SCENARIO,
      msgid type symsgid value 'ZBPC_RUN_PACK',
      msgno type symsgno value '026',
      attr1 type scx_attrname value 'ARG1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_RP_INVALID_SCENARIO .
  constants:
    begin of EX_RP_INVALID_TIME,
      msgid type symsgid value 'ZBPC_RUN_PACK',
      msgno type symsgno value '028',
      attr1 type scx_attrname value 'ARG1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EX_RP_INVALID_TIME .
  data I_APPSET_ID type UJ_APPSET_ID .
  data I_APPL_ID type UJ_APPL_ID .
  data ARG1 type STRING .
  data ARG2 type STRING .
  data ARG3 type STRING .
  data ARG4 type STRING .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !I_APPSET_ID type UJ_APPSET_ID optional
      !I_APPL_ID type UJ_APPL_ID optional
      !ARG1 type STRING optional
      !ARG2 type STRING optional
      !ARG3 type STRING optional
      !ARG4 type STRING optional .
