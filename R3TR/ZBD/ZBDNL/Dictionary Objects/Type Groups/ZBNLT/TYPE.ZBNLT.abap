type-pool zbnlt.

type-pools zbd0t.

types zbnlt_t__string type table of string.

types zbnlt_v__tablename type string.

types zbnlt_v__token type string.

types zbnlt_v__tape_program type string.

types: begin of zbnlt_s__variable
       , var  type string
       , val  type string
       , end of zbnlt_s__variable.

types:
  zbnlt_t__variable type hashed table of zbnlt_s__variable with unique key var .

types zbnlt_t__param type standard table of uj_value with non-unique default key.

types: begin of zbnlt_s__match_res.
include type match_result.
types: token        type string
       , esc        type rs_bool
       , f_letter   type rs_bool
       , f_variable type rs_bool
       , f_num      type rs_bool
*       , value      type string
       , refvalue   type ref to string
       , end of zbnlt_s__match_res.

types: zbnlt_t__match_res type sorted table of zbnlt_s__match_res with unique key line offset.

types: begin of zbnlt_s__stack_range
       , name type string
       , range type uj0_t_sel
       , end of zbnlt_s__stack_range.

types zbnlt_t__stack_range type standard table of zbnlt_s__stack_range with non-unique default key.

types: begin of zbnlt_s__stack_container
       , tablename          type zbnlt_v__tablename " имя внутренней таблицы
       , dim_list	          type zbd00_t_ch_key
       , kyf_list           type zbd0t_ty_t_kf
       , alias              type zbd00_t_alias      " alias
       , const              type zbd0t_ty_t_constant
       , command            type string             " команда выбора контейнера
       , appset_id          type uj_appset_id       " ИД. набора приложения
       , appl_id            type uj_appl_id         " ИД. приложения
       , dim_name           type uj_dim_name        " ИД. приложения
       , range              type uj0_t_sel          " range table
       , packagesize        type i
       , mode_table         type string
       , type_table         type string             " тип таблицы
       , tech_type_table    type zbd00_type_appl_table              " тип таблицы
       , cmd_add            type string             " команда вставки данных в таблицу
       , dimension          type zbd0t_ty_t_dim
       , turn               type i
       , appl_obj           type ref to zcl_bd00_application
       , notsupresszero     type rs_bool
       , f_write            type rs_bool
       , destination        type string
       , end of zbnlt_s__stack_container.

types: zbnlt_t__stack_container type standard table of zbnlt_s__stack_container with non-unique default key.

types: begin of zbnlt_s__container
       , tablename          type zbnlt_v__tablename
       , container          type ref to object
       , end of zbnlt_s__container.

types: zbnlt_t__container type standard table of zbnlt_s__container with non-unique default key.


types: begin of zbnlt_s__func_param
       , index type i
       , const  type string
       , data type ref to data
       , tablename type string
       , field  type zbd0t_ty_s_dim
       , end of zbnlt_s__func_param.

types: zbnlt_t__func_param type standard table of zbnlt_s__func_param with non-unique default key.

types: begin of zbnlt_s__cust_link
       , tg type zbd0t_ty_s_dim
       , sc type zbd0t_ty_s_dim
       , tablename type zbnlt_v__tablename
       , const type string
       , clear type rs_bool
       , data type ref to data
       , func_name type string
       , param type zbnlt_t__func_param
       , end of zbnlt_s__cust_link
       .

types: zbnlt_t__cust_link type standard table of zbnlt_s__cust_link with non-unique default key.

types: begin of zbnlt_s__math_var
       , varname   type string
       , tablename type zbnlt_v__tablename
       , dimension type uj_dim_name
       , attribute type uj_attr_name
       , data      type ref to uj_keyfigure
       , func_name type string
       , param     type zbnlt_t__func_param
       , end of zbnlt_s__math_var
       .

types: zbnlt_t__math_var type standard table of zbnlt_s__math_var with non-unique default key.

types: begin of zbnlt_s__var_op
       , tablename            type zbnlt_v__tablename.
include              type zbd0t_ty_s_dim.
types
: const              type string
, data               type ref to data
, func_name          type string
, param              type zbnlt_t__func_param
, end of zbnlt_s__var_op.

types: begin of zbnlt_s__stack_check
       , turn       type i
       , left       type zbnlt_s__var_op
       , log_exp    type c length 2
       , right      type zbnlt_s__var_op
       , token      type string
       , in         type rs_bool
       , end of zbnlt_s__stack_check
       .

types: zbnlt_t__stack_check type standard table of zbnlt_s__stack_check with non-unique default key.

types: begin of zbnlt_s__stack_search
       , check     type zbnlt_t__stack_check
       , tablename type zbnlt_v__tablename
       , link      type zbnlt_t__cust_link
       , default   type string
       , end of zbnlt_s__stack_search.

types: zbnlt_t__stack_search type standard table of zbnlt_s__stack_search with non-unique default key.


types: begin of zbnlt_s__stack_assign
       , tablename type zbnlt_v__tablename " имя внутренней таблицы
       , link      type zbnlt_t__cust_link
       , exp       type string
       , variables type zbnlt_t__math_var
       , f_found   type rs_bool
       , check     type zbnlt_t__stack_check
       , end of zbnlt_s__stack_assign
       .

types: zbnlt_t__stack_assign type standard table of zbnlt_s__stack_assign with non-unique default key.

types zbnlt_s__lgfsource type uj_string.
types zbnlt_t__lgfsource type standard table of zbnlt_s__lgfsource
                              with non-unique default key.

types: begin of zbnlt_s__containers
       , tablename    type zbnlt_v__tablename " имя внутренней таблицы
       , container    type ref to object
       , type_table   type string
       , command      type string             " команда выбора контейнера
       , object       type ref to zcl_bd00_appl_table
       , read_mode    type c length 1
       , script       type i                  " код скрипта
       , turn         type i                  " цикл for
       , log_turn     type i                  " порядок печати в логе
       , init         type rs_bool
       , clear        type rs_bool
       , not_used     type rs_bool
       , end of zbnlt_s__containers.

types: zbnlt_t__containers type standard table of zbnlt_s__containers
                          with non-unique default key.

types:
   begin of zbnlt_s__function
            , func_name type string
            , bindparam  type abap_parmbind_tab
            , end of zbnlt_s__function .
types:
  zbnlt_t__function type standard table of zbnlt_s__function with non-unique default key .

types: begin of zbnlt_s__log_exp
       , left type ref to data
       , log_exp type c length 2
       , right type ref to data
*       , in_right type ref to table
       , result type ref to data
       , end of zbnlt_s__log_exp.

types zbnlt_t__log_exp type standard table of zbnlt_s__log_exp with non-unique default key.

types: begin of zbnlt_s__check_exp
       , data type ref to data
       , operator type string
       , end of zbnlt_s__check_exp.

types: zbnlt_t__check_exp type standard table of zbnlt_s__check_exp with non-unique default key.

types: begin of zbnlt_s__check
       , log_exp type zbnlt_t__log_exp
       , exp     type zbnlt_t__check_exp
       , end of zbnlt_s__check
       .

types zbnlt_t__check type standard table of zbnlt_s__check with non-unique default key.

types: begin of zbnlt_s__search
       , tablename type zbnlt_v__tablename
       , object    type ref to zcl_bd00_appl_table
       , id        type zbd0t_id_rules
       , f_uk      type rs_bool
       , turn      type i
       , function  type zbnlt_t__function
       , class     type ref to zif_bd00_int_table
       , check     type zbnlt_t__check
       , end of zbnlt_s__search.

types: zbnlt_t__search type standard table of zbnlt_s__search with non-unique default key.

types: begin of zbnlt_s__assign
       , id        type zbd0t_id_rules
       , tablename type zbnlt_v__tablename
       , object    type ref to zcl_bd00_appl_table
       , command   type string
       , class     type ref to zif_bd00_int_table
       , function  type zbnlt_t__function
       , check     type zbnlt_t__check
       , end of zbnlt_s__assign.

types: zbnlt_t__assign type standard table of zbnlt_s__assign with non-unique default key.

types: begin of zbnlt_s__assign_function
       , turn             type i
       , object           type ref to object
       , f_static         type rs_bool
       , ld_t__bindparam  type abap_parmbind_tab
       , end of zbnlt_s__assign_function
       .

types zbnlt_t__clear  type hashed table of zbnlt_v__tablename with unique default key.
types zbnlt_t__print  type hashed table of zbnlt_v__tablename with unique default key.
types zbnlt_t__commit type hashed table of zbnlt_v__tablename with unique default key.

types: begin of zbnlt_s__for_rules
       , assign         type zbnlt_t__stack_assign
       , search         type zbnlt_t__stack_search
       , f_continue     type rs_bool
       , end of zbnlt_s__for_rules.

types: zbnlt_t__for_rules type standard table of zbnlt_s__for_rules with non-unique default key.

types: begin of  zbnlt_s__for
       , turn           type i
       , tablename      type zbnlt_v__tablename
       , where          type zbnlt_t__cust_link
       , packagesize    type i
       , rules          type zbnlt_t__for_rules
       , clear          type zbnlt_t__clear
       , commit         type zbnlt_t__commit
       , print          type zbnlt_t__print
       , end of zbnlt_s__for.

types: zbnlt_t__for type standard table of zbnlt_s__for with non-unique default key.

types: begin of zbnlt_s__stack
       , turn           type i
       , range          type zbnlt_t__stack_range
       , containers     type zbnlt_t__container
       , for            type zbnlt_t__for
       , end of zbnlt_s__stack.

types: zbnlt_t__stack type standard table of zbnlt_s__stack with non-unique default key.

types: begin of zbnlt_s__log_for
       , tablename  type zbnlt_v__tablename
       , read       type zbd0t_t__log_read
       , write      type zbd0t_t__log_write
       , end of zbnlt_s__log_for.
