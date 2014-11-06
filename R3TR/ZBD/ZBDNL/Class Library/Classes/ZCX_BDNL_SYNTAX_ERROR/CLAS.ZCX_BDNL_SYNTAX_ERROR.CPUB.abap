class ZCX_BDNL_SYNTAX_ERROR definition
  public
  inheriting from ZCX_BDNL_EXCEPTION
  create public .

*"* public components of class ZCX_BDNL_SYNTAX_ERROR
*"* do not include other source files here!!!
public section.

  interfaces IF_T100_MESSAGE .

  constants:
    begin of ZCX_BDNL_SYNTAX_ERROR,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '000',
      attr1 type scx_attrname value 'LINE',
      attr2 type scx_attrname value 'OFFSET',
      attr3 type scx_attrname value 'TOKEN',
      attr4 type scx_attrname value '',
    end of ZCX_BDNL_SYNTAX_ERROR .
  constants:
    begin of ZCX_APPSET_UNKNOW,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '001',
      attr1 type scx_attrname value 'APPSET_ID',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_APPSET_UNKNOW .
  constants:
    begin of ZCX_APPL_UNKNOW,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '002',
      attr1 type scx_attrname value 'APPL_ID',
      attr2 type scx_attrname value 'APPSET_ID',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_APPL_UNKNOW .
  constants:
    begin of ZCX_EXPECTED,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '003',
      attr1 type scx_attrname value 'EXPECTED',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_EXPECTED .
  constants:
    begin of ZCX_DIMENSION,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '004',
      attr1 type scx_attrname value 'DIMENSION',
      attr2 type scx_attrname value 'APPSET_ID',
      attr3 type scx_attrname value 'APPL_ID',
      attr4 type scx_attrname value '',
    end of ZCX_DIMENSION .
  constants:
    begin of ZCX_ATTRIBUTE,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '005',
      attr1 type scx_attrname value 'ATTRIBUTE',
      attr2 type scx_attrname value 'DIMENSION',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_ATTRIBUTE .
  constants:
    begin of ZCX_UNABLE_INTERPRET,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '006',
      attr1 type scx_attrname value 'TOKEN',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_UNABLE_INTERPRET .
  constants:
    begin of ZCX_HAS_DECLARATE,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '007',
      attr1 type scx_attrname value 'TOKEN',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_HAS_DECLARATE .
  constants:
    begin of ZCX_TABLE_NU,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '009',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_TABLE_NU .
  constants:
    begin of ZCX_AFTER_SELECT,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '008',
      attr1 type scx_attrname value 'EXPECTED',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_AFTER_SELECT .
  constants:
    begin of ZCX_AFTER_BEETWEEN,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '010',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_AFTER_BEETWEEN .
  constants:
    begin of ZCX_AFTER_FILTER,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '011',
      attr1 type scx_attrname value 'EXPECTED',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_AFTER_FILTER .
  constants:
    begin of ZCX_AFTER_FILTERS,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '012',
      attr1 type scx_attrname value 'EXPECTED',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_AFTER_FILTERS .
  constants:
    begin of ZCX_FILTER_UNKNOW,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '013',
      attr1 type scx_attrname value 'TOKEN',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_FILTER_UNKNOW .
  constants:
    begin of ZCX_FUNC_WHERE_RETURN0,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '014',
      attr1 type scx_attrname value 'TOKEN',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_FUNC_WHERE_RETURN0 .
  constants:
    begin of ZCX_ONE_MASTER,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '015',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_ONE_MASTER .
  constants:
    begin of ZCX_VAR_DECLARED,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '016',
      attr1 type scx_attrname value 'TOKEN',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_VAR_DECLARED .
  constants:
    begin of ZCX_FORMAT_NAME,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '017',
      attr1 type scx_attrname value 'TOKEN',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_FORMAT_NAME .
  constants:
    begin of ZCX_TABLE_NOT_DEFINED,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '018',
      attr1 type scx_attrname value 'TOKEN',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_TABLE_NOT_DEFINED .
  constants:
    begin of ZCX_NO_COMPONENT_EXISTS,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '019',
      attr1 type scx_attrname value 'TOKEN',
      attr2 type scx_attrname value 'TABLENAME',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_NO_COMPONENT_EXISTS .
  constants:
    begin of ZCX_RECURSIVE_FILTERPOOLS,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '020',
      attr1 type scx_attrname value 'TOKEN',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_RECURSIVE_FILTERPOOLS .
  constants:
    begin of ZCX_WHERE_FUNC_NOT_DEFINED,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '021',
      attr1 type scx_attrname value 'TOKEN',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_WHERE_FUNC_NOT_DEFINED .
  constants:
    begin of ZCX_HASHED_NOT_CHANGE,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '022',
      attr1 type scx_attrname value 'TABLENAME',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_HASHED_NOT_CHANGE .
  constants:
    begin of ZCX_INFOCUBE_UNKNOW,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '023',
      attr1 type scx_attrname value 'APPL_ID',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_INFOCUBE_UNKNOW .
  constants:
    begin of ZCX_MORE_ONE_PARAM,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '024',
      attr1 type scx_attrname value 'TABLENAME',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_MORE_ONE_PARAM .
  constants:
    begin of ZCX_INC_LE_PARENT,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '025',
      attr1 type scx_attrname value 'TOKEN',
      attr2 type scx_attrname value 'TOKEN1',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_INC_LE_PARENT .
  constants:
    begin of ZCX_LE_UNABLE_INTERPRET,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '026',
      attr1 type scx_attrname value 'TOKEN',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_LE_UNABLE_INTERPRET .
  constants:
    begin of ZCX_APPL_OR_DIM_UNKNOW,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '027',
      attr1 type scx_attrname value 'TOKEN',
      attr2 type scx_attrname value 'APPSET_ID',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_APPL_OR_DIM_UNKNOW .
  constants:
    begin of ZCX_AFTER_CONTAINERS,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '028',
      attr1 type scx_attrname value 'EXPECTED',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_AFTER_CONTAINERS .
  constants:
    begin of ZCX_UNCORRECT_PARAM,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '031',
      attr1 type scx_attrname value 'TOKEN',
      attr2 type scx_attrname value 'TOKEN1',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_UNCORRECT_PARAM .
  constants:
    begin of ZCX_STVARV_NOT_VAR,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '032',
      attr1 type scx_attrname value 'TOKEN',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_STVARV_NOT_VAR .
  constants:
    begin of ZCX_NO_CAN_SAVE,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '056',
      attr1 type scx_attrname value 'TABLENAME',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_NO_CAN_SAVE .
  constants:
    begin of ZCX_ERR_IN_FUNCTION,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '057',
      attr1 type scx_attrname value 'TOKEN1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_ERR_IN_FUNCTION .
  constants:
    begin of ZCX_READING_FILE,
      msgid type symsgid value 'ZBDNL',
      msgno type symsgno value '065',
      attr1 type scx_attrname value 'TOKEN',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_READING_FILE .
  class-data LINE type I .
  class-data OFFSET type I .
  class-data TOKEN type STRING .
  class-data APPSET_ID type UJ_APPSET_ID .
  class-data APPL_ID type UJ_APPL_ID .
  class-data EXPECTED type STRING .
  data INDEX type I .
  class-data DIMENSION type UJ_DIM_NAME .
  class-data ATTRIBUTE type UJ_ATTR_NAME .
  type-pools ZBNLT .
  class-data TABLENAME type ZBNLT_V__TABLENAME .
  class-data CURSOR type ref to ZCL_BDNL_CURSOR .
  class-data TOKEN1 type STRING .
  class-data MESSAGE type STRING .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !LINE type I optional
      !OFFSET type I optional
      !TOKEN type STRING optional
      !APPSET_ID type UJ_APPSET_ID optional
      !APPL_ID type UJ_APPL_ID optional
      !EXPECTED type STRING optional
      !INDEX type I optional
      !DIMENSION type UJ_DIM_NAME optional
      !ATTRIBUTE type UJ_ATTR_NAME optional
      !TABLENAME type ZBNLT_V__TABLENAME optional
      !CURSOR type ref to ZCL_BDNL_CURSOR optional
      !TOKEN1 type STRING optional
      !MESSAGE type STRING optional .
