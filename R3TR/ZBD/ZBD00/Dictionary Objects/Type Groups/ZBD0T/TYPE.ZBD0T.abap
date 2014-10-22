type-pool zbd0t .

types zbd0t_id_rules  type i.

types begin     of zbd0t_ty_s_dim.
types dimension type uj_dim_name.
types attribute type uj_attr_name.
types end       of zbd0t_ty_s_dim.

types: zbd0t_ty_t_dim type standard table of zbd0t_ty_s_dim with non-unique default key.

types begin of zbd0t_ty_s_link_key.
types tg    type zbd0t_ty_s_dim.
types sc    type zbd0t_ty_s_dim.
types end   of zbd0t_ty_s_link_key.

types zbd0t_ty_t_link_key type hashed table of zbd0t_ty_s_link_key with unique key tg.

types begin of zbd0t_ty_s_custom_link.
types tg       type zbd0t_ty_s_dim.
types begin of sc.
include        type zbd0t_ty_s_dim.
types object   type ref to object.
types data     type ref to data.
types const    type uj_value.
types clear    type rs_bool.
types end of sc.
types end   of zbd0t_ty_s_custom_link.

types zbd0t_ty_t_custom_link  type hashed table of   zbd0t_ty_s_custom_link with unique key tg.
types zbd0t_ty_t_custom_link1 type standard table of zbd0t_ty_s_custom_link with non-unique default key.

types begin of zbd0t_ty_s_constant.
include     type zbd0t_ty_s_dim.
types const type uj_value.
types end   of zbd0t_ty_s_constant.

types zbd0t_ty_t_constant type hashed table of zbd0t_ty_s_constant with unique key dimension attribute.

types zbd0t_ty_s_rule_field type zbd0t_ty_s_custom_link.

*types begin    of zbd0t_ty_s_rule_field.
*types tg       type zbd0t_ty_s_dim.
*types begin of sc.
*include        type zbd0t_ty_s_dim.
*types object   type ref to object.
*types data     type ref to data.
*types const    type uj_value.
*types clear    type rs_bool.
*types end of sc.
*types end      of zbd0t_ty_s_rule_field.

types zbd0t_ty_t_rule_field type hashed table of zbd0t_ty_s_rule_field with unique key tg.

types begin of zbd0t_ty_s_math_operand.
types var    type string.
types object type ref to object.
types kyf    type zbd0t_ty_s_dim.
types data   type ref to uj_keyfigure.
types const  type uj_keyfigure.
types end   of zbd0t_ty_s_math_operand.

types zbd0t_ty_t_math_operand type hashed table of  zbd0t_ty_s_math_operand with unique key var .

types begin of  zbd0t_ty_s_rule_math.
types operand type zbd0t_ty_t_math_operand.
types exp type string.
types end of  zbd0t_ty_s_rule_math.

types zbd0t_ty_name_rfc_task type c length 8 .

types zbd0t_ty_method type c length 10.

types zbd0t_ty_t_range_kf type range of uj_keyfigure.
types zbd0t_ty_s_range_kf type line  of zbd0t_ty_t_range_kf.

types zbd0t_ty_t_kf type hashed table of uj_dim_name with unique default key.

types: begin of zbd0t_s__log_read
       , mode       type c length 1
       , nr_pack    type i
       , num_rec    type i " количество записей
       , sup_rec    type i " количество записей после сжатия
       , status     type i
       , time_start type tzntstmpl
       , time_end   type tzntstmpl
       , rfc_task   type string
       , end of zbd0t_s__log_read
       .

types zbd0t_t__log_read type standard table of zbd0t_s__log_read with non-unique default key.

types: begin of zbd0t_s__log_actual
       , nr_pack  type i
       , num_rec  type i
       , end of zbd0t_s__log_actual.

types: zbd0t_t__log_actual type standard table of zbd0t_s__log_actual with non-unique default key.

types: begin of zbd0t_s__log_write
       , mode               type c length 1
       , nr_pack            type i
       , status_records     type ujr_s_status_records
       , cnt_raise_write    type i
       , message            type uj0_t_message
       , time_start         type tzntstmpl
       , time_end           type tzntstmpl
       , rfc_task           type string
       , end of zbd0t_s__log_write
       .

types zbd0t_t__log_write type standard table of zbd0t_s__log_write with non-unique default key.


types: begin of zbd0t_s__log_dimension
       , dimension type uj_dim_name
       , log       type zbd0t_t__log_read
       , end of zbd0t_s__log_dimension.

types zbd0t_t__log_dimension type standard table of zbd0t_s__log_dimension with non-unique default key.
