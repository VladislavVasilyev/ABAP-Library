type-pool zbd0c .

types zbd0c_ty_read_st type c length 1.

constants
  : begin of zbd0c_ty_tab
    , std_non_unique_dk type zbd00_type_appl_table value '001'
    , srd_non_unique_dk type zbd00_type_appl_table value '002'
    , srd_unique_dk     type zbd00_type_appl_table value '003'
    , srd_non_unique    type zbd00_type_appl_table value '004'
    , srd_unique        type zbd00_type_appl_table value '005'
    , has_unique_dk     type zbd00_type_appl_table value '006'
    , has_unique        type zbd00_type_appl_table value '007'
  , end of   zbd0c_ty_tab
  , begin of zbd0c_mode_add_line
    , collect           type zbd00_mode_add_line   value '1'
    , insert            type zbd00_mode_add_line   value '2'
    , append            type zbd00_mode_add_line   value '3'
    , change            type zbd00_mode_add_line   value '4'
  , end of zbd0c_mode_add_line
  , begin of zbd0c_read_mode
    , arfc              type c length 1 value `1`
    , srfc              type c length 1 value `2`
    , full              type c length 1 value `3`
    , pack              type c length 1 value `4`
    , genpack           type c length 1 value `5`
    , genfull           type c length 1 value `6`
    , gendim            type c length 1 value `7`
  , end   of zbd0c_read_mode
  , zbd0c_not_found     type zbd0c_ty_read_st value `X`
  , zbd0c_found         type zbd0c_ty_read_st value `O`
  , zbd0c_end_of_data   type zbd0c_ty_read_st value `X`
  , zbd0c_read_pack     type zbd0c_ty_read_st value `O`
  .
